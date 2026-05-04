import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/home/presentation/pages/home_page.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/main/presentation/pages/main_page.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

class LyricsErrorView extends ConsumerWidget {
  const LyricsErrorView({
    required this.error,
    super.key,
  });

  final Object error;

  void _goBack(WidgetRef ref, {bool clearForm = false}) {
    if (clearForm) {
      ref.read(clearHomeFormSignalProvider.notifier).increment();
    }
    ref.read(navIndexProvider.notifier).index = 0;
    ref.invalidate(lyricsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final e = error;

    if (e is SongNotFoundException) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Text(
                context.l10n.songNotFound,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.songNotFoundMessage(
                  e.title,
                  e.artist,
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _goBack(ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sakura,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.edit_rounded,
                ),
                label: const Text('Edit Search'),
              ),
            ],
          ),
        ),
      );
    }

    if (e is ServerOverloadedException) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.sakura,
              ),
              const SizedBox(height: 16),
              Text(
                'AI is Busy',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The AI service is currently overloaded (503).\n'
                'This happens with the Free Tier.\n'
                'Please wait a moment and try again.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _goBack(ref),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.sakura,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(lyricsProvider.notifier).retry();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sakura,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (e is QuotaExceededException) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_empty_rounded,
                size: 48,
                color: AppColors.sakura,
              ),
              const SizedBox(height: 16),
              Text(
                'Daily Limit Reached',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You've hit the daily usage limit for the free AI tier.\n"
                'Please try again tomorrow.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _goBack(ref),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sakura,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // General Error Handling
    final errorMsg = e.toString();
    final isNotJapanese = errorMsg.contains(
      'not appear to be primarily in Japanese',
    );
    final isJsonError = errorMsg.contains('JSON Parse Error') ||
        errorMsg.contains('FormatException');
    final isLyricsNotFound = errorMsg.contains(
      'LYRICS_NOT_FOUND',
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNotJapanese
                ? Icons.translate_rounded
                : isLyricsNotFound
                    ? Icons.library_music_rounded
                    : Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            isNotJapanese
                ? 'Language Mismatch'
                : isLyricsNotFound
                    ? 'Lyrics Unavailable'
                    : 'Analysis Failed',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
            ),
            child: Text(
              isJsonError
                  ? 'Sometimes AI makes a mistake.\n'
                      'Please try again.'
                  : isLyricsNotFound
                      ? 'The AI could not find the full official lyrics '
                          'for this song.\n'
                          'Please try a different song or artist variation.'
                      : errorMsg.replaceAll(
                          'Exception: ',
                          '',
                        ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 32),
          if (isNotJapanese || isLyricsNotFound)
            ElevatedButton.icon(
              onPressed: () => _goBack(ref),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sakura,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _goBack(ref),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.sakura,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(lyricsProvider.notifier).retry();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Analysis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sakura,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
