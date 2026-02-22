// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle => '好きな曲で日本語を学ぼう。';

  @override
  String get analyzeNewSong => '新しい曲を分析';

  @override
  String get songTitleLabel => '曲名';

  @override
  String get songTitleHint => '例：Lemon';

  @override
  String get artistNameLabel => 'アーティスト名';

  @override
  String get artistNameHint => '例：米津玄師';

  @override
  String get targetLanguageLabel => '学習言語';

  @override
  String get analyzeButton => '分析する';

  @override
  String get recentAnalysisTitle => '最近の分析';

  @override
  String get noHistory => '履歴がありません。';

  @override
  String get unknownArtist => '不明なアーティスト';

  @override
  String get settingsTitle => '設定';

  @override
  String get uiLanguage => 'アプリの言語';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get analysisInProgress => '分析中...\n数分かかる場合があります。';

  @override
  String get songNotFound => '曲が見つかりません';

  @override
  String songNotFoundMessage(String title, String artist) {
    return '「$artist」の「$title」の歌詞が見つかりませんでした。\n名前が正しいか確認してください。';
  }

  @override
  String get vocabTab => '単語';

  @override
  String get grammarTab => '文法';

  @override
  String get kanjiTab => '漢字';

  @override
  String get watchOnYouTube => 'YouTubeで見る';

  @override
  String get searchLanguageHint => '言語を検索...';

  @override
  String get homeTab => 'ホーム';

  @override
  String get lyricsTab => '歌詞';

  @override
  String get exportToAnki => 'Ankiへエクスポート';

  @override
  String get generatingApkg => '.apkgファイルを生成中...';

  @override
  String get selectJlptLevel => 'JLPTレベルを選択:';

  @override
  String get furiganaExplanation => 'このレベル以上の単語には、カードの表面にふりがなが付きます。';

  @override
  String get cancelButton => 'キャンセル';

  @override
  String get exportButton => 'エクスポート';

  @override
  String get noLyricsAvailable => '歌詞が見つかりません。';

  @override
  String get vocabType => '単語';

  @override
  String get grammarType => '文法';

  @override
  String get kanjiType => '漢字';

  @override
  String get closeButton => '閉じる';

  @override
  String get allFilter => 'すべて';

  @override
  String get otherFilter => 'その他';

  @override
  String get learningModeLabel => '学習モード';

  @override
  String get modeJapanese => '日本語を学ぶ';

  @override
  String get modeEnglish => '英語を学ぶ\n(日本人向け)';

  @override
  String get modeKorean => '韓国語を学ぶ\n(日本人向け)';

  @override
  String get ipaType => '発音記号';

  @override
  String get structureType => '構文';

  @override
  String get songTitleHintEn => '例：Shape of You';

  @override
  String get artistNameHintEn => '例：Ed Sheeran';

  @override
  String get songTitleHintKo => '例：Gangnam Style';

  @override
  String get artistNameHintKo => '例：PSY';

  @override
  String get romanizationType => 'ローマ字表記';

  @override
  String get reverseLearningDescription => 'リバース学習モード：日本語話者が英語/韓国語を学ぶためのモード。';
}
