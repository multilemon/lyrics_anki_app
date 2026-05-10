import 'package:lyrics_anki_app/features/srs/data/repositories/hive_srs_repository.dart';
import 'package:lyrics_anki_app/features/srs/domain/entities/srs_card.dart';
import 'package:lyrics_anki_app/features/srs/domain/services/srs_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'srs_review_notifier.g.dart';

@riverpod
class SrsReviewNotifier extends _$SrsReviewNotifier {
  final _srsService = SrsService();

  @override
  List<SrsCard> build() {
    return ref.read(srsRepositoryProvider).getDueCards();
  }

  void refresh() {
    state = ref.read(srsRepositoryProvider).getDueCards();
  }

  Future<void> rateCard(SrsCard card, ReviewQuality quality) async {
    final updatedCard = _srsService.calculateNextReview(card, quality);
    await ref.read(srsRepositoryProvider).saveCard(updatedCard);
    
    // Remove from current session list
    state = state.where((c) => c.word != card.word).toList();
  }

  Future<void> suspendCard(SrsCard card) async {
    final updatedCard = card.copyWith(isSuspended: true);
    await ref.read(srsRepositoryProvider).saveCard(updatedCard);
    state = state.where((c) => c.word != card.word).toList();
  }
}

@riverpod
Map<String, dynamic> srsStats(Ref ref) {
  // Listen to the stream and invalidate this provider when the repository changes
  final sub = ref.read(srsRepositoryProvider).watchCards().listen((_) {
    ref.invalidateSelf();
  });
  ref.onDispose(sub.cancel);

  return ref.read(srsRepositoryProvider).getStats();
}
