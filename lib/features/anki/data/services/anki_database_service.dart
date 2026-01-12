import 'dart:convert';
import 'dart:typed_data';

import 'package:lyrics_anki_app/core/database/database_helper.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:sqlite3/common.dart';

class AnkiDatabaseService {
  CommonDatabase? _db;

  Future<void> _init() async {
    if (_db != null) return;

    final sqlite3 = await getSqlite3();
    _db = sqlite3.openInMemory();
    _initSchema();
  }

  void _initSchema() {
    _db!.execute('''
      CREATE TABLE col (
          id integer primary key,
          crt integer not null,
          mod integer not null,
          scm integer not null,
          ver integer not null,
          dty integer not null,
          usn integer not null,
          ls integer not null,
          conf text not null,
          models text not null,
          decks text not null,
          dconf text not null,
          tags text not null
      );
      CREATE TABLE notes (
          id integer primary key,
          guid text not null,
          mid integer not null,
          mod integer not null,
          usn integer not null,
          tags text not null,
          flds text not null,
          sfld integer not null,
          csum integer not null,
          flags integer not null,
          data text not null
      );
      CREATE TABLE cards (
          id integer primary key,
          nid integer not null,
          did integer not null,
          ord integer not null,
          mod integer not null,
          usn integer not null,
          type integer not null,
          queue integer not null,
          due integer not null,
          ivl integer not null,
          factor integer not null,
          reps integer not null,
          lapses integer not null,
          left integer not null,
          odue integer not null,
          odid integer not null,
          flags integer not null,
          data text not null
      );
      CREATE TABLE revlog (
          id integer primary key,
          cid integer not null,
          usn integer not null,
          ease integer not null,
          ivl integer not null,
          lastIvl integer not null,
          factor integer not null,
          time integer not null,
          type integer not null
      );
      CREATE TABLE graves (
          usn integer not null,
          oid integer not null,
          type integer not null
      );
    ''');
  }

  Future<Uint8List> createDatabase({
    required List<Vocab> vocabs,
    required List<Grammar> grammar,
    required List<Kanji> kanji,
    required String deckName,
  }) async {
    await _init();

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final modelId = now;
    final deckId = now + 1;

    // 1. Insert Collection Config
    _insertCollection(now, deckId, deckName, modelId);

    // 2. Insert Notes and Cards
    await _insertData(vocabs, grammar, kanji, modelId, deckId);

    // 3. Export
    return exportDatabase(_db!);
  }

