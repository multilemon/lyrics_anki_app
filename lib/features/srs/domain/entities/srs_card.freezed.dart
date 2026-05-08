// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'srs_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SrsCard {

@HiveField(0) String get word;@HiveField(1) String get reading;@HiveField(2) String get meaning;@HiveField(9) DateTime get nextReview;@HiveField(10) DateTime get lastReviewed;@HiveField(3) String? get songTitle;@HiveField(4) String? get artist;@HiveField(5) String? get context;@HiveField(6) double get easeFactor;@HiveField(7) int get interval;// in days
@HiveField(8) int get repetitions;@HiveField(11) bool get isSuspended;@HiveField(12) String? get jlptV;
/// Create a copy of SrsCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SrsCardCopyWith<SrsCard> get copyWith => _$SrsCardCopyWithImpl<SrsCard>(this as SrsCard, _$identity);

  /// Serializes this SrsCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SrsCard&&(identical(other.word, word) || other.word == word)&&(identical(other.reading, reading) || other.reading == reading)&&(identical(other.meaning, meaning) || other.meaning == meaning)&&(identical(other.nextReview, nextReview) || other.nextReview == nextReview)&&(identical(other.lastReviewed, lastReviewed) || other.lastReviewed == lastReviewed)&&(identical(other.songTitle, songTitle) || other.songTitle == songTitle)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.context, context) || other.context == context)&&(identical(other.easeFactor, easeFactor) || other.easeFactor == easeFactor)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.repetitions, repetitions) || other.repetitions == repetitions)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.jlptV, jlptV) || other.jlptV == jlptV));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,reading,meaning,nextReview,lastReviewed,songTitle,artist,context,easeFactor,interval,repetitions,isSuspended,jlptV);

@override
String toString() {
  return 'SrsCard(word: $word, reading: $reading, meaning: $meaning, nextReview: $nextReview, lastReviewed: $lastReviewed, songTitle: $songTitle, artist: $artist, context: $context, easeFactor: $easeFactor, interval: $interval, repetitions: $repetitions, isSuspended: $isSuspended, jlptV: $jlptV)';
}


}

