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

  @override
  String get noLyricsAvailable => '未找到歌词。';

  @override
  String get vocabType => '词汇';

  @override
  String get grammarType => '语法';

  @override
  String get kanjiType => '汉字';

  @override
  String get closeButton => '关闭';

  @override
  String get allFilter => '全部';

  @override
  String get otherFilter => '其他';

  @override
  String get learningModeLabel => '学习模式';

  @override
  String get modeJapanese => '学日语';

  @override
  String get modeEnglish => '学英语\n(For JP)';

  @override
  String get modeKorean => '学韩语\n(For JP)';

  @override
  String get ipaType => '国际音标';

  @override
  String get structureType => '句型';

  @override
  String get songTitleHintEn => '例如 Shape of You';

  @override
  String get artistNameHintEn => '例如 Ed Sheeran';

  @override
  String get songTitleHintKo => '例如 Gangnam Style';

  @override
  String get artistNameHintKo => '例如 PSY';

  @override
  String get romanizationType => '罗马字';

  @override
  String get reverseLearningDescription => '反向学习模式：面向日语母语者学习英语/韩语。';

  @override
  String get exportOptions => '导出选项';

  @override
  String get exportAnkiOption => '导出到 Anki (.apkg)';

  @override
  String get exportAnkiDescription => 'Anki 应用的闪卡牌组';

  @override
  String get exportPlainTextOption => '导出单词列表 (文本)';

  @override
  String get exportPlainTextDescription => '用逗号分隔的单词，适用于 Renshuu 等';

  @override
  String get wordListCopied => '单词列表已复制到剪贴板！';

  @override
  String get wordListDownloaded => '单词列表已下载！';

  @override
  String get exportWordsTitle => '导出单词列表';

  @override
  String get includeVocab => '词汇';

  @override
  String get includeKanji => '汉字';

  @override
  String get includeGrammar => '语法';

  @override
  String get copyToClipboard => '复制';

  @override
  String get downloadAsFile => '下载';

  @override
  String get noWordsToExport => '没有可导出的单词。请至少选择一个类别。';

  @override
  String get translationTab => 'Translation';

  @override
  String get nuanceExplanation => 'Nuance & Interpretation';

  @override
  String get noTranslationAvailable =>
      'Translation not available for this song. Try re-analyzing to generate verse translations.';
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

  @override
  String get noLyricsAvailable => '未找到歌词。';

  @override
  String get vocabType => '词汇';

  @override
  String get grammarType => '语法';

  @override
  String get kanjiType => '汉字';

  @override
  String get closeButton => '关闭';

  @override
  String get allFilter => '全部';

  @override
  String get otherFilter => '其他';

  @override
  String get learningModeLabel => '学习模式';

  @override
  String get modeJapanese => '学日语';

  @override
  String get modeEnglish => '学英语\n(For JP)';

  @override
  String get modeKorean => '学韩语\n(For JP)';

  @override
  String get ipaType => '国际音标';

  @override
  String get structureType => '句型';

  @override
  String get songTitleHintEn => '例如 Shape of You';

  @override
  String get artistNameHintEn => '例如 Ed Sheeran';

  @override
  String get songTitleHintKo => '例如 Gangnam Style';

  @override
  String get artistNameHintKo => '例如 PSY';

  @override
  String get romanizationType => '罗马字';

  @override
  String get reverseLearningDescription => '反向学习模式：面向日语母语者学习英语/韩语。';

  @override
  String get exportOptions => '导出选项';

  @override
  String get exportAnkiOption => '导出到 Anki (.apkg)';

  @override
  String get exportAnkiDescription => 'Anki 应用的闪卡牌组';

  @override
  String get exportPlainTextOption => '导出单词列表 (文本)';

  @override
  String get exportPlainTextDescription => '用逗号分隔的单词，适用于 Renshuu 等';

  @override
  String get wordListCopied => '单词列表已复制到剪贴板！';

  @override
  String get wordListDownloaded => '单词列表已下载！';

  @override
  String get exportWordsTitle => '导出单词列表';

  @override
  String get includeVocab => '词汇';

  @override
  String get includeKanji => '汉字';

  @override
  String get includeGrammar => '语法';

  @override
  String get copyToClipboard => '复制';

  @override
  String get downloadAsFile => '下载';

  @override
  String get noWordsToExport => '没有可导出的单词。请至少选择一个类别。';
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

  @override
  String get noLyricsAvailable => '找不到歌詞。';

  @override
  String get vocabType => '詞彙';

  @override
  String get grammarType => '語法';

  @override
  String get kanjiType => '漢字';

  @override
  String get closeButton => '關閉';

  @override
  String get allFilter => '全部';

  @override
  String get otherFilter => '其他';

  @override
  String get learningModeLabel => '學習模式';

  @override
  String get modeJapanese => '學日語';

  @override
  String get modeEnglish => '學英語\n(For JP)';

  @override
  String get modeKorean => '學韓語\n(For JP)';

  @override
  String get ipaType => '國際音標';

  @override
  String get structureType => '句型';

  @override
  String get songTitleHintEn => '例如 Shape of You';

  @override
  String get artistNameHintEn => '例如 Ed Sheeran';

  @override
  String get songTitleHintKo => '例如 Gangnam Style';

  @override
  String get artistNameHintKo => '例如 PSY';

  @override
  String get romanizationType => '羅馬字';

  @override
  String get reverseLearningDescription => '反向學習模式：面向日語母語者學習英語/韓語。';

  @override
  String get exportOptions => '匯出選項';

  @override
  String get exportAnkiOption => '匯出至 Anki (.apkg)';

  @override
  String get exportAnkiDescription => 'Anki 應用的閃卡牌組';

  @override
  String get exportPlainTextOption => '匯出單字列表 (文字)';

  @override
  String get exportPlainTextDescription => '用逗號分隔的單字，適用於 Renshuu 等';

  @override
  String get wordListCopied => '單字列表已複製到剪貼簿！';

  @override
  String get wordListDownloaded => '單字列表已下載！';

  @override
  String get exportWordsTitle => '匯出單字列表';

  @override
  String get includeVocab => '詞彙';

  @override
  String get includeKanji => '漢字';

  @override
  String get includeGrammar => '文法';

  @override
  String get copyToClipboard => '複製';

  @override
  String get downloadAsFile => '下載';

  @override
  String get noWordsToExport => '沒有可匯出的單字。請至少選擇一個類別。';
}
