import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web/web.dart' as web;

Future<String> saveContentToFile(String content, String filenamePrefix) async {
  final filename =
      '${filenamePrefix}_${DateTime.now().millisecondsSinceEpoch}.txt';

  if (kIsWeb) {
    // Web implementation: Trigger browser download
    final bytes = utf8.encode(content);
    final blob = web.Blob([bytes.toJS].toJS);
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = filename;
    anchor.click();
    web.URL.revokeObjectURL(url);
    return 'Downloads/$filename';
  } else {
    // Mobile/Desktop implementation
    final directory = await getApplicationDocumentsDirectory();
    final file = io.File('${directory.path}/$filename');
    await file.writeAsString(content);
    return file.path;
  }
}
