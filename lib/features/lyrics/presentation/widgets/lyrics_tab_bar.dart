import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/core/utils/jlpt_utils.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/jlpt_level_notifier.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

class LyricsTabBar extends ConsumerWidget {
  const LyricsTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(lyricsProvider).asData?.value;
    if (analysis == null || !analysis.isComplete) {
      return const SizedBox.shrink();
    }

    final jlptLevel = ref.watch(jlptLevelProvider);

    // Calculate counts based on learning mode and JLPT filter
    final vocabCount = analysis.vocabs
        .where((v) => shouldShowJlpt(v.jlptV, jlptLevel))
        .length;
    final grammarCount = analysis.grammar
        .where((g) => shouldShowJlpt(g.level, jlptLevel))
        .length;
    final kanjiCount = analysis.kanji
        .where((k) => shouldShowJlpt(k.level, jlptLevel))
        .length;

    // Verse count for translation tab
    final verseCount = analysis.verses.length;
    final translationLabel = verseCount > 0
        ? '${context.l10n.translationTab} ($verseCount)'
        : context.l10n.translationTab;

    // Prepare labels
    final vocabLabel = '${context.l10n.vocabTab} ($vocabCount)';
    final grammarLabel = '${context.l10n.grammarTab} ($grammarCount)';
    final kanjiLabel = '${context.l10n.kanjiTab} ($kanjiCount)';

    return TabBar(
      labelColor: AppColors.sakura,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.sakura,
      isScrollable: true,
      tabAlignment: TabAlignment.center,
      tabs: [
        Tab(text: context.l10n.lyricsTab),
        Tab(text: translationLabel),
        Tab(text: vocabLabel),
        Tab(text: grammarLabel),
        Tab(text: kanjiLabel),
      ],
    );
  }
}
