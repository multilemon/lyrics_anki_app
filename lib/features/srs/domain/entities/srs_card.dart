import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'srs_card.freezed.dart';
part 'srs_card.g.dart';

@freezed
@HiveType(typeId: 4)
abstract class SrsCard with _$SrsCard {
  const factory SrsCard({
    @HiveField(0) required String word,
    @HiveField(1) required String reading,
    @HiveField(2) required String meaning,
    @HiveField(9) required DateTime nextReview,
    @HiveField(10) required DateTime lastReviewed,
    @HiveField(3) String? songTitle,
    @HiveField(4) String? artist,
    @HiveField(5) String? context,
    @HiveField(6) @Default(2.5) double easeFactor,
    @HiveField(7) @Default(0) int interval, // in days
    @HiveField(8) @Default(0) int repetitions,
    @HiveField(11) @Default(false) bool isSuspended,
    @HiveField(12) String? jlptV,
  }) = _SrsCard;

  factory SrsCard.fromJson(Map<String, dynamic> json) =>
      _$SrsCardFromJson(json);

  const SrsCard._();

  /// Create a brand new card from a vocab entry
  factory SrsCard.newCard({
    required String word,
    required String reading,
    required String meaning,
    String? songTitle,
    String? artist,
    String? context,
    String? jlptV,
  }) {
    final now = DateTime.now();
    return SrsCard(
      word: word,
      reading: reading,
      meaning: meaning,
      songTitle: songTitle,
      artist: artist,
      context: context,
      jlptV: jlptV,
      nextReview: now, // Review immediately
      lastReviewed: now,
    );
  }

  bool get isDue => !isSuspended && DateTime.now().isAfter(nextReview);
}
