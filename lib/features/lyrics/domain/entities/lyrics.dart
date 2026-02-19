import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lyrics.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Vocab {
  Vocab({
    required this.word,
    required this.reading,
    required this.meaning,
    required this.partOfSpeech,
    required this.jlptV,
    required this.jlptK,
    required this.context,
    required this.nuanceNote,
  });

  factory Vocab.fromJson(Map<String, dynamic> json) => _$VocabFromJson(json);
  @HiveField(0)
  final String word;
  @HiveField(1)
  final String reading;
  @HiveField(2)
  final String meaning;
  @HiveField(7)
  @JsonKey(name: 'part_of_speech')
  final String partOfSpeech;
  @HiveField(3)
  @JsonKey(name: 'jlpt_v')
  final String jlptV;
  @HiveField(4)
  @JsonKey(name: 'jlpt_k')
  final String jlptK;
  @HiveField(5)
  final String context;
  @HiveField(6)
  @JsonKey(name: 'nuance_note')
  final String nuanceNote;
  Map<String, dynamic> toJson() => _$VocabToJson(this);
}

@HiveType(typeId: 2)
@JsonSerializable()
class Grammar {
  Grammar({
    required this.point,
    required this.level,
    required this.explanation,
    required this.usage,
  });

  factory Grammar.fromJson(Map<String, dynamic> json) =>
      _$GrammarFromJson(json);
  @HiveField(0)
  final String point;
  @HiveField(1)
  final String level;
  @HiveField(2)
  final String explanation;
  @HiveField(3)
  final String usage;
  Map<String, dynamic> toJson() => _$GrammarToJson(this);
}

@HiveType(typeId: 3)
@JsonSerializable()
class Kanji {
  Kanji({
    required this.char,
    required this.level,
    required this.meanings,
    required this.readings,
  });

  factory Kanji.fromJson(Map<String, dynamic> json) => _$KanjiFromJson(json);
  @HiveField(0)
  final String char;
  @HiveField(1)
  final String level;
  @HiveField(2)
  final String meanings;
  @HiveField(3)
  final String readings;
  Map<String, dynamic> toJson() => _$KanjiToJson(this);
}

@HiveType(typeId: 4)
@JsonSerializable()
class EnVocab {
  EnVocab({
    required this.term,
    required this.ipa,
    required this.pos,
    required this.meaningJp,
    required this.nuanceJp,
  });

  factory EnVocab.fromJson(Map<String, dynamic> json) =>
      _$EnVocabFromJson(json);
  @HiveField(0)
  final String term;
  @HiveField(1)
  final String ipa;
  @HiveField(2)
  final String pos;
  @HiveField(3)
  @JsonKey(name: 'meaning_jp')
  final String meaningJp;
  @HiveField(4)
  @JsonKey(name: 'nuance_jp')
  final String nuanceJp;
  Map<String, dynamic> toJson() => _$EnVocabToJson(this);
}

@HiveType(typeId: 5)
@JsonSerializable()
class EnGrammar {
  EnGrammar({
    required this.structure,
    required this.cefrLevel,
    required this.explanationJp,
    required this.excerpt,
  });

  factory EnGrammar.fromJson(Map<String, dynamic> json) =>
      _$EnGrammarFromJson(json);
  @HiveField(0)
  final String structure;
  @HiveField(1)
  @JsonKey(name: 'cefr_level')
  final String cefrLevel;
  @HiveField(2)
  @JsonKey(name: 'explanation_jp')
  final String explanationJp;
  @HiveField(3)
  final String excerpt;
  Map<String, dynamic> toJson() => _$EnGrammarToJson(this);
}

@HiveType(typeId: 0)
class HistoryItem extends HiveObject {
  HistoryItem({
    required this.songTitle,
    required this.artist,
    required this.lyricsSnippet,
    required this.analyzedAt,
    this.tags = const [],
    this.targetLanguage = 'English',
  });
  @HiveField(0)
  late String songTitle;

  @HiveField(1)
  late String artist;

  @HiveField(2)
  late String lyricsSnippet;

  @HiveField(3)
  late DateTime analyzedAt;

  @HiveField(4)
  List<String> tags = [];

  @HiveField(5)
  late String targetLanguage;

  @HiveField(6)
  List<Vocab> vocabs = [];

  @HiveField(7)
  List<Grammar> grammar = [];

  @HiveField(8)
  List<Kanji> kanji = [];

  @HiveField(9)
  String? youtubeId;

  @HiveField(10)
  String? lyrics;

  @HiveField(11)
  List<EnVocab>? enVocab;

  @HiveField(12)
  List<EnGrammar>? enGrammar;

  @HiveField(13)
  String? overallCefr;
}

class SongNotFoundException implements Exception {
  SongNotFoundException(this.title, this.artist);
  final String title;
  final String artist;

  @override
  String toString() => 'SongNotFoundException: $title by $artist';
}

class ServerOverloadedException implements Exception {
  @override
  String toString() => 'ServerOverloadedException: model is overloaded';
}

class QuotaExceededException implements Exception {
  @override
  String toString() => 'QuotaExceededException: daily quota exceeded';
}

class AnalysisResult {
  AnalysisResult({
    required this.vocabs,
    required this.grammar,
    required this.kanji,
    this.song = '',
    this.artist = '',
    this.youtubeId,
    this.lyrics = '',
    this.isComplete = true,
    this.enVocab,
    this.enGrammar,
    this.overallCefr,
  });

  final List<Vocab> vocabs;
  final List<Grammar> grammar;
  final List<Kanji> kanji;
  final String song;
  final String artist;
  final String? youtubeId;
  final String lyrics;
  final bool isComplete;
  final List<EnVocab>? enVocab;
  final List<EnGrammar>? enGrammar;
  final String? overallCefr;
}
