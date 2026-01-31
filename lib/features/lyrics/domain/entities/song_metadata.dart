import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_metadata.freezed.dart';
part 'song_metadata.g.dart';

@freezed
class SongMetadata with _$SongMetadata {
  const factory SongMetadata({
    required String title,
    required String artist,
    required String youtubeId,
  }) = _SongMetadata;

  factory SongMetadata.fromJson(Map<String, dynamic> json) =>
      _$SongMetadataFromJson(json);
}
