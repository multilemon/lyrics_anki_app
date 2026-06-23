import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/grammar_list.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/kanji_list.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/lyrics_error_view.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/lyrics_view.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/musical_note_loading.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/translation_view.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/vocab_list.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

class LyricsTabBarView extends ConsumerWidget {
  const LyricsTabBarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(lyricsProvider);

    return state.when(
      data: (analysis) {
        if (analysis == null) {
          return Center(
            child: Text(
              'No analysis data available.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          );
        }

        final isLoading = !analysis.isComplete;

        return TabBarView(
          children: [
            LyricsView(analysis: analysis),
            TranslationView(
              verses: analysis.verses,
              isLoading: isLoading,
            ),
            VocabList(
              vocabList: analysis.vocabs,
              isLoading: isLoading,
            ),
            GrammarList(
              grammarList: analysis.grammar,
              isLoading: isLoading,
            ),
            KanjiList(
              kanjiList: analysis.kanji,
              isLoading: isLoading,
            ),
          ],
        );
      },
      loading: () => Center(
        child: MusicalNoteLoading(
          message: context.l10n.analysisInProgress,
        ),
      ),
      error: (e, s) {
        return LyricsErrorView(error: e);
      },
    );
  }
}
