import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:lyrics_anki_app/app/app.dart';
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:lyrics_anki_app/core/services/logger_service.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/srs/data/repositories/hive_srs_repository.dart';
import 'package:lyrics_anki_app/features/srs/domain/entities/srs_card.dart';
import 'package:lyrics_anki_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log all unhandled Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    talker.handle(details.exception, details.stack);
  };

  // Log all unhandled asynchronous errors
  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return true;
  };

  Box<HistoryItem>? box;
  Box<dynamic>? settingsBox;
  Box<SrsCard>? srsBox;
  try {
    await Hive.initFlutter();
    Hive
      ..registerAdapter(HistoryItemAdapter())
      ..registerAdapter(VocabAdapter())
      ..registerAdapter(GrammarAdapter())
      ..registerAdapter(KanjiAdapter())
      ..registerAdapter(LyricVerseAdapter())
      ..registerAdapter(SrsCardAdapter());

    try {
      box = await Hive.openBox<HistoryItem>('history_box');
      settingsBox = await Hive.openBox('settings');
      srsBox = await Hive.openBox<SrsCard>(HiveSrsRepository.boxName);
    } on Object catch (e, st) {
      talker.warning(
        '⚠️ Hive openBox failed. Attempting to recover by clearing box...',
        e,
        st,
      );
      try {
        await Hive.deleteBoxFromDisk('history_box');
        await Hive.deleteBoxFromDisk('settings');
        await Hive.deleteBoxFromDisk(HiveSrsRepository.boxName);
        box = await Hive.openBox<HistoryItem>('history_box');
        settingsBox = await Hive.openBox('settings');
        srsBox = await Hive.openBox<SrsCard>(HiveSrsRepository.boxName);
      } on Object catch (e2, st2) {
        talker.critical('🔴 Critical: Failed to recover Hive box', e2, st2);
      }
    }
  } on Object catch (e, st) {
    talker.error('Hive initialization failed', e, st);
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (!kDebugMode) {
      try {
        await FirebaseAppCheck.instance.activate(
          providerWeb: ReCaptchaEnterpriseProvider(
            '6LfrmCItAAAAAD1ru_O_WdWo5afm6GYCaZ0DPo84',
          ),
          providerAndroid: const AndroidDebugProvider(),
          providerApple: const AppleDebugProvider(),
        );
      } on Object catch (e) {
        // Ignore 'already-initialized' error on hot restart
        if (!e.toString().contains('already-initialized')) {
          rethrow;
        }
      }
    }
  } on Object catch (e, st) {
    talker.error('Firebase initialization failed', e, st);
  }

  runApp(
    ProviderScope(
      observers: [talkerRiverpodObserver],
      overrides: [
        if (box != null) historyBoxProvider.overrideWithValue(box),
        if (settingsBox != null)
          settingsBoxProvider.overrideWithValue(settingsBox),
        if (srsBox != null)
          srsRepositoryProvider.overrideWithValue(HiveSrsRepository(srsBox)),
      ],
      child: const App(),
    ),
  );
}
