import 'package:flutter/material.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';

/// Animates [text] character-by-character with a trailing sakura-coloured
/// neural glow, creating a "data materialisation" effect.
///
/// Each character fades in from transparent to full opacity while a bright
/// scan-glow sweeps left-to-right across the frontier of revealed text.
class AnimatedRevealText extends StatefulWidget {
  const AnimatedRevealText({
    required this.text,
    required this.style,
    super.key,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 900),
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextStyle? style;
  final Duration delay;
  final Duration duration;
  final TextAlign textAlign;

  @override
  State<AnimatedRevealText> createState() => _AnimatedRevealTextState();
}

class _AnimatedRevealTextState extends State<AnimatedRevealText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.text.characters.toList();
    final n = chars.length;
    if (n == 0) return Text(widget.text, style: widget.style);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Text.rich(
          TextSpan(
            children: [
              for (var i = 0; i < n; i++) _buildCharSpan(chars[i], i, n),
            ],
          ),
          style: widget.style,
          textAlign: widget.textAlign,
        );
      },
    );
  }

  TextSpan _buildCharSpan(String char, int index, int total) {
    // Each character's reveal window is staggered over the first 70% of the
    // animation; the reveal itself takes 35% of the total duration.
    final start = (index / total) * 0.65;
    final end = (start + 0.35).clamp(0.0, 1.0);
    final charT = ((_controller.value - start) / (end - start)).clamp(0.0, 1.0);
    final opacity = Curves.easeOut.transform(charT);

    // "Scan glow": chars near the current reveal frontier receive a temporary
    // sakura halo that dims as they fully appear.
    final scanPos = _controller.value * total;
    final distFromScan = (scanPos - index).abs();
    final glowStrength =
        (1.0 - (distFromScan / 1.6).clamp(0.0, 1.0)) *
        (opacity > 0.02 ? 1.0 : 0.0) *
        (1.0 - opacity); // halo fades as char solidifies

    final baseColor = widget.style?.color ?? AppColors.textPrimary;

    return TextSpan(
      text: char,
      style: TextStyle(
        color: baseColor.withValues(alpha: opacity.clamp(0.0, 1.0)),
        shadows: glowStrength > 0.06
            ? [
                Shadow(
                  color: AppColors.sakura.withValues(
                    alpha: (glowStrength * 0.75).clamp(0.0, 1.0),
                  ),
                  blurRadius: 18,
                ),
                Shadow(
                  color: AppColors.sakuraLight.withValues(
                    alpha: (glowStrength * 0.35).clamp(0.0, 1.0),
                  ),
                  blurRadius: 32,
                ),
              ]
            : [],
      ),
    );
  }
}
