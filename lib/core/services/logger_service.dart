import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

/// Global talker instance for advanced logging
final Talker talker = TalkerFlutter.init();

/// Riverpod Observer to automatically log state changes and errors
final talkerRiverpodObserver = TalkerRiverpodObserver(
  talker: talker,
  settings: const TalkerRiverpodLoggerSettings(
    printProviderAdded: false,
  ),
);
