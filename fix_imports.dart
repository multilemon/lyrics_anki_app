import 'dart:io';

void main() {
  final dir = Directory('lib/features/lyrics/presentation/widgets');
  final files = dir.listSync().whereType<File>().toList();

  final commonImports = [
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/staggered_list_item.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/result_card.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/vocab_list.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/grammar_list.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/kanji_list.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/en_vocab_list.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/en_grammar_list.dart';",
    "import 'package:lyrics_anki_app/features/lyrics/domain/entities/learning_mode.dart';",
    "import 'package:lyrics_anki_app/core/providers/hive_provider.dart';",
  ];

  for (final file in files) {
    if (!file.path.endsWith('.dart')) continue;

    var content = file.readAsStringSync();

    // Replace leftover private class references
    content = content.replaceAll('_ResultCard', 'ResultCard');
    content = content.replaceAll('_Tag', 'Tag');
    content = content.replaceAll('_VocabItem', 'VocabItem');
    content = content.replaceAll('_EnVocabItem', 'EnVocabItem');
    content = content.replaceAll('_GrammarItem', 'GrammarItem');
    content = content.replaceAll('_EnGrammarItem', 'EnGrammarItem');
    content = content.replaceAll('_KanjiItem', 'KanjiItem');

    // Add missing imports
    final importIdx = content.lastIndexOf("import '");
    if (importIdx != -1) {
      final endOfImports = content.indexOf('\n', importIdx) + 1;
      final existingImports = content.substring(0, endOfImports);
      final restOfContent = content.substring(endOfImports);

      final importsToAdd = commonImports
          .where((imp) => !existingImports.contains(imp))
          .toList();
      content = '$existingImports${importsToAdd.join('\n')}\n$restOfContent';
    }

    file.writeAsStringSync(content);
  }
  print('Imports fixed');
}
