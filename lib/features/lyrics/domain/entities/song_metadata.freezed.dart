// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SongMetadata _$SongMetadataFromJson(Map<String, dynamic> json) {
  return _SongMetadata.fromJson(json);
}

/// @nodoc
mixin _$SongMetadata {
  String get title => throw _privateConstructorUsedError;
  String get artist => throw _privateConstructorUsedError;
  String get youtubeId => throw _privateConstructorUsedError;

  /// Serializes this SongMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SongMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SongMetadataCopyWith<SongMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongMetadataCopyWith<$Res> {
  factory $SongMetadataCopyWith(
          SongMetadata value, $Res Function(SongMetadata) then) =
      _$SongMetadataCopyWithImpl<$Res, SongMetadata>;
  @useResult
  $Res call({String title, String artist, String youtubeId});
}

/// @nodoc
class _$SongMetadataCopyWithImpl<$Res, $Val extends SongMetadata>
    implements $SongMetadataCopyWith<$Res> {
  _$SongMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SongMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? artist = null,
    Object? youtubeId = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      youtubeId: null == youtubeId
          ? _value.youtubeId
          : youtubeId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SongMetadataImplCopyWith<$Res>
    implements $SongMetadataCopyWith<$Res> {
  factory _$$SongMetadataImplCopyWith(
          _$SongMetadataImpl value, $Res Function(_$SongMetadataImpl) then) =
      __$$SongMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String artist, String youtubeId});
}

/// @nodoc
class __$$SongMetadataImplCopyWithImpl<$Res>
    extends _$SongMetadataCopyWithImpl<$Res, _$SongMetadataImpl>
    implements _$$SongMetadataImplCopyWith<$Res> {
  __$$SongMetadataImplCopyWithImpl(
      _$SongMetadataImpl _value, $Res Function(_$SongMetadataImpl) _then)
      : super(_value, _then);

  /// Create a copy of SongMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? artist = null,
    Object? youtubeId = null,
  }) {
    return _then(_$SongMetadataImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      youtubeId: null == youtubeId
          ? _value.youtubeId
          : youtubeId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SongMetadataImpl implements _SongMetadata {
  const _$SongMetadataImpl(
      {required this.title, required this.artist, required this.youtubeId});

  factory _$SongMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SongMetadataImplFromJson(json);

  @override
  final String title;
  @override
  final String artist;
  @override
  final String youtubeId;

  @override
  String toString() {
    return 'SongMetadata(title: $title, artist: $artist, youtubeId: $youtubeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SongMetadataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.youtubeId, youtubeId) ||
                other.youtubeId == youtubeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, artist, youtubeId);

  /// Create a copy of SongMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SongMetadataImplCopyWith<_$SongMetadataImpl> get copyWith =>
      __$$SongMetadataImplCopyWithImpl<_$SongMetadataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SongMetadataImplToJson(
      this,
    );
  }
}

abstract class _SongMetadata implements SongMetadata {
  const factory _SongMetadata(
      {required final String title,
      required final String artist,
      required final String youtubeId}) = _$SongMetadataImpl;

  factory _SongMetadata.fromJson(Map<String, dynamic> json) =
      _$SongMetadataImpl.fromJson;

  @override
  String get title;
  @override
  String get artist;
  @override
  String get youtubeId;

  /// Create a copy of SongMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SongMetadataImplCopyWith<_$SongMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
