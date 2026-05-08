// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SongMetadata {

 String get title; String get artist; String get youtubeId;
/// Create a copy of SongMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SongMetadataCopyWith<SongMetadata> get copyWith => _$SongMetadataCopyWithImpl<SongMetadata>(this as SongMetadata, _$identity);

  /// Serializes this SongMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SongMetadata&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.youtubeId, youtubeId) || other.youtubeId == youtubeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,artist,youtubeId);

@override
String toString() {
  return 'SongMetadata(title: $title, artist: $artist, youtubeId: $youtubeId)';
}


}

/// @nodoc
abstract mixin class $SongMetadataCopyWith<$Res>  {
  factory $SongMetadataCopyWith(SongMetadata value, $Res Function(SongMetadata) _then) = _$SongMetadataCopyWithImpl;
@useResult
$Res call({
 String title, String artist, String youtubeId
});




}
/// @nodoc
class _$SongMetadataCopyWithImpl<$Res>
    implements $SongMetadataCopyWith<$Res> {
  _$SongMetadataCopyWithImpl(this._self, this._then);

  final SongMetadata _self;
  final $Res Function(SongMetadata) _then;

/// Create a copy of SongMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? artist = null,Object? youtubeId = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,youtubeId: null == youtubeId ? _self.youtubeId : youtubeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SongMetadata].
extension SongMetadataPatterns on SongMetadata {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SongMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SongMetadata() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SongMetadata value)  $default,){
final _that = this;
switch (_that) {
case _SongMetadata():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SongMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _SongMetadata() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String artist,  String youtubeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SongMetadata() when $default != null:
return $default(_that.title,_that.artist,_that.youtubeId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String artist,  String youtubeId)  $default,) {final _that = this;
switch (_that) {
case _SongMetadata():
return $default(_that.title,_that.artist,_that.youtubeId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String artist,  String youtubeId)?  $default,) {final _that = this;
switch (_that) {
case _SongMetadata() when $default != null:
return $default(_that.title,_that.artist,_that.youtubeId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SongMetadata implements SongMetadata {
  const _SongMetadata({required this.title, required this.artist, required this.youtubeId});
  factory _SongMetadata.fromJson(Map<String, dynamic> json) => _$SongMetadataFromJson(json);

@override final  String title;
@override final  String artist;
@override final  String youtubeId;

/// Create a copy of SongMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SongMetadataCopyWith<_SongMetadata> get copyWith => __$SongMetadataCopyWithImpl<_SongMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SongMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SongMetadata&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.youtubeId, youtubeId) || other.youtubeId == youtubeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,artist,youtubeId);

@override
String toString() {
  return 'SongMetadata(title: $title, artist: $artist, youtubeId: $youtubeId)';
}


}

/// @nodoc
abstract mixin class _$SongMetadataCopyWith<$Res> implements $SongMetadataCopyWith<$Res> {
  factory _$SongMetadataCopyWith(_SongMetadata value, $Res Function(_SongMetadata) _then) = __$SongMetadataCopyWithImpl;
@override @useResult
$Res call({
 String title, String artist, String youtubeId
});




}
/// @nodoc
class __$SongMetadataCopyWithImpl<$Res>
    implements _$SongMetadataCopyWith<$Res> {
  __$SongMetadataCopyWithImpl(this._self, this._then);

  final _SongMetadata _self;
  final $Res Function(_SongMetadata) _then;

/// Create a copy of SongMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? artist = null,Object? youtubeId = null,}) {
  return _then(_SongMetadata(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,youtubeId: null == youtubeId ? _self.youtubeId : youtubeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
