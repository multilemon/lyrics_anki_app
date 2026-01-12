import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

Future<String> saveContentToFile(String content, String filenamePrefix) async {
  final filename =
      '${filenamePrefix}_${DateTime.now().millisecondsSinceEpoch}.txt';

  if (kIsWeb) {
    // Web implementation: Trigger browser download
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
    return 'Downloads/$filename';
  } else {
    // Mobile/Desktop implementation
    final directory = await getApplicationDocumentsDirectory();
    final file = io.File('${directory.path}/$filename');
    await file.writeAsString(content);
    return file.path;
  }
}
