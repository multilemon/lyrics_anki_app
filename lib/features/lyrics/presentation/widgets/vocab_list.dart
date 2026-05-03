import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/result_card.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/staggered_list_item.dart';
// Add more imports as needed

class VocabList extends StatefulWidget {
  const VocabList(
      {required this.vocabList, required this.isLoading, super.key});
  final List<Vocab> vocabList;
  final bool isLoading;

  @override
  State<VocabList> createState() => VocabListState();
}

class VocabListState extends State<VocabList>
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
          child: VocabItem(
            index: index,
            vocab: widget.vocabList[index],
          ),
        );
      },
    );
  }
}

class VocabItem extends ConsumerWidget {
  const VocabItem({required this.index, required this.vocab, super.key});

  final int index;
  final Vocab vocab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSelected = ref.watch(
      selectionManagerProvider.select((s) => s.vocabIndices.contains(index)),
    );

    return ResultCard(
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: vocab.word,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (vocab.partOfSpeech.isNotEmpty) ...[
              const WidgetSpan(child: SizedBox(width: 8)),
              TextSpan(
                text: '[${vocab.partOfSpeech}]',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.sakura,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const WidgetSpan(child: SizedBox(width: 8)),
            TextSpan(
              text: vocab.reading,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vocab.meaning,
            style: theme.textTheme.bodyMedium,
          ),
          if (vocab.context.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                vocab.context,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          if (vocab.nuanceNote.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Note: ${vocab.nuanceNote}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      trailingTag: vocab.jlptV.trim().isNotEmpty
          ? Tag(
              label: vocab.jlptV,
              color: AppColors.sakura,
            )
          : const Tag(
              label: 'Other',
              color: AppColors.textTertiary,
            ),
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
