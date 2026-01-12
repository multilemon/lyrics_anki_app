import 'package:flutter_test/flutter_test.dart';
import 'package:lyrics_anki_app/features/lyrics/data/lyrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:hive_ce/hive.dart';
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';

class MockBox extends Mock implements Box<HistoryItem> {}

void main() {
  group('LyricsRepository Parser', () {
    late LyricsRepository repository;
    late MockBox mockBox;

    setUp(() {
      mockBox = MockBox();
      repository = LyricsRepository(mockBox);
    });

    test('parseAnalysisResult handles valid minified JSON correctly', () async {
      const jsonString =
          '{"song":{"title":"T","artist":"A"},"vocab":[["Word","Read","Mean","N5","N5","Ctx","Note"]],"grammar":[],"kanji":[]}';

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
      final jsonString =
          '{"song":{"title":"T","artist":"A"},"vocab":[],"grammar":[],"kanji":[]}';

      final result = await repository.parseAnalysisResult(jsonString);

      expect(result.vocabs, isEmpty);
      expect(result.grammar, isEmpty);
      expect(result.kanji, isEmpty);
    });

    test('parseAnalysisResult handles invalid JSON gracefully', () async {
      final jsonString = 'INVALID_JSON';

      final result = await repository.parseAnalysisResult(jsonString);

      expect(result.vocabs, isEmpty);
    });

    test('parseAnalysisResult handles missing vocab key', () async {
      final jsonString = '{"song":{"title":"T","artist":"A"}}';

      final result = await repository.parseAnalysisResult(jsonString);

      expect(result.vocabs, isEmpty);
    });
  });
}
