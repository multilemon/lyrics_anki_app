import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';

/// A delicate loading animation that floats musical notes upward
/// in a sine wave pattern, using the HanaUta sakura palette.
///
/// Use [compact] mode for inline indicators (e.g., partial-result state).
class MusicalNoteLoading extends StatefulWidget {
  const MusicalNoteLoading({
    super.key,
    this.message,
    this.compact = false,
  });

  /// Optional text displayed below the animation.
  final String? message;

  /// If true, renders a smaller version suitable for inline use.
  final bool compact;

  @override
  State<MusicalNoteLoading> createState() => _MusicalNoteLoadingState();
}

class _MusicalNoteLoadingState extends State<MusicalNoteLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? 60.0 : 120.0;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size * 2,
          height: size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _NotesPainter(
                  progress: _controller.value,
                  compact: widget.compact,
                ),
              );
            },
          ),
        ),
        if (widget.message != null) ...[
          SizedBox(height: widget.compact ? 8 : 16),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Gentle opacity pulse on the text
              final opacity = 0.5 + 0.5 * sin(_controller.value * 2 * pi);
              return Opacity(
                opacity: opacity.clamp(0.4, 1.0),
                child: child,
              );
            },
            child: Text(
              widget.message!,
              textAlign: TextAlign.center,
              style: (widget.compact
                      ? theme.textTheme.bodySmall
                      : theme.textTheme.bodyMedium)
                  ?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Paints floating musical notes in a sine wave pattern.
class _NotesPainter extends CustomPainter {
  _NotesPainter({
    required this.progress,
    required this.compact,
  });

  final double progress;
  final bool compact;

  static const _notes = ['♩', '♪', '♫', '♬', '♪', '♫', '♩'];

  static const List<Color> _colors = [
    AppColors.sakura,
    AppColors.accent,
    AppColors.accentLight,
    AppColors.peach,
    AppColors.sakura,
    AppColors.accent,
    AppColors.matcha,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final noteCount = compact ? 4 : _notes.length;
    final baseFontSize = compact ? 16.0 : 24.0;

    for (var i = 0; i < noteCount; i++) {
      // Each note has a phase offset for staggering
      final phase = (progress + i / noteCount) % 1.0;

      // Vertical: float upward (bottom → top)
      final y = size.height * (1.0 - phase);

      // Horizontal: gentle sine wave drift
      final xCenter = size.width / 2;
      final xAmplitude = size.width * (compact ? 0.2 : 0.3);
      final sineOffset = sin(phase * 2 * pi + i * 1.2);
      final x = xCenter + xAmplitude * sineOffset;

      // Opacity: fade in at bottom, fade out at top
      final fadeIn = (phase * 3).clamp(0.0, 1.0);
      final fadeOut = ((1.0 - phase) * 3).clamp(0.0, 1.0);
      final opacity = (fadeIn * fadeOut).clamp(0.0, 1.0);

      // Slight size variation for depth
      final scale = 0.7 + 0.3 * sin(phase * pi);
      final fontSize = baseFontSize * scale;

      final textPainter = TextPainter(
        text: TextSpan(
          text: _notes[i % _notes.length],
          style: TextStyle(
            fontSize: fontSize,
            color: _colors[i % _colors.length].withValues(alpha: opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_NotesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
