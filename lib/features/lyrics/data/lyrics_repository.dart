import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:lyrics_anki_app/core/services/analytics_service.dart';
import 'package:lyrics_anki_app/features/lyrics/data/services/song_metadata_service.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:retry/retry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lyrics_repository.g.dart';

@Riverpod(keepAlive: true)
LyricsRepository lyricsRepository(Ref ref) {
  final box = ref.watch(historyBoxProvider);
  final metadataService = ref.watch(songMetadataServiceProvider);
  return LyricsRepository(box, metadataService);
}

class LyricsRepository {
  LyricsRepository(this._box, this._metadataService);
  final Box<HistoryItem>? _box;
  final SongMetadataService _metadataService;

  // Fallback for when Hive/IndexedDB is blocked (e.g. Mobile Private Mode)
  final List<HistoryItem> _memoryStore = [];
  final _memoryStreamController = StreamController<void>.broadcast();

  bool get isReady => _box != null;

  Stream<AnalysisResult> analyzeSong(
    String title,
    String artist,
    String language, {
    String? customLyrics,
  }) async* {
    // 1. Check Local Cache First
    final normalizedTitle = title.trim().toLowerCase();
    final normalizedArtist = artist.trim().toLowerCase();
    final source = _box?.values ?? _memoryStore;

    try {
      final cachedItem = source.cast<HistoryItem?>().firstWhere(
        (item) {
          if (item == null) return false;
          final t = item.songTitle.trim().toLowerCase();
          final a = item.artist.trim().toLowerCase();
          final l = item.targetLanguage;
          if (t != normalizedTitle || a != normalizedArtist) return false;

          return l == language && item.vocabs.isNotEmpty;
        },
        orElse: () => null,
      );

      if (cachedItem != null) {
        yield AnalysisResult(
          vocabs: cachedItem.vocabs,
          grammar: cachedItem.grammar,
          kanji: cachedItem.kanji,
          song: cachedItem.songTitle,
          artist: cachedItem.artist,
          lyrics: cachedItem.lyrics ?? '',
          youtubeId: cachedItem.youtubeId,
          verses: cachedItem.verses,
        );
        return;
      }
    } on Object catch (_) {
      // Ignore cache check error
    }

    final systemInstruction = _buildSystemInstruction(language);

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash', // Use faster model for English/Japanese
      generationConfig: GenerationConfig(
        candidateCount: 1,
        temperature: 0,
        topP: 0.95,
        topK: 1,
        responseMimeType: 'application/json',
      ),
      systemInstruction: Content.system(systemInstruction),
    );

    // Priority: Fetch Official Metadata & Video ID from iTunes/YouTube
    String? refinedYoutubeId;
    String? officialTitle;
    String? officialArtist;
    try {
      final metadata = await _metadataService.fetchMetadata(
        title: title,
        artist: artist,
      );
      debugPrint('[LRCLIB] metadata: $metadata');

      officialTitle = metadata.title;
      officialArtist = metadata.artist;
      refinedYoutubeId = metadata.youtubeId;
    } on Exception catch (_) {
      // Ignore metadata fetch error
    }

    // Use custom lyrics if provided, otherwise fetch from LRCLIB
    final String lyricsToAnalyze;
    if (customLyrics != null && customLyrics.trim().isNotEmpty) {
      lyricsToAnalyze = customLyrics.trim();
    } else {
      final fetchedLyrics = await _fetchLyricsFromLrclib(
        trackName: officialTitle ?? title,
        artistName: officialArtist ?? artist,
      );

      if (fetchedLyrics == null) {
        throw SongNotFoundException(title, artist);
      }
      lyricsToAnalyze = fetchedLyrics;
    }

    // YIELD PARTIAL RESULT (Lyrics + YoutubeID if found)
    yield AnalysisResult(
      vocabs: [],
      grammar: [],
      kanji: [],
      song: officialTitle ?? title,
      artist: officialArtist ?? artist,
      lyrics: lyricsToAnalyze,
      youtubeId: refinedYoutubeId,
      isComplete: false,
    );

