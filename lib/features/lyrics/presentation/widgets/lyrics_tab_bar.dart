import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

class LyricsTabBar extends ConsumerWidget {
  const LyricsTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(lyricsProvider).asData?.value;
    if (analysis == null || !analysis.isComplete) {
      return const SizedBox.shrink();
    }

    final isReverseLearning = analysis.enVocab != null;

    // Calculate counts based on learning mode
    final int vocabCount;
    final int grammarCount;
    final int kanjiCount;

    if (isReverseLearning) {
      vocabCount = analysis.enVocab?.length ?? 0;
      grammarCount = analysis.enGrammar?.length ?? 0;
      kanjiCount = 0; // Not applicable for reverse learning
    } else {
      vocabCount = analysis.vocabs.length;
      grammarCount = analysis.grammar.length;
      kanjiCount = analysis.kanji.length;
    }

    // Prepare labels
    final vocabLabel = '${context.l10n.vocabTab} ($vocabCount)';
    final grammarLabel = '${context.l10n.grammarTab} ($grammarCount)';
    final structureLabel = '${context.l10n.structureType} ($grammarCount)';
    final kanjiLabel = '${context.l10n.kanjiTab} ($kanjiCount)';

    if (isReverseLearning) {
      return TabBar(
        labelColor: AppColors.sakura,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.sakura,
        tabs: [
          Tab(text: context.l10n.lyricsTab),
          Tab(text: vocabLabel),
          Tab(text: structureLabel),
        ],
      );
    }

    return TabBar(
      labelColor: AppColors.sakura,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.sakura,
      tabs: [
        Tab(text: context.l10n.lyricsTab),
        Tab(text: vocabLabel),
        Tab(text: grammarLabel),
        Tab(text: kanjiLabel),
      ],
    );
  }
}
