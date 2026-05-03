import 'dart:io';

void main() {
  final file = File('lib/features/lyrics/presentation/pages/lyrics_page.dart');
  final lines = file.readAsLinesSync();
  
  // 1. Extract Header
  int headerStart = lines.indexWhere((l) => l.contains('// Song Title & Artist Header'));
  int headerEnd = lines.indexWhere((l) => l.contains('// Filters (Quick Select)')) - 1;
  while(lines[headerEnd].trim().isEmpty) headerEnd--;

  // 2. Extract Filters
  int filterStart = lines.indexWhere((l) => l.contains('// Filters (Quick Select)'));
  int filterEnd = lines.indexWhere((l) => l.contains('// Tabs')) - 1;
  while(lines[filterEnd].trim().isEmpty) filterEnd--;

  // Write LyricsHeader
  final headerContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/musical_note_loading.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

class LyricsHeader extends ConsumerWidget {
  const LyricsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(lyricsProvider).asData?.value;
    if (analysis == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            analysis.song,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            analysis.artist,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (!analysis.isComplete) ...[
            const SizedBox(height: 12),
            MusicalNoteLoading(
              compact: true,
              message: context.l10n.analysisInProgress,
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
''';
  File('lib/features/lyrics/presentation/widgets/lyrics_header.dart').writeAsStringSync(headerContent);

  // Quick Select Filters
  // We need to rewrite it slightly as a separate widget
  var filterLines = lines.sublist(filterStart + 1, filterEnd + 1).join('\n');
  final filterContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/home/presentation/providers/home_ui_providers.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/learning_mode.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

class QuickSelectFilters extends ConsumerWidget {
  const QuickSelectFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    $filterLines
  }
}

class FilterChip extends StatelessWidget {
  const FilterChip({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
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
      selectedColor: AppColors.sakuraDark,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: value ? Colors.white : AppColors.textSecondary,
        fontWeight: value ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: value ? AppColors.sakuraDark : Colors.grey[300]!,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
''';
  // Note: the filter lines originally contain `_FilterChip`, so we must rename `_FilterChip` to `FilterChip` in filterLines
  final finalFilterContent = filterContent.replaceAll('_FilterChip', 'FilterChip');
  File('lib/features/lyrics/presentation/widgets/quick_select_filters.dart').writeAsStringSync(finalFilterContent);

  print('Generated header: \${headerStart} to \${headerEnd}');
  print('Generated filters: \${filterStart} to \${filterEnd}');
}
