import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupService {
  BackupService._();

  static Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup export is only supported on Web currently.'),
      ),
    );
  }

  static Future<void> importBackup(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup restore is only supported on Web currently.'),
      ),
    );
  }
}
