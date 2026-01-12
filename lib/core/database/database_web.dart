import 'dart:typed_data';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/wasm.dart';

InMemoryFileSystem? _fs;

Future<CommonSqlite3> getSqlite3() async {
  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  _fs = InMemoryFileSystem();
  sqlite3.registerVirtualFileSystem(_fs!, makeDefault: true);
  return sqlite3;
}

Future<Uint8List> exportDatabase(CommonDatabase db) async {
  // serialize() is not reliably available on all sqlite3 builds.
  // Workaround: VACUUM INTO a file in the virtual filesystem, then read bytes.

  if (_fs == null) {
    throw StateError('FileSystem not initialized');
  }

  final path = '/export.db';
  try {
    _fs!.xDelete(path, 0);
  } catch (_) {
    // Ignore if file doesn't exist
  }

  db.execute('VACUUM INTO ?', [path]);

  final file =
      _fs!.xOpen(Sqlite3Filename(path), SqlFlag.SQLITE_OPEN_READONLY).file;
  try {
    final size = file.xFileSize();
    final bytes = Uint8List(size);
    file.xRead(bytes, 0);
    return bytes;
  } finally {
    file.xClose();
    try {
      _fs!.xDelete(path, 0);
    } catch (_) {}
  }
}