/// @nodoc
abstract mixin class $SrsCardCopyWith<$Res>  {
  factory $SrsCardCopyWith(SrsCard value, $Res Function(SrsCard) _then) = _$SrsCardCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String word,@HiveField(1) String reading,@HiveField(2) String meaning,@HiveField(9) DateTime nextReview,@HiveField(10) DateTime lastReviewed,@HiveField(3) String? songTitle,@HiveField(4) String? artist,@HiveField(5) String? context,@HiveField(6) double easeFactor,@HiveField(7) int interval,@HiveField(8) int repetitions,@HiveField(11) bool isSuspended,@HiveField(12) String? jlptV
});




}
/// @nodoc
class _$SrsCardCopyWithImpl<$Res>
    implements $SrsCardCopyWith<$Res> {
  _$SrsCardCopyWithImpl(this._self, this._then);

  final SrsCard _self;
  final $Res Function(SrsCard) _then;

/// Create a copy of SrsCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? word = null,Object? reading = null,Object? meaning = null,Object? nextReview = null,Object? lastReviewed = null,Object? songTitle = freezed,Object? artist = freezed,Object? context = freezed,Object? easeFactor = null,Object? interval = null,Object? repetitions = null,Object? isSuspended = null,Object? jlptV = freezed,}) {
  return _then(_self.copyWith(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,reading: null == reading ? _self.reading : reading // ignore: cast_nullable_to_non_nullable
as String,meaning: null == meaning ? _self.meaning : meaning // ignore: cast_nullable_to_non_nullable
as String,nextReview: null == nextReview ? _self.nextReview : nextReview // ignore: cast_nullable_to_non_nullable
as DateTime,lastReviewed: null == lastReviewed ? _self.lastReviewed : lastReviewed // ignore: cast_nullable_to_non_nullable
as DateTime,songTitle: freezed == songTitle ? _self.songTitle : songTitle // ignore: cast_nullable_to_non_nullable
as String?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String?,easeFactor: null == easeFactor ? _self.easeFactor : easeFactor // ignore: cast_nullable_to_non_nullable
as double,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,repetitions: null == repetitions ? _self.repetitions : repetitions // ignore: cast_nullable_to_non_nullable
as int,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,jlptV: freezed == jlptV ? _self.jlptV : jlptV // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SrsCard].
extension SrsCardPatterns on SrsCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SrsCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SrsCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SrsCard value)  $default,){
final _that = this;
switch (_that) {
case _SrsCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SrsCard value)?  $default,){
final _that = this;
switch (_that) {
case _SrsCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String word, @HiveField(1)  String reading, @HiveField(2)  String meaning, @HiveField(9)  DateTime nextReview, @HiveField(10)  DateTime lastReviewed, @HiveField(3)  String? songTitle, @HiveField(4)  String? artist, @HiveField(5)  String? context, @HiveField(6)  double easeFactor, @HiveField(7)  int interval, @HiveField(8)  int repetitions, @HiveField(11)  bool isSuspended, @HiveField(12)  String? jlptV)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SrsCard() when $default != null:
return $default(_that.word,_that.reading,_that.meaning,_that.nextReview,_that.lastReviewed,_that.songTitle,_that.artist,_that.context,_that.easeFactor,_that.interval,_that.repetitions,_that.isSuspended,_that.jlptV);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String word, @HiveField(1)  String reading, @HiveField(2)  String meaning, @HiveField(9)  DateTime nextReview, @HiveField(10)  DateTime lastReviewed, @HiveField(3)  String? songTitle, @HiveField(4)  String? artist, @HiveField(5)  String? context, @HiveField(6)  double easeFactor, @HiveField(7)  int interval, @HiveField(8)  int repetitions, @HiveField(11)  bool isSuspended, @HiveField(12)  String? jlptV)  $default,) {final _that = this;
switch (_that) {
case _SrsCard():
return $default(_that.word,_that.reading,_that.meaning,_that.nextReview,_that.lastReviewed,_that.songTitle,_that.artist,_that.context,_that.easeFactor,_that.interval,_that.repetitions,_that.isSuspended,_that.jlptV);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String word, @HiveField(1)  String reading, @HiveField(2)  String meaning, @HiveField(9)  DateTime nextReview, @HiveField(10)  DateTime lastReviewed, @HiveField(3)  String? songTitle, @HiveField(4)  String? artist, @HiveField(5)  String? context, @HiveField(6)  double easeFactor, @HiveField(7)  int interval, @HiveField(8)  int repetitions, @HiveField(11)  bool isSuspended, @HiveField(12)  String? jlptV)?  $default,) {final _that = this;
switch (_that) {
case _SrsCard() when $default != null:
return $default(_that.word,_that.reading,_that.meaning,_that.nextReview,_that.lastReviewed,_that.songTitle,_that.artist,_that.context,_that.easeFactor,_that.interval,_that.repetitions,_that.isSuspended,_that.jlptV);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SrsCard extends SrsCard {
  const _SrsCard({@HiveField(0) required this.word, @HiveField(1) required this.reading, @HiveField(2) required this.meaning, @HiveField(9) required this.nextReview, @HiveField(10) required this.lastReviewed, @HiveField(3) this.songTitle, @HiveField(4) this.artist, @HiveField(5) this.context, @HiveField(6) this.easeFactor = 2.5, @HiveField(7) this.interval = 0, @HiveField(8) this.repetitions = 0, @HiveField(11) this.isSuspended = false, @HiveField(12) this.jlptV}): super._();
  factory _SrsCard.fromJson(Map<String, dynamic> json) => _$SrsCardFromJson(json);

@override@HiveField(0) final  String word;
@override@HiveField(1) final  String reading;
@override@HiveField(2) final  String meaning;
@override@HiveField(9) final  DateTime nextReview;
@override@HiveField(10) final  DateTime lastReviewed;
@override@HiveField(3) final  String? songTitle;
@override@HiveField(4) final  String? artist;
@override@HiveField(5) final  String? context;
@override@JsonKey()@HiveField(6) final  double easeFactor;
@override@JsonKey()@HiveField(7) final  int interval;
// in days
@override@JsonKey()@HiveField(8) final  int repetitions;
@override@JsonKey()@HiveField(11) final  bool isSuspended;
@override@HiveField(12) final  String? jlptV;

/// Create a copy of SrsCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SrsCardCopyWith<_SrsCard> get copyWith => __$SrsCardCopyWithImpl<_SrsCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SrsCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SrsCard&&(identical(other.word, word) || other.word == word)&&(identical(other.reading, reading) || other.reading == reading)&&(identical(other.meaning, meaning) || other.meaning == meaning)&&(identical(other.nextReview, nextReview) || other.nextReview == nextReview)&&(identical(other.lastReviewed, lastReviewed) || other.lastReviewed == lastReviewed)&&(identical(other.songTitle, songTitle) || other.songTitle == songTitle)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.context, context) || other.context == context)&&(identical(other.easeFactor, easeFactor) || other.easeFactor == easeFactor)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.repetitions, repetitions) || other.repetitions == repetitions)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.jlptV, jlptV) || other.jlptV == jlptV));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,reading,meaning,nextReview,lastReviewed,songTitle,artist,context,easeFactor,interval,repetitions,isSuspended,jlptV);

@override
String toString() {
  return 'SrsCard(word: $word, reading: $reading, meaning: $meaning, nextReview: $nextReview, lastReviewed: $lastReviewed, songTitle: $songTitle, artist: $artist, context: $context, easeFactor: $easeFactor, interval: $interval, repetitions: $repetitions, isSuspended: $isSuspended, jlptV: $jlptV)';
}


}

/// @nodoc
abstract mixin class _$SrsCardCopyWith<$Res> implements $SrsCardCopyWith<$Res> {
  factory _$SrsCardCopyWith(_SrsCard value, $Res Function(_SrsCard) _then) = __$SrsCardCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String word,@HiveField(1) String reading,@HiveField(2) String meaning,@HiveField(9) DateTime nextReview,@HiveField(10) DateTime lastReviewed,@HiveField(3) String? songTitle,@HiveField(4) String? artist,@HiveField(5) String? context,@HiveField(6) double easeFactor,@HiveField(7) int interval,@HiveField(8) int repetitions,@HiveField(11) bool isSuspended,@HiveField(12) String? jlptV
});




}
/// @nodoc
class __$SrsCardCopyWithImpl<$Res>
    implements _$SrsCardCopyWith<$Res> {
  __$SrsCardCopyWithImpl(this._self, this._then);

  final _SrsCard _self;
  final $Res Function(_SrsCard) _then;

/// Create a copy of SrsCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? word = null,Object? reading = null,Object? meaning = null,Object? nextReview = null,Object? lastReviewed = null,Object? songTitle = freezed,Object? artist = freezed,Object? context = freezed,Object? easeFactor = null,Object? interval = null,Object? repetitions = null,Object? isSuspended = null,Object? jlptV = freezed,}) {
  return _then(_SrsCard(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,reading: null == reading ? _self.reading : reading // ignore: cast_nullable_to_non_nullable
as String,meaning: null == meaning ? _self.meaning : meaning // ignore: cast_nullable_to_non_nullable
as String,nextReview: null == nextReview ? _self.nextReview : nextReview // ignore: cast_nullable_to_non_nullable
as DateTime,lastReviewed: null == lastReviewed ? _self.lastReviewed : lastReviewed // ignore: cast_nullable_to_non_nullable
as DateTime,songTitle: freezed == songTitle ? _self.songTitle : songTitle // ignore: cast_nullable_to_non_nullable
as String?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String?,easeFactor: null == easeFactor ? _self.easeFactor : easeFactor // ignore: cast_nullable_to_non_nullable
as double,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,repetitions: null == repetitions ? _self.repetitions : repetitions // ignore: cast_nullable_to_non_nullable
as int,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,jlptV: freezed == jlptV ? _self.jlptV : jlptV // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
