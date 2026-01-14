import 'package:flutter/material.dart';
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_notifier.g.dart';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const _kLocaleKey = 'app_locale';

  @override
  Locale build() {
    final box = ref.watch(settingsBoxProvider);
    final savedCode = box?.get(_kLocaleKey);

    if (savedCode != null && savedCode is String) {
      if (savedCode.contains('_')) {
        final parts = savedCode.split('_');
        return Locale(parts[0], parts[1]);
      }
      return Locale(savedCode);
    }

    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final box = ref.read(settingsBoxProvider);
    // Store as "en", "zh_Hans", etc.
    final code = locale.scriptCode != null
        ? '${locale.languageCode}_${locale.scriptCode}'
        : locale.languageCode;
    await box?.put(_kLocaleKey, code);
  }
}
