import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/srs/data/repositories/hive_srs_repository.dart';
import 'package:lyrics_anki_app/features/srs/domain/entities/srs_card.dart';
import 'package:web/web.dart' as web;

class BackupService {
  BackupService._();

  static Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
    try {
      final historyBox = ref.read(historyBoxProvider);
      final settingsBox = ref.read(settingsBoxProvider);
      final srsRepo = ref.read(srsRepositoryProvider);

      final historyList = <Map<String, dynamic>>[];
      if (historyBox != null) {
        for (final item in historyBox.values) {
          historyList.add({
            'songTitle': item.songTitle,
            'artist': item.artist,
            'lyricsSnippet': item.lyricsSnippet,
            'analyzedAt': item.analyzedAt.toIso8601String(),
            'tags': item.tags,
            'targetLanguage': item.targetLanguage,
            'vocabs': item.vocabs.map((v) => v.toJson()).toList(),
            'grammar': item.grammar.map((g) => g.toJson()).toList(),
            'kanji': item.kanji.map((k) => k.toJson()).toList(),
            'youtubeId': item.youtubeId,
            'lyrics': item.lyrics,
          });
        }
      }

      final srsList = <Map<String, dynamic>>[];
      final allCards = srsRepo.getAllCards();
      for (final card in allCards) {
        srsList.add(card.toJson());
      }

      final settingsMap = <String, dynamic>{};
      if (settingsBox != null) {
        for (final key in settingsBox.keys) {
          settingsMap[key.toString()] = settingsBox.get(key);
        }
      }

      final backupData = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'history': historyList,
        'srsCards': srsList,
        'settings': settingsMap,
      };

      final jsonString = jsonEncode(backupData);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      final filename =
          'hanauta_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      await FileSaver.instance.saveFile(
        name: filename,
        bytes: bytes,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup exported and downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> importBackup(BuildContext context, WidgetRef ref) async {
    try {
      final jsonString = await _pickAndReadJsonFile();
      if (jsonString == null || jsonString.isEmpty) {
        return; // User cancelled
      }

      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic> || !decoded.containsKey('version')) {
        throw const FormatException('Invalid backup file structure.');
      }

      final historyBox = ref.read(historyBoxProvider);
      final settingsBox = ref.read(settingsBoxProvider);
      final srsRepo = ref.read(srsRepositoryProvider);

      if (decoded.containsKey('history')) {
        final historyList = decoded['history'] as List<dynamic>;
        if (historyBox != null) {
          await historyBox.clear();
          for (final raw in historyList) {
            if (raw is Map<String, dynamic>) {
              final item = HistoryItem(
                songTitle: raw['songTitle'] as String? ?? '',
                artist: raw['artist'] as String? ?? '',
                lyricsSnippet: raw['lyricsSnippet'] as String? ?? '',
                analyzedAt:
                    DateTime.tryParse(
                      raw['analyzedAt'] as String? ?? '',
                    ) ??
                    DateTime.now(),
                tags:
                    (raw['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
                targetLanguage: raw['targetLanguage'] as String? ?? 'English',
              );
              item.vocabs =
                  (raw['vocabs'] as List<dynamic>?)
                      ?.map((e) => Vocab.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  [];
              item.grammar =
                  (raw['grammar'] as List<dynamic>?)
                      ?.map((e) => Grammar.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  [];
              item.kanji =
                  (raw['kanji'] as List<dynamic>?)
                      ?.map((e) => Kanji.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  [];
              item.youtubeId = raw['youtubeId'] as String?;
              item.lyrics = raw['lyrics'] as String?;
              await historyBox.add(item);
            }
          }
        }
      }

      if (decoded.containsKey('srsCards')) {
        final srsList = decoded['srsCards'] as List<dynamic>;
        await srsRepo.clearAll();
        for (final raw in srsList) {
          if (raw is Map<String, dynamic>) {
            final card = SrsCard.fromJson(raw);
            await srsRepo.saveCard(card);
          }
        }
      }

      if (decoded.containsKey('settings')) {
        final settingsMap = decoded['settings'] as Map<String, dynamic>;
        if (settingsBox != null) {
          await settingsBox.clear();
          for (final entry in settingsMap.entries) {
            await settingsBox.put(entry.key, entry.value);
          }
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Backup restored successfully! App will reload data.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<String?> _pickAndReadJsonFile() async {
    final completer = Completer<String?>();
    final input = web.document.createElement('input') as web.HTMLInputElement;
    input.type = 'file';
    input.accept = '.json';

    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.length == 0) {
        completer.complete(null);
        return;
      }
      final file = files.item(0);
      if (file == null) {
        completer.complete(null);
        return;
      }
      final reader = web.FileReader();
      reader.readAsText(file);
      reader.onLoadEnd.listen((_) {
        completer.complete(reader.result.toString());
      });
    });

    input.click();
    return completer.future;
  }
}
