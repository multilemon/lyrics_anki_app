import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:lyrics_anki_app/core/services/analytics_service.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lyrics_repository.g.dart';

@Riverpod(keepAlive: true)
LyricsRepository lyricsRepository(Ref ref) {
  final box = ref.watch(historyBoxProvider);
  return LyricsRepository(box);
}

class LyricsRepository {
  LyricsRepository(this._box);
  final Box<HistoryItem>? _box;

  // Fallback for when Hive/IndexedDB is blocked (e.g. Mobile Private Mode)
  final List<HistoryItem> _memoryStore = [];
  final _memoryStreamController = StreamController<void>.broadcast();

  bool get isReady => _box != null;

  Future<AnalysisResult> analyzeSong(
    String title,
    String artist,
    String language,
  ) async {
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-pro',
      generationConfig: GenerationConfig(
        candidateCount: 1,
        temperature: 0.1,
        topP: 0.95,
        topK: 40,
      ),
      tools: [
        Tool.googleSearch(),
      ],
      systemInstruction: Content.system(
        '''
**ROLE**: Japanese Linguistic Data Engineer.
**GOAL**: Analyze lyrics -> Structured JSON.

**WORKFLOW**:

1. **Language Verification**: Check if the song's lyrics are primarily in Japanese.
   - If **NO**: Return strictly `{"error": "NOT_JAPANESE"}`.
   - If **YES**: Proceed to step 2.

1b. **Existence Verification**: Check if the specific song by the artist largely exists.
   - If **NO (Not Found/Ambiguous)**: Return strictly `{"error": "NOT_FOUND"}`.

2. **Search**: 
   - Use Google Search to find the **Official Music Video** on YouTube. Extract the exact **11-character Video ID**.
   - Use Google Search for official lyrics.
3. **Extract**: Atomic Vocab, Functional Grammar, Exhaustive Kanji.
4. **Format**: Strictly Minified JSON.

**CONSTRAINTS**:

- **Translate**: Use formal linguistics (e.g., "Intransitive Verb") in TARGET_LANGUAGE.
- **Vocab**: Atomic N/V/Adj/Adv. Break compounds (e.g., 喉 + 奥).
- **Grammar**: NO N5. Format: "V.て", "V.る", "V.た". No trailing slashes.
- **Kanji (EXHAUSTIVE)**:
  - 1 Char/entry. No okurigana.
  - Meanings: ALL standard dictionary definitions.
  - Readings: ALL On'yomi (Katakana) | ALL Kun'yomi (Hiragana). Format: "コウ | のど".
  - NO transliterations (e.g., No Thai/English phonetics).
- **JLPT**: Standard calibration. Basic greetings = N5.
- **Data Integrity**: Every Kanji in vocab/grammar MUST be in the kanji list. NO DUPLICATES.

**CRITICAL JSON FORMATTING**:
- **ESCAPE QUOTES**: All double quotes within values MUST be escaped (e.g., `"`).
- **NO COMMENTS**: Do not include comments or markdown.
- **Youtube ID**: Must be exactly 11 characters (e.g., `dQw4w9WgXcQ`), NOT a full URL.

**OUTPUT (STRICT MINIFIED JSON)**:

- NO markdown, NO preamble, NO citations.
- VALID RFC 8259. Double quotes ONLY. No trailing commas.

{
"song":{"title":"","artist":"","youtube_id":"11_CHAR_ID_ONLY"},
"vocab":[["word","reading","meaning","jlpt_v","jlpt_k","context","nuance_note"]],
"grammar":[["point","level","explanation","usage"]],
"kanji":[["char","level","meanings","readings"]]
}
        ''',
      ),
    );

