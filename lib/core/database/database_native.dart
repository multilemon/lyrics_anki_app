import 'package:flutter/foundation.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

Future<CommonSqlite3> getSqlite3() async {
  return sqlite3;
}

Future<Uint8List> exportDatabase(CommonDatabase db) async {
  // On native, standard serialize might not be available without extensions.
  // For now, return empty or implement file-based workaround if needed.
  // But since we prioritize web:
  try {
    // Attempt serialize if available (e.g. if custom lib sqlite3 is used)
    // Use definition from package:sqlite3/sqlite3.dart
    // return (db as Database).serialize();
    debugPrint(
      'Native serialize not implemented/available in this environment',
    );
    return Uint8List(0);
  } catch (e) {
    debugPrint(
      'Native export not explicitly supported in this plain '
      'implementation: $e',
    );
    return Uint8List(0);
  }
}
