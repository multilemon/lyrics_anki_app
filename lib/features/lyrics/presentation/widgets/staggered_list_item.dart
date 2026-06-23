import 'dart:math';

import 'package:flutter/material.dart';

/// Wraps a child widget with a staggered slide-up + fade-in entrance animation.
///
/// Use [index] to control the stagger delay — each subsequent item
/// appears 30ms after the previous one, capped at 500ms total delay.
class StaggeredListItem extends StatefulWidget {
  const StaggeredListItem({
    required this.index,
    required this.child,
    super.key,
  });

  /// The position of this item in the list, used to calculate stagger delay.
  final int index;

  /// The actual content to display.
  final Widget child;

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
          ),
        );

    // Stagger delay: 30ms per index, capped at 500ms
    final delay = Duration(
      milliseconds: min(widget.index * 30, 500),
    );

    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
