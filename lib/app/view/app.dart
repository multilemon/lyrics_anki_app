import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyrics_anki_app/features/main/presentation/pages/main_page.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HanaUta',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansJpTextTheme(),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MainPage(),
    );
  }
}
