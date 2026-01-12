import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:lyrics_anki_app/app/app.dart';
import 'package:lyrics_anki_app/bootstrap.dart';
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Box<HistoryItem>? box;
  try {
    await Hive.initFlutter();
    Hive
      ..registerAdapter(HistoryItemAdapter())
      ..registerAdapter(VocabAdapter())
      ..registerAdapter(GrammarAdapter())
      ..registerAdapter(KanjiAdapter());

    box = await Hive.openBox<HistoryItem>('history_box');
  } catch (e, st) {
    debugPrint('Hive initialization failed: $e\n$st');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      providerWeb: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      providerAndroid: const AndroidDebugProvider(),
      providerApple: const AppleDebugProvider(),
    );
  } catch (e, st) {
    debugPrint('Firebase initialization failed: $e\n$st');
  }

  await bootstrap(
    () => const App(),
    overrides: [
      if (box != null) historyBoxProvider.overrideWithValue(box),
    ],
  );
}
