import 'dart:async';
import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:lyrics_anki_app/core/services/analytics_service.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/data/services/anki_export_service_impl.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';
// Add more imports as needed

class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({required this.onExport, super.key});

  final Future<void> Function(String userLevel) onExport;

  @override
  ConsumerState<ExportDialog> createState() => ExportDialogState();
}

class ExportDialogState extends ConsumerState<ExportDialog> {
  String _selectedLevel = 'N5';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = ref.read(settingsBoxProvider);
      final saved = box?.get('export_jlpt_level');
      if (saved != null && saved is String) {
        setState(() {
          _selectedLevel = saved;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(
        l10n.exportToAnki,
        style: theme.textTheme.titleLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      content: _isLoading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.sakura),
                const SizedBox(height: 16),
                Text(l10n.generatingApkg),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.selectJlptLevel),
                const SizedBox(height: 8),
                Text(
                  l10n.furiganaExplanation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLevel,
                  dropdownColor: AppColors.surface,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ['N5', 'N4', 'N3', 'N2', 'N1'].map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedLevel = val);
                    }
                  },
                ),
              ],
            ),
      actions: _isLoading
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancelButton,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(settingsBoxProvider)
                      ?.put('export_jlpt_level', _selectedLevel);
                  setState(() => _isLoading = true);
                  await widget.onExport(_selectedLevel);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sakura,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.exportButton),
              ),
            ],
    );
  }
}

/// Shows the Anki export dialog (extracted as a method for cleanliness)
void showAnkiExportDialog({
  required BuildContext context,
  required WidgetRef ref,
  required AnalysisResult analysis,
  required List<Vocab> selectedVocabs,
  required List<Grammar> selectedGrammar,
  required List<Kanji> selectedKanji,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => ExportDialog(
      onExport: (userLevel) async {
        try {
          final exportService = ref.read(ankiExportServiceProvider);

          // Log export initiation
          unawaited(
            analyticsService.logExport(
              songTitle: analysis.song,
              artist: analysis.artist,
              level: userLevel,
              vocabCount: selectedVocabs.length,
              grammarCount: selectedGrammar.length,
              kanjiCount: selectedKanji.length,
            ),
          );

          // Generate .apkg
          final bytes = await exportService.generateApkg(
            vocabs: selectedVocabs,
            grammar: selectedGrammar,
            kanji: selectedKanji,
            songTitle: analysis.song,
            artist: analysis.artist,
            userLevel: userLevel,
          );

          if (!context.mounted) return;

          final filename =
              '${analysis.song.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')}_${analysis.artist}.apkg';

          // Save file (trigger download)
          await FileSaver.instance.saveFile(
            name: filename,
            bytes: bytes,
          );

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export downloaded successfully'),
            ),
          );
        } on Exception catch (e) {
          unawaited(
            analyticsService.logError(
              'Export failed: $e',
              'export_dialog',
            ),
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: $e'),
            ),
          );
        }
      },
    ),
  );
}

/// Dialog for exporting selected words/kanji as comma-separated plain text
class PlainTextExportDialog extends StatefulWidget {
  const PlainTextExportDialog({
    required this.vocabs,
    required this.grammar,
    required this.kanji,
    required this.songTitle,
    required this.artist,
    super.key,
  });

  final List<String> vocabs;
  final List<String> grammar;
  final List<String> kanji;
  final String songTitle;
  final String artist;

  @override
  State<PlainTextExportDialog> createState() => PlainTextExportDialogState();
}

class PlainTextExportDialogState extends State<PlainTextExportDialog> {
  bool _includeVocab = true;
  bool _includeKanji = true;
  bool _includeGrammar = true;

  String _buildWordList() {
    final words = <String>[];

    if (_includeVocab) words.addAll(widget.vocabs);
    if (_includeGrammar) words.addAll(widget.grammar);
    if (_includeKanji) words.addAll(widget.kanji);

    return words.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final wordList = _buildWordList();

    // Hide kanji toggle if empty
    final showKanjiToggle = widget.kanji.isNotEmpty;

    // Show grammar toggle if grammar is available
    final showGrammarToggle = widget.grammar.isNotEmpty;

    return AlertDialog(
      title: Text(
        l10n.exportWordsTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category toggles
          if (widget.vocabs.isNotEmpty)
            CheckboxListTile(
              value: _includeVocab,
              onChanged: (val) => setState(() => _includeVocab = val ?? true),
              title: Text(l10n.includeVocab),
              activeColor: AppColors.sakura,
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          if (showGrammarToggle)
            CheckboxListTile(
              value: _includeGrammar,
              onChanged: (val) => setState(() => _includeGrammar = val ?? true),
              title: Text(l10n.includeGrammar),
              activeColor: AppColors.sakura,
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          if (showKanjiToggle)
            CheckboxListTile(
              value: _includeKanji,
              onChanged: (val) => setState(() => _includeKanji = val ?? true),
              title: Text(l10n.includeKanji),
              activeColor: AppColors.sakura,
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          const SizedBox(height: 12),
          // Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.sakura.withValues(alpha: 0.2),
              ),
            ),
            constraints: const BoxConstraints(maxHeight: 160),
            child: SingleChildScrollView(
              child: wordList.isEmpty
                  ? Text(
                      l10n.noWordsToExport,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : SelectableText(
                      wordList,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancelButton,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        // Download as file
        OutlinedButton.icon(
          onPressed: wordList.isEmpty
              ? null
              : () async {
                  final filename =
                      '${widget.songTitle.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')}_${widget.artist}_words.txt';
                  await FileSaver.instance.saveFile(
                    name: filename,
                    bytes: utf8.encode(wordList),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.wordListDownloaded),
                    ),
                  );
                },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.sakura,
            side: const BorderSide(color: AppColors.sakura),
          ),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: Text(l10n.downloadAsFile),
        ),
        // Copy to clipboard
        ElevatedButton.icon(
          onPressed: wordList.isEmpty
              ? null
              : () async {
                  await Clipboard.setData(ClipboardData(text: wordList));
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.wordListCopied),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.sakura,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: Text(l10n.copyToClipboard),
        ),
      ],
    );
  }
}
