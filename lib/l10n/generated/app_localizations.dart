import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_my.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_uz.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('id'),
    Locale('ja'),
    Locale('my'),
    Locale('ru'),
    Locale('th'),
    Locale('uz'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'HanaUta'**
  String get appTitle;

  /// Subtitle on the home screen
  ///
  /// In en, this message translates to:
  /// **'Learn Japanese from your favorite songs.'**
  String get homeSubtitle;

  /// Header for the analysis input section
  ///
  /// In en, this message translates to:
  /// **'Analyze New Song'**
  String get analyzeNewSong;

  /// Label for song title input
  ///
  /// In en, this message translates to:
  /// **'Song Title'**
  String get songTitleLabel;

  /// Hint text for song title input
  ///
  /// In en, this message translates to:
  /// **'e.g. Lemon'**
  String get songTitleHint;

  /// Label for artist name input
  ///
  /// In en, this message translates to:
  /// **'Artist Name'**
  String get artistNameLabel;

  /// Hint text for artist name input
  ///
  /// In en, this message translates to:
  /// **'e.g. Kenshi Yonezu'**
  String get artistNameHint;

  /// Label for target language selector
  ///
  /// In en, this message translates to:
  /// **'Target Language'**
  String get targetLanguageLabel;

  /// Button text to start analysis
  ///
  /// In en, this message translates to:
  /// **'Analyze Song'**
  String get analyzeButton;

  /// Title for the history section
  ///
  /// In en, this message translates to:
  /// **'Recent Analysis'**
  String get recentAnalysisTitle;

  /// Message shown when history is empty
  ///
  /// In en, this message translates to:
  /// **'No history yet.'**
  String get noHistory;

  /// Fallback text for unknown artist
  ///
  /// In en, this message translates to:
  /// **'Unknown Artist'**
  String get unknownArtist;

  /// Title for the settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Label for UI language setting
  ///
  /// In en, this message translates to:
  /// **'UI Language'**
  String get uiLanguage;

  /// Dialog title for selecting language
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Loading message during analysis
  ///
  /// In en, this message translates to:
  /// **'Analysis in progress...\nThis could take a few minutes.'**
  String get analysisInProgress;

  /// Error title when song is not found
  ///
  /// In en, this message translates to:
  /// **'Song Not Found'**
  String get songNotFound;

  /// Error message when song is not found
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find lyrics for \"{title}\" by \"{artist}\".\nPlease check if the name is correct.'**
  String songNotFoundMessage(String title, String artist);

  /// Tab label for Vocabulary
  ///
  /// In en, this message translates to:
  /// **'Vocab'**
  String get vocabTab;

  /// Tab label for Grammar
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get grammarTab;

  /// Tab label for Kanji
  ///
  /// In en, this message translates to:
  /// **'Kanji'**
  String get kanjiTab;

  /// Button text to open video in external player
  ///
  /// In en, this message translates to:
  /// **'Watch on YouTube'**
  String get watchOnYouTube;

  /// No description provided for @searchLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Search language...'**
  String get searchLanguageHint;

  /// Label for the Home tab in the bottom navigation bar
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// Label for the Lyrics tab in the bottom navigation bar
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyricsTab;

  /// Title for the export dialog
  ///
  /// In en, this message translates to:
  /// **'Export to Anki'**
  String get exportToAnki;

  /// Progress message during export
  ///
  /// In en, this message translates to:
  /// **'Generating .apkg file...'**
  String get generatingApkg;

  /// Label for JLPT level dropdown
  ///
  /// In en, this message translates to:
  /// **'Select your JLPT Level:'**
  String get selectJlptLevel;

  /// Explanation text for JLPT level selection
  ///
  /// In en, this message translates to:
  /// **'Words above this level will include furigana on the front of the card.'**
  String get furiganaExplanation;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Export button text
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportButton;

  /// Message shown when no lyrics are found
  ///
  /// In en, this message translates to:
  /// **'No lyrics available.'**
  String get noLyricsAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'es',
        'id',
        'ja',
        'my',
        'ru',
        'th',
        'uz',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'my':
      return AppLocalizationsMy();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'uz':
      return AppLocalizationsUz();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
