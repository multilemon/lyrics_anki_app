import 'package:lyrics_anki_app/features/srs/domain/entities/srs_card.dart';

abstract class SrsRepository {
  Future<void> init();

  /// Get all cards that are due for review today
  List<SrsCard> getDueCards();

  /// Get all cards in the system
  List<SrsCard> getAllCards();

  /// Update or add a card
  Future<void> saveCard(SrsCard card);

  /// Delete a card
  Future<void> deleteCard(String word);

  /// Delete all cards
  Future<void> clearAll();

  /// Get stats (total learned, due today, etc)
  Map<String, dynamic> getStats();

  /// Watch for changes in the SRS database
  Stream<List<SrsCard>> watchCards();
}
