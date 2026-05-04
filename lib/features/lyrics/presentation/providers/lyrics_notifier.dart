import 'dart:async';

import 'package:lyrics_anki_app/features/lyrics/data/lyrics_repository.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lyrics_notifier.g.dart';

@Riverpod(keepAlive: true)
class LyricsNotifier extends _$LyricsNotifier {
  @override
  FutureOr<AnalysisResult?> build() {
    return null;
  }

  String? _lastTitle;
  String? _lastArtist;
  String? _lastLanguage;
  String? _lastCustomLyrics;

  Future<void> retry() async {
    if (_lastTitle != null &&
        _lastArtist != null &&
        _lastLanguage != null) {
      await analyzeSong(
        _lastTitle!,
        _lastArtist!,
        _lastLanguage!,
        customLyrics: _lastCustomLyrics,
      );
    }
  }

  Future<AnalysisResult?> analyzeSong(
    String title,
    String artist,
    String language, {
    String? customLyrics,
  }) async {
    _lastTitle = title;
    _lastArtist = artist;
    _lastLanguage = language;
    _lastCustomLyrics = customLyrics;
    state = const AsyncValue.loading();

    final repository = ref.read(lyricsRepositoryProvider);
    AnalysisResult? lastResult;

    try {
      final stream = repository.analyzeSong(
        title,
        artist,
        language,
        customLyrics: customLyrics,
      );

      await for (final result in stream) {
        state = AsyncValue.data(result);
        lastResult = result;
      }

      // Check final result logic
      if (lastResult != null) {
        final hasData = lastResult.vocabs.isNotEmpty ||
            lastResult.grammar.isNotEmpty ||
            lastResult.kanji.isNotEmpty;

        if (hasData) {
          await repository.saveAnalysisResult(
            lastResult,
            language,
          );
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
    _lastTitle = item.songTitle;
    _lastArtist = item.artist;
    _lastLanguage = item.targetLanguage;
    _lastCustomLyrics = item.lyrics;

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
    // Japanese Levels (JLPT)
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
      final vocabCount = analysis.vocabs.length;
      final grammarCount = analysis.grammar.length;

      state = SelectionState(
        vocabIndices: List.generate(vocabCount, (i) => i).toSet(),
        grammarIndices: List.generate(grammarCount, (i) => i).toSet(),
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
