import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';

final historyBoxProvider = Provider<Box<HistoryItem>?>((ref) {
  return null;
});
