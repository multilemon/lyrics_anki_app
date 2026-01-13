import 'dart:typed_data';

import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';

abstract class IAnkiExportService {
  Future<String> generateCsv({
    List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
    String? userLevel,
    required String songTitle,
    required String artist,
  });

  Future<Uint8List> generateApkg({
    List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
    required String songTitle,
    required String artist,
    String? userLevel,
  });

  Future<void> addToAnkiDroid({
    List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
  });
}
