// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle => '从你最喜欢的歌曲中学习日语。';

  @override
  String get analyzeNewSong => '分析新歌';

  @override
  String get songTitleLabel => '歌曲标题';

  @override
  String get songTitleHint => '例如：Lemon';

  @override
  String get artistNameLabel => '艺术家姓名';

  @override
  String get artistNameHint => '例如：米津玄师';

  @override
  String get targetLanguageLabel => '目标语言';

  @override
  String get analyzeButton => '分析歌曲';

  @override
  String get recentAnalysisTitle => '最近分析';

  @override
  String get noHistory => '尚无记录。';

  @override
  String get unknownArtist => '未知艺术家';

  @override
  String get settingsTitle => '设置';

  @override
  String get uiLanguage => '界面语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get analysisInProgress => '正在分析...\n这可能需要几分钟。';

  @override
  String get songNotFound => '未找到歌曲';

  @override
  String songNotFoundMessage(String title, String artist) {
    return '我们找不到 \"$artist\" 的歌曲 \"$title\" 的歌词。\n请检查名称是否正确。';
  }

  @override
  String get vocabTab => '词汇';

  @override
  String get grammarTab => '语法';

  @override
  String get kanjiTab => '汉字';

  @override
  String get watchOnYouTube => '在 YouTube 上观看';

  @override
  String get searchLanguageHint => '搜索语言...';

  @override
  String get homeTab => '首页';

  @override
  String get lyricsTab => '歌词';

  @override
  String get exportToAnki => '导出到 Anki';

  @override
  String get generatingApkg => '正在生成 .apkg 文件...';

  @override
  String get selectJlptLevel => '选择您的 JLPT 等级：';

  @override
  String get furiganaExplanation => '高于此等级的单词将在卡片正面显示注音。';

  @override
  String get cancelButton => '取消';

  @override
  String get exportButton => '导出';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle => '从你最喜欢的歌曲中学习日语。';

  @override
  String get analyzeNewSong => '分析新歌';

  @override
  String get songTitleLabel => '歌曲标题';

  @override
  String get songTitleHint => '例如：Lemon';

  @override
  String get artistNameLabel => '艺术家姓名';

  @override
  String get artistNameHint => '例如：米津玄师';

  @override
  String get targetLanguageLabel => '目标语言';

  @override
  String get analyzeButton => '分析歌曲';

  @override
  String get recentAnalysisTitle => '最近分析';

  @override
  String get noHistory => '尚无记录。';

  @override
  String get unknownArtist => '未知艺术家';

  @override
  String get settingsTitle => '设置';

  @override
  String get uiLanguage => '界面语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get analysisInProgress => '正在分析...\n这可能需要几分钟。';

  @override
  String get songNotFound => '未找到歌曲';

  @override
  String songNotFoundMessage(String title, String artist) {
    return '我们找不到 \"$artist\" 的歌曲 \"$title\" 的歌词。\n请检查名称是否正确。';
  }

  @override
  String get vocabTab => '词汇';

  @override
  String get grammarTab => '语法';

  @override
  String get kanjiTab => '汉字';

  @override
  String get watchOnYouTube => '在 YouTube 上观看';

  @override
  String get searchLanguageHint => '搜索语言...';

  @override
  String get homeTab => '首页';

  @override
  String get lyricsTab => '歌词';

  @override
  String get exportToAnki => '导出到 Anki';

  @override
  String get generatingApkg => '正在生成 .apkg 文件...';

  @override
  String get selectJlptLevel => '选择您的 JLPT 等级：';

  @override
  String get furiganaExplanation => '高于此等级的单词将在卡片正面显示注音。';

  @override
  String get cancelButton => '取消';

  @override
  String get exportButton => '导出';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle => '從你最喜歡的歌曲中學習日語。';

  @override
  String get analyzeNewSong => '分析新歌';

  @override
  String get songTitleLabel => '歌曲標題';

  @override
  String get songTitleHint => '例如：Lemon';

  @override
  String get artistNameLabel => '藝術家姓名';

  @override
  String get artistNameHint => '例如：米津玄師';

  @override
  String get targetLanguageLabel => '目標語言';

  @override
  String get analyzeButton => '分析歌曲';

  @override
  String get recentAnalysisTitle => '最近分析';

  @override
  String get noHistory => '尚無記錄。';

  @override
  String get unknownArtist => '未知藝術家';

  @override
  String get settingsTitle => '設置';

  @override
  String get uiLanguage => '介面語言';

  @override
  String get selectLanguage => '選擇語言';

  @override
  String get analysisInProgress => '正在分析...\n這可能需要幾分鐘。';

  @override
  String get songNotFound => '未找到歌曲';

  @override
  String songNotFoundMessage(String title, String artist) {
    return '我們找不到 \"$artist\" 的歌曲 \"$title\" 的歌詞。\n請檢查名稱是否正確。';
  }

  @override
  String get vocabTab => '詞彙';

  @override
  String get grammarTab => '文法';

  @override
  String get kanjiTab => '漢字';

  @override
  String get watchOnYouTube => '在 YouTube 上觀看';

  @override
  String get searchLanguageHint => '搜尋語言...';

  @override
  String get homeTab => '首頁';

  @override
  String get lyricsTab => '歌詞';

  @override
  String get exportToAnki => '匯出至 Anki';

  @override
  String get generatingApkg => '正在產生 .apkg 檔案...';

  @override
  String get selectJlptLevel => '選擇您的 JLPT 等級：';

  @override
  String get furiganaExplanation => '高於此等級的單字將在卡片正面顯示振假名。';

  @override
  String get cancelButton => '取消';

  @override
  String get exportButton => '匯出';
}
