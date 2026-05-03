import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/learning_mode.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/result_card.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/staggered_list_item.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';
// Add more imports as needed

class EnVocabList extends StatefulWidget {
  const EnVocabList(
      {required this.vocabList, required this.isLoading, super.key});
  final List<EnVocab> vocabList;
  final bool isLoading;

  @override
  State<EnVocabList> createState() => EnVocabListState();
}

class EnVocabListState extends State<EnVocabList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    if (widget.vocabList.isEmpty) {
      if (widget.isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.sakura),
        );
      }
      return Center(
        child: Text(
          'No vocabulary found.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: AppColors.textTertiary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88, left: 16, right: 16),
      cacheExtent: 100,
      itemCount: widget.vocabList.length,
      itemBuilder: (context, index) {
        return StaggeredListItem(
          index: index,
          child: EnVocabItem(
            index: index,
            vocab: widget.vocabList[index],
          ),
        );
      },
    );
  }
}

class EnVocabItem extends ConsumerWidget {
  const EnVocabItem({required this.index, required this.vocab, super.key});

  final int index;
  final EnVocab vocab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSelected = ref.watch(
      selectionManagerProvider.select((s) => s.vocabIndices.contains(index)),
    );

    // Get the current learning mode to decide label (IPA vs Romanization)
    final box = ref.read(settingsBoxProvider);
    final savedModeIndex = box?.get('learning_mode_index');
    final isKorean = savedModeIndex == LearningMode.korean.index;

    return ResultCard(
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: vocab.term,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (vocab.pos.isNotEmpty) ...[
              const WidgetSpan(child: SizedBox(width: 8)),
              TextSpan(
                text: '[${vocab.pos}]',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.sakura,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IPA / Romanization Line
          if (vocab.ipa.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: isKorean
                          ? '${context.l10n.romanizationType}: '
                          : '${context.l10n.ipaType}: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: vocab.ipa,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontFamily: isKorean ? null : 'IpaFont',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Text(
            vocab.meaningJp,
            style: theme.textTheme.bodyMedium,
          ),
          if (vocab.nuanceJp.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Note: ${vocab.nuanceJp}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      trailingTag:
          const SizedBox.shrink(), // No JLPT tag for English/Korean yet
      isSelected: isSelected,
      onToggle: () {
        ref
            .read(selectionManagerProvider.notifier)
            .toggle(SelectionType.vocab, index);
      },
      themeColor: AppColors.sakura,
    );
  }
}