    final prompt = StringBuffer()
      ..writeln('"$title" by "$artist" [$language]')
      ..writeln('LYRICS:')
      ..writeln(lyricsToAnalyze);

    try {
      final content = [Content.text(prompt.toString())];

      final stopwatch = Stopwatch()..start();
      final response = await retry(
        () => model.generateContent(content),
        retryIf: (e) => e is FirebaseAIException || e is http.ClientException,
        maxAttempts: 3,
      );
      stopwatch.stop();

      final text = response.text;

      if (text == null) {
        // Return empty result, or we could throw
        yield AnalysisResult(vocabs: [], grammar: [], kanji: []);
        return;
      }

      // Log successful analysis attempt
      unawaited(
        analyticsService.logSongAnalysis(
          songTitle: title,
          artist: artist,
          language: language,
        ),
      );

      // Clean up if the model wraps in backticks
      final cleanText = _extractJson(text);

      // Check for language error *before* parsing full structure
      if (cleanText.contains('"error"') && cleanText.contains('NOT_JAPANESE')) {
        throw Exception(
          'This song does not appear to be primarily in Japanese.',
        );
      }

      if (cleanText.contains('"error"') && cleanText.contains('NOT_FOUND')) {
        throw SongNotFoundException(title, artist);
      }

      final parsedPart = await parseAnalysisResult(
        cleanText,
      );

      yield AnalysisResult(
        vocabs: parsedPart.vocabs,
        grammar: parsedPart.grammar,
        kanji: parsedPart.kanji,
        song: officialTitle ?? title,
        artist: officialArtist ?? artist,
        lyrics: lyricsToAnalyze,
        youtubeId: refinedYoutubeId,
        verses: parsedPart.verses,
      );

      unawaited(
        analyticsService.logAnalysisComplete(
          songTitle: title,
          artist: artist,
          vocabCount: parsedPart.vocabs.length,
          grammarCount: parsedPart.grammar.length,
          kanjiCount: parsedPart.kanji.length,
          durationMs: stopwatch.elapsedMilliseconds,
        ),
      );
    } catch (e) {
      // Check for 503 Overloaded
      if (e is FirebaseAIException) {
        final message = e.message.toLowerCase();
        if (message.contains('503') || message.contains('overloaded')) {
          throw ServerOverloadedException();
        }
        if (message.contains('429') ||
            message.contains('quota') ||
            message.contains('exhausted')) {
          throw QuotaExceededException();
        }
      }

      if (e is Exception) rethrow;
      if (e is String) throw Exception(e);

      throw Exception('Failed to analyze song. Please try again.');
    }
  }

  Future<void> saveToHistory(HistoryItem item) async {
    final box = _box;
    if (box != null) {
      await box.add(item);
    } else {
      _memoryStore.add(item);
      _memoryStreamController.add(null);
    }
  }

  Future<void> saveAnalysisResult(
    AnalysisResult result,
    String language,
  ) async {
    final item =
        HistoryItem(
            songTitle: result.song,
            artist: result.artist,
            lyricsSnippet: result.vocabs.isNotEmpty
                ? 'Analysis Complete (${result.vocabs.length} words)'
                : 'No Data',
            analyzedAt: DateTime.now(),
            targetLanguage: language,
          )
          ..vocabs = result.vocabs
          ..grammar = result.grammar
          ..kanji = result.kanji
          ..youtubeId = result.youtubeId
          ..lyrics = result.lyrics
          ..verses = result.verses;

    await saveToHistory(item);
  }

  List<HistoryItem> getHistory({
    int limit = 50,
  }) {
    try {
      final box = _box;
      if (box == null) {
        // Memory store fallback
        final source = _memoryStore;
        final count = limit < source.length ? limit : source.length;
        if (count == 0) return [];
        return source.sublist(source.length - count).reversed.toList();
      }

      // Optimization: Use getAt(i) which is O(1) for standard Boxes
      final length = box.length;
      final items = <HistoryItem>[];

      // Iterate backwards to get most recent first
      for (var i = length - 1; i >= 0; i--) {
        // Break early if we have enough items
        if (items.length >= limit) break;

        try {
          final item = box.getAt(i);
          if (item != null) {
            items.add(item);
          }
        } on Object catch (e) {
          // If a specific item is corrupted, log and skip it
          debugPrint('Failed to deserialize history item at index $i: $e');
          try {
            // Delete corrupt item from disk to clean up the DB
            box.deleteAt(i);
          } on Object catch (_) {}
        }
      }
      return items;
    } on Object catch (e) {
      debugPrint('Failed to load history: $e');
      return [];
    }
  }

  Stream<List<HistoryItem>> watchHistory() async* {
    yield getHistory();
    final box = _box;
    if (box != null) {
      await for (final _ in box.watch()) {
        yield getHistory();
      }
    } else {
      await for (final _ in _memoryStreamController.stream) {
        yield getHistory();
      }
    }
  }

  Future<void> clearHistory() async {
    final box = _box;
    if (box != null) {
      await box.clear();
    } else {
      _memoryStore.clear();
      _memoryStreamController.add(null);
    }
  }

  Future<AnalysisResult> parseAnalysisResult(
    String jsonString,
  ) async {
    // compute() is web-safe (runs sync on web, isolate on native)
    return compute(_parseAnalysisResultIsolate, jsonString);
  }

  static AnalysisResult _parseAnalysisResultIsolate(String jsonString) {
    try {
      final parsed = jsonDecode(jsonString);
      if (parsed is! Map<String, dynamic>) {
        return AnalysisResult(vocabs: [], grammar: [], kanji: []);
      }

      final vocabs = <Vocab>[];
      if (parsed.containsKey('vocab')) {
        final list = parsed['vocab'] as List<dynamic>;
        vocabs.addAll(list.map((e) => _mapToVocab(e)));
      }

      final grammar = <Grammar>[];
      if (parsed.containsKey('grammar')) {
        final list = parsed['grammar'] as List<dynamic>;
        grammar.addAll(list.map((e) => _mapToGrammar(e)));
      }

      final kanji = <Kanji>[];
      if (parsed.containsKey('kanji')) {
        final list = parsed['kanji'] as List<dynamic>;
        kanji.addAll(list.map((e) => _mapToKanji(e)));
      }

      final verses = <LyricVerse>[];
      if (parsed.containsKey('verses')) {
        final list = parsed['verses'] as List<dynamic>;
        verses.addAll(list.map((e) => _mapToLyricVerse(e)));
      }

      var songTitle = '';
      var artistName = '';

      if (parsed.containsKey('song')) {
        final songData = parsed['song'];
        if (songData is Map<String, dynamic>) {
          songTitle = songData['title']?.toString() ?? '';
          artistName = songData['artist']?.toString() ?? '';
        }
      }

      return AnalysisResult(
        vocabs: vocabs,
        grammar: grammar,
        kanji: kanji,
        song: songTitle,
        artist: artistName,
        lyrics: parsed['lyrics']?.toString() ?? '',
        verses: verses,
      );
    } on Exception catch (_) {
      throw const FormatException(
        'Failed to parse AI response: Invalid JSON format.',
      );
    }
  }

  static Vocab _mapToVocab(dynamic data) {
    if (data is List<dynamic>) {
      if (data.isEmpty) {
        return Vocab(
          word: '',
          reading: '',
          partOfSpeech: '',
          meaning: '',
          jlptV: '',
          jlptK: '',
          context: '',
          nuanceNote: '',
        );
      }
      return Vocab(
        word: _safeString(data, 0),
        reading: _safeString(data, 1),
        partOfSpeech: '',
        meaning: _safeString(data, 2),
        jlptV: _safeString(data, 3),
        jlptK: _safeString(data, 4),
        context: _safeString(data, 5),
        nuanceNote: _safeString(data, 6),
      );
    } else if (data is Map<String, dynamic>) {
      return Vocab(
        word: data['word']?.toString() ?? '',
        reading: data['reading']?.toString() ?? '',
        partOfSpeech: data['partOfSpeech']?.toString() ?? '',
        meaning: data['meaning']?.toString() ?? '',
        jlptV: data['jlpt_v']?.toString() ?? '',
        jlptK: data['jlpt_k']?.toString() ?? '',
        context: data['context']?.toString() ?? '',
        nuanceNote: data['nuance_note']?.toString() ?? '',
      );
    }
    return Vocab(
      word: '',
      reading: '',
      partOfSpeech: '',
      meaning: '',
      jlptV: '',
      jlptK: '',
      context: '',
      nuanceNote: '',
    );
  }

  static Grammar _mapToGrammar(dynamic data) {
    if (data is List<dynamic>) {
      if (data.isEmpty) {
        return Grammar(point: '', level: '', explanation: '', usage: '');
      }
      return Grammar(
        point: _safeString(data, 0),
        level: _safeString(data, 1),
        explanation: _safeString(data, 2),
        usage: _safeString(data, 3),
      );
    } else if (data is Map<String, dynamic>) {
      return Grammar(
        point: data['point']?.toString() ?? '',
        level: data['level']?.toString() ?? '',
        explanation: data['explanation']?.toString() ?? '',
        usage: data['usage']?.toString() ?? '',
      );
    }
    return Grammar(point: '', level: '', explanation: '', usage: '');
  }

  static Kanji _mapToKanji(dynamic data) {
    if (data is List<dynamic>) {
      if (data.isEmpty) {
        return Kanji(char: '', level: '', meanings: '', readings: '');
      }
      return Kanji(
        char: _safeString(data, 0),
        level: _safeString(data, 1),
        meanings: _safeString(data, 2),
        readings: _safeString(data, 3),
      );
    } else if (data is Map<String, dynamic>) {
      return Kanji(
        char: data['char']?.toString() ?? '',
        level: data['level']?.toString() ?? '',
        meanings: data['meanings']?.toString() ?? '',
        readings: data['readings']?.toString() ?? '',
      );
    }
    return Kanji(char: '', level: '', meanings: '', readings: '');
  }

  // Helper to safely get string from index, handling potential nulls or bounds
  static String _safeString(List<dynamic> list, int index) {
    if (index < 0 || index >= list.length) return '';
    final val = list[index];
    return val?.toString() ?? '';
  }

  static LyricVerse _mapToLyricVerse(dynamic data) {
    if (data is List<dynamic>) {
      return LyricVerse(
        original: _safeString(data, 0),
        translation: _safeString(data, 1),
        nuance: _safeString(data, 2),
      );
    } else if (data is Map<String, dynamic>) {
      return LyricVerse(
        original: data['original']?.toString() ?? '',
        translation: data['translation']?.toString() ?? '',
        nuance: data['nuance']?.toString() ?? '',
      );
    }
    return LyricVerse(original: '', translation: '', nuance: '');
  }

  String _extractJson(String text) {
    final source = text.trim();
    final startIndex = source.indexOf('{');
    if (startIndex == -1) return source;

    var braceCount = 0;
    var endIndex = -1;
    var inString = false;
    var escaped = false;

    for (var i = startIndex; i < source.length; i++) {
      final char = source[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (char == r'\') {
        escaped = true;
        continue;
      }

      if (char == '"') {
        inString = !inString;
        continue;
      }

      if (inString) continue;

      if (char == '{') {
        braceCount++;
      } else if (char == '}') {
        braceCount--;
        if (braceCount == 0) {
          endIndex = i;
          break;
        }
      }
    }

    if (endIndex != -1) {
      return source.substring(startIndex, endIndex + 1);
    }

    // Fallback if structure is oddly broken
    final lastIndex = source.lastIndexOf('}');
    if (lastIndex > startIndex) {
      return source.substring(startIndex, lastIndex + 1);
    }

    return source;
  }

  Future<String?> _fetchLyricsFromLrclib({
    required String trackName,
    required String artistName,
  }) async {
    debugPrint('[LRCLIB] trackName: $trackName');
    debugPrint('[LRCLIB] artistName: $artistName');

    // 1. Try precise search with track_name + artist_name
    final precise = await _searchLrclib({
      'track_name': trackName,
      'artist_name': artistName,
    });
    if (precise != null) return precise;

    // 2. Fallback: generic q search
    return _searchLrclib({'q': '$trackName $artistName'});
  }

  Future<String?> _searchLrclib(
    Map<String, String> queryParams,
  ) async {
    try {
      final uri = Uri.https(
        'lrclib.net',
        '/api/search',
        queryParams,
      );

      debugPrint('[LRCLIB] Request: $uri');

      final response = await retry(
        () => http.get(uri),
        retryIf: (e) => e is http.ClientException || e is TimeoutException,
        maxAttempts: 3,
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        if (list.isEmpty) return null;

        // Find the first non-instrumental track if possible,
        // or just the first one
        final match =
            list.firstWhere(
                  (e) => (e as Map<String, dynamic>)['instrumental'] == false,
                  orElse: () => list.first,
                )
                as Map<String, dynamic>;

        final plainLyrics = match['plainLyrics'] as String?;
        final syncedLyrics = match['syncedLyrics'] as String?;
        return (syncedLyrics?.isNotEmpty ?? false) ? syncedLyrics : plainLyrics;
      } else {
        debugPrint(
          '[LRCLIB] Error Response: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } on Exception catch (e) {
      debugPrint('[LRCLIB] Request Failed: $e');
      return null;
    }
  }

  static String _buildSystemInstruction(String targetLanguage) =>
      '''
JP Linguistic Data Engineer. Analyze lyrics→JSON.

1. Verify lyrics are primarily Japanese. If NO: {"error":"NOT_JAPANESE"}
1b. Verify song exists. If NO: {"error":"NOT_FOUND"}
2. Extract atomic vocab, functional grammar, exhaustive kanji.
3. Split lyrics into logical verses and translate each verse.

Rules:
- All meanings/explanations/context/nuance in $targetLanguage, formal linguistics (e.g. "Intransitive Verb").
- Vocab: Atomic N/V/Adj/Adv. Break compounds (喉+奥). jlpt_v=vocab JLPT(N5-N1), jlpt_k=kanji JLPT(N5-N1). Nuance: explain register (e.g. slang, feminine).
- Grammar: NO N5. Format: "V.て","V.る","V.た". level=JLPT(N4-N1).
- Kanji: 1 char/entry, no okurigana. level=JLPT(N5-N1). Meanings: all defs in $targetLanguage. Readings: On(カタカナ)|Kun(ひらがな) e.g. "コウ|のど". No transliterations.
- JLPT kanji calibration (STRICT): N5=日,本,人,大. N4=広,写,病,死. N3=悲,届,相,湖. N2=涙,瞳,濡,溢. N1=輝,叶,儚,慟. Ref community-standard JLPT lists. Songs often contain N2/N1 kanji—do NOT default lower.
- Every kanji in vocab/grammar must appear in kanji list. No duplicates.
- Verses: Split lyrics into logical verses (intro/verse/chorus/bridge/outro). For each verse provide: original Japanese text (preserve line breaks), natural translation in $targetLanguage, and a nuance note explaining metaphors, wordplay, cultural references, double meanings, poetic devices, or register shifts. Keep verse boundaries at natural musical phrase breaks.
- CRITICAL JSON FORMAT: You MUST output an Array-of-Arrays for vocab, grammar, kanji, and verses (e.g. `[["val1", "val2"]]`). DO NOT output Array-of-Objects (`[{"key":"val"}]`). This is strictly required to minimize tokens.

Schema:
{"song":{"title":"","artist":"","target_language":""},"vocab":[["word","reading","meaning","jlpt_v","jlpt_k","context","nuance_note"]],"grammar":[["point","level","explanation","usage"]],"kanji":[["char","level","meanings","readings"]],"verses":[["original_jp_verse","translation","nuance_explanation"]]}
Example vocab entry: ["喉奥","のどおく","deep in the throat","Noun","N1","N2","Poetic compound of 喉+奥"]
Example verse entry: ["誰もいない部屋で\n一人きりの夜","In an empty room\na night all alone","Sets a melancholic tone of solitude (孤独). '一人きり' emphasizes 'completely alone' — stronger than plain '一人'."]
''';
}
