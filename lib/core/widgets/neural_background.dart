import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';

/// Ambient animated neural-network background canvas.
///
/// Renders a field of drifting nodes connected by glowing edges.
/// Each node traces a smooth Lissajous-like orbit around its base
/// position. The canvas is pointer-transparent so it never blocks
/// any interaction above it.
class NeuralNetworkBackground extends StatefulWidget {
  const NeuralNetworkBackground({super.key});

  @override
  State<NeuralNetworkBackground> createState() =>
      _NeuralNetworkBackgroundState();
}

class _NeuralNetworkBackgroundState extends State<NeuralNetworkBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_NeuralNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // slow ambient loop
    )..repeat();

    final rand = Random(2025); // seeded → stable layout on every render
    _nodes = List.generate(18, (i) {
      return _NeuralNode(
        baseX: rand.nextDouble(),
        baseY: rand.nextDouble(),
        size: 2.2 + rand.nextDouble() * 2.6,
        colorIndex: i % 3,
        phaseX: rand.nextDouble(),
        phaseY: rand.nextDouble(),
        amplitudeX: 0.04 + rand.nextDouble() * 0.06,
        amplitudeY: 0.03 + rand.nextDouble() * 0.05,
        pulsePhase: rand.nextDouble(),
        speedMult: 0.45 + rand.nextDouble() * 0.85,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: _NeuralPainter(
            nodes: _nodes,
            t: _controller.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

// ── Data model ──────────────────────────────────────────────────────────────

class _NeuralNode {
  const _NeuralNode({
    required this.baseX,
    required this.baseY,
    required this.size,
    required this.colorIndex,
    required this.phaseX,
    required this.phaseY,
    required this.amplitudeX,
    required this.amplitudeY,
    required this.pulsePhase,
    required this.speedMult,
  });

  final double baseX;
  final double baseY;
  final double size;
  final int colorIndex;
  final double phaseX;
  final double phaseY;
  final double amplitudeX;
  final double amplitudeY;
  final double pulsePhase;
  final double speedMult;

  double getX(double t) =>
      (baseX + sin(2 * pi * (t * speedMult * 0.4 + phaseX)) * amplitudeX).clamp(
        0.02,
        0.98,
      );

  double getY(double t) =>
      (baseY + cos(2 * pi * (t * speedMult * 0.3 + phaseY)) * amplitudeY).clamp(
        0.02,
        0.98,
      );

  /// Smooth pulsation value in [0, 1].
  double getPulse(double t) =>
      0.5 + 0.5 * sin(2 * pi * (t * speedMult * 0.9 + pulsePhase));
}

// ── Painter ─────────────────────────────────────────────────────────────────

class _NeuralPainter extends CustomPainter {
  const _NeuralPainter({required this.nodes, required this.t});

  final List<_NeuralNode> nodes;
  final double t;

  static const _nodeColors = [
    AppColors.sakura, // warm amber
    AppColors.accent, // cherry blossom pink
    AppColors.peach, // muted blue (peach alias)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final maxDist = size.width * 0.32;

    // Pre-compute screen positions for all nodes.
    final positions = [
      for (final n in nodes)
        Offset(n.getX(t) * size.width, n.getY(t) * size.height),
    ];

    // ── Edges ────────────────────────────────────────────────────────────────
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;

    for (var i = 0; i < nodes.length; i++) {
      for (var j = i + 1; j < nodes.length; j++) {
        final d = (positions[i] - positions[j]).distance;
        if (d >= maxDist) continue;

        final proximity = 1.0 - d / maxDist;
        edgePaint.color = AppColors.textSecondary.withValues(
          alpha: proximity * 0.20, // more visible than default (~15%)
        );
        canvas.drawLine(positions[i], positions[j], edgePaint);
      }
    }

    // ── Nodes ────────────────────────────────────────────────────────────────
    final glowPaint = Paint()..style = PaintingStyle.fill;
    final corePaint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final pos = positions[i];
      final pulse = node.getPulse(t);
      final color = _nodeColors[node.colorIndex];
      final r = node.size;

      // Wide soft glow halo
      glowPaint
        ..color = color.withValues(alpha: 0.14 + 0.12 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(pos, r * 4.0, glowPaint);

      // Tight inner glow
      glowPaint
        ..color = color.withValues(alpha: 0.20 + 0.14 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(pos, r * 2.0, glowPaint);

      // Solid core dot
      glowPaint.maskFilter = null;
      corePaint.color = color.withValues(alpha: 0.38 + 0.24 * pulse);
      canvas.drawCircle(pos, r, corePaint);
    }
  }

  @override
  bool shouldRepaint(_NeuralPainter old) => old.t != t;
}
