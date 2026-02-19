import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:lyrics_anki_app/features/lyrics/data/lyrics_repository.dart';
import 'package:lyrics_anki_app/features/lyrics/data/services/song_metadata_service.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:mocktail/mocktail.dart';

class MockBox extends Mock implements Box<HistoryItem> {}

class MockSongMetadataService extends Mock implements SongMetadataService {}

void main() {
  group('LyricsRepository Parser', () {
    late LyricsRepository repository;
    late MockBox mockBox;
    late MockSongMetadataService mockMetadataService;

    setUp(() {
      mockBox = MockBox();
      mockMetadataService = MockSongMetadataService();
      repository = LyricsRepository(mockBox, mockMetadataService);
    });

    test('parseAnalysisResult handles valid minified JSON correctly', () async {
      const jsonString =
          '{"song":{"title":"T","artist":"A"},"vocab":[["Word","Read","Mean",'
          '"N5","N5","Ctx","Note"]],"grammar":[],"kanji":[]}';

      final result = await repository.parseAnalysisResult(jsonString);

      expect(result.vocabs.length, 1);
      expect(result.vocabs[0].word, 'Word');
      expect(result.vocabs[0].reading, 'Read');
      expect(result.vocabs[0].meaning, 'Mean');
      expect(result.vocabs[0].jlptV, 'N5');
      expect(result.vocabs[0].jlptK, 'N5');
      expect(result.vocabs[0].context, 'Ctx');
      expect(result.vocabs[0].nuanceNote, 'Note');
    });

    test('parseAnalysisResult handles empty vocab list', () async {
      const jsonString = '{"song":{"title":"T","artist":"A"},'
          '"vocab":[],"grammar":[],"kanji":[]}';

      final result = await repository.parseAnalysisResult(jsonString);

      expect(result.vocabs, isEmpty);
      expect(result.grammar, isEmpty);
      expect(result.kanji, isEmpty);
    });

    test('parseAnalysisResult handles invalid JSON gracefully', () async {
      const jsonString = 'INVALID_JSON';

      expect(
        () => repository.parseAnalysisResult(jsonString),
        throwsA(isA<FormatException>()),
      );
    });

    test('parseAnalysisResult handles missing vocab key', () async {
      const jsonString = '{"song":{"title":"T","artist":"A"}}';

      final result = await repository.parseAnalysisResult(jsonString);

      expect(result.vocabs, isEmpty);
    });
  });
}
