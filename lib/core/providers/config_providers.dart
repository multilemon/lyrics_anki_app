import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/config/env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_providers.g.dart';

@riverpod
String geminiApiKey(Ref ref) {
  return Env.geminiApiKey;
}
