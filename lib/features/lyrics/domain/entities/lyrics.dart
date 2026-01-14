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
}

class SongNotFoundException implements Exception {

  SongNotFoundException(this.title, this.artist);
  final String title;
  final String artist;

  @override
  String toString() => 'SongNotFoundException: $title by $artist';
}

class AnalysisResult {
  AnalysisResult({
    required this.vocabs,
    required this.grammar,
    required this.kanji,
    this.song = '',
    this.artist = '',
    this.youtubeId,
  });

  final List<Vocab> vocabs;
  final List<Grammar> grammar;
  final List<Kanji> kanji;
  final String song;
  final String artist;
  final String? youtubeId;
}
