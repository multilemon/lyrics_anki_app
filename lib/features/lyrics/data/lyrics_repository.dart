import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
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

**PROCESS**:
1.  **VERIFY CONTEXT**:
    -   You will be provided with `CONTEXT_LYRICS`.
    -   **ACTION**: YOU MUST USE THIS TEXT for your analysis.
    -   **CRITICAL**: DO NOT SEARCH for lyrics yourself. DO NOT use your internal knowledge of the song.
    -   If `CONTEXT_LYRICS` is missing or empty, return `{"error": "LYRICS_NOT_FOUND"}` immediately.

2.  **VERIFY LANGUAGE**:
    -   Scan the `CONTEXT_LYRICS`.
    -   If the text is NOT primarily Japanese, return `{"error": "NOT_JAPANESE"}`.

3.  **SEARCH MEDIA (STRICT)**:
    -   **TOOL USAGE**: You MUST use the Google Search tool.
    -   **QUERY**: `"{Song Title}" "{Artist}" official music video youtube`
    -   **VERIFICATION**: 
        -   Look for a result from `youtube.com` or `youtu.be`.
        -   Verify the video title matches the song/artist.
    -   **EXTRACTION**: Extract the 11-char Video ID (e.g. `dQw4w9WgXcQ`).
    -   **ANTI-HALLUCINATION**: 
        -   **NEVER** GUESS or INVENT an ID. 
        -   If strict verification fails or no result is found, return `""` (empty string).
    -   **STORE**: Result in `song.youtube_id`.

4.  **ANALYZE (EXHAUSTIVE MODE)**:
    -   **SCOPE**: You MUST analyze the lyrics **line-by-line** from start to finish.
    -   **STRICT**: DO NOT SUMMARIZE. DO NOT SKIP repeated choruses if context differs.
    -   Perform Linguistic Extraction on the `CONTEXT_LYRICS`.

**EXTRACTION_CONSTRAINTS**:
- **Vocab**:
  - **Requirement**: Extract **ALL** non-trivial words (JLPT N5+) found in the lyrics.
  - **Index 2 (part_of_speech)**:
    -   **Verbs**: `V1` (Godan), `V2` (Ichidan), `V3` (Irregular).
    -   **Suru-Nouns**: MUST use "N, VS".
    -   **Others**: `N`, `Adj-i`, `Adj-na`, `Adv`.
  - **Index 6 (context)**: Verbatim line from `CONTEXT_LYRICS`.
  - **Index 7 (nuance)**: Essential data in **TARGET_LANGUAGE**.
    -   **Silence Rule**: If standard/neutral, **RETURN STRICTLY `""`**.
    -   **Mappings**: "Transitive"->"สกรรมกิริยา", "Intransitive"->"อกรรมกิริยา".

- **Grammar**:
  - **Requirement**: Identify **ALL** functional patterns (N5-N1).
  - Explanations in **TARGET_LANGUAGE**.

- **Kanji**: 
  - **Requirement**: List **ALL** Kanji chars found (level N5-N1).
  -   Atomic (1 Char/entry). 
  -   Levels: `N1`-`N5`. (Strictly).
  -   Meanings: In **TARGET_LANGUAGE**.

**FORMAT (STRICT MINIFIED JSON)**:
- NO markdown. Valid RFC 8259. Use \n for newlines in lyrics.

{
"song":{"title":"","artist":"","youtube_id":"","target_language":""},
"lyrics": "FULL_TEXT_FROM_CONTEXT_LYRICS",
"vocab":[["word","reading","part_of_speech","meaning","jlpt_v","jlpt_k","context","nuance"]],
"grammar":[["point","level","explanation","usage"]],
"kanji":[["char","level","meanings","readings"]]
}
        ''',
      ),
    );

    // Priority: Refine Query First
    // We always attempt to refine the query (e.g. Romaji -> Japanese) to ensure
    // the best chance of finding potential lyrics, even if it adds latency.
    debugPrint(
      'LRCLIB: Refining query for "$title - $artist"...',
    );
    final refinedQuery = await _refineSearchQuery(title, artist);

    final queryToUse = (refinedQuery != null && refinedQuery.isNotEmpty)
        ? refinedQuery
        : '$title $artist';

    debugPrint('LRCLIB: Searching with query: "$queryToUse"');
    final fetchedLyrics = await _fetchLyricsFromLrclib(queryToUse);

    debugPrint(
      'LRCLIB: ${fetchedLyrics != null ? "Found lyrics" : "Not found"}',
    );

    final prompt = StringBuffer()
      ..writeln('Analyze Request:')
      ..writeln('User Input: "$title" by "$artist"');

    if (refinedQuery != null && refinedQuery.isNotEmpty) {
      prompt
        ..writeln('Refined Official Metadata: "$refinedQuery"')
        ..writeln(
            'NOTE: Prefer the Refined Metadata for the "song" JSON output.');
    }

    prompt.writeln('Target Language: $language');

    if (fetchedLyrics != null) {
      prompt
        ..writeln('\nCONTEXT_LYRICS (STRICT SOURCE):')
        ..writeln(fetchedLyrics);
    }

    debugPrint('AI Prompt: $prompt');

    try {
      final content = [Content.text(prompt.toString())];

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

  Future<String?> _fetchLyricsFromLrclib(String query) async {
    try {
      final uri = Uri.https('lrclib.net', '/api/search', {
        'q': query,
      });

      debugPrint('Fetching lyrics from: $uri');
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
        debugPrint('LRCLIB Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Failed to fetch from LRCLIB: $e');
      return null;
    }
  }

  Future<String?> _refineSearchQuery(String title, String artist) async {
    try {
      // Use a lightweight model instance for simple text manipulation
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-pro',
        generationConfig: GenerationConfig(
          candidateCount: 1,
          temperature: 0,
        ),
      );

      final prompt =
          'Role: Query Optimizer. Task: Convert "$title" by "$artist" into '
          'the best official search query (using original language like '
          'Japanese if applicable) for lyrics databases. '
          'Output: ONLY the search string.';

      final response = await model.generateContent([Content.text(prompt)]);
      final rawText = response.text;
      debugPrint('Refinement Raw Response: $rawText');

      if (rawText == null) return null;

      // Clean up the response (remove quotes, markdown)
      var clean = rawText.trim();
      clean = clean.replaceAll('"', '').replaceAll("'", '');
      clean = clean.replaceAll('`', ''); // Remove code block ticks

      return clean.trim();
    } catch (e) {
      debugPrint('Query refinement failed: $e');
      return null;
    }
  }
}
