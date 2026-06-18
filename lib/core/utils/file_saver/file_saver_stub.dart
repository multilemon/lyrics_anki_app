import 'dart:async';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

Future<String> saveContentToFile(String content, String filenamePrefix) async {
  final filename =
      '${filenamePrefix}_${DateTime.now().millisecondsSinceEpoch}.txt';
  final directory = await getApplicationDocumentsDirectory();
  final file = io.File('${directory.path}/$filename');
  await file.writeAsString(content);
  return file.path;
}
