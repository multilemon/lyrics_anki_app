import 'package:flutter/widgets.dart';
import 'package:lyrics_anki_app/l10n/generated/app_localizations.dart';

export 'package:lyrics_anki_app/l10n/generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
