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
    try {
      _emitCurrent();
    } on Object catch (_) {
      try {
        _box.clear();
      } on Object catch (_) {}
      _emitCurrent();
    }
  }

  @override
  Future<void> init() async {}

  void _emitCurrent() {
    _streamController.add(getAllCards());
  }

  @override
  List<SrsCard> getAllCards() {
    try {
      return _box.values.toList();
    } on Object catch (_) {
      try {
        _box.clear();
      } on Object catch (_) {}
      return [];
    }
  }

  @override
  List<SrsCard> getDueCards() {
    try {
      final now = DateTime.now();
      return _box.values.where((card) {
        return !card.isSuspended && now.isAfter(card.nextReview);
      }).toList();
    } on Object catch (_) {
      return [];
    }
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
  Map<String, dynamic> getStats() {
    final cards = getAllCards();
    final now = DateTime.now();
    
    final uniqueSongs = cards
        .map((c) => c.songTitle)
        .where((title) => title != null)
        .toSet()
        .length;

    final jlptCounts = <String, int>{};
    for (final card in cards) {
      if (card.jlptV != null) {
        jlptCounts[card.jlptV!] = (jlptCounts[card.jlptV!] ?? 0) + 1;
      }
    }

    return {
      'total': cards.length,
      'due': cards
          .where((c) => !c.isSuspended && now.isAfter(c.nextReview))
          .length,
      'new': cards.where((c) => c.repetitions == 0).length,
      'suspended': cards.where((c) => c.isSuspended).length,
      'songs': uniqueSongs,
      'jlpt': jlptCounts,
    };
  }

  @override
  Stream<List<SrsCard>> watchCards() => _streamController.stream;
}

@riverpod
SrsRepository srsRepository(Ref ref) {
  throw UnimplementedError('Override srsRepositoryProvider in ProviderScope');
}
