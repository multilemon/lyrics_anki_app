import 'package:flutter/material.dart';
import 'package:lyrics_anki_app/core/theme/app_theme.dart';
import 'package:lyrics_anki_app/features/main/presentation/pages/main_page.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/locale_notifier.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider);

    return MaterialApp(
      title: 'HanaUta',
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MainPage(),
    );
  }
}
