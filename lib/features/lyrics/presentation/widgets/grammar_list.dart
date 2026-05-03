import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/result_card.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/staggered_list_item.dart';
// Add more imports as needed

class GrammarList extends StatefulWidget {
  const GrammarList(
      {required this.grammarList, required this.isLoading, super.key});
  final List<Grammar> grammarList;
  final bool isLoading;

  @override
  State<GrammarList> createState() => GrammarListState();
}

class GrammarListState extends State<GrammarList>
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
          child: GrammarItem(
            index: index,
            grammar: widget.grammarList[index],
          ),
        );
      },
    );
  }
}

class GrammarItem extends ConsumerWidget {
  const GrammarItem({required this.index, required this.grammar, super.key});

  final int index;
  final Grammar grammar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSelected = ref.watch(
      selectionManagerProvider.select((s) => s.grammarIndices.contains(index)),
    );

    return ResultCard(
      title: Text(
        grammar.point,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            grammar.explanation,
            style: theme.textTheme.bodyMedium,
          ),
          if (grammar.usage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Usage: ${grammar.usage}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
      trailingTag: grammar.level.trim().isNotEmpty
          ? Tag(
              label: grammar.level,
              color: AppColors.sakura,
            )
          : const Tag(label: 'Other', color: AppColors.textTertiary),
      isSelected: isSelected,
      onToggle: () {
        ref
            .read(selectionManagerProvider.notifier)
            .toggle(SelectionType.grammar, index);
      },
      themeColor: AppColors.matcha, // Use matcha for Grammar
    );
  }
}
