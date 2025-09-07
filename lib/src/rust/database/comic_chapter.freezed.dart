// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comic_chapter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ComicChapter {

 String get id; String get comicId; String get title; int get indexInComic; int get imageCount;
/// Create a copy of ComicChapter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComicChapterCopyWith<ComicChapter> get copyWith => _$ComicChapterCopyWithImpl<ComicChapter>(this as ComicChapter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComicChapter&&(identical(other.id, id) || other.id == id)&&(identical(other.comicId, comicId) || other.comicId == comicId)&&(identical(other.title, title) || other.title == title)&&(identical(other.indexInComic, indexInComic) || other.indexInComic == indexInComic)&&(identical(other.imageCount, imageCount) || other.imageCount == imageCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,comicId,title,indexInComic,imageCount);

@override
String toString() {
  return 'ComicChapter(id: $id, comicId: $comicId, title: $title, indexInComic: $indexInComic, imageCount: $imageCount)';
}


}

/// @nodoc
abstract mixin class $ComicChapterCopyWith<$Res>  {
  factory $ComicChapterCopyWith(ComicChapter value, $Res Function(ComicChapter) _then) = _$ComicChapterCopyWithImpl;
@useResult
$Res call({
 String id, String comicId, String title, int indexInComic, int imageCount
});




}
/// @nodoc
class _$ComicChapterCopyWithImpl<$Res>
    implements $ComicChapterCopyWith<$Res> {
  _$ComicChapterCopyWithImpl(this._self, this._then);

  final ComicChapter _self;
  final $Res Function(ComicChapter) _then;

/// Create a copy of ComicChapter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? comicId = null,Object? title = null,Object? indexInComic = null,Object? imageCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,comicId: null == comicId ? _self.comicId : comicId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,indexInComic: null == indexInComic ? _self.indexInComic : indexInComic // ignore: cast_nullable_to_non_nullable
as int,imageCount: null == imageCount ? _self.imageCount : imageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ComicChapter].
extension ComicChapterPatterns on ComicChapter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComicChapter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComicChapter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComicChapter value)  $default,){
final _that = this;
switch (_that) {
case _ComicChapter():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComicChapter value)?  $default,){
final _that = this;
switch (_that) {
case _ComicChapter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String comicId,  String title,  int indexInComic,  int imageCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComicChapter() when $default != null:
return $default(_that.id,_that.comicId,_that.title,_that.indexInComic,_that.imageCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String comicId,  String title,  int indexInComic,  int imageCount)  $default,) {final _that = this;
switch (_that) {
case _ComicChapter():
return $default(_that.id,_that.comicId,_that.title,_that.indexInComic,_that.imageCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String comicId,  String title,  int indexInComic,  int imageCount)?  $default,) {final _that = this;
switch (_that) {
case _ComicChapter() when $default != null:
return $default(_that.id,_that.comicId,_that.title,_that.indexInComic,_that.imageCount);case _:
  return null;

}
}

}

/// @nodoc


class _ComicChapter implements ComicChapter {
  const _ComicChapter({required this.id, required this.comicId, required this.title, required this.indexInComic, required this.imageCount});
  

@override final  String id;
@override final  String comicId;
@override final  String title;
@override final  int indexInComic;
@override final  int imageCount;

/// Create a copy of ComicChapter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComicChapterCopyWith<_ComicChapter> get copyWith => __$ComicChapterCopyWithImpl<_ComicChapter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComicChapter&&(identical(other.id, id) || other.id == id)&&(identical(other.comicId, comicId) || other.comicId == comicId)&&(identical(other.title, title) || other.title == title)&&(identical(other.indexInComic, indexInComic) || other.indexInComic == indexInComic)&&(identical(other.imageCount, imageCount) || other.imageCount == imageCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,comicId,title,indexInComic,imageCount);

@override
String toString() {
  return 'ComicChapter(id: $id, comicId: $comicId, title: $title, indexInComic: $indexInComic, imageCount: $imageCount)';
}


}

/// @nodoc
abstract mixin class _$ComicChapterCopyWith<$Res> implements $ComicChapterCopyWith<$Res> {
  factory _$ComicChapterCopyWith(_ComicChapter value, $Res Function(_ComicChapter) _then) = __$ComicChapterCopyWithImpl;
@override @useResult
$Res call({
 String id, String comicId, String title, int indexInComic, int imageCount
});




}
/// @nodoc
class __$ComicChapterCopyWithImpl<$Res>
    implements _$ComicChapterCopyWith<$Res> {
  __$ComicChapterCopyWithImpl(this._self, this._then);

  final _ComicChapter _self;
  final $Res Function(_ComicChapter) _then;

/// Create a copy of ComicChapter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? comicId = null,Object? title = null,Object? indexInComic = null,Object? imageCount = null,}) {
  return _then(_ComicChapter(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,comicId: null == comicId ? _self.comicId : comicId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,indexInComic: null == indexInComic ? _self.indexInComic : indexInComic // ignore: cast_nullable_to_non_nullable
as int,imageCount: null == imageCount ? _self.imageCount : imageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
