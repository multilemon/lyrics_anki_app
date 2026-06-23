import 'package:flutter/material.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
// Add more imports as needed

class ResultCard extends StatefulWidget {
  const ResultCard({
    required this.title,
    required this.isSelected,
    required this.onToggle,
    required this.themeColor,
    super.key,
    this.subtitle,
    this.details,
    this.trailingTag,
    this.leadingContent,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? details;
  final Widget? trailingTag;
  final bool isSelected;
  final VoidCallback onToggle;
  final Color themeColor;
  final Widget? leadingContent;

  @override
  State<ResultCard> createState() => ResultCardState();
}

class ResultCardState extends State<ResultCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  bool _previousSelected = false;

  @override
  void initState() {
    super.initState();
    _previousSelected = widget.isSelected;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.025,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.025,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_pulseController);
  }

  @override
  void didUpdateWidget(ResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger pulse only when selection changes to true
    if (widget.isSelected && !_previousSelected) {
      _pulseController
        ..reset()
        ..forward();
    }
    _previousSelected = widget.isSelected;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final themeColor = widget.themeColor;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? themeColor.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? themeColor.withValues(alpha: 0.4)
                : AppColors.border.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? themeColor.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: isSelected,
                        activeColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (_) => widget.onToggle(),
                      ),
                      if (widget.leadingContent != null) ...[
                        widget.leadingContent!,
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 4,
                        right: 8,
                        bottom: 8,
                        left: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: widget.title),
                              if (widget.trailingTag != null) ...[
                                const SizedBox(width: 8),
                                widget.trailingTag!,
                              ],
                            ],
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 4),
                            widget.subtitle!,
                          ],
                          if (widget.details != null) ...[
                            const SizedBox(height: 8),
                            widget.details!,
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag({required this.label, required this.color, super.key});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.8),
            color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          height: 1,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
