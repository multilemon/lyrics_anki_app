import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/services/i_anki_export_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'anki_export_service_impl.g.dart';

@riverpod
IAnkiExportService ankiExportService(Ref ref) {
  return AnkiExportServiceImpl();
}

class AnkiExportServiceImpl implements IAnkiExportService {
  @override
  Future<String> generateCsv({
    List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
    String? userLevel,
  }) async {
    final buffer = StringBuffer();
    final userLevelValue = _getLevelValue(userLevel);

    // Vocab
    for (final item in vocabs) {
      final itemLevelValue = _getLevelValue(item.jlptV);
      final showReading = itemLevelValue > userLevelValue;

      String front;
      if (showReading) {
        // Use ruby tag for furigana on front
        front =
            '<ruby>${_escape(item.word)}<rt>${_escape(item.reading)}</rt></ruby>';
      } else {
        front = _escape(item.word);
      }

      final backBuffer = StringBuffer()
        ..write('${_escape(item.reading)}<br>')
        ..write('${_escape(item.meaning)}<br>')
        ..write('<small>${_escape(item.context)}</small>');

      if (item.nuanceNote.isNotEmpty) {
        backBuffer.write('<br>[${_escape(item.nuanceNote)}]');
      }
      buffer.writeln('$front\t$backBuffer\t[Vocab]'); // line 43
    }

    // Grammar (No reading field usually, so standard display)
    for (final item in grammar) {
      final front = _escape(item.point);
      final back = '${item.level.isNotEmpty ? "[${_escape(item.level)}] " : ""}'
          '${_escape(item.explanation)}<br>'
          'Usage: ${_escape(item.usage)}';
      buffer.writeln('$front\t$back\t[Grammar]');
    }

    // Kanji
    for (final item in kanji) {
      // Kanji logic simplified to standard display as per plan
      final front = _escape(item.char);
      final backBuffer = StringBuffer()
        ..write('Meanings: ${_escape(item.meanings)}<br>')
        ..write('Readings: ${_escape(item.readings)}');

      if (item.level.isNotEmpty) {
        backBuffer.write('<br>[${_escape(item.level)}]');
      }
      buffer.writeln('$front\t$backBuffer\t[Kanji]');
    }

    return buffer.toString();
  }

  int _getLevelValue(String? level) {
    if (level == null || level.isEmpty) return 0;
    // N5 = 1 (Easiest), N1 = 5 (Hardest)
    // Scale: N5=1, N4=2, N3=3, N2=4, N1=5
    switch (level.toUpperCase()) {
      case 'N5':
        return 1;
      case 'N4':
        return 2;
      case 'N3':
        return 3;
      case 'N2':
        return 4;
      case 'N1':
        return 5;
      default:
        return 0; // Unknown/None
    }
  }

  @override
  Future<void> addToAnkiDroid({
    List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
  }) async {
    // Placeholder implementation
    debugPrint('[AnkiExport] AddToAnkiDroid not implemented.');
    debugPrint(
      'Stats: ${vocabs.length} V, ${grammar.length} G, ${kanji.length} K',
    );
  }

  String _escape(String input) {
    // Basic CSV/TSV escaping: replace tabs and newlines to avoid breaking format
    return input.replaceAll('\t', ' ').replaceAll('\n', '<br>');
  }
}
