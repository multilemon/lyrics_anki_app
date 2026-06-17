import 'package:flutter/material.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';

/// A full-width gradient CTA button that emits concentric synaptic pulse
/// rings on press, giving tactile "neural fire" feedback.
///
/// On press-down the button scales to 96 %. On release it springs back
/// while two expanding sakura/accent ring waves propagate outward beyond
/// the button bounds ([Stack.clipBehavior] is [Clip.none]).
class NeuralPulseButton extends StatefulWidget {
  const NeuralPulseButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  State<NeuralPulseButton> createState() => _NeuralPulseButtonState();
}

class _NeuralPulseButtonState extends State<NeuralPulseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    _pulseController.forward(from: 0);
    widget.onPressed();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final pulseRadius = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    final pulseOpacity = Tween<double>(begin: 0.60, end: 0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeIn),
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none, // let rings overflow button bounds
            alignment: Alignment.center,
            children: [
              // Synaptic pulse rings drawn behind the button surface
              Positioned.fill(
                child: CustomPaint(
                  painter: _PulsePainter(
                    radius: pulseRadius.value,
                    opacity: pulseOpacity.value,
                  ),
                ),
              ),
              // Button body with spring-scale on press
              AnimatedScale(
                scale: _pressed ? 0.96 : 1.0,
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeOut,
                child: child!,
              ),
            ],
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [AppColors.sakura, AppColors.accent],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.sakura.withValues(alpha: 0.38),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pulse ring painter ───────────────────────────────────────────────────────

class _PulsePainter extends CustomPainter {
  const _PulsePainter({required this.radius, required this.opacity});

  final double radius;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || radius <= 0) return;

    final center = size.center(Offset.zero);
    final maxR = size.longestSide * 1.25;

    // Primary sakura ring
    canvas.drawCircle(
      center,
      radius * maxR,
      Paint()
        ..color = AppColors.sakura.withValues(alpha: opacity * 0.70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Secondary accent ring (slightly behind primary)
    if (radius > 0.12) {
      final r2 = (radius - 0.10).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        r2 * maxR,
        Paint()
          ..color = AppColors.accent.withValues(alpha: opacity * 0.40)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    // Tertiary ghost ring (earliest/largest)
    if (radius > 0.25) {
      final r3 = (radius - 0.22).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        r3 * maxR,
        Paint()
          ..color = AppColors.sakuraLight.withValues(alpha: opacity * 0.20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(_PulsePainter old) =>
      old.radius != radius || old.opacity != opacity;
}
