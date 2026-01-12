// import 'package:ankidroid_for_flutter/ankidroid_for_flutter.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/services/i_anki_export_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'anki_export_service_impl.g.dart';

@riverpod
IAnkiExportService ankiExportService(AnkiExportServiceRef ref) {
  return AnkiExportServiceImpl();
}

class AnkiExportServiceImpl implements IAnkiExportService {
  @override
  Future<String> generateCsv({
    List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
  }) async {
    final buffer = StringBuffer();

    // Vocab
    for (final item in vocabs) {
      final front = _escape(item.word);
      final back = '${_escape(item.reading)}<br>'
          '${_escape(item.meaning)}<br>'
          '<small>${_escape(item.context)}</small>'
          '${item.nuanceNote.isNotEmpty ? '<br>[${_escape(item.nuanceNote)}]' : ''}';
      buffer.writeln('$front\t$back\t[Vocab]');
    }

    // Grammar
    for (final item in grammar) {
      final front = _escape(item.point);
      final back = '${item.level.isNotEmpty ? "[${_escape(item.level)}] " : ""}'
          '${_escape(item.explanation)}<br>'
          'Usage: ${_escape(item.usage)}';
      buffer.writeln('$front\t$back\t[Grammar]');
    }

    // Kanji
    for (final item in kanji) {
      final front = _escape(item.char);
      final back = 'Meanings: ${_escape(item.meanings)}<br>'
          'Readings: ${_escape(item.readings)}'
          '${item.level.isNotEmpty ? "<br>[${_escape(item.level)}]" : ""}';
      buffer.writeln('$front\t$back\t[Kanji]');
    }

    return buffer.toString();
  }

  @override
  Future<void> addToAnkiDroid({
    List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
  }) async {
    // Placeholder implementation
    print(
      'AddToAnkiDroid called with ${vocabs.length} vocabs, ${grammar.length} grammar, ${kanji.length} kanji (Not implemented yet)',
    );
  }

  // Also keep the file saving logic if needed, or user might just want the string.
  // The interface said `generateCsv` returns String.
  // But usually we save it to a file for the user to open.
  // I will add a helper or keep it simple as per interface.
  // The previous implementation saved to file. I might add a `exportToTsvFile` if needed
  // similar to previous logic, but adhering to the interface strictly for now.

  String _escape(String input) {
    // Basic CSV/TSV escaping: replace tabs and newlines to avoid breaking format
    return input.replaceAll('\t', ' ').replaceAll('\n', '<br>');
  }
}
