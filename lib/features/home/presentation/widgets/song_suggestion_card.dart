import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';

/// A delicate, animated empty-state widget for the home page.
///
/// Shows a floating music-note illustration with decorative sparkles
/// and a curated list of beginner-friendly song suggestions.
class SongSuggestionCard extends StatefulWidget {
  const SongSuggestionCard({
    required this.onSuggestionTap,
    super.key,
  });

  /// Called when the user taps a suggestion chip.
  /// Provides (title, artist) for the selected song.
  final void Function(String title, String artist) onSuggestionTap;

  @override
  State<SongSuggestionCard> createState() => _SongSuggestionCardState();
}

class _SongSuggestionCardState extends State<SongSuggestionCard>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _fadeController;
  late final AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ─── Illustration ───
            _FloatingIllustration(
              floatController: _floatController,
              sparkleController: _sparkleController,
            ),

            const SizedBox(height: 24),

            // ─── Message ───
            Text(
              'Search for a Japanese song\nto start learning!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // ─── "Try these" label ───
            Row(
              children: [
                Container(
                  width: 20,
                  height: 1,
                  color: AppColors.sakura.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 10),
                Text(
                  'Try these songs',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.sakura.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.sakura.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─── Song Suggestion Chips ───
            ..._kSuggestions.asMap().entries.map(
              (entry) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(
                    milliseconds: 600 + (entry.key * 150),
                  ),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key < _kSuggestions.length - 1 ? 10 : 0,
                    ),
                    child: _SuggestionTile(
                      suggestion: entry.value,
                      onTap: () => widget.onSuggestionTap(
                        entry.value.title,
                        entry.value.artist,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Data
// ─────────────────────────────────────────────

class _SongSuggestion {
  const _SongSuggestion({
    required this.title,
    required this.artist,
    required this.artistJa,
    required this.difficulty,
    required this.icon,
  });

  final String title;
  final String artist;
  final String artistJa;
  final String difficulty; // e.g. "Beginner", "Intermediate"
  final IconData icon;
}

const _kSuggestions = [
  _SongSuggestion(
    title: 'Lemon',
    artist: 'Kenshi Yonezu',
    artistJa: '米津玄師',
    difficulty: 'Intermediate',
    icon: Icons.music_note_rounded,
  ),
  _SongSuggestion(
    title: '夜に駆ける',
    artist: 'YOASOBI',
    artistJa: 'YOASOBI',
    difficulty: 'Intermediate',
    icon: Icons.nightlife_rounded,
  ),
  _SongSuggestion(
    title: 'さくら (独唱)',
    artist: 'Naotaro Moriyama',
    artistJa: '森山直太朗',
    difficulty: 'Beginner',
    icon: Icons.local_florist_rounded,
  ),
];

// ─────────────────────────────────────────────
//  Suggestion Tile
// ─────────────────────────────────────────────

class _SuggestionTile extends StatefulWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.onTap,
  });

  final _SongSuggestion suggestion;
  final VoidCallback onTap;

  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = widget.suggestion;

    final isBeginnerFriendly = s.difficulty == 'Beginner';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _hovering
            ? AppColors.sakura.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hovering
              ? AppColors.sakura.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: widget.onTap,
          onHover: (v) => setState(() => _hovering = v),
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.sakura.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                // Icon circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.sakura.withValues(alpha: 0.2),
                        AppColors.accent.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                  child: Icon(
                    s.icon,
                    size: 20,
                    color: AppColors.sakura,
                  ),
                ),
                const SizedBox(width: 14),

                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${s.artistJa}  ·  ${s.artist}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Difficulty badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isBeginnerFriendly
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.sakura.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    s.difficulty,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isBeginnerFriendly
                          ? AppColors.success
                          : AppColors.sakura,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Arrow
                Icon(
                  Icons.play_arrow_rounded,
                  size: 18,
                  color: AppColors.sakura.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Floating Illustration
// ─────────────────────────────────────────────

class _FloatingIllustration extends StatelessWidget {
  const _FloatingIllustration({
    required this.floatController,
    required this.sparkleController,
  });

  final AnimationController floatController;
  final AnimationController sparkleController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow
          Positioned.fill(
            child: AnimatedBuilder(
              animation: floatController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sakura.withValues(
                          alpha:
                              0.06 +
                              0.04 *
                                  Curves.easeInOut.transform(
                                    floatController.value,
                                  ),
                        ),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Sparkles
          ..._buildSparkles(),

          // Main floating note
          AnimatedBuilder(
            animation: floatController,
            builder: (context, child) {
              final bounce = Curves.easeInOut.transform(floatController.value);
              return Transform.translate(
                offset: Offset(0, -8 * bounce),
                child: child,
              );
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.sakura, AppColors.accent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sakura.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),

          // Small secondary note (floating offset)
          AnimatedBuilder(
            animation: floatController,
            builder: (context, child) {
              final bounce = Curves.easeInOut.transform(floatController.value);
              return Positioned(
                right: 30,
                top: 15 + 5 * bounce,
                child: Opacity(
                  opacity: 0.6,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      size: 14,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              );
            },
          ),

          // Tiny tertiary note
          AnimatedBuilder(
            animation: floatController,
            builder: (context, child) {
              final bounce = Curves.easeInOut.transform(floatController.value);
              return Positioned(
                left: 40,
                bottom: 10 + 4 * (1 - bounce),
                child: Opacity(
                  opacity: 0.4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.sakuraLight.withValues(alpha: 0.3),
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      size: 10,
                      color: AppColors.sakuraLight,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles() {
    const sparklePositions = [
      Offset(-60, -20),
      Offset(65, -10),
      Offset(-40, 30),
      Offset(50, 35),
      Offset(0, -45),
    ];

    return sparklePositions.asMap().entries.map((entry) {
      final index = entry.key;
      final pos = entry.value;
      final phaseOffset = index * 0.2;

      return Positioned(
        left: 100 + pos.dx,
        top: 60 + pos.dy,
        child: AnimatedBuilder(
          animation: sparkleController,
          builder: (context, child) {
            final t = (sparkleController.value + phaseOffset) % 1.0;
            // Pulse: fade in then out
            final opacity = (sin(t * pi * 2) * 0.5 + 0.5).clamp(0.0, 1.0);
            final scale = 0.6 + 0.4 * opacity;

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity * 0.7,
                child: Icon(
                  Icons.auto_awesome,
                  size: 12 + (index % 3) * 2.0,
                  color: index.isEven
                      ? AppColors.sakuraLight
                      : AppColors.accent.withValues(alpha: 0.8),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }
}
