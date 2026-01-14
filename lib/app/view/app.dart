import 'package:flutter/material.dart';
import 'package:lyrics_anki_app/core/theme/app_theme.dart';
import 'package:lyrics_anki_app/features/main/presentation/pages/main_page.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HanaUta',
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MainPage(),
    );
  }
}
