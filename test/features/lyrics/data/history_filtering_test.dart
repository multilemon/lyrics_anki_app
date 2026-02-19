import 'package:flutter_test/flutter_test.dart';
import 'package:lyrics_anki_app/features/lyrics/data/lyrics_repository.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/learning_mode.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:mockito/mockito.dart';
import 'package:lyrics_anki_app/features/lyrics/data/services/song_metadata_service.dart';

// Mock dependencies
class MockSongMetadataService extends Mock implements SongMetadataService {}

void main() {
  group('LyricsRepository History Filtering', () {
    late LyricsRepository repository;
    late MockSongMetadataService mockMetadataService;

    setUp(() {
      mockMetadataService = MockSongMetadataService();
      // Initialize with null box to use memory store
      repository = LyricsRepository(null, mockMetadataService);
    });

    test('should filter history by explicit learning mode index', () async {
      // Arrange
      final itemJP = HistoryItem(
        songTitle: 'Sakura',
        artist: 'Naotarou',
        lyricsSnippet: 'Info',
        analyzedAt: DateTime.now(),
        learningModeIndex: LearningMode.japanese.index,
      );
      final itemEN = HistoryItem(
        songTitle: 'Hello',
        artist: 'Adele',
        lyricsSnippet: 'Info',
        analyzedAt: DateTime.now(),
        learningModeIndex: LearningMode.english.index,
      );

      await repository.saveToHistory(itemJP);
      await repository.saveToHistory(itemEN);

      // Act
      final historyJP = repository.getHistory(mode: LearningMode.japanese);
      final historyEN = repository.getHistory(mode: LearningMode.english);

      // Assert
      expect(historyJP.length, 1);
      expect(historyJP.first.songTitle, 'Sakura');

      expect(historyEN.length, 1);
      expect(historyEN.first.songTitle, 'Hello');
    });

    test('should use heuristic for legacy japanese items', () async {
      // Arrange
      final itemLegacyJP = HistoryItem(
        songTitle: 'Lemon',
        artist: 'Kenshi',
        lyricsSnippet: 'Info',
        analyzedAt: DateTime.now(),
        learningModeIndex: null, // Legacy
      )..vocabs = [
          Vocab(
              word: '夢',
              reading: 'yume',
              meaning: 'dream',
              partOfSpeech: 'n',
              jlptV: 'N4',
              jlptK: 'N4',
              context: '',
              nuanceNote: '')
        ];

      final itemLegacyReverse = HistoryItem(
        songTitle: 'Shape of You',
        artist: 'Ed',
        lyricsSnippet: 'Info',
        analyzedAt: DateTime.now(),
        learningModeIndex: null, // Legacy
      )..enVocab = [
          EnVocab(
              term: 'love', ipa: 'lʌv', pos: 'v', meaningJp: '愛', nuanceJp: '')
        ];

      await repository.saveToHistory(itemLegacyJP);
      await repository.saveToHistory(itemLegacyReverse);

      // Act
      final historyJP = repository.getHistory(mode: LearningMode.japanese);
      final historyEN = repository.getHistory(mode: LearningMode.english);

      // Assert
      // Legacy JP item has vocabs, so it should appear in JP mode
      expect(historyJP.any((i) => i.songTitle == 'Lemon'), true);
      // Legacy Reverse item has enVocab and NO vocabs, so likely NOT in JP mode (unless mixed)
      expect(historyJP.any((i) => i.songTitle == 'Shape of You'), false);

      // Legacy Reverse item should appear in EN mode
      expect(historyEN.any((i) => i.songTitle == 'Shape of You'), true);
    });
  });
}
