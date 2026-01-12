import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';

abstract class IAnkiExportService {
  Future<String> generateCsv({
    List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
  });
  Future<void> addToAnkiDroid({
    List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
  });
}
