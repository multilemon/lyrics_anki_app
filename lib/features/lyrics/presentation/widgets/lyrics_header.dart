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
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AppColors.sakura,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 8),
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
        ],
      ),
    );
  }
}
