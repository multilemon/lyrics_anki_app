import 'dart:typed_data';

import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';

abstract class IAnkiExportService {
  Future<String> generateCsv({
    required String songTitle, required String artist, List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
    String? userLevel,
  });

  Future<Uint8List> generateApkg({
    required String songTitle, required String artist, List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
    String? userLevel,
  });

  Future<void> addToAnkiDroid({
    List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
  });
}