  void _insertCollection(int now, int deckId, String deckName, int modelId) {
    final models = {
      '$modelId': {
        'id': modelId,
        'name': 'HanaUta Basic',
        'type': 0,
        'mod': now,
        'usn': -1,
        'sortf': 0,
        'did': deckId,
        'tmpls': [
          {
            'name': 'Card 1',
            'ord': 0,
            'qfmt': '{{Front}}',
            'afmt': '{{FrontSide}}<hr id=answer>{{Back}}',
            'bqfmt': '',
            'bafmt': '',
            'did': null
          }
        ],
        'flds': [
          {
            'name': 'Front',
            'ord': 0,
            'sticky': false,
            'rtl': false,
            'font': 'Arial',
            'size': 20,
            'media': []
          },
          {
            'name': 'Back',
            'ord': 1,
            'sticky': false,
            'rtl': false,
            'font': 'Arial',
            'size': 20,
            'media': []
          },
        ],
        'css':
            '.card { font-family: arial; font-size: 20px; text-align: center; color: black; background-color: white; }',
        'latexPre':
            '\\documentclass[12pt]{article}\n\\special{papersize=3in,5in}\n\\usepackage[utf8]{inputenc}\n\\usepackage{amssymb,amsmath}\n\\pagestyle{empty}\n\\setlength{\\parindent}{0in}\n\\begin{document}\n',
        'latexPost': '\\end{document}',
        'latexSvg': false,
        'req': [
          [
            0,
            'all',
            [0]
          ]
        ]
      }
    };

    final decks = {
      '$deckId': {
        'id': deckId,
        'mod': now,
        'name': deckName,
        'usn': -1,
        'lrnToday': [0, 0],
        'revToday': [0, 0],
        'newToday': [0, 0],
        'timeToday': [0, 0],
        'collapsed': false,
        'browserCollapsed': false,
        'desc': 'Created by HanaUta',
        'dyn': 0,
        'conf': 1,
        'extendNew': 10,
        'extendRev': 50
      },
      '1': {
        'id': 1,
        'name': 'Default',
        'mod': now,
        'conf': 1,
        'usn': -1,
        'desc': '',
        'dyn': 0,
        'collapsed': false,
        'extendNew': 10,
        'extendRev': 50,
        'newToday': [0, 0],
        'timeToday': [0, 0],
        'revToday': [0, 0],
        'lrnToday': [0, 0],
        'browserCollapsed': false
      }
    };

    final dconf = {
      '1': {
        'id': 1,
        'mod': now,
        'name': 'Default',
        'usn': -1,
        'maxTaken': 60,
        'autoplay': true,
        'timer': 0,
        'replayq': true,
        'new': {
          'bury': false,
          'delays': [1, 10],
          'initialFactor': 2500,
          'ints': [1, 4, 7],
          'order': 1,
          'perDay': 20
        },
        'rev': {
          'bury': false,
          'ease4': 1.3,
          'fuzz': 0.05,
          'ivlFct': 1,
          'maxIvl': 36500,
          'minSpace': 1,
          'perDay': 200
        },
        'lapse': {
          'delays': [10],
          'leechAction': 1,
          'leechFails': 8,
          'minInt': 1,
          'mult': 0
        }
      }
    };

    _db!.execute(
      'INSERT INTO col VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        1, // id
        now, // crt
        now, // mod
        now, // scm
        11, // ver
        0, // dty
        0, // usn
        0, // ls
        jsonEncode({}), // conf
        jsonEncode(models), // models
        jsonEncode(decks), // decks
        jsonEncode(dconf), // dconf
        jsonEncode({}), // tags
      ],
    );
  }

  Future<void> _insertData(
    List<Vocab> vocabs,
    List<Grammar> grammar,
    List<Kanji> kanji,
    int modelId,
    int deckId,
  ) async {
    int idCounter = DateTime.now().millisecondsSinceEpoch;

    // Helper to insert a note and card
    void insertItem(String front, String back, List<String> tags) {
      final noteId = idCounter++;
      final cardId = idCounter++;
      // GUID: basic implementation, usually hashing
      final guid = _generateGuid(front, noteId);
      final fields = '$front\u001f$back'; // 0x1f is unit separator

      _db!.execute(
        'INSERT INTO notes VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          noteId, // id
          guid, // guid
          modelId, // mid
          _timestamp(), // mod
          -1, // usn
          ' ${tags.join(" ")} ', // tags (padded with spaces)
          fields, // flds
          front, // sfld
          0, // csum
          0, // flags
          '', // data
        ],
      );

      _db!.execute(
        'INSERT INTO cards VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          cardId, // id
          noteId, // nid
          deckId, // did
          0, // ord
          _timestamp(), // mod
          -1, // usn
          0, // type
          0, // queue
          0, // due
          0, // ivl
          0, // factor
          0, // reps
          0, // lapses
          0, // left
          0, // odue
          0, // odid
          0, // flags
          '', // data
        ],
      );
    }

    // Insert Vocab
    for (final item in vocabs) {
      final front = '<b>${item.word}</b> <small>${item.reading}</small>';
      final back =
          '${item.meaning}<br>${item.jlptV} ${item.context}<br>[${item.nuanceNote}]';
      insertItem(
        front,
        back,
        <String>['Vocab', if (item.jlptV.isNotEmpty) item.jlptV],
      );
    }

    // Insert Grammar
    for (final item in grammar) {
      final front = '<b>${item.point}</b>';
      final back = '${item.explanation}<br>Usage: ${item.usage}';
      insertItem(
        front,
        back,
        <String>['Grammar', if (item.level.isNotEmpty) item.level],
      );
    }

    // Insert Kanji
    for (final item in kanji) {
      final front = '<b>${item.char}</b>';
      final back = 'Meanings: ${item.meanings}<br>Readings: ${item.readings}';
      insertItem(
        front,
        back,
        <String>['Kanji', if (item.level.isNotEmpty) item.level],
      );
    }
  }

  int _timestamp() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  String _generateGuid(String key, int id) {
    // Simple mock GUID generation.
    // Anki uses a specific hash but for imports, uniqueness is sufficient
    return '${key.hashCode.toRadixString(16)}-$id';
  }
}
