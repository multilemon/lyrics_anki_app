import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_ce/hive.dart';
import 'package:lyrics_anki_app/core/config/env.dart';
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
    final model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: Env.geminiApiKey,
      generationConfig: GenerationConfig(
        candidateCount: 1,
        temperature: 0,
        topP: 1,
        topK: 40,
      ),
      systemInstruction: Content.system(
        '''
**ROLE**: Senior Japanese Linguistic Data Engineer.
**TARGET_LANGUAGE**: [Specify Target Language, e.g., Thai, English].
**GOAL**: Absolute Exhaustive Analysis of Lyrics -> Structured JSON for Language Learners.

**WORKFLOW**:
1. **Validation**: Check if primarily Japanese and if the song exists. If fail, return strictly `{"error": "NOT_JAPANESE"}` or `{"error": "NOT_FOUND"}`.
2. **Search (Grounding)**: 
   - Fetch Official Lyrics. Scan every single line (Line-by-Line Parsing).
   - Fetch Official MV 11-char YouTube ID.
3. **Verify (Data-Backed)**: Use Google Search to find official JLPT levels for every unit identified. 
   - **jlpt_v**: Must reflect Official Usage Frequency. [DO NOT estimate by kanji].
   - **jlpt_k**: Must reflect Official Kanji Grade.
4. **Filter**: If verified official level is **N5**, DISCARD immediately. Only N4-N1 allowed for vocab and grammar.

**EXTRACTION_CONSTRAINTS**:
- **Vocab (Target >50 entries)**: Break all compounds (Atomic). 
  - **Index 5 (context)**: MUST be the exact, verbatim line from the lyrics. NO explanations.
  - **Index 6 (nuance)**: Provide essential linguistic data in **TARGET_LANGUAGE**. 
    - **Identify**: Grammatical Properties (Transitivity, Register, Honorifics) and Linguistic Nuance (Connotation, Intensity, Emotional undertones).
    - **Technical Terms**: Use formal terminology of **TARGET_LANGUAGE**.
    - **Neutrality**: NO plot summaries. NO gender-bias based on sentence endings. Return strictly `""` for common nouns/neutral verbs with no specific linguistic property.
- **Grammar (N4-N1 ONLY)**: High Recall. All explanations and usage rules in **TARGET_LANGUAGE**.
- **Kanji (STRICT ATOMIC)**:
  - **Single Char ONLY**: 1 Char/entry. NO compounds (e.g., If "自分", create two entries: "自" and "分").
  - **Coverage**: Every unique N4-N1 Kanji used in `vocab` and `grammar` arrays.
  - **Readings**: Format: "On | Kun" (Katakana | Hiragana).
  - **Meanings**: ALL standard definitions in **TARGET_LANGUAGE**.
  - **Level Standard**: MUST be strictly based on official JLPT levels.
- **Integrity**: Every character used in `vocab` and `grammar` MUST exist in the `kanji` list. No duplicates.

**FORMAT (STRICT MINIFIED JSON)**:
- NO markdown, NO preamble, NO extra text.
- VALID RFC 8259. Double quotes ONLY. No standalone hyphens `-`.

{
"song":{"title":"","artist":"","youtube_id":""},
"vocab":[["word","reading","meaning","jlpt_v","jlpt_k","context","nuance"]],
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
      if (e is GenerativeAIException) {
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
      ..youtubeId = result.youtubeId;

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
