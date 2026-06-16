import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

/// Global talker instance for advanced logging
final talker = TalkerFlutter.init(
  settings: TalkerSettings(
    // Enable logging only in debug mode to save resources in production
    enabled: kDebugMode,
    useConsoleLogs: kDebugMode,
  ),
  logger: TalkerLogger(
    settings: TalkerLoggerSettings(
      enableColors: true,
    ),
  ),
);

/// Riverpod Observer to automatically log state changes and errors
final talkerRiverpodObserver = TalkerRiverpodObserver(
  talker: talker,
  settings: const TalkerRiverpodLoggerSettings(
    printProviderAdded: false,
    printProviderUpdated: true,
    printProviderDisposed: false,
    printProviderFailed: true,
  ),
);
