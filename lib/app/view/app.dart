import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_theme.dart';
import 'package:lyrics_anki_app/features/main/presentation/pages/main_page.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/locale_notifier.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';
import 'package:universal_html/html.dart' as html;

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Remove skeleton loader after the first frame
        try {
          html.document.getElementById('app_skeleton')?.remove();
        } catch (_) {
          // Ignore
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
