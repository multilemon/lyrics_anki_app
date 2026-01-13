import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/features/anki/data/services/anki_database_service.dart';
import 'package:lyrics_anki_app/features/anki/data/services/anki_package_service.dart';
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
    required String songTitle,
    required String artist,
  }) async {
    final buffer = StringBuffer();

    // Add Headers
    buffer
        .writeln('#deck:HanaUta::${songTitle.replaceAll(':', ' ')} - $artist');
    buffer.writeln('#html:true');
    buffer.writeln('#separator:Tab');

    final userLevelValue = _getLevelValue(userLevel);

    // Vocab
    for (final item in vocabs) {
      final itemLevelValue = _getLevelValue(item.jlptV);
      final showReading = itemLevelValue > userLevelValue;

      String front;
      // Front: Bold word + Reading (if hard)
      // Format: <b>Word</b> [Reading]

      final escapedWord = '<b>${_escape(item.word)}</b>';

      if (showReading) {
        front = '$escapedWord <small>${_escape(item.reading)}</small>';
      } else {
        front = escapedWord;
      }

      final backBuffer = StringBuffer()
        ..write('${_escape(item.reading)}<br>')
        ..write('${_escape(item.meaning)}<br>')
        ..write('${item.jlptV.isNotEmpty ? "[${_escape(item.jlptV)}] " : ""}')
        ..write('<small>${_escape(item.context)}</small>');

      if (item.nuanceNote.isNotEmpty) {
        backBuffer.write('<br>[${_escape(item.nuanceNote)}]');
      }
      buffer.writeln('$front\t$backBuffer\t[Vocab]');
    }

    // Grammar
    for (final item in grammar) {
      final front = '<b>${_escape(item.point)}</b>';
      final back = '${item.level.isNotEmpty ? "[${_escape(item.level)}] " : ""}'
          '${_escape(item.explanation)}<br>'
          'Usage: ${_escape(item.usage)}';
      buffer.writeln('$front\t$back\t[Grammar]');
    }

    // Kanji
    for (final item in kanji) {
      final front = '<b>${_escape(item.char)}</b>';
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
        return 0;
    }
  }

  @override
  Future<Uint8List> generateApkg({
    List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
    required String songTitle,
    required String artist,
    String? userLevel,
  }) async {
    final databaseService = AnkiDatabaseService();
    final deckName =
        'HanaUta::${userLevel != null ? "[$userLevel] " : ""}${songTitle.replaceAll(':', ' ')} - $artist';

    final dbBytes = await databaseService.createDatabase(
      vocabs: vocabs,
      grammar: grammar,
      kanji: kanji,
      deckName: deckName,
    );

    final packageService = AnkiPackageService();
    return packageService.createApkg(databaseBytes: dbBytes);
  }

  @override
  Future<void> addToAnkiDroid({
    List<Vocab> vocabs = const [],
    List<Grammar> grammar = const [],
    List<Kanji> kanji = const [],
  }) async {
    // Placeholder implementation
    debugPrint('[AnkiExport] AddToAnkiDroid not implemented.');
  }

  String _escape(String input) {
    // Basic CSV/TSV escaping
    // Replace tabs with spaces to avoid breaking columns
    // Replace newlines with <br> for HTML display
    return input.replaceAll('\t', ' ').replaceAll('\n', '<br>');
  }
}
