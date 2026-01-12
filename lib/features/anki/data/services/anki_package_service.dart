import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

class AnkiPackageService {
  Future<Uint8List> createApkg({
    required Uint8List databaseBytes,
    Map<String, Uint8List> mediaFiles = const {},
  }) async {
    final archive = Archive();

    // 1. Add database as 'collection.anki2'
    archive.addFile(ArchiveFile(
        'collection.anki2', databaseBytes.lengthInBytes, databaseBytes));

    // 2. Add media
    final mediaMap = <String, String>{};
    int index = 0;
    mediaFiles.forEach((filename, bytes) {
      final key = '$index';
      mediaMap[key] = filename;
      archive.addFile(ArchiveFile(key, bytes.lengthInBytes, bytes));
      index++;
    });

    // 3. Add 'media' JSON file
    final mediaJson = jsonEncode(mediaMap);
    final mediaBytes = utf8.encode(mediaJson);
    archive.addFile(ArchiveFile('media', mediaBytes.length, mediaBytes));

    // 4. Encode to Zip
    final encoder = ZipEncoder();
    return Uint8List.fromList(encoder.encode(archive));
  }
}
