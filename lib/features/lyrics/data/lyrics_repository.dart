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
        temperature: 0,
        topP: 0.95,
        topK: 1,
      ),
      tools: [
        Tool.googleSearch(),
      ],
      systemInstruction: Content.system(
        // ignore: unnecessary_raw_strings
        r'''
**ROLE**: Senior Japanese Linguistic Data Engineer.
**SOURCE_LANGUAGE**: Japanese.
**PROFICIENCY_STANDARD**: JLPT.
**GOAL**: 100% Verified Lyrics Analysis -> Minified JSON.

**INPUT PROCESSING**:
1.  **Parse**: Identify "Song Title", "Artist", and "Target Language".
2.  **Scope**: If not Japanese, return `{"error": "NOT_JAPANESE"}`.

**PIPELINE (STRICT)**:
1.  **Raw Lyric Retrieval (THE COPY-PASTE RULE)**: 
    -   **Action**: Search `"[Song Title]" "[Artist]" 歌詞 uta-net` or `j-lyric`.
    -   **Extraction**: Locate the lyrics in the search result. **COPY THE TEXT EXACTLY AS IS.**
    -   **PROHIBITED**: 
        -   DO NOT think about the song structure.
        -   DO NOT use your internal memory.
        -   DO NOT merge repeating lines.
        -   DO NOT write "(Repeat)". 
    -   **Ending Verification**: Check the *very last line* of the text you copied. Does it match the actual ending of the song in the search result? If not, keep copying until the end.
    -   **Fail-Safe**: If you cannot find the text, return `{"error": "LYRICS_NOT_FOUND"}`.

2.  **Linguistic Extraction**: Scan the *copied text* (from Step 1) for vocab/grammar.

3.  **Data Grounding**: Verify Levels (N5-N1).

**EXTRACTION_CONSTRAINTS**:
- **Vocab**:
  - **Index 2 (part_of_speech)**:
    -   **Verbs**: `V1` (Godan), `V2` (Ichidan), `V3` (Irregular).
    -   **Suru-Nouns**: MUST use "N, VS".
    -   **Others**: `N`, `Adj-i`, `Adj-na`, `Adv`.
  - **Index 6 (context)**: Verbatim line from Step 1.
  - **Index 7 (nuance)**: Essential data in **TARGET_LANGUAGE**.
    -   **Silence Rule**: If standard/neutral, **RETURN STRICTLY `""`**.
    -   **Mappings**: "Transitive"->"สกรรมกิริยา", "Intransitive"->"อกรรมกิริยา".

- **Grammar**: Functional patterns (N5-N1). Explanations in **TARGET_LANGUAGE**.

- **Kanji**: 
  -   Atomic (1 Char/entry). 
  -   Levels: `N1`-`N5`. (Strictly).
  -   Meanings: In **TARGET_LANGUAGE**.

**FORMAT (STRICT MINIFIED JSON)**:
- NO markdown. Valid RFC 8259. Use \n for newlines in lyrics.

{
"song":{"title":"","artist":"","youtube_id":"","target_language":""},
"lyrics": "FULL_RAW_COPIED_LYRICS_TEXT",
"vocab":[["word","reading","part_of_speech","meaning","jlpt_v","jlpt_k","context","nuance"]],
"grammar":[["point","level","explanation","usage"]],
"kanji":[["char","level","meanings","readings"]]
}
        ''',
      ),
    );

    final prompt =
        'Analyze "$title" by "$artist" for Target Language: $language';
    debugPrint('AI Prompt: $prompt');

    try {
      final content = [Content.text(prompt)];

      final stopwatch = Stopwatch()..start();
      final response = await model.generateContent(content);
      stopwatch.stop();

      debugPrint('⏱️ AI Analysis took: ${stopwatch.elapsedMilliseconds}ms');

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
          : 'No Data',
      analyzedAt: DateTime.now(),
      targetLanguage: language,
    )
      ..vocabs = result.vocabs
      ..grammar = result.grammar
      ..kanji = result.kanji
      ..youtubeId = result.youtubeId
      ..lyrics = result.lyrics;

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
        lyrics: parsed['lyrics']?.toString() ?? '',
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
      partOfSpeech: _safeString(array, 2),
      meaning: _safeString(array, 3),
      jlptV: _safeString(array, 4),
      jlptK: _safeString(array, 5),
      context: _safeString(array, 6),
      nuanceNote: _safeString(array, 7),
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
