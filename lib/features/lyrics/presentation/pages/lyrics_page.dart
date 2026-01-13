import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_saver/file_saver.dart';
import 'package:lyrics_anki_app/features/home/presentation/providers/home_ui_providers.dart';
import 'package:lyrics_anki_app/features/lyrics/data/services/anki_export_service_impl.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/main/presentation/pages/main_page.dart';

class LyricsPage extends ConsumerStatefulWidget {
  const LyricsPage({super.key});

  @override
  ConsumerState<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends ConsumerState<LyricsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF8E7F7F),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Song Title & Artist Header
                Consumer(
                  builder: (context, ref, _) {
                    final analysis =
                        ref.watch(lyricsNotifierProvider).asData?.value;
                    if (analysis == null) return const SizedBox.shrink();

                    return Column(
                      children: [
                        Text(
                          analysis.song,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D4037),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          analysis.artist,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8E7F7F),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),

                // Filters (Quick Select) - Applies to all tabs
                Consumer(
                  builder: (context, ref, child) {
                    final analysis =
                        ref.watch(lyricsNotifierProvider).asData?.value;
                    if (analysis == null) return const SizedBox.shrink();

                    final selected = ref.watch(selectionManagerProvider);

                    bool isLevelSelected(String level) {
                      // Check if at least one item of this level exists
                      // and is selected
                      final vocabIndices = <int>[];
                      for (var i = 0; i < analysis.vocabs.length; i++) {
                        if (analysis.vocabs[i].jlptV.toUpperCase() ==
                            level.toUpperCase()) {
                          vocabIndices.add(i);
                        }
                      }

                      if (vocabIndices.isEmpty) return false;
                      // Simple check: are all vocabs of this level selected?
                      return vocabIndices.every(selected.vocabIndices.contains);
                    }

                    bool isAllSelected() {
                      if (analysis.vocabs.isEmpty &&
                          analysis.grammar.isEmpty &&
                          analysis.kanji.isEmpty) {
                        return false;
                      }

                      final vocabAll = selected.vocabIndices.length ==
                          analysis.vocabs.length;
                      final grammarAll = selected.grammarIndices.length ==
                          analysis.grammar.length;
                      final kanjiAll =
                          selected.kanjiIndices.length == analysis.kanji.length;

                      return vocabAll && grammarAll && kanjiAll;
                    }

                    // Determine which levels actually exist in the data
                    final presentLevels = <String>{};
                    bool hasOther = false;

                    void checkLevels(List<dynamic> items,
                        String Function(dynamic) getLevel) {
                      for (final item in items) {
                        final lvl = getLevel(item).toUpperCase();
                        if (['N1', 'N2', 'N3', 'N4', 'N5'].contains(lvl)) {
                          presentLevels.add(lvl);
                        } else {
                          hasOther = true;
                        }
                      }
                    }

                    checkLevels(analysis.vocabs, (d) => (d as Vocab).jlptV);
                    checkLevels(analysis.grammar, (d) => (d as Grammar).level);
                    checkLevels(analysis.kanji, (d) => (d as Kanji).level);

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _FilterCheckbox(
                          label: 'All',
                          value: isAllSelected(),
                          onChanged: (val) {
                            ref
                                .read(selectionManagerProvider.notifier)
                                .toggleAll(analysis, select: val ?? false);
                          },
                        ),
                        for (final level in ['N1', 'N2', 'N3', 'N4', 'N5'])
                          if (presentLevels.contains(level))
                            _FilterCheckbox(
                              label: level,
                              value: isLevelSelected(level),
                              onChanged: (val) {
                                ref
                                    .read(selectionManagerProvider.notifier)
                                    .toggleLevel(
                                      analysis,
                                      level,
                                      select: val ?? false,
                                    );
                              },
                            ),
                        if (hasOther)
                          _FilterCheckbox(
                            label: 'Other',
                            value: (() {
                              final nonLevels = <int>[];
                              for (var i = 0; i < analysis.vocabs.length; i++) {
                                final lvl =
                                    analysis.vocabs[i].jlptV.toUpperCase();
                                if (!['N1', 'N2', 'N3', 'N4', 'N5']
                                    .contains(lvl)) {
                                  nonLevels.add(i);
                                }
                              }
                              if (nonLevels.isEmpty) return false;
                              return nonLevels
                                  .every(selected.vocabIndices.contains);
                            })(),
                            onChanged: (val) {
                              // Select all non-standard levels
                              // This logic should ideally be in the notifier,
                              // but implementing here for now
                              // Or better, update notifier to handle a filter
                              // predicate?
                              // For simplicity/speed, I'll manually iterate here
                              // and toggle.
                              final targetIndices = <int>[];
                              for (var i = 0; i < analysis.vocabs.length; i++) {
                                final lvl =
                                    analysis.vocabs[i].jlptV.toUpperCase();
                                if (!['N1', 'N2', 'N3', 'N4', 'N5']
                                    .contains(lvl)) {
                                  targetIndices.add(i);
                                }
                              }

                              for (final idx in targetIndices) {
                                ref
                                    .read(selectionManagerProvider.notifier)
                                    .toggle(SelectionType.vocab, idx,
                                        force: val);
                              }
                              // Note: Logic for 'Other' currently only targets
                              // Vocab based on typical usage.
                              // Grammar usually has strict levels. Kanji might
                              // have levels too.
                              // If we want 'Other' to apply to Kanji too:
                              for (var i = 0; i < analysis.kanji.length; i++) {
                                final lvl =
                                    analysis.kanji[i].level.toUpperCase();
                                if (!['N1', 'N2', 'N3', 'N4', 'N5']
                                    .contains(lvl)) {
                                  ref
                                      .read(selectionManagerProvider.notifier)
                                      .toggle(SelectionType.kanji, i,
                                          force: val);
                                }
                              }
                            },
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Tabs
                Consumer(
                  builder: (context, ref, _) {
                    final analysis =
                        ref.watch(lyricsNotifierProvider).asData?.value;
                    final vocabCount = analysis?.vocabs.length ?? 0;
                    final grammarCount = analysis?.grammar.length ?? 0;
                    final kanjiCount = analysis?.kanji.length ?? 0;

                    return TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFFD4A5A5),
                      unselectedLabelColor: const Color(0xFF8E7F7F),
                      indicatorColor: const Color(0xFFD4A5A5),
                      tabs: [
                        Tab(text: 'Vocab ($vocabCount)'),
                        Tab(text: 'Grammar ($grammarCount)'),
                        Tab(text: 'Kanji ($kanjiCount)'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Results Area
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final state = ref.watch(lyricsNotifierProvider);
                      return state.when(
                        data: (analysis) {
                          if (analysis == null) {
                            return Center(
                              child: Text(
                                'No analysis data available.',
                                style: TextStyle(
                                  color: const Color(0xFF8E7F7F)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            );
                          }

                          return TabBarView(
                            controller: _tabController,
                            children: [
                              _VocabList(vocabList: analysis.vocabs),
                              _GrammarList(grammarList: analysis.grammar),
                              _KanjiList(kanjiList: analysis.kanji),
                            ],
                          );
                        },
                        loading: () => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Color(0xFFD4A5A5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Analysis in progress...\n'
                                'This could take a few minutes.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF8E7F7F)
                                      .withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        error: (Object e, StackTrace s) {
                          final errorMsg = e.toString();
                          final isNotJapanese = errorMsg.contains(
                              'not appear to be primarily in Japanese');

                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isNotJapanese
                                      ? Icons.translate_rounded
                                      : Icons.error_outline,
                                  size: 48,
                                  color: const Color(0xFFE57373),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isNotJapanese
                                      ? 'Language Mismatch'
                                      : 'Analysis Failed',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32),
                                  child: Text(
                                    errorMsg.replaceAll('Exception: ', ''),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                if (isNotJapanese)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Clear Home fields
                                      ref
                                          .read(clearHomeFormSignalProvider
                                              .notifier)
                                          .state++;
                                      // Navigate to Home (Index 0)
                                      ref
                                          .read(navIndexProvider.notifier)
                                          .state = 0;
                                      // Also clear current lyrics state
                                      ref.invalidate(lyricsNotifierProvider);
                                    },
                                    icon: const Icon(Icons.search),
                                    label: const Text('Search Another Song'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD4A5A5),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(lyricsNotifierProvider.notifier)
                                          .retry();
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry Analysis'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD4A5A5),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final analysis = ref.watch(lyricsNotifierProvider).asData?.value;
          final selectedState = ref.watch(selectionManagerProvider);
          final hasSelection = selectedState.vocabIndices.isNotEmpty ||
              selectedState.grammarIndices.isNotEmpty ||
              selectedState.kanjiIndices.isNotEmpty;

          if (analysis == null || !hasSelection) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            backgroundColor: const Color(0xFFD4A5A5),
            onPressed: () {
              // Re-read to get latest state in callback
              final analysis = ref.read(lyricsNotifierProvider).asData?.value;
              if (analysis == null) return;

              final selectedState = ref.read(selectionManagerProvider);

              final selectedVocabs = <Vocab>[];
              for (final i in selectedState.vocabIndices) {
                if (i < analysis.vocabs.length) {
                  selectedVocabs.add(analysis.vocabs[i]);
                }
              }

              final selectedGrammar = <Grammar>[];
              for (final i in selectedState.grammarIndices) {
                if (i < analysis.grammar.length) {
                  selectedGrammar.add(analysis.grammar[i]);
                }
              }

              final selectedKanji = <Kanji>[];
              for (final i in selectedState.kanjiIndices) {
                if (i < analysis.kanji.length) {
                  selectedKanji.add(analysis.kanji[i]);
                }
              }

              if (selectedVocabs.isEmpty &&
                  selectedGrammar.isEmpty &&
                  selectedKanji.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select items to export')),
                );
                return;
              }

              showDialog<void>(
                context: context,
                builder: (context) => _ExportDialog(
                  onExport: (userLevel) {
                    final exportService = ref.read(ankiExportServiceProvider);
                    exportService
                        .generateApkg(
                      vocabs: selectedVocabs,
                      grammar: selectedGrammar,
                      kanji: selectedKanji,
                      songTitle: analysis.song,
                      artist: analysis.artist,
                    )
                        .then((bytes) {
                      if (!context.mounted) return;

                      final filename =
                          '${analysis.song.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')}_${analysis.artist}.apkg';

                      FileSaver.instance
                          .saveFile(
                        name: filename,
                        bytes: bytes,
                        mimeType: MimeType.other,
                      )
                          .then((path) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Export downloaded successfully')),
                        );
                      });
                    }).catchError((Object e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $e')),
                      );
                    });
                  },
                ),
              );
            },
            child: const Icon(Icons.file_upload_outlined, color: Colors.white),
          );
        },
      ),
    );
  }
}

