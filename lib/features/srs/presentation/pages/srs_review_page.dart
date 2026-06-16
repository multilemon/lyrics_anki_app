import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/core/theme/app_text_styles.dart';
import 'package:lyrics_anki_app/features/srs/domain/entities/srs_card.dart';
import 'package:lyrics_anki_app/features/srs/domain/services/srs_service.dart';
import 'package:lyrics_anki_app/features/srs/presentation/providers/srs_review_notifier.dart';

class SrsReviewPage extends ConsumerStatefulWidget {
  const SrsReviewPage({super.key});

  @override
  ConsumerState<SrsReviewPage> createState() => _SrsReviewPageState();
}

class _SrsReviewPageState extends ConsumerState<SrsReviewPage> {
  bool _isFlipped = false;

  // Session tracking
  int _totalReviewed = 0;
  int _totalStartCount = 0;
  int _againCount = 0;
  int _hardCount = 0;
  int _goodCount = 0;
  int _easyCount = 0;
  bool _initialized = false;

  void _flip() => setState(() => _isFlipped = true);

  Future<void> _next(SrsCard card, ReviewQuality quality) async {
    await ref.read(srsReviewProvider.notifier).rateCard(card, quality);
    if (mounted) {
      setState(() {
        _isFlipped = false;
        _totalReviewed++;
        switch (quality) {
          case ReviewQuality.again:
            _againCount++;
          case ReviewQuality.hard:
            _hardCount++;
          case ReviewQuality.good:
            _goodCount++;
          case ReviewQuality.easy:
            _easyCount++;
        }
      });
    }
  }

  Future<void> _suspend(SrsCard card) async {
    await ref.read(srsReviewProvider.notifier).suspendCard(card);
    if (mounted) {
      setState(() {
        _isFlipped = false;
        _totalReviewed++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueCards = ref.watch(srsReviewProvider);

    // Capture starting count on first build
    if (!_initialized && dueCards.isNotEmpty) {
      _totalStartCount = dueCards.length;
      _initialized = true;
    }

    // ─── Session Complete ───
    if (dueCards.isEmpty && _initialized) {
      return _SessionSummary(
        totalReviewed: _totalReviewed,
        againCount: _againCount,
        hardCount: _hardCount,
        goodCount: _goodCount,
        easyCount: _easyCount,
      );
    }

    // ─── Empty (no cards at all) ───
    if (dueCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Session')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.celebration,
                size: 64,
                color: AppColors.sakura,
              ),
              const SizedBox(height: 16),
              Text(
                'Nothing to review yet!',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 8),
              Text(
                'Add words from a song analysis\n'
                'to start building your study list.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final card = dueCards[0];
    final progress = _totalStartCount > 0
        ? _totalReviewed / _totalStartCount
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Review (${dueCards.length} left)'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Suspend button — skip known words
          IconButton(
            icon: const Icon(Icons.visibility_off_outlined),
            tooltip: 'Skip — I know this word',
            onPressed: () => _suspend(card),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation(
              AppColors.sakura,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flashcard
                      _FlashcardContent(
                        card: card,
                        isFlipped: _isFlipped,
                      ),
                      const SizedBox(height: 48),

                      // Action Buttons
                      if (!_isFlipped)
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _flip,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sakura,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Show Answer'),
                          ),
                        )
                      else
                        _QualityButtons(
                          onSelected: (q) => _next(card, q),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  Session Summary — shown after all cards reviewed
// ─────────────────────────────────────────────────────

class _SessionSummary extends StatelessWidget {
  const _SessionSummary({
    required this.totalReviewed,
    required this.againCount,
    required this.hardCount,
    required this.goodCount,
    required this.easyCount,
  });

  final int totalReviewed;
  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;

  @override
  Widget build(BuildContext context) {
    final accuracy = totalReviewed > 0
        ? ((goodCount + easyCount) / totalReviewed * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Session Complete')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 72,
                  color: AppColors.sakura,
                ),
                const SizedBox(height: 16),
                Text(
                  'Great work!',
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You reviewed $totalReviewed cards',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 32),

                // Stats card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Accuracy
                      Text(
                        '$accuracy%',
                        style: AppTextStyles.display.copyWith(
                          color: accuracy >= 80
                              ? AppColors.matcha
                              : accuracy >= 50
                                  ? Colors.orange
                                  : AppColors.error,
                          fontSize: 48,
                        ),
                      ),
                      Text(
                        'Accuracy',
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SummaryStatItem(
                            label: 'Again',
                            count: againCount,
                            color: AppColors.error,
                          ),
                          _SummaryStatItem(
                            label: 'Hard',
                            count: hardCount,
                            color: Colors.orange,
                          ),
                          _SummaryStatItem(
                            label: 'Good',
                            count: goodCount,
                            color: AppColors.matcha,
                          ),
                          _SummaryStatItem(
                            label: 'Easy',
                            count: easyCount,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sakura,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  const _SummaryStatItem({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: AppTextStyles.heading1.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
//  Flashcard Content
// ─────────────────────────────────────────────────────

class _FlashcardContent extends StatelessWidget {
  const _FlashcardContent({
    required this.card,
    required this.isFlipped,
  });

  final SrsCard card;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.sakura.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            card.word,
            style: AppTextStyles.display.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (card.context != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                card.context!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          if (isFlipped) ...[
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              card.reading,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.sakura,
                fontFamily: 'Serif',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card.meaning,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  Quality Rating Buttons
// ─────────────────────────────────────────────────────

class _QualityButtons extends StatelessWidget {
  const _QualityButtons({required this.onSelected});

  final void Function(ReviewQuality) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _Button(
              label: 'Again',
              color: AppColors.error,
              onTap: () => onSelected(ReviewQuality.again),
            ),
            const SizedBox(width: 12),
            _Button(
              label: 'Hard',
              color: Colors.orange,
              onTap: () => onSelected(ReviewQuality.hard),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Button(
              label: 'Good',
              color: AppColors.matcha,
              onTap: () => onSelected(ReviewQuality.good),
            ),
            const SizedBox(width: 12),
            _Button(
              label: 'Easy',
              color: Colors.blue,
              onTap: () => onSelected(ReviewQuality.easy),
            ),
          ],
        ),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 60,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.1),
            foregroundColor: color,
            elevation: 0,
            side: BorderSide(
              color: color.withValues(alpha: 0.3),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
