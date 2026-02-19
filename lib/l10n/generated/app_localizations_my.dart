// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle => 'သင်အကြိုက်ဆုံးသီချင်းများမှ ဂျပန်စာလေ့လာပါ။';

  @override
  String get analyzeNewSong => 'သီချင်းအသစ်လေ့လာရန်';

  @override
  String get songTitleLabel => 'သီချင်းခေါင်းစဉ်';

  @override
  String get songTitleHint => 'ဥပမာ - Lemon';

  @override
  String get artistNameLabel => 'အဆိုတော်အမည်';

  @override
  String get artistNameHint => 'ဥပမာ - Kenshi Yonezu';

  @override
  String get targetLanguageLabel => 'ဘာသာစကားရွေးချယ်ရန်';

  @override
  String get analyzeButton => 'သီချင်းလေ့လာပါ';

  @override
  String get recentAnalysisTitle => 'လတ်တလောလေ့လာမှုများ';

  @override
  String get noHistory => 'မှတ်တမ်းမရှိသေးပါ။';

  @override
  String get unknownArtist => 'အဆိုတော်အမည်မသိပါ';

  @override
  String get settingsTitle => 'ဆက်တင်များ';

  @override
  String get uiLanguage => 'အသုံးပြုမည့်ဘာသာစကား';

  @override
  String get selectLanguage => 'ဘာသာစကားရွေးချယ်ပါ';

  @override
  String get analysisInProgress =>
      'လေ့လာနေဆဲဖြစ်ပါသည်...\nမိနစ်အနည်းငယ်ကြာနိုင်ပါသည်။';

  @override
  String get songNotFound => 'သီချင်းမတွေ့ပါ';

  @override
  String songNotFoundMessage(String title, String artist) {
    return '\"$artist\" ၏ \"$title\" သီချင်းစာသားကို ရှာမတွေ့ပါ။\nအမည်မှန်ကန်ကြောင်း ပြန်လည်စစ်ဆေးပါ။';
  }

  @override
  String get vocabTab => 'ဝေါဟာရ';

  @override
  String get grammarTab => 'သဒ္ဒါ';

  @override
  String get kanjiTab => 'ခန်းဂျီး';

  @override
  String get watchOnYouTube => 'YouTube တွင်ကြည့်ပါ';

  @override
  String get searchLanguageHint => 'ဘာသာစကားရှာပါ...';

  @override
  String get homeTab => 'မူလစာမျက်နှာ';

  @override
  String get lyricsTab => 'သီချင်းစာသား';

  @override
  String get exportToAnki => 'Anki သို့ ပို့ရန်';

  @override
  String get generatingApkg => '.apkg ဖိုင်ကို ဖန်တီးနေသည်...';

  @override
  String get selectJlptLevel => 'သင့် JLPT အဆင့်ကို ရွေးချယ်ပါ-';

  @override
  String get furiganaExplanation =>
      'ဒီအဆင့်အထက်ရှိ စကားလုံးများတွင် ကတ်၏ ရှေ့မျက်နှာပြင်၌ furigana ပါဝင်ပါမည်။';

  @override
  String get cancelButton => 'မလုပ်တော့ပါ';

  @override
  String get exportButton => 'ပို့ရန်';

  @override
  String get noLyricsAvailable => 'သီချင်းစာသား မရှိပါ။';

  @override
  String get vocabType => 'ဝေါဟာရ';

  @override
  String get grammarType => 'သဒ္ဒါ';

  @override
  String get kanjiType => 'ခန်းဂျိ';

  @override
  String get closeButton => 'ပိတ်';

  @override
  String get allFilter => 'အားလုံး';

  @override
  String get otherFilter => 'အခြား';

  @override
  String get learningModeLabel => 'လေ့လာမှုမုဒ်';

  @override
  String get modeJapanese => 'ဂျပန်ဘာသာ လေ့လာ';

  @override
  String get modeEnglish => 'အင်္ဂလိပ်ဘာသာ လေ့လာ';

  @override
  String get modeKorean => 'ကိုရီးယားဘာသာ လေ့လာ';

  @override
  String get ipaType => 'IPA';

  @override
  String get structureType => 'ဖွဲ့စည်းပုံ';

  @override
  String get songTitleHintEn => 'ဥပမာ Shape of You';

  @override
  String get artistNameHintEn => 'ဥပမာ Ed Sheeran';

  @override
  String get songTitleHintKo => 'ဥပမာ Gangnam Style';

  @override
  String get artistNameHintKo => 'ဥပမာ PSY';

  @override
  String get romanizationType => 'ရောမဂဏန်း';

  @override
  String get reverseLearningDescription =>
      'ပြောင်းပြန်လေ့လာမှု: ဂျပန်စကားပြောသူများ အင်္ဂလိပ်/ကိုရီးယား လေ့လာရန်။';
}
