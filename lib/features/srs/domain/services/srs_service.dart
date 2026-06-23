import 'package:lyrics_anki_app/features/srs/domain/entities/srs_card.dart';

enum ReviewQuality {
  again(0, 'Again'),
  hard(2, 'Hard'),
  good(3, 'Good'),
  easy(5, 'Easy')
  ;

  final int value;
  final String label;
  const ReviewQuality(this.value, this.label);
}

class SrsService {
  SrsService();

  static const double minEaseFactor = 1.3;

  /// Implements the SM-2 Spaced Repetition Algorithm
  ///
  /// [quality] is 0-5. We map our Again/Hard/Good/Easy buttons to these values.
  SrsCard calculateNextReview(SrsCard card, ReviewQuality quality) {
    final q = quality.value;

    var newEaseFactor = card.easeFactor;
    var newInterval = card.interval;
    var newRepetitions = card.repetitions;

    if (q >= 3) {
      // Correct response
      if (newRepetitions == 0) {
        newInterval = 1;
      } else if (newRepetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (newInterval * newEaseFactor).round();
      }

      newRepetitions++;

      // Calculate new Ease Factor (E-Factor)
      newEaseFactor = newEaseFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      if (newEaseFactor < minEaseFactor) newEaseFactor = minEaseFactor;
    } else {
      // Incorrect response
      newRepetitions = 0;
      newInterval = 1;
      // Ease factor remains the same for failures in standard SM-2
    }

    final now = DateTime.now();
    return card.copyWith(
      easeFactor: newEaseFactor,
      interval: newInterval,
      repetitions: newRepetitions,
      lastReviewed: now,
      nextReview: now.add(Duration(days: newInterval)),
    );
  }
}
