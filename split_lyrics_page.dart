import 'dart:io';

void main() async {
  final file = File('lib/features/lyrics/presentation/pages/lyrics_page.dart');
  final lines = await file.readAsLines();

  // We want to extract specific classes to other files
  // Instead of a complex regex, we'll just extract from known start to end line
  // Let's find the start of each section
  int findClass(String name) {
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('class $name ')) return i;
    }
    return -1;
  }

  int endOfClass(int startIdx) {
    if (startIdx == -1) return -1;
    var braceCount = 0;
    var started = false;
    for (var i = startIdx; i < lines.length; i++) {
      final line = lines[i];
      for (var j = 0; j < line.length; j++) {
        if (line[j] == '{') {
          braceCount++;
          started = true;
        } else if (line[j] == '}') {
          braceCount--;
        }
      }
      if (started && braceCount == 0) return i;
    }
    return -1;
  }

  void extract(String path, List<String> classes) {
    final imports = <String>[
      "import 'dart:async';",
      "import 'dart:convert';",
      "import 'package:flutter/material.dart';",
      "import 'package:flutter/services.dart';",
      "import 'package:flutter_riverpod/flutter_riverpod.dart';",
      "import 'package:file_saver/file_saver.dart';",
      "import 'package:lyrics_anki_app/core/services/analytics_service.dart';",
      "import 'package:lyrics_anki_app/core/theme/app_colors.dart';",
      "import 'package:lyrics_anki_app/features/home/presentation/providers/home_ui_providers.dart';",
      "import 'package:lyrics_anki_app/features/lyrics/data/services/anki_export_service_impl.dart';",
      "import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';",
      "import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';",
      "import 'package:lyrics_anki_app/l10n/l10n.dart';",
      '// Add more imports as needed',
    ];

    final content = <String>[...imports, ''];
    final linesToRemove = <int>[];

    for (final c in classes) {
      var start = findClass(c);
      if (start == -1) {
        // Maybe it's a function? Check for void name(
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('void $c(')) {
            start = i;
            break;
          }
        }
      }

      if (start == -1) continue;

      // Look for comments before class
      var realStart = start;
      while (realStart > 0 &&
          (lines[realStart - 1].trim().startsWith('///') ||
              lines[realStart - 1].trim().startsWith('//'))) {
        realStart--;
      }

      final end = endOfClass(start);
      if (end != -1) {
        content.addAll(lines.sublist(realStart, end + 1));
        content.add('');
        for (var i = realStart; i <= end; i++) {
          linesToRemove.add(i);
        }
      }
    }

    // Convert private classes to public in the extracted file
    var text = content.join('\n');
    for (final c in classes) {
      if (c.startsWith('_')) {
        final publicName = c.substring(1);
        text = text.replaceAll(c, publicName);
        // Also fix the corresponding widget usages in lyrics_page later
      }
    }

    File(
      'lib/features/lyrics/presentation/widgets/$path',
    ).writeAsStringSync(text);

    // Remove from lines (bottom up)
    linesToRemove.sort((a, b) => b.compareTo(a));
    for (final i in linesToRemove) {
      lines.removeAt(i);
    }
  }

  extract('vocab_list.dart', ['_VocabList', '_VocabListState', '_VocabItem']);
  extract('grammar_list.dart', [
    '_GrammarList',
    '_GrammarListState',
    '_GrammarItem',
  ]);
  extract('kanji_list.dart', ['_KanjiList', '_KanjiListState', '_KanjiItem']);
  extract('en_vocab_list.dart', [
    '_EnVocabList',
    '_EnVocabListState',
    '_EnVocabItem',
  ]);
  extract('en_grammar_list.dart', [
    '_EnGrammarList',
    '_EnGrammarListState',
    '_EnGrammarItem',
  ]);
  extract('lyrics_view.dart', ['_Match', '_LyricsView']);
  extract('result_card.dart', ['_ResultCard', '_ResultCardState', '_Tag']);
  extract('export_dialogs.dart', [
    '_ExportDialog',
    '_ExportDialogState',
    '_showAnkiExportDialog',
    '_PlainTextExportDialog',
    '_PlainTextExportDialogState',
  ]);

  // We need to also rename the private classes in the original file
  var text = lines.join('\n');
  final classesToRename = [
    '_VocabList',
    '_VocabItem',
    '_GrammarList',
    '_GrammarItem',
    '_KanjiList',
    '_KanjiItem',
    '_EnVocabList',
    '_EnVocabItem',
    '_EnGrammarList',
    '_EnGrammarItem',
    '_Match',
    '_LyricsView',
    '_ResultCard',
    '_Tag',
    '_ExportDialog',
    '_showAnkiExportDialog',
    '_PlainTextExportDialog',
  ];
  for (final c in classesToRename) {
    final publicName = c.startsWith('_') ? c.substring(1) : c;
    text = text.replaceAll(c, publicName);
  }

  // Add imports to the original file
  final importsToAdd = [
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/vocab_list.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/grammar_list.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/kanji_list.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/en_vocab_list.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/en_grammar_list.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/lyrics_view.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/result_card.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/export_dialogs.dart';",
  ];

  final importIdx = text.lastIndexOf("import '");
  final endOfImports = text.indexOf('\n', importIdx) + 1;
  text =
      '${text.substring(0, endOfImports)}${importsToAdd.join('\n')}\n${text.substring(endOfImports)}';

  File(
    'lib/features/lyrics/presentation/pages/lyrics_page.dart',
  ).writeAsStringSync(text);
  print('Done splitting!');
}