class _VocabList extends ConsumerWidget {
  const _VocabList({required this.vocabList});
  final List<Vocab> vocabList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (vocabList.isEmpty) {
      return const Center(child: Text('No vocabulary found.'));
    }

    return ListView.builder(
      itemCount: vocabList.length,
      itemBuilder: (context, index) {
        final vocab = vocabList[index];
        final selected = ref.watch(selectionManagerProvider);
        final isSelected = selected.vocabIndices.contains(index);

        return _ResultCard(
          title: Text(
            vocab.word,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            vocab.reading,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          details: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vocab.meaning,
                style: const TextStyle(color: Colors.black87),
              ),
              if (vocab.context.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    vocab.context,
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
          trailingTag: vocab.jlptV.isNotEmpty
              ? _Tag(
                  label: vocab.jlptV,
                  color: const Color(0xFFD4A5A5),
                )
              : null,
          isSelected: isSelected,
          onToggle: () {
            ref
                .read(selectionManagerProvider.notifier)
                .toggle(SelectionType.vocab, index);
          },
          themeColor: const Color(0xFFD4A5A5),
        );
      },
    );
  }
}

class _GrammarList extends ConsumerWidget {
  const _GrammarList({required this.grammarList});
  final List<Grammar> grammarList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (grammarList.isEmpty) {
      return const Center(child: Text('No grammar points found.'));
    }

