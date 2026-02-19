import 'package:flutter_test/flutter_test.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('SelectionManager CEFR Filtering', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should select grammar items by CEFR level', () {
      // Arrange
      final analysis = AnalysisResult(
        vocabs: [],
        grammar: [],
        kanji: [],
        enGrammar: [
          EnGrammar(
            structure: 'Point A',
            cefrLevel: 'A1',
            explanationJp: 'Exp A',
            excerpt: '',
          ),
          EnGrammar(
            structure: 'Point B',
            cefrLevel: 'B2',
            explanationJp: 'Exp B',
            excerpt: '',
          ),
          EnGrammar(
            structure: 'Point C',
            cefrLevel: 'A1',
            explanationJp: 'Exp C',
            excerpt: '',
          ),
        ],
      );

      final notifier = container.read(selectionManagerProvider.notifier);

      // Act - Select A1
      notifier.toggleLevel(analysis, 'A1', select: true);
      var state = container.read(selectionManagerProvider);

      // Assert
      expect(state.grammarIndices.contains(0), true,
          reason: 'Point A (A1) should be selected');
      expect(state.grammarIndices.contains(2), true,
          reason: 'Point C (A1) should be selected');
      expect(state.grammarIndices.contains(1), false,
          reason: 'Point B (B2) should NOT be selected');

      // Act - Deselect A1
      notifier.toggleLevel(analysis, 'A1', select: false);
      state = container.read(selectionManagerProvider);

      // Assert
      expect(state.grammarIndices.isEmpty, true);
    });

    test('toggleAll should include EN vocab and grammar indices', () {
      // Arrange
      final analysis = AnalysisResult(
        vocabs: [],
        grammar: [],
        kanji: [],
        enVocab: [
          EnVocab(
              term: 'Apple', ipa: '', pos: 'n', meaningJp: '', nuanceJp: ''),
          EnVocab(
              term: 'Banana', ipa: '', pos: 'n', meaningJp: '', nuanceJp: ''),
        ],
        enGrammar: [
          EnGrammar(
              structure: 'Rule 1',
              cefrLevel: 'A1',
              explanationJp: '',
              excerpt: ''),
        ],
      );

      final notifier = container.read(selectionManagerProvider.notifier);

      // Act
      notifier.toggleAll(analysis, select: true);
      final state = container.read(selectionManagerProvider);

      // Assert
      expect(state.vocabIndices.length, 2);
      expect(state.vocabIndices.contains(0), true);
      expect(state.vocabIndices.contains(1), true);

      expect(state.grammarIndices.length, 1);
      expect(state.grammarIndices.contains(0), true);
    });
  });
}
