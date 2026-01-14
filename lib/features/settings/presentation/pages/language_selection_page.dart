import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/locale_notifier.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.uiLanguage),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
          color: AppColors.sakuraDark,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.sakuraDark),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _LanguageTile(
            label: 'English',
            value: const Locale('en'),
            groupValue: currentLocale,
            onChanged: (v) =>
                ref.read(localeNotifierProvider.notifier).setLocale(v),
          ),
          _LanguageTile(
            label: 'ไทย (Thai)',
            value: const Locale('th'),
            groupValue: currentLocale,
            onChanged: (v) =>
                ref.read(localeNotifierProvider.notifier).setLocale(v),
          ),
          _LanguageTile(
            label: '简体中文 (Chinese Simplified)',
            value: const Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hans',
            ),
            groupValue: currentLocale,
            onChanged: (v) =>
                ref.read(localeNotifierProvider.notifier).setLocale(v),
          ),
          _LanguageTile(
            label: '繁體中文 (Chinese Traditional)',
            value: const Locale.fromSubtags(
              languageCode: 'zh',
              scriptCode: 'Hant',
            ),
            groupValue: currentLocale,
            onChanged: (v) =>
                ref.read(localeNotifierProvider.notifier).setLocale(v),
          ),
          _LanguageTile(
            label: 'Bahasa Indonesia',
            value: const Locale('id'),
            groupValue: currentLocale,
            onChanged: (v) =>
                ref.read(localeNotifierProvider.notifier).setLocale(v),
          ),
          _LanguageTile(
            label: 'ဗမာစာ (Burmese)',
            value: const Locale('my'),
            groupValue: currentLocale,
            onChanged: (v) =>
                ref.read(localeNotifierProvider.notifier).setLocale(v),
          ),
          _LanguageTile(
            label: '日本語 (Japanese)',
            value: const Locale('ja'),
            groupValue: currentLocale,
            onChanged: (v) =>
                ref.read(localeNotifierProvider.notifier).setLocale(v),
          ),
          _LanguageTile(
            label: 'Oʻzbek (Uzbek)',
            value: const Locale('uz'),
            groupValue: currentLocale,
            onChanged: (v) =>
                ref.read(localeNotifierProvider.notifier).setLocale(v),
          ),
          _LanguageTile(
            label: 'Tiếng Việt (Vietnamese)',
            value: const Locale('vi'),
            groupValue: currentLocale,
            onChanged: (v) =>
                ref.read(localeNotifierProvider.notifier).setLocale(v),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final Locale value;
  final Locale groupValue;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    // Compare logic: check scriptCode if present, else languageCode
    final isSelected = value.languageCode == groupValue.languageCode &&
        value.scriptCode == groupValue.scriptCode;

    return RadioListTile<Locale>(
      value: value,
      groupValue: groupValue,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      title: Text(label),
      activeColor: AppColors.sakuraDark,
      selected: isSelected,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
