import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  void _flip() => setState(() => _isFlipped = true);

  Future<void> _next(SrsCard card, ReviewQuality quality) async {
    await ref.read(srsReviewProvider.notifier).rateCard(card, quality);
    if (mounted) {
      setState(() {
        _isFlipped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueCards = ref.watch(srsReviewProvider);

    if (dueCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Session')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, size: 64, color: AppColors.sakura),
              const SizedBox(height: 16),
              Text(
                'All done for today!',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final card = dueCards[0];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Review (\${dueCards.length} left)'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: 1 - (dueCards.length / (dueCards.length + 1)),
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation(AppColors.sakura),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
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
            side: BorderSide(color: color.withValues(alpha: 0.3)),
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