    return ListView.builder(
      itemCount: grammarList.length,
      itemBuilder: (context, index) {
        final grammar = grammarList[index];
        final selected = ref.watch(selectionManagerProvider);
        final isSelected = selected.grammarIndices.contains(index);

        return _ResultCard(
          title: Text(
            grammar.point,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          details: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                grammar.explanation,
                style: const TextStyle(color: Colors.black87),
              ),
              if (grammar.usage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Usage: ${grammar.usage}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          trailingTag: grammar.level.isNotEmpty
              ? _Tag(
                  label: grammar.level,
                  color: const Color(0xFF90A4AE), // Blue Grey
                )
              : null,
          isSelected: isSelected,
          onToggle: () {
            ref
                .read(selectionManagerProvider.notifier)
                .toggle(SelectionType.grammar, index);
          },
          themeColor: const Color(0xFF78909C), // Blue Grey
        );
      },
    );
  }
}

class _KanjiList extends ConsumerWidget {
  const _KanjiList({required this.kanjiList});
  final List<Kanji> kanjiList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kanjiList.isEmpty) {
      return const Center(child: Text('No kanji found.'));
    }

    return ListView.builder(
      itemCount: kanjiList.length,
      itemBuilder: (context, index) {
        final kanji = kanjiList[index];
        final selected = ref.watch(selectionManagerProvider);
        final isSelected = selected.kanjiIndices.contains(index);

        return _ResultCard(
          leadingContent: CircleAvatar(
            backgroundColor: const Color(0xFFEFEBE9), // Light Brown
            foregroundColor: const Color(0xFF5D4037), // Dark Brown
            child: Text(kanji.char, style: const TextStyle(fontSize: 20)),
          ),
          title: Text(
            kanji.meanings,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            kanji.readings,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailingTag: kanji.level.isNotEmpty
              ? _Tag(
                  label: kanji.level,
                  color: const Color(0xFFA1887F), // Brown
                )
              : null,
          isSelected: isSelected,
          onToggle: () {
            ref
                .read(selectionManagerProvider.notifier)
                .toggle(SelectionType.kanji, index);
          },
          themeColor: const Color(0xFF8D6E63), // Brown
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FilterCheckbox extends StatelessWidget {
  const _FilterCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      checkmarkColor: Colors.white,
      selectedColor: const Color(0xFFD4A5A5),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE0E0E0)),
      labelStyle: TextStyle(
        color: value ? Colors.white : const Color(0xFF8E7F7F),
        fontWeight: value ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: true,
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.isSelected,
    required this.onToggle,
    required this.themeColor,
    this.subtitle,
    this.details,
    this.trailingTag,
    this.leadingContent,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? details;
  final Widget? trailingTag;
  final bool isSelected;
  final VoidCallback onToggle;
  final Color themeColor;
  final Widget? leadingContent;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isSelected ? themeColor.withValues(alpha: 0.1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? themeColor : Colors.transparent,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox and Leading
              // Checkbox and Leading
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: isSelected,
                    activeColor: themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (_) => onToggle(),
                  ),
                  if (leadingContent != null) ...[
                    leadingContent!,
                    const SizedBox(width: 8),
                  ],
                ],
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    right: 8,
                    bottom: 8,
                    left: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: title),
                          if (trailingTag != null) ...[
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: trailingTag,
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        subtitle!,
                      ],
                      if (details != null) ...[
                        const SizedBox(height: 8),
                        details!,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportDialog extends StatefulWidget {
  const _ExportDialog({required this.onExport});

  final void Function(String userLevel) onExport;

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  String _selectedLevel = 'N5';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Export to Anki',
        style: TextStyle(color: Color(0xFF8E7F7F)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select your JLPT Level:'),
          const SizedBox(height: 8),
          const Text(
            'Words above this level will include furigana on the '
            'front of the card.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedLevel,
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9F6F7),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onExport(_selectedLevel);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4A5A5),
            foregroundColor: Colors.white,
          ),
          child: const Text('Export'),
        ),
      ],
    );
  }
}
