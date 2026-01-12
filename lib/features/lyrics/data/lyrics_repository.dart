import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
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

  Future<AnalysisResult> analyzeSong(
    String title,
    String artist,
    String language,
  ) async {
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'models/gemini-flash-latest',
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
**ROLE**: You are a Japanese Linguistic Data Engineer. Your task is to perform a deep, exhaustive analysis of song lyrics to create a structured dataset for language learners (JLPT N4-N1).

**TASK MODALITY**:
1. **INPUT**: User provides "Song: [Title] - [Artist]" and "TARGET_LANGUAGE: [Language]".
2. **SEARCH**: Use Google Search Grounding to retrieve the COMPLETE and official Japanese lyrics.
3. **ANALYSIS**: Process the lyrics and translate all descriptive fields into the TARGET_LANGUAGE.

**CORE RULES**:

1. **PROFESSIONAL TRANSLATION**:
- Use formal linguistic terminology (e.g., "Intransitive Verb" for "自動詞").
- Translate all labels, meanings, and notes into the specified TARGET_LANGUAGE.

2. **VOCAB EXTRACTION (EXHAUSTIVE & ATOMIC)**:
- Extract unique Nouns, Verbs (Dictionary Form), Adjectives, and Adverbs.
- **ATOMICITY**: Break down compound phrases (e.g., extract "喉" and "奥" separately).

3. **GRAMMAR SCAN (FILTERED & STANDARDIZED)**:
- **FILTER**: STRICTLY EXCLUDE N5-level grammar.
- **POINT FORMAT**: Use standardized connection labels with **Japanese Hiragana ONLY**. (e.g., **"V.て"** instead of "V-te", **"V.る"** instead of "V-ru", **"V.た"**, **"V.ない"**).
- **STRICT JSON SAFE**: Ensure no trailing slashes `/` or raw quotes `"` break the JSON string.

4. **KANJI PURITY & INTEGRITY (STRICT UNICITY & EXHAUSTIVENESS)**:
- **CHAR FIELD**: EXACTLY ONE character per entry. No okurigana.
- **NO OMISSION (COVERAGE)**: Every unique Kanji character found in the `vocab` and `grammar` sections MUST have a corresponding entry in the `kanji` list. Scan the lyrics thoroughly to ensure 100% coverage.
- **NO DUPLICATION (DEDUPLICATION)**: Strictly ensure each Kanji character exists EXACTLY ONCE in the `kanji` array. Do not repeat the same character even if it appears in multiple words.
- **EXHAUSTIVE DATA**: 
    - Provide **ALL** standard dictionary meanings.
    - Provide **ALL** standard On'yomi (Katakana) and Kun'yomi (Hiragana).
    - **FORMAT**: Use ` | ` to separate groups, and commas within groups (e.g., `"セイ, ショウ | い.きる, う.まれる"`).
- **VERIFICATION**: Perform a final cross-check between the `vocab` list and the `kanji` list before finalizing the JSON to ensure zero duplicates and zero omissions.

5. **JLPT CALIBRATION**:
- **ACCURACY**: Verify levels against official JLPT N5-N1 lists.
- **COMMON WORDS**: Basic greetings (e.g., さよなら) must be marked as **"N5"**. Do not over-level common vocabulary.

6. **OUTPUT STRUCTURE (STRICT VALIDITY)**:
- **JSON INTEGRITY**: Strictly VALID RFC 8259 JSON. Return ONLY a **SINGLE SINGLE-LINE MINIFIED JSON object**.
- **FORBIDDEN**: **STRICTLY NO trailing commas** at the end of arrays or objects.
- **NO CITATIONS**: Do not include any footnotes or citations (e.g., [1], [2]).

  {
  "song": { "title": "", "artist": "" },
  "vocab": [["word", "reading", "meaning", "jlpt_v", "jlpt_k", "context", "nuance_note"]],
  "grammar": [["point", "level", "explanation", "usage"]],
  "kanji": [["char", "level", "meanings", "readings"]]
  }
        ''',
      ),
    );

    final prompt = '''
      Song: $title - $artist
      TARGET_LANGUAGE: $language
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final text = response.text;

      print('Response: $text');

      if (text == null) {
        return AnalysisResult(vocabs: [], grammar: [], kanji: []);
      }

      // Clean up if the model wraps in backticks
      final cleanText = _extractJson(text);

      return await parseAnalysisResult(cleanText);
    } catch (e) {
      print('Analysis error: $e');
      return AnalysisResult(vocabs: [], grammar: [], kanji: []);
    }
  }

  Future<void> saveToHistory(HistoryItem item) async {
    if (_box != null) {
      await _box!.add(item);
    }
  }

  List<HistoryItem> getHistory() {
    if (_box == null) return [];
    return _box!.values.toList().reversed.toList();
  }

  Stream<List<HistoryItem>> watchHistory() async* {
    yield getHistory();
    if (_box != null) {
      await for (final _ in _box!.watch()) {
        yield getHistory();
      }
    }
  }

  Future<void> clearHistory() async {
    if (_box != null) {
      await _box!.clear();
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

      return AnalysisResult(
        vocabs: vocabs,
        grammar: grammar,
        kanji: kanji,
      );
    } catch (e) {
      print('JSON Parse Error: $e');
      return AnalysisResult(vocabs: [], grammar: [], kanji: []);
    }
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
    final startIndex = text.indexOf('{');
    final endIndex = text.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return text.substring(startIndex, endIndex + 1);
    }
    return text.replaceAll('```json', '').replaceAll('```', '').trim();
  }
}
