import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/musical_note_loading.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

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
          // ─── Back button row ───
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AppColors.sakura,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // ─── Song title ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              analysis.song,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontFamily: 'Outfit',
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 6),

          // ─── Artist name ───
          Text(
            analysis.artist,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.sakura,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // ─── Loading state ───
          if (!analysis.isComplete) ...[
            const SizedBox(height: 12),
            MusicalNoteLoading(
              compact: true,
              message: context.l10n.analysisInProgress,
            ),
          ],

          // ─── Stats + Difficulty (only when complete) ───
          if (analysis.isComplete) ...[
            const SizedBox(height: 16),

            // Stats row
            _StatsRow(analysis: analysis),

            const SizedBox(height: 12),

            // Difficulty badge + JLPT bar
            _DifficultySection(analysis: analysis),

            // YouTube button
            if (analysis.youtubeId != null) ...[
              const SizedBox(height: 12),
              _YouTubeButton(youtubeId: analysis.youtubeId!),
            ],
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  Stats Row — "23 vocab · 8 grammar · 12 kanji"
// ─────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.analysis});

  final AnalysisResult analysis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <_StatItem>[
      _StatItem(
        count: analysis.vocabs.length,
        label: 'vocab',
        icon: Icons.translate_rounded,
      ),
      _StatItem(
        count: analysis.grammar.length,
        label: 'grammar',
        icon: Icons.auto_stories_rounded,
      ),
      _StatItem(
        count: analysis.kanji.length,
        label: 'kanji',
        icon: Icons.brush_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 28,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[i].icon,
                    size: 14,
                    color: AppColors.sakura.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${items[i].count}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: ' ${items[i].label}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.count,
    required this.label,
    required this.icon,
  });

  final int count;
  final String label;
  final IconData icon;
}

// ─────────────────────────────────────────────────────
//  Difficulty Section — Badge + JLPT Breakdown Bar
// ─────────────────────────────────────────────────────

class _DifficultySection extends StatelessWidget {
  const _DifficultySection({required this.analysis});

  final AnalysisResult analysis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difficulty = analysis.difficulty;
    final dist = SongDifficulty.jlptDistributionOf(
      analysis.vocabs,
      analysis.kanji,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          // ─── Badge row ───
          Row(
            children: [
              // Difficulty badge
              _DifficultyBadge(difficulty: difficulty),

              const Spacer(),

              // Score label
              Text(
                'JLPT Breakdown',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ─── Stacked bar chart ───
          _JlptBarChart(distribution: dist),

          const SizedBox(height: 8),

          // ─── Legend ───
          _JlptLegend(distribution: dist),
        ],
      ),
    );
  }
}

// ─── Difficulty Badge ───

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final SongDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (label, color, icon) = switch (difficulty) {
      SongDifficulty.beginner => (
          'Beginner-friendly',
          AppColors.success,
          Icons.sentiment_satisfied_alt_rounded,
        ),
      SongDifficulty.intermediate => (
          'Intermediate',
          AppColors.sakura,
          Icons.trending_up_rounded,
        ),
      SongDifficulty.advanced => (
          'Advanced',
          AppColors.accent,
          Icons.local_fire_department_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── JLPT Stacked Bar Chart ───

const _jlptColors = {
  'N5': Color(0xFF6BCB77), // Green
  'N4': Color(0xFF97D98F), // Light green
  'N3': Color(0xFFE8A87C), // Amber (sakura)
  'N2': Color(0xFFD4749C), // Pink (accent)
  'N1': Color(0xFFE06060), // Red
};

class _JlptBarChart extends StatelessWidget {
  const _JlptBarChart({required this.distribution});

  final Map<String, int> distribution;

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (s, v) => s + v);
    if (total == 0) {
      return Container(
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(5),
        ),
      );
    }

    // Build segments
    final segments = <_BarSegment>[];
    for (final level in ['N5', 'N4', 'N3', 'N2', 'N1']) {
      final count = distribution[level] ?? 0;
      if (count > 0) {
        segments.add(
          _BarSegment(
            fraction: count / total,
            color: _jlptColors[level]!,
          ),
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            for (var i = 0; i < segments.length; i++)
              Flexible(
                flex: (segments[i].fraction * 1000).round(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: segments[i].color,
                    borderRadius: BorderRadius.horizontal(
                      left: i == 0 ? const Radius.circular(5) : Radius.zero,
                      right: i == segments.length - 1
                          ? const Radius.circular(5)
                          : Radius.zero,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BarSegment {
  const _BarSegment({
    required this.fraction,
    required this.color,
  });

  final double fraction;
  final Color color;
}

// ─── JLPT Legend ───

class _JlptLegend extends StatelessWidget {
  const _JlptLegend({required this.distribution});

  final Map<String, int> distribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = distribution.values.fold(0, (s, v) => s + v);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final level in ['N5', 'N4', 'N3', 'N2', 'N1'])
          _LegendItem(
            level: level,
            count: distribution[level] ?? 0,
            total: total,
            color: _jlptColors[level]!,
            theme: theme,
          ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.level,
    required this.count,
    required this.total,
    required this.color,
    required this.theme,
  });

  final String level;
  final int count;
  final int total;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    final isActive = count > 0;

    return Opacity(
      opacity: isActive ? 1.0 : 0.35,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                level,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          Text(
            '$pct%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textTertiary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── YouTube Button ───

class _YouTubeButton extends StatelessWidget {
  const _YouTubeButton({required this.youtubeId});

  final String youtubeId;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        final url = Uri.parse(
          'https://www.youtube.com/watch?v=$youtubeId',
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        }
      },
      icon: const Icon(Icons.smart_display_rounded, size: 18),
      label: const Text('Watch on YouTube'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.sakura,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.sakura),
        ),
      ),
    );
  }
}
