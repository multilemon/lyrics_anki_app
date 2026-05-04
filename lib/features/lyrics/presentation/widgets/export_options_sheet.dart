import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';

import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/export_dialogs.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

void showExportOptionsSheet({
  required BuildContext context,
  required WidgetRef ref,
}) {
  final analysis = ref.read(lyricsProvider).asData?.value;
  if (analysis == null) return;

  final selectedState = ref.read(selectionManagerProvider);

  final selectedVocabs = <Vocab>[];
  final selectedGrammar = <Grammar>[];
  final selectedKanji = <Kanji>[];

  final plainTextVocabs = <String>[];
  final plainTextGrammar = <String>[];
  final plainTextKanji = <String>[];

  // Collect normal Vocab/Grammar/Kanji
  for (final i in selectedState.vocabIndices) {
    if (i < analysis.vocabs.length) {
      selectedVocabs.add(analysis.vocabs[i]);
      if (analysis.vocabs[i].word.isNotEmpty) {
        plainTextVocabs.add(analysis.vocabs[i].word);
      }
    }
  }
  for (final i in selectedState.grammarIndices) {
    if (i < analysis.grammar.length) {
      selectedGrammar.add(analysis.grammar[i]);
      if (analysis.grammar[i].point.isNotEmpty) {
        plainTextGrammar.add(analysis.grammar[i].point);
      }
    }
  }
  for (final i in selectedState.kanjiIndices) {
    if (i < analysis.kanji.length) {
      selectedKanji.add(analysis.kanji[i]);
      if (analysis.kanji[i].char.isNotEmpty &&
          !plainTextVocabs.contains(analysis.kanji[i].char)) {
        plainTextKanji.add(analysis.kanji[i].char);
      }
    }
  }

  if (plainTextVocabs.isEmpty &&
      plainTextGrammar.isEmpty &&
      plainTextKanji.isEmpty &&
      selectedVocabs.isEmpty &&
      selectedGrammar.isEmpty &&
      selectedKanji.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Select items to export')),
    );
    return;
  }

  final l10n = context.l10n;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.exportOptions,
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.sakura.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.style_rounded,
                      color: AppColors.sakura,
                    ),
                  ),
                  title: Text(l10n.exportAnkiOption),
                  subtitle: Text(
                    l10n.exportAnkiDescription,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showAnkiExportDialog(
                      context: context,
                      ref: ref,
                      analysis: analysis,
                      selectedVocabs: selectedVocabs,
                      selectedGrammar: selectedGrammar,
                      selectedKanji: selectedKanji,
                    );
                  },
                ),
              const Divider(indent: 72, endIndent: 16, height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.sakura.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.text_snippet_rounded,
                    color: AppColors.sakura,
                  ),
                ),
                title: Text(l10n.exportPlainTextOption),
                subtitle: Text(
                  l10n.exportPlainTextDescription,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => PlainTextExportDialog(
                      vocabs: plainTextVocabs,
                      grammar: plainTextGrammar,
                      kanji: plainTextKanji,
                      songTitle: analysis.song,
                      artist: analysis.artist,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );
}
