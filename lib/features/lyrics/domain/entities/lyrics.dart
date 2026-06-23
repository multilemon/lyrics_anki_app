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

@HiveType(typeId: 5)
@JsonSerializable()
class LyricVerse {
  LyricVerse({
    required this.original,
    required this.translation,
    required this.nuance,
  });

  factory LyricVerse.fromJson(Map<String, dynamic> json) =>
      _$LyricVerseFromJson(json);
  @HiveField(0)
  final String original;
  @HiveField(1)
  final String translation;
  @HiveField(2)
  final String nuance;
  Map<String, dynamic> toJson() => _$LyricVerseToJson(this);
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
  List<LyricVerse> verses = [];

  /// Computes difficulty from stored vocab/kanji JLPT data.
  SongDifficulty get difficulty =>
      SongDifficulty.fromVocabsAndKanji(vocabs, kanji);
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
    this.verses = const [],
    this.isComplete = true,
  });

  final List<Vocab> vocabs;
  final List<Grammar> grammar;
  final List<Kanji> kanji;
  final String song;
  final String artist;
  final String? youtubeId;
  final String lyrics;
  final List<LyricVerse> verses;
  final bool isComplete;

  /// Human-readable difficulty label.
  SongDifficulty get difficulty =>
      SongDifficulty.fromVocabsAndKanji(vocabs, kanji);
}

/// Song difficulty derived from JLPT distribution.
// dart format off
enum SongDifficulty {
  beginner,
  intermediate,
  advanced,
  ;

  /// Computes difficulty from a list of vocab and kanji items.
  static SongDifficulty fromVocabsAndKanji(
    List<Vocab> vocabs,
    List<Kanji> kanji,
  ) {
    final dist = jlptDistributionOf(vocabs, kanji);
    final total = dist.values.fold(0, (s, v) => s + v);
    if (total == 0) return SongDifficulty.beginner;

    const weights = {'N5': 1, 'N4': 2, 'N3': 3, 'N2': 4, 'N1': 5};
    var weightedSum = 0.0;
    for (final entry in dist.entries) {
      weightedSum += (weights[entry.key] ?? 0) * entry.value;
    }

    final avgLevel = weightedSum / total;
    final score = ((avgLevel - 1) / 4).clamp(0.0, 1.0);

    if (score < 0.35) return SongDifficulty.beginner;
    if (score < 0.65) return SongDifficulty.intermediate;
    return SongDifficulty.advanced;
  }

  /// JLPT distribution across vocab (jlptV) and kanji (level).
  static Map<String, int> jlptDistributionOf(
    List<Vocab> vocabs,
    List<Kanji> kanji,
  ) {
    final dist = <String, int>{
      'N5': 0,
      'N4': 0,
      'N3': 0,
      'N2': 0,
      'N1': 0,
    };

    for (final v in vocabs) {
      final level = v.jlptV.toUpperCase().trim();
      if (dist.containsKey(level)) {
        dist[level] = dist[level]! + 1;
      }
    }

    for (final k in kanji) {
      final level = k.level.toUpperCase().trim();
      if (dist.containsKey(level)) {
        dist[level] = dist[level]! + 1;
      }
    }

    return dist;
  }
}
// dart format on
