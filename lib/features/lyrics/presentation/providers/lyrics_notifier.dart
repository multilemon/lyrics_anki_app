import 'dart:async';

import 'package:lyrics_anki_app/features/lyrics/data/lyrics_repository.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/learning_mode.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lyrics_notifier.g.dart';

@Riverpod(keepAlive: true)
class LyricsNotifier extends _$LyricsNotifier {
  @override
  FutureOr<AnalysisResult?> build() {
    return null;
  }

  // Expose the current learning mode for UI to use even during loading
  LearningMode get currentMode => _lastMode ?? LearningMode.japanese;

  String? _lastTitle;
  String? _lastArtist;
  String? _lastLanguage;
  LearningMode? _lastMode;

  Future<void> retry() async {
    if (_lastTitle != null &&
        _lastArtist != null &&
        _lastLanguage != null &&
        _lastMode != null) {
      await analyzeSong(
        _lastTitle!,
        _lastArtist!,
        _lastLanguage!,
        learningMode: _lastMode!,
      );
    }
  }

  Future<AnalysisResult?> analyzeSong(
    String title,
    String artist,
    String language, {
    LearningMode learningMode = LearningMode.japanese,
  }) async {
    _lastTitle = title;
    _lastArtist = artist;
    _lastLanguage = language;
    _lastMode = learningMode;
    state = const AsyncValue.loading();

    final repository = ref.read(lyricsRepositoryProvider);
    AnalysisResult? lastResult;

    try {
      final stream = repository.analyzeSong(
        title,
        artist,
        language,
        learningMode: learningMode,
      );

      await for (final result in stream) {
        state = AsyncValue.data(result);
        lastResult = result;
      }

      // Check final result logic
      if (lastResult != null) {
        if (lastResult.vocabs.isNotEmpty ||
            lastResult.grammar.isNotEmpty ||
            lastResult.kanji.isNotEmpty) {
          await repository.saveAnalysisResult(lastResult, language);
        }
      }
      return lastResult;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Return null or rethrow? Future expects nullable result.
      // Usually we don't rethrow if we set state to error in Riverpod,
      // but the caller might await it.
      return null;
    }
  }

  void loadFromHistory(HistoryItem item) {
    // Best effort to restore mode from history item content
    // If enVocab is present (future), it's reverse mode.
    // For now, if we don't have enVocab in history, we assume Japanese.
    // However, if we added a mode field to history, we should use it.
    // Since we don't have it yet, we default to Japanese or existing logic.

    // We can infer from targetLanguage maybe?
    // If target is "Japanese" -> Reverse Mode?
    // No, existing logic: target Language is what user WANTS to learn?
    // In original app: Target Language was output language.
    // In Reverse Mode: Target is English/Korean.

    // Actually, let's just leave _lastMode as is or default to Japanese if unsure.
    // But to be safe for "Retry", we should probably update it if we can.
    // If we can't be sure, maybe don't touch it, or set to Japanese?
    // Let's set it to Japanese as default for now since history items are mostly Japanese.
    _lastMode = LearningMode.japanese;

    state = AsyncValue.data(
      AnalysisResult(
        vocabs: item.vocabs,
        grammar: item.grammar,
        kanji: item.kanji,
        song: item.songTitle,
        artist: item.artist,
        youtubeId: item.youtubeId,
        lyrics: item.lyrics ?? '',
      ),
    );
  }

  void toggleSelection(int index) {
    // Implement selection logic, probably need a separate state for selection
    // or wrap List<Vocab> in a VM with selection status.
  }
}

class SelectionState {
  const SelectionState({
    this.vocabIndices = const {},
    this.grammarIndices = const {},
    this.kanjiIndices = const {},
  });

  final Set<int> vocabIndices;
  final Set<int> grammarIndices;
  final Set<int> kanjiIndices;

  SelectionState copyWith({
    Set<int>? vocabIndices,
    Set<int>? grammarIndices,
    Set<int>? kanjiIndices,
  }) {
    return SelectionState(
      vocabIndices: vocabIndices ?? this.vocabIndices,
      grammarIndices: grammarIndices ?? this.grammarIndices,
      kanjiIndices: kanjiIndices ?? this.kanjiIndices,
    );
  }
}

enum SelectionType { vocab, grammar, kanji }

@riverpod
class SelectionManager extends _$SelectionManager {
  @override
  SelectionState build() => const SelectionState();

  void toggle(SelectionType type, int index, {bool? force}) {
    switch (type) {
      case SelectionType.vocab:
        state = state.copyWith(
          vocabIndices: _toggleSet(state.vocabIndices, index, force: force),
        );
      case SelectionType.grammar:
        state = state.copyWith(
          grammarIndices: _toggleSet(state.grammarIndices, index, force: force),
        );
      case SelectionType.kanji:
        state = state.copyWith(
          kanjiIndices: _toggleSet(state.kanjiIndices, index, force: force),
        );
    }
  }

  Set<int> _toggleSet(Set<int> current, int index, {bool? force}) {
    if (force ?? false) {
      return {...current, index};
    } else if (force != null) {
      return {...current}..remove(index);
    }

    if (current.contains(index)) {
      return {...current}..remove(index);
    } else {
      return {...current, index};
    }
  }

  void toggleLevel(
    AnalysisResult analysis,
    String level, {
    required bool select,
  }) {
    final vocabIndices = <int>{};
    for (var i = 0; i < analysis.vocabs.length; i++) {
      if (analysis.vocabs[i].jlptV.toUpperCase() == level.toUpperCase()) {
        vocabIndices.add(i);
      }
    }

    final grammarIndices = <int>{};
    for (var i = 0; i < analysis.grammar.length; i++) {
      if (analysis.grammar[i].level.toUpperCase() == level.toUpperCase()) {
        grammarIndices.add(i);
      }
    }

    final kanjiIndices = <int>{};
    for (var i = 0; i < analysis.kanji.length; i++) {
      if (analysis.kanji[i].level.toUpperCase() == level.toUpperCase()) {
        kanjiIndices.add(i);
      }
    }

    if (select) {
      state = state.copyWith(
        vocabIndices: {...state.vocabIndices, ...vocabIndices},
        grammarIndices: {...state.grammarIndices, ...grammarIndices},
        kanjiIndices: {...state.kanjiIndices, ...kanjiIndices},
      );
    } else {
      state = state.copyWith(
        vocabIndices: {...state.vocabIndices}..removeAll(vocabIndices),
        grammarIndices: {...state.grammarIndices}..removeAll(grammarIndices),
        kanjiIndices: {...state.kanjiIndices}..removeAll(kanjiIndices),
      );
    }
  }

  void toggleAll(AnalysisResult analysis, {required bool select}) {
    if (select) {
      state = SelectionState(
        vocabIndices: List.generate(analysis.vocabs.length, (i) => i).toSet(),
        grammarIndices:
            List.generate(analysis.grammar.length, (i) => i).toSet(),
        kanjiIndices: List.generate(analysis.kanji.length, (i) => i).toSet(),
      );
    } else {
      state = const SelectionState();
    }
  }

  void clear() {
    state = const SelectionState();
  }
}
