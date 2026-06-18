import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<String> saveContentToFile(String content, String filenamePrefix) async {
  final filename =
      '${filenamePrefix}_${DateTime.now().millisecondsSinceEpoch}.txt';
  final bytes = utf8.encode(content);
  final blob = web.Blob([bytes.toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
  return 'Downloads/$filename';
}
