import 'package:flutter_test/flutter_test.dart';
import 'package:lyrics_anki_app/features/lyrics/data/services/anki_export_service_impl.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';

void main() {
  late AnkiExportServiceImpl service;

  setUp(() {
    service = AnkiExportServiceImpl();
  });

  group('AnkiExportService', () {
    test('generates CSV with correct headers', () async {
      final result = await service.generateCsv(
        songTitle: 'Test Song',
        artist: 'Test Artist',
      );

      expect(result, startsWith('#deck:HanaUta::Test Song - Test Artist\n'));
      expect(result, contains('#html:true\n'));
      expect(result, contains('#separator:Tab\n'));
    });

    test('replaces colons in song title with spaces for deck name', () async {
      final result = await service.generateCsv(
        songTitle: 'Title: Subtitle',
        artist: 'Artist',
      );

      expect(result, startsWith('#deck:HanaUta::Title  Subtitle - Artist\n'));
    });

    test('formats vocab with HTML and correct columns', () async {
      final vocabs = [
        Vocab(
          word: '猫',
          reading: 'ねこ',
          meaning: 'Cat',
          jlptV: 'N5',
          jlptK: 'N5',
          context: '吾輩は猫である',
          nuanceNote: 'Generic cat',
        ),
      ];

      final result = await service.generateCsv(
        vocabs: vocabs,
        songTitle: 'S',
        artist: 'A',
        userLevel: 'N5', // User meets level, so no furigana in front
      );

      final lines = result.split('\n');
      // Skip headers (3 lines) and empty last line
      final vocabLine = lines.firstWhere((l) => l.contains('[Vocab]'));

      final parts = vocabLine.split('\t');
      expect(parts.length, 3);

      // Front: '<b>Word</b>' (escaped)
      expect(parts[0], '<b>猫</b>');

      // Back: Reading, Meaning, JLPT, Context, Note
      final back = parts[1];
      expect(back, contains('ねこ<br>'));
      expect(back, contains('Cat<br>'));
      expect(back, contains('[N5] '));
      expect(back, contains('<small>吾輩は猫である</small>'));
      expect(back, contains('<br>[Generic cat]'));
    });

    test('shows furigana on front if level is higher than user level',
        () async {
      final vocabs = [
        Vocab(
          word: '難しい',
          reading: 'むずかしい',
          meaning: 'Difficult',
          jlptV: 'N3',
          jlptK: 'N3',
          context: '',
          nuanceNote: '',
        ),
      ];

      final result = await service.generateCsv(
        vocabs: vocabs,
        songTitle: 'S',
        artist: 'A',
        userLevel: 'N5', // N3 > N5, so show reading
      );

      final vocabLine =
          result.split('\n').firstWhere((l) => l.contains('[Vocab]'));
      final parts = vocabLine.split('\t');

      // Front should have reading in small tag next to word
      expect(parts[0], '<b>難しい</b> <small>むずかしい</small>');
    });

    test('formats grammar correctly', () async {
      final grammar = [
        Grammar(
          point: '〜てはいけない',
          level: 'N4',
          explanation: 'Must not do',
          usage: '食べてはいけない',
        ),
      ];

      final result = await service.generateCsv(
        grammar: grammar,
        songTitle: 'S',
        artist: 'A',
      );

      final line =
          result.split('\n').firstWhere((l) => l.contains('[Grammar]'));
      final parts = line.split('\t');

      expect(parts[0], '<b>〜てはいけない</b>');
      expect(parts[1], contains('[N4] Must not do<br>Usage: 食べてはいけない'));
    });

    test('formats kanji correctly', () async {
      final kanji = [
        Kanji(
          char: '猫',
          level: 'N2',
          meanings: 'Cat',
          readings: 'ビョウ, ねこ',
        ),
      ];

      final result = await service.generateCsv(
        kanji: kanji,
        songTitle: 'S',
        artist: 'A',
      );

      final line = result.split('\n').firstWhere((l) => l.contains('[Kanji]'));
      final parts = line.split('\t');

      expect(parts[0], '<b>猫</b>');
      expect(parts[1], contains('Meanings: Cat<br>Readings: ビョウ, ねこ'));
      expect(parts[1], contains('<br>[N2]'));
    });
  });
}
