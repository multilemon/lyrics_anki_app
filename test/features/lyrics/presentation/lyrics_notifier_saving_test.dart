import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyrics_anki_app/features/lyrics/data/lyrics_repository.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/learning_mode.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate MockLyricsRepository
@GenerateNiceMocks([MockSpec<LyricsRepository>()])
import 'lyrics_notifier_saving_test.mocks.dart';

void main() {
  group('LyricsNotifier Saving', () {
    late MockLyricsRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockLyricsRepository();
      container = ProviderContainer(
        overrides: [
          lyricsRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should save analysis result for English song', () async {
      // Arrange
      final result = AnalysisResult(
        vocabs: [],
        grammar: [],
        kanji: [],
        enVocab: [
          EnVocab(
            term: 'Apple',
            ipa: '',
            pos: 'n',
            meaningJp: '',
            nuanceJp: '',
          ),
        ],
        enGrammar: [],
        song: 'Title',
        artist: 'Artist',
        lyrics: 'Lyrics',
      );

      when(
        mockRepository.analyzeSong(
          any,
          any,
          any,
          learningMode: anyNamed('learningMode'),
        ),
      ).thenAnswer((_) => Stream.value(result));

      when(
        mockRepository.saveAnalysisResult(
          any,
          any,
          learningMode: anyNamed('learningMode'),
        ),
      ).thenAnswer((_) async {});

      final notifier = container.read(lyricsNotifierProvider.notifier);

      // Act
      await notifier.analyzeSong(
        'Titile',
        'Artist',
        'English',
        learningMode: LearningMode.english,
      );

      // Assert
      verify(
        mockRepository.saveAnalysisResult(
          result,
          'English',
          learningMode: LearningMode.english,
        ),
      ).called(1);
    });

    test('should save analysis result for Korean song', () async {
      // Arrange
      // Korean usually populates EnVocab/EnGrammar structures currently in our legacy setup
      // or at least passes the check if EnVocab is present.
      final result = AnalysisResult(
        vocabs: [],
        grammar: [],
        kanji: [],
        enVocab: [
          EnVocab(
            term: 'Kimchi',
            ipa: '',
            pos: 'n',
            meaningJp: '',
            nuanceJp: '',
          ),
        ],
        enGrammar: [],
        song: 'Title',
        artist: 'Artist',
        lyrics: 'Lyrics',
      );

      when(
        mockRepository.analyzeSong(
          any,
          any,
          any,
          learningMode: anyNamed('learningMode'),
        ),
      ).thenAnswer((_) => Stream.value(result));

      when(
        mockRepository.saveAnalysisResult(
          any,
          any,
          learningMode: anyNamed('learningMode'),
        ),
      ).thenAnswer((_) async {});

      final notifier = container.read(lyricsNotifierProvider.notifier);

      // Act
      await notifier.analyzeSong(
        'Title',
        'Artist',
        'Korean',
        learningMode: LearningMode.korean,
      );

      // Assert
      verify(
        mockRepository.saveAnalysisResult(
          result,
          'Korean',
          learningMode: LearningMode.korean,
        ),
      ).called(1);
    });
  });
}
