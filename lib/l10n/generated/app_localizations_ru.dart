// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle => 'Учите японский с помощью любимых песен.';

  @override
  String get analyzeNewSong => 'Анализ новой песни';

  @override
  String get songTitleLabel => 'Название песни';

  @override
  String get songTitleHint => 'например, Lemon';

  @override
  String get artistNameLabel => 'Имя исполнителя';

  @override
  String get artistNameHint => 'например, Kenshi Yonezu';

  @override
  String get targetLanguageLabel => 'Целевой язык';

  @override
  String get analyzeButton => 'Анализировать';

  @override
  String get recentAnalysisTitle => 'Недавние анализы';

  @override
  String get noHistory => 'История пуста.';

  @override
  String get unknownArtist => 'Неизвестный исполнитель';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get uiLanguage => 'Язык интерфейса';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get analysisInProgress =>
      'Идет анализ...\nЭто может занять несколько минут.';

  @override
  String get songNotFound => 'Песня не найдена';

  @override
  String songNotFoundMessage(String title, String artist) {
    return 'Мы не нашли текст песни \"$title\" исполнителя \"$artist\".\nПожалуйста, проверьте правильность названия.';
  }

  @override
  String get vocabTab => 'Словарь';

  @override
  String get grammarTab => 'Грамматика';

  @override
  String get kanjiTab => 'Кандзи';

  @override
  String get watchOnYouTube => 'Смотреть на YouTube';

  @override
  String get searchLanguageHint => 'Поиск языка...';

  @override
  String get homeTab => 'Главная';

  @override
  String get lyricsTab => 'Текст';

  @override
  String get exportToAnki => 'Экспорт в Anki';

  @override
  String get generatingApkg => 'Создание файла .apkg...';

  @override
  String get selectJlptLevel => 'Выберите ваш уровень JLPT:';

  @override
  String get furiganaExplanation =>
      'Слова выше этого уровня будут содержать фуригану на лицевой стороне карточки.';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get exportButton => 'Экспорт';

  @override
  String get noLyricsAvailable => 'Текст песни не найден.';

  @override
  String get vocabType => 'Словарь';

  @override
  String get grammarType => 'Грамматика';

  @override
  String get kanjiType => 'Кандзи';

  @override
  String get closeButton => 'Закрыть';

  @override
  String get allFilter => 'Все';

  @override
  String get otherFilter => 'Другое';

  @override
  String get learningModeLabel => 'Режим обучения';

  @override
  String get modeJapanese => 'Учить японский';

  @override
  String get modeEnglish => 'Учить английский\n(For JP)';

  @override
  String get modeKorean => 'Учить корейский\n(For JP)';

  @override
  String get ipaType => 'МФА';

  @override
  String get structureType => 'Структура';

  @override
  String get songTitleHintEn => 'напр. Shape of You';

  @override
  String get artistNameHintEn => 'напр. Ed Sheeran';

  @override
  String get songTitleHintKo => 'напр. Gangnam Style';

  @override
  String get artistNameHintKo => 'напр. PSY';

  @override
  String get romanizationType => 'Романизация';

  @override
  String get reverseLearningDescription =>
      'Обратный режим: для японцев, изучающих английский/корейский.';

  @override
  String get exportOptions => 'Варианты экспорта';

  @override
  String get exportAnkiOption => 'Экспорт в Anki (.apkg)';

  @override
  String get exportAnkiDescription => 'Набор карточек для Anki';

  @override
  String get exportPlainTextOption => 'Экспорт списка слов (текст)';

  @override
  String get exportPlainTextDescription =>
      'Слова через запятую для Renshuu и др.';

  @override
  String get wordListCopied => 'Список слов скопирован!';

  @override
  String get wordListDownloaded => 'Список слов загружен!';

  @override
  String get exportWordsTitle => 'Экспорт списка слов';

  @override
  String get includeVocab => 'Словарь';

  @override
  String get includeKanji => 'Кандзи';

  @override
  String get includeGrammar => 'Грамматика';

  @override
  String get copyToClipboard => 'Копировать';

  @override
  String get downloadAsFile => 'Скачать';

  @override
  String get noWordsToExport =>
      'Нет слов для экспорта. Выберите хотя бы одну категорию.';

  @override
  String get translationTab => 'Translation';

  @override
  String get nuanceExplanation => 'Nuance & Interpretation';

  @override
  String get noTranslationAvailable =>
      'Translation not available for this song. Try re-analyzing to generate verse translations.';
}
