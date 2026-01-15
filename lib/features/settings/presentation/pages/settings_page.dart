import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/settings/presentation/pages/language_selection_page.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/locale_notifier.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeNotifierProvider);
    final localeName = _getLocaleName(currentLocale);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
          color: AppColors.sakuraDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.sakuraDark),
            title: Text(l10n.uiLanguage),
            subtitle: Text(localeName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const LanguageSelectionPage(),
                ),
              );
            },
          ),
          // TEMPORARY FEATURE: QR Code Share
          // TODO: Remove this block when no longer needed
          ListTile(
            leading: const Icon(Icons.qr_code, color: AppColors.sakuraDark),
            title: const Text('Share App'),
            subtitle: const Text('Show QR Code'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) => const _ShareDialog(),
              );
            },
          ),
          // END TEMPORARY FEATURE
        ],
      ),
    );
  }

  String _getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'th':
        return 'ไทย (Thai)';
      case 'zh':
        if (locale.scriptCode == 'Hant') {
          return '繁體中文 (Chinese Traditional)';
        }
        return '简体中文 (Chinese Simplified)';
      case 'id':
        return 'Bahasa Indonesia';
      case 'my':
        return 'ဗမာစာ (Burmese)';
      case 'ja':
        return '日本語 (Japanese)';
      case 'uz':
        return 'Oʻzbek (Uzbek)';
      case 'vi':
        return 'Tiếng Việt (Vietnamese)';
      case 'ru':
        return 'Русский (Russian)';
      case 'en':
      default:
        return 'English';
    }
  }
}

// TEMPORARY FEATURE: QR Code Share Dialog
// TODO: Remove this class when removing the feature
class _ShareDialog extends StatelessWidget {
  const _ShareDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share HanaUta',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.sakuraDark,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: 'https://multilemon.github.io/lyrics_anki_app/',
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.sakuraDark,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan to open app',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
// END TEMPORARY FEATURE
