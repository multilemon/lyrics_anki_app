import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/settings/presentation/pages/language_selection_page.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/locale_notifier.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

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
      case 'en':
      default:
        return 'English';
    }
  }
}
