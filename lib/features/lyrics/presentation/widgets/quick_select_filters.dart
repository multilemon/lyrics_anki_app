import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';
class QuickSelectFilters extends ConsumerWidget {
  const QuickSelectFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(lyricsProvider).asData?.value;
    if (analysis == null || !analysis.isComplete) {
      return const SizedBox.shrink();
    }
    final data = analysis;

                          bool isLevelSelected(String level) {
                            final selected =
                                ref.watch(selectionManagerProvider);

                            // JLPT Check
                            final vocabIndices = <int>[];
                            for (var i = 0; i < data.vocabs.length; i++) {
                              if (data.vocabs[i].jlptV.trim().toUpperCase() ==
                                  level.toUpperCase()) {
                                vocabIndices.add(i);
                              }
                            }

                            final grammarIndices = <int>[];
                            for (var i = 0; i < data.grammar.length; i++) {
                              if (data.grammar[i].level.trim().toUpperCase() ==
                                  level.toUpperCase()) {
                                grammarIndices.add(i);
                              }
                            }

                            final kanjiIndices = <int>[];
                            for (var i = 0; i < data.kanji.length; i++) {
                              if (data.kanji[i].level.trim().toUpperCase() ==
                                  level.toUpperCase()) {
                                kanjiIndices.add(i);
                              }
                            }

                            if (vocabIndices.isEmpty &&
                                grammarIndices.isEmpty &&
                                kanjiIndices.isEmpty) {
                              return false;
                            }

                            final vocabSelected = vocabIndices
                                .every(selected.vocabIndices.contains);
                            final grammarSelected = grammarIndices
                                    .every(selected.grammarIndices.contains);
                            final kanjiSelected = kanjiIndices
                                .every(selected.kanjiIndices.contains);

                            return vocabSelected &&
                                grammarSelected &&
                                kanjiSelected;
                          }

                          bool isAllSelected() {
                            final selected =
                                ref.watch(selectionManagerProvider);

                            final hasVocab = data.vocabs.isNotEmpty;
                            final hasGrammar = data.grammar.isNotEmpty;
                            final hasKanji = data.kanji.isNotEmpty;

                            if (!hasVocab && !hasGrammar && !hasKanji) {
                              return false;
                            }

                            final vocabAll = selected.vocabIndices.length ==
                                data.vocabs.length;
                            final grammarAll = selected.grammarIndices.length ==
                                data.grammar.length;
                            final kanjiAll = selected.kanjiIndices.length ==
                                data.kanji.length;

                            return vocabAll && grammarAll && kanjiAll;
                          }

                          final presentLevels = <String>{};
                          var hasOther = false;

                          final targetLevels = ['N1', 'N2', 'N3', 'N4', 'N5'];

                          void checkLevels(
                            List<dynamic> items,
                            String Function(dynamic) getLevel,
                          ) {
                            for (final item in items) {
                              final lvl = getLevel(item).trim().toUpperCase();
                              if (targetLevels.contains(lvl)) {
                                presentLevels.add(lvl);
                              } else {
                                hasOther = true;
                              }
                            }
                          }

                          checkLevels(
                            data.vocabs,
                            (d) => (d as Vocab).jlptV,
                          );
                          checkLevels(
                            data.grammar,
                            (d) => (d as Grammar).level,
                          );
                          checkLevels(
                            data.kanji,
                            (d) => (d as Kanji).level,
                          );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: context.l10n.allFilter,
            value: isAllSelected(),
            onChanged: (val) {
              ref
                  .read(selectionManagerProvider.notifier)
                  .toggleAll(data, select: val);
            },
          ),
          const SizedBox(width: 8),
          for (final level in targetLevels)
            if (presentLevels.contains(level)) ...[
              FilterChip(
                label: level,
                value: isLevelSelected(level),
                onChanged: (val) {
                  ref
                      .read(selectionManagerProvider.notifier)
                      .toggleLevel(data, level, select: val);
                },
              ),
              const SizedBox(width: 8),
            ],
          if (hasOther)
            FilterChip(
              label: context.l10n.otherFilter,
              value: (() {
                final selected = ref.watch(selectionManagerProvider);

                final nonLevelVocab = <int>[];
                for (var i = 0; i < data.vocabs.length; i++) {
                  final lvl = data.vocabs[i].jlptV.trim().toUpperCase();
                  if (!targetLevels.contains(lvl)) {
                    nonLevelVocab.add(i);
                  }
                }
                final nonLevelGrammar = <int>[];
                for (var i = 0; i < data.grammar.length; i++) {
                  final lvl = data.grammar[i].level.trim().toUpperCase();
                  if (!targetLevels.contains(lvl)) {
                    nonLevelGrammar.add(i);
                  }
                }
                final nonLevelKanji = <int>[];
                for (var i = 0; i < data.kanji.length; i++) {
                  final lvl = data.kanji[i].level.trim().toUpperCase();
                  if (!targetLevels.contains(lvl)) {
                    nonLevelKanji.add(i);
                  }
                }

                if (nonLevelVocab.isEmpty &&
                    nonLevelGrammar.isEmpty &&
                    nonLevelKanji.isEmpty) {
                  return false;
                }

                final vocabAll = nonLevelVocab.every(
                  selected.vocabIndices.contains,
                );
                final grammarAll = nonLevelGrammar.every(
                  selected.grammarIndices.contains,
                );
                final kanjiAll = nonLevelKanji.every(
                  selected.kanjiIndices.contains,
                );

                return vocabAll && grammarAll && kanjiAll;
              })(),
              onChanged: (val) {
                  final targetIndices = <int>[];
                  for (var i = 0; i < data.vocabs.length; i++) {
                    final lvl = data.vocabs[i].jlptV.trim().toUpperCase();
                    if (!targetLevels.contains(lvl)) {
                      targetIndices.add(i);
                    }
                  }
                  for (final idx in targetIndices) {
                    ref
                        .read(selectionManagerProvider.notifier)
                        .toggle(SelectionType.vocab, idx, force: val);
                  }

                  for (var i = 0; i < data.grammar.length; i++) {
                    final lvl = data.grammar[i].level.trim().toUpperCase();
                    if (!targetLevels.contains(lvl)) {
                      ref
                          .read(selectionManagerProvider.notifier)
                          .toggle(SelectionType.grammar, i, force: val);
                    }
                  }

                  for (var i = 0; i < data.kanji.length; i++) {
                    final lvl = data.kanji[i].level.trim().toUpperCase();
                    if (!targetLevels.contains(lvl)) {
                      ref
                          .read(selectionManagerProvider.notifier)
                          .toggle(SelectionType.kanji, i, force: val);
                    }
                  }
              },
            ),
        ],
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  const FilterChip({
    required this.label, required this.value, required this.onChanged, super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      selectedColor: AppColors.sakura,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: value ? AppColors.background : AppColors.textSecondary,
        fontWeight: value ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: value ? AppColors.sakura : AppColors.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
