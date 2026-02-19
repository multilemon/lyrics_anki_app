import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:lyrics_anki_app/core/services/analytics_service.dart';
import 'package:lyrics_anki_app/features/lyrics/data/services/song_metadata_service.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/learning_mode.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
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
    LearningMode learningMode = LearningMode.japanese,
  }) async* {
    final isReverseLearning = learningMode.isReverse;
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
          // Soft match: title + artist must match, language preferred
          if (t != normalizedTitle || a != normalizedArtist) return false;

          if (isReverseLearning) {
            return item.enVocab != null && item.enVocab!.isNotEmpty;
          }

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
          enVocab: cachedItem.enVocab,
          enGrammar: cachedItem.enGrammar,
          overallCefr: cachedItem.overallCefr,
        );
        return;
      }
    } catch (e) {
      // Ignore cache check error
    }

    String systemInstruction;
    switch (learningMode) {
      case LearningMode.english:
        systemInstruction = _systemInstructionReverse;
      case LearningMode.korean:
        systemInstruction = _systemInstructionKorean;
      case LearningMode.japanese:
        systemInstruction = _systemInstruction;
    }

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash', // Use faster model for English/Japanese
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
    var queryToUse = '$title $artist';

    try {
      final metadata = await _metadataService.fetchMetadata(
        title: title,
        artist: artist,
      );

      officialTitle = metadata.title;
      officialArtist = metadata.artist;

      // Use official metadata for lyrics search
      queryToUse = '${metadata.title} ${metadata.artist}';
      refinedYoutubeId = metadata.youtubeId;
    } catch (e) {
      // Ignore metadata fetch error
    }

    final fetchedLyrics = await _fetchLyricsFromLrclib(queryToUse);

    if (fetchedLyrics == null) {
      throw SongNotFoundException(title, artist);
    }

    // YIELD PARTIAL RESULT (Lyrics + YoutubeID if found)
    yield AnalysisResult(
      vocabs: [],
      grammar: [],
      kanji: [],
      song: officialTitle ?? title,
      artist: officialArtist ?? artist,
      lyrics: fetchedLyrics,
      youtubeId: refinedYoutubeId,
      isComplete: false,
    );

    final prompt = StringBuffer()
      ..writeln('Analyze Request:')
      ..writeln('User Input: "$title" by "$artist"')
      ..writeln('Target Language: $language')
      ..writeln('\nCONTEXT_LYRICS (STRICT SOURCE):')
      ..writeln(fetchedLyrics);

    try {
      final content = [Content.text(prompt.toString())];

      final stopwatch = Stopwatch()..start();
      final response = await model.generateContent(content);
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

      final parsedPart = await parseAnalysisResult(cleanText,
          isReverseLearning: isReverseLearning);

      yield AnalysisResult(
        vocabs: parsedPart.vocabs,
        grammar: parsedPart.grammar,
        kanji: parsedPart.kanji,
        song: title,
        artist: artist,
        lyrics: fetchedLyrics,
        youtubeId: refinedYoutubeId,
        enVocab: parsedPart.enVocab,
        enGrammar: parsedPart.enGrammar,
        overallCefr: parsedPart.overallCefr,
      );

      unawaited(
        analyticsService.logAnalysisComplete(
          songTitle: title,
          artist: artist,
          vocabCount: isReverseLearning
              ? (parsedPart.enVocab?.length ?? 0)
              : parsedPart.vocabs.length,
          grammarCount: isReverseLearning
              ? (parsedPart.enGrammar?.length ?? 0)
              : parsedPart.grammar.length,
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
          : result.enVocab != null && result.enVocab!.isNotEmpty
              ? 'Analysis Complete (${result.enVocab!.length} words)'
              : 'No Data',
      analyzedAt: DateTime.now(),
      targetLanguage: language,
    )
      ..vocabs = result.vocabs
      ..grammar = result.grammar
      ..kanji = result.kanji
      ..youtubeId = result.youtubeId
      ..lyrics = result.lyrics
      ..enVocab = result.enVocab
      ..enGrammar = result.enGrammar
      ..overallCefr = result.overallCefr;

    await saveToHistory(item);
  }

  List<HistoryItem> getHistory({int limit = 50}) {
    if (_box == null) {
      // Memory store fallback
      final count = limit < _memoryStore.length ? limit : _memoryStore.length;
      if (count == 0) return [];
      return _memoryStore
          .sublist(_memoryStore.length - count)
          .reversed
          .toList();
    }

    // Optimization: Use getAt(i) which is O(1) for standard Boxes to avoid
    // realizing the entire values list.
    final length = _box!.length;
    final count = limit < length ? limit : length;
    final items = <HistoryItem>[];

    for (var i = length - 1; i >= length - count; i--) {
      final item = _box!.getAt(i);
      if (item != null) {
        items.add(item);
      }
    }
    return items;
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

  Future<AnalysisResult> parseAnalysisResult(String jsonString,
      {bool isReverseLearning = false}) async {
    try {
      final parsed = jsonDecode(jsonString);
      if (parsed is! Map<String, dynamic>) {
        return AnalysisResult(vocabs: [], grammar: [], kanji: []);
      }

      if (isReverseLearning) {
        final enVocab = <EnVocab>[];
        if (parsed.containsKey('vocab')) {
          final list = parsed['vocab'] as List<dynamic>;
          enVocab.addAll(
              list.map((e) => EnVocab.fromJson(e as Map<String, dynamic>)));
        }

        final enGrammar = <EnGrammar>[];
        if (parsed.containsKey('grammar')) {
          final list = parsed['grammar'] as List<dynamic>;
          enGrammar.addAll(
              list.map((e) => EnGrammar.fromJson(e as Map<String, dynamic>)));
        }

        var songTitle = '';
        var artistName = '';
        String? overallCefr;

        if (parsed.containsKey('meta')) {
          final meta = parsed['meta'];
          if (meta is Map<String, dynamic>) {
            songTitle = meta['title']?.toString() ?? '';
            artistName = meta['artist']?.toString() ?? '';
            overallCefr = meta['overall_cefr']?.toString();
          }
        }

        return AnalysisResult(
          vocabs: [],
          grammar: [],
          kanji: [],
          song: songTitle,
          artist: artistName,
          youtubeId: null,
          lyrics: parsed['lyrics']?.toString() ?? '',
          enVocab: enVocab,
          enGrammar: enGrammar,
          overallCefr: overallCefr,
        );
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
        youtubeId: null,
        lyrics: parsed['lyrics']?.toString() ?? '',
      );
    } catch (e) {
      throw const FormatException(
        'Failed to parse AI response: Invalid JSON format.',
      );
    }
  }

  Vocab _mapToVocab(List<dynamic> array) {
    if (array.isEmpty) {
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
      word: _safeString(array, 0),
      reading: _safeString(array, 1),
      partOfSpeech: '',
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
    var source = text.trim();
    final startIndex = source.indexOf('{');
    if (startIndex == -1) return source;

    var braceCount = 0;
    var endIndex = -1;
    var inString = false;
    var escaped = false;

    for (int i = startIndex; i < source.length; i++) {
      final char = source[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (char == '\\') {
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

  Future<String?> _fetchLyricsFromLrclib(String query) async {
    try {
      final uri = Uri.https('lrclib.net', '/api/search', {
        'q': query,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        if (list.isEmpty) return null;

        // Find the first non-instrumental track if possible,
        // or just the first one
        final match = list.firstWhere(
          (e) => (e as Map<String, dynamic>)['instrumental'] == false,
          orElse: () => list.first,
        ) as Map<String, dynamic>;

        final plainLyrics = match['plainLyrics'] as String?;
        final syncedLyrics = match['syncedLyrics'] as String?;

        return (plainLyrics?.isNotEmpty ?? false) ? plainLyrics : syncedLyrics;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static const _systemInstruction = '''
**ROLE**: Japanese Linguistic Data Engineer.
**GOAL**: Analyze lyrics -> Structured JSON.

**WORKFLOW**:

1. **Language Verification**: Check if the song's lyrics are primarily in Japanese.
   - If **NO**: Return strictly `{"error": "NOT_JAPANESE"}`.
   - If **YES**: Proceed to step 2.

2. **Extract**: Atomic Vocab, Functional Grammar, Exhaustive Kanji.
3. **Format**: Strictly Minified JSON.

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

**OUTPUT (STRICT MINIFIED JSON)**:

- NO markdown, NO preamble, NO citations.
- VALID RFC 8259. Double quotes ONLY. No trailing commas.

{
"song":{"title":"","artist":"","target_language":""},
"vocab":[["word","reading","meaning","jlpt_v","jlpt_k","context","nuance_note"]],
"grammar":[["point","level","explanation","usage"]],
"kanji":[["char","level","meanings","readings"]]
}
''';

  static const _systemInstructionReverse = '''
You are a Senior English Linguistic Data Engineer acting as the backend processor for a Japanese ESL application. Your role is to analyze English song lyrics and output strictly formatted linguistic data.

### 1. CORE DIRECTIVES
* **Ground Truth:** Use the provided `lyrics_text` strictly. Do not search the web or alter the lyrics.
* **Target Audience:** Japanese native speakers learning English.
* **Scope (CRITICAL):** Extract **ALL** unique content words (nouns, verbs, adjectives, adverbs) and distinct phrases. Do not filter out simple words unless they are purely functional (like "the", "a").
* **Output Format:** Return ONLY a single, valid, minified RFC 8259 JSON object. Do not include Markdown code blocks (```json), whitespace, or conversational text.

### 2. LINGUISTIC PROCESSING RULES
**A. Vocabulary Extraction**
* **Atomicity:** Tokenize words based on meaning. Treat Phrasal Verbs (e.g., "give up", "look forward to") and Idioms as single atomic units, not separate words.
* **IPA:** Provide the International Phonetic Alphabet transcription (e.g., /həˈləʊ/).
* **POS:** Use standard tags: n., v., adj., adv., prep., conj., phrasal verb, idiom.
* **Meaning:** Provide the contextual definition in natural Japanese (日本語).
* **Nuance & Silence Rule:**
    * Detect slang, poetic license, register (formal/casual), or specific dialect usage (US/UK). Translate this nuance into Japanese.
    * **CRITICAL:** If the word is a standard CEFR A1/A2 term with no special nuance or deviation from standard usage, return an empty string `""`.

**B. Grammar Analysis**
* Identify specific grammatical structures used in the lyrics (e.g., Present Perfect, Third Conditional, Gerunds).
* **CEFR:** Map the structure to levels A1-C2.
* **Explanation:** Explain the grammar point's function in Japanese.

### 3. JSON SCHEMA ENFORCEMENT
You must adhere to this structure exactly:

{
  "meta": {
    "title": "String",
    "artist": "String",
    "overall_cefr": "String"
  },
  "vocab": [
    {
      "term": "String",
      "ipa": "String",
      "pos": "String",
      "meaning_jp": "String",
      "nuance_jp": "String"
    }
  ],
  "grammar": [
    {
      "structure": "String",
      "cefr_level": "String",
      "explanation_jp": "String",
      "excerpt": "String"
    }
  ]
}
''';

  static const _systemInstructionKorean = '''
You are a Senior Korean Linguistic Data Engineer acting as the backend processor for a Japanese ESL application. Your role is to analyze Korean song lyrics and output strictly formatted linguistic data for Japanese speakers.

### 1. CORE DIRECTIVES
* **Ground Truth:** Use the provided `lyrics_text` strictly. Do not search the web or alter the lyrics.
* **Target Audience:** Japanese native speakers learning Korean.
* **Scope (CRITICAL):** Extract **ALL** unique content words (nouns, verbs, adjectives, adverbs) and distinct phrases. Do not filter out simple words.
* **Output Format:** Return ONLY a single, valid, minified RFC 8259 JSON object. Do not include Markdown code blocks (```json), whitespace, or conversational text.

### 2. LINGUISTIC PROCESSING RULES
**A. Vocabulary Extraction**
* **Atomicity:** Tokenize words based on meaning. Treat idioms and common phrases as single units.
* **IPA (Romanization):** Provide the Revised Romanization (RR) for the word (e.g., "sarang").
* **POS:** Use standard tags: n., v., adj., adv., prep., conj., idiom.
* **Meaning:** Provide the contextual definition in natural Japanese (日本語).
* **Nuance:**
    * Detect honorifics (polite/casual), slang, or dialect. Translate this nuance into Japanese.
    * If standard usage, return empty string `""`.

**B. Grammar Analysis**
* Identify specific grammatical structures (e.g., particles, verb endings like -mnida, -yo).
* **CEFR:** Estimate difficult level (A1-C2).
* **Explanation:** Explain the grammar point's function in Japanese.

### 3. JSON SCHEMA ENFORCEMENT
You must adhere to this structure exactly (using same keys as English mode for compatibility):

{
  "meta": {
    "title": "String",
    "artist": "String",
    "overall_cefr": "String"
  },
  "vocab": [
    {
      "term": "String (Hangul)",
      "ipa": "String (Romanization)",
      "pos": "String",
      "meaning_jp": "String",
      "nuance_jp": "String"
    }
  ],
  "grammar": [
    {
      "structure": "String (Hangul/Rule)",
      "cefr_level": "String",
      "explanation_jp": "String",
      "excerpt": "String"
    }
  ]
}
''';
}
