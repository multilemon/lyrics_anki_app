import 'dart:async';
import 'package:hive_ce/hive.dart';
import 'package:lyrics_anki_app/features/srs/domain/entities/srs_card.dart';
import 'package:lyrics_anki_app/features/srs/domain/repositories/srs_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hive_srs_repository.g.dart';

class HiveSrsRepository implements SrsRepository {
  static const String boxName = 'srs_cards_v1';
  final Box<SrsCard> _box;
  
  final _streamController = StreamController<List<SrsCard>>.broadcast();

  HiveSrsRepository(this._box) {
    _emitCurrent();
  }

  @override
  Future<void> init() async {}

  void _emitCurrent() {
    _streamController.add(_box.values.toList());
  }

  @override
  List<SrsCard> getAllCards() {
    return _box.values.toList();
  }

  @override
  List<SrsCard> getDueCards() {
    final now = DateTime.now();
    return _box.values.where((card) {
      return !card.isSuspended && now.isAfter(card.nextReview);
    }).toList();
  }

  @override
  Future<void> saveCard(SrsCard card) async {
    await _box.put(card.word, card);
    _emitCurrent();
  }

  @override
  Future<void> deleteCard(String word) async {
    await _box.delete(word);
    _emitCurrent();
  }

  @override
  Map<String, int> getStats() {
    final cards = getAllCards();
    final now = DateTime.now();
    
    return {
      'total': cards.length,
      'due': cards
          .where((c) => !c.isSuspended && now.isAfter(c.nextReview))
          .length,
      'new': cards.where((c) => c.repetitions == 0).length,
      'suspended': cards.where((c) => c.isSuspended).length,
    };
  }

  @override
  Stream<List<SrsCard>> watchCards() => _streamController.stream;
}

@riverpod
SrsRepository srsRepository(Ref ref) {
  throw UnimplementedError('Override srsRepositoryProvider in ProviderScope');
}
