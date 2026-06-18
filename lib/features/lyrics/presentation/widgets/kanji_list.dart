import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/result_card.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/staggered_list_item.dart';
// Add more imports as needed

import 'package:lyrics_anki_app/core/utils/jlpt_utils.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/jlpt_level_notifier.dart';

class KanjiList extends ConsumerStatefulWidget {
  const KanjiList({
    required this.kanjiList,
    required this.isLoading,
    super.key,
  });
  final List<Kanji> kanjiList;
  final bool isLoading;

  @override
  ConsumerState<KanjiList> createState() => KanjiListState();
}

class KanjiListState extends ConsumerState<KanjiList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final jlptLevel = ref.watch(jlptLevelProvider);

    final filteredItems = <MapEntry<int, Kanji>>[];
    for (var i = 0; i < widget.kanjiList.length; i++) {
      final kanji = widget.kanjiList[i];
      if (shouldShowJlpt(kanji.level, jlptLevel)) {
        filteredItems.add(MapEntry(i, kanji));
      }
    }

    if (filteredItems.isEmpty) {
      if (widget.isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        );
      }
      return Center(
        child: Text(
          'No kanji found.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88, left: 16, right: 16),
      cacheExtent: 100,
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final entry = filteredItems[index];
        return StaggeredListItem(
          index: index,
          child: KanjiItem(
            index: entry.key,
            kanji: entry.value,
          ),
        );
      },
    );
  }
}

class KanjiItem extends ConsumerWidget {
  const KanjiItem({required this.index, required this.kanji, super.key});

  final int index;
  final Kanji kanji;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSelected = ref.watch(
      selectionManagerProvider.select((s) => s.kanjiIndices.contains(index)),
    );

    return ResultCard(
      leadingContent: CircleAvatar(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.textPrimary,
        child: Text(kanji.char, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(
        kanji.meanings,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        kanji.readings
            .split('|')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .join(' ｜ '),
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      trailingTag: kanji.level.trim().isNotEmpty
          ? Tag(
              label: kanji.level,
              color: AppColors.sakura,
            )
          : const Tag(label: 'Other', color: AppColors.textTertiary),
      isSelected: isSelected,
      onToggle: () {
        ref
            .read(selectionManagerProvider.notifier)
            .toggle(SelectionType.kanji, index);
      },
      themeColor: const Color(0xFF8D6E63), // Brown for Kanji
    );
  }
}
