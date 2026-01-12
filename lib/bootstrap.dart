import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  List<Override> overrides = const [],
}) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  // Add cross-flavor configuration here

  runApp(
    ProviderScope(
      overrides: overrides,
      child: await builder(),
    ),
  );
}
