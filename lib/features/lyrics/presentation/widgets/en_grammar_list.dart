import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/result_card.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/staggered_list_item.dart';
// Add more imports as needed

class EnGrammarList extends StatefulWidget {
  const EnGrammarList(
      {required this.grammarList, required this.isLoading, super.key});
  final List<EnGrammar> grammarList;
  final bool isLoading;

  @override
  State<EnGrammarList> createState() => EnGrammarListState();
}

class EnGrammarListState extends State<EnGrammarList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    if (widget.grammarList.isEmpty) {
      if (widget.isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.matcha),
        );
      }
      return Center(
        child: Text(
          'No grammar points found.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: AppColors.textTertiary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88, left: 16, right: 16),
      cacheExtent: 100,
      itemCount: widget.grammarList.length,
      itemBuilder: (context, index) {
        return StaggeredListItem(
          index: index,
          child: EnGrammarItem(
            index: index,
            grammar: widget.grammarList[index],
          ),
        );
      },
    );
  }
}

class EnGrammarItem extends ConsumerWidget {
  const EnGrammarItem({required this.index, required this.grammar, super.key});

  final int index;
  final EnGrammar grammar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSelected = ref.watch(
      selectionManagerProvider.select((s) => s.grammarIndices.contains(index)),
    );

    return ResultCard(
      title: Text(
        grammar.structure,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            grammar.explanationJp,
            style: theme.textTheme.bodyMedium,
          ),
          if (grammar.excerpt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Excerpt: "${grammar.excerpt}"',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
      trailingTag: grammar.cefrLevel.trim().isNotEmpty
          ? Tag(
              label: grammar.cefrLevel,
              color: AppColors.sakura,
            )
          : const Tag(label: 'Other', color: AppColors.textTertiary),
      isSelected: isSelected,
      onToggle: () {
        ref
            .read(selectionManagerProvider.notifier)
            .toggle(SelectionType.grammar, index);
      },
      themeColor: AppColors.matcha,
    );
  }
}