    final prompt = '''
      Song: $title - $artist
      
      Step 1: Search for the "Official Music Video" for this song on YouTube. (Ignore TARGET_LANGUAGE for this search).
      Step 2: Analyze the lyrics as requested.
      
      TARGET_LANGUAGE for Analysis: $language
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final text = response.text;

      debugPrint('Response: $text');

      if (text == null) {
        return AnalysisResult(vocabs: [], grammar: [], kanji: []);
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

      return await parseAnalysisResult(cleanText);
    } catch (e) {
      debugPrint('Analysis error: $e');

      if (e is Exception) rethrow;
      if (e is String) throw Exception(e);

      throw Exception('Failed to analyze song. Please try again.');
    }
  }

  Future<void> saveToHistory(HistoryItem item) async {
    if (_box != null) {
      await _box!.add(item);
    } else {
      _memoryStore.add(item);
      _memoryStreamController.add(null);
    }
  }

  Future<void> saveAnalysisResult(
    AnalysisResult result,
    String language,
  ) async {
    final item = HistoryItem(
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
      ..youtubeId = result.youtubeId;

    await saveToHistory(item);
  }

  List<HistoryItem> getHistory() {
    if (_box == null) return _memoryStore.reversed.toList();
    return _box!.values.toList().reversed.toList();
  }

  Stream<List<HistoryItem>> watchHistory() async* {
    yield getHistory();
    if (_box != null) {
      await for (final _ in _box!.watch()) {
        yield getHistory();
      }
    } else {
      await for (final _ in _memoryStreamController.stream) {
        yield getHistory();
      }
    }
  }

  Future<void> clearHistory() async {
    if (_box != null) {
      await _box!.clear();
    } else {
      _memoryStore.clear();
      _memoryStreamController.add(null);
    }
  }

  Future<AnalysisResult> parseAnalysisResult(String jsonString) async {
    try {
      final parsed = jsonDecode(jsonString);
      if (parsed is! Map<String, dynamic>) {
        return AnalysisResult(vocabs: [], grammar: [], kanji: []);
      }

      final vocabs = <Vocab>[];
      if (parsed.containsKey('vocab')) {
        final list = parsed['vocab'] as List<dynamic>;
        vocabs.addAll(list.map((e) => _mapToVocab(e as List<dynamic>)));
      }

      final grammar = <Grammar>[];
      if (parsed.containsKey('grammar')) {
        final list = parsed['grammar'] as List<dynamic>;
        grammar.addAll(list.map((e) => _mapToGrammar(e as List<dynamic>)));
      }

      final kanji = <Kanji>[];
      if (parsed.containsKey('kanji')) {
        final list = parsed['kanji'] as List<dynamic>;
        kanji.addAll(list.map((e) => _mapToKanji(e as List<dynamic>)));
      }

      var songTitle = '';
      var artistName = '';
      String? youtubeId;
      if (parsed.containsKey('song')) {
        final songData = parsed['song'];
        if (songData is Map<String, dynamic>) {
          songTitle = songData['title']?.toString() ?? '';
          artistName = songData['artist']?.toString() ?? '';
          final rawId = songData['youtube_id']?.toString();
          youtubeId = _extractYoutubeId(rawId);

          if (youtubeId == null || youtubeId.isEmpty) {
            debugPrint(
              '⚠️ Video NOT FOUND (or invalid) for: $songTitle - $artistName',
            );
          } else {
            debugPrint('✅ Video FOUND: $youtubeId from "$rawId"');
          }
        }
      }

      return AnalysisResult(
        vocabs: vocabs,
        grammar: grammar,
        kanji: kanji,
        song: songTitle,
        artist: artistName,
        youtubeId: youtubeId,
      );
    } catch (e) {
      debugPrint('JSON Parse Error: $e');
      throw const FormatException(
        'Failed to parse AI response: Invalid JSON format.',
      );
    }
  }

  String? _extractYoutubeId(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final text = raw.trim();

    // 1. If it's a full URL, try to parse 'v=' or 'youtu.be/'
    final uri = Uri.tryParse(text);
    if (uri != null && uri.host.contains('youtube.com')) {
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v'];
      }
    }
    if (uri != null && uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
    }

    // 2. Strict Regex for ID: ^[a-zA-Z0-9_-]{11}$
    final idRegex = RegExp(r'^[a-zA-Z0-9_-]{11}$');
    if (idRegex.hasMatch(text)) {
      return text;
    }

    // 3. Fallback: Search for any 11-char sequence that looks like an ID
    // This handles cases like "ID: dQw4w9WgXcQ" or "dQw4w9WgXcQ."
    final fallbackRegex = RegExp('[a-zA-Z0-9_-]{11}');
    final match = fallbackRegex.firstMatch(text);
    if (match != null) {
      return match.group(0);
    }

    return null;
  }

  Vocab _mapToVocab(List<dynamic> array) {
    if (array.isEmpty) {
      return Vocab(
        word: '',
        reading: '',
        meaning: '',
        jlptV: '',
        jlptK: '',
        context: '',
        nuanceNote: '',
      );
    }

    return Vocab(
      word: _safeString(array, 0),
      reading: _safeString(array, 1),
      meaning: _safeString(array, 2),
      jlptV: _safeString(array, 3),
      jlptK: _safeString(array, 4),
      context: _safeString(array, 5),
      nuanceNote: _safeString(array, 6),
    );
  }

  Grammar _mapToGrammar(List<dynamic> array) {
    if (array.isEmpty) {
      return Grammar(
        point: '',
        level: '',
        explanation: '',
        usage: '',
      );
    }

    return Grammar(
      point: _safeString(array, 0),
      level: _safeString(array, 1),
      explanation: _safeString(array, 2),
      usage: _safeString(array, 3),
    );
  }

  Kanji _mapToKanji(List<dynamic> array) {
    if (array.isEmpty) {
      return Kanji(
        char: '',
        level: '',
        meanings: '',
        readings: '',
      );
    }

    return Kanji(
      char: _safeString(array, 0),
      level: _safeString(array, 1),
      meanings: _safeString(array, 2),
      readings: _safeString(array, 3),
    );
  }

  // Helper to safely get string from index, handling potential nulls or bounds
  String _safeString(List<dynamic> list, int index) {
    if (index < 0 || index >= list.length) return '';
    final val = list[index];
    return val?.toString() ?? '';
  }

  String _extractJson(String text) {
    var clean = text.trim();
    // Remove markdown code blocks
    clean = clean.replaceAll('```json', '').replaceAll('```', '').trim();

    // Find the first '{' and last '}'
    final startIndex = clean.indexOf('{');
    final endIndex = clean.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      clean = clean.substring(startIndex, endIndex + 1);
    }

    return clean;
  }
}
