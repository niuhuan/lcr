// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comic_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ComicImage {

 String get id; String get comicId; String get chapterId; int get indexInChapter; String get path; int get width; int get height; String get format; String get status;
/// Create a copy of ComicImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComicImageCopyWith<ComicImage> get copyWith => _$ComicImageCopyWithImpl<ComicImage>(this as ComicImage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComicImage&&(identical(other.id, id) || other.id == id)&&(identical(other.comicId, comicId) || other.comicId == comicId)&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.indexInChapter, indexInChapter) || other.indexInChapter == indexInChapter)&&(identical(other.path, path) || other.path == path)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.format, format) || other.format == format)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,comicId,chapterId,indexInChapter,path,width,height,format,status);

@override
String toString() {
  return 'ComicImage(id: $id, comicId: $comicId, chapterId: $chapterId, indexInChapter: $indexInChapter, path: $path, width: $width, height: $height, format: $format, status: $status)';
}


}

/// @nodoc
abstract mixin class $ComicImageCopyWith<$Res>  {
  factory $ComicImageCopyWith(ComicImage value, $Res Function(ComicImage) _then) = _$ComicImageCopyWithImpl;
@useResult
$Res call({
 String id, String comicId, String chapterId, int indexInChapter, String path, int width, int height, String format, String status
});




}
/// @nodoc
class _$ComicImageCopyWithImpl<$Res>
    implements $ComicImageCopyWith<$Res> {
  _$ComicImageCopyWithImpl(this._self, this._then);

  final ComicImage _self;
  final $Res Function(ComicImage) _then;

/// Create a copy of ComicImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? comicId = null,Object? chapterId = null,Object? indexInChapter = null,Object? path = null,Object? width = null,Object? height = null,Object? format = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,comicId: null == comicId ? _self.comicId : comicId // ignore: cast_nullable_to_non_nullable
as String,chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String,indexInChapter: null == indexInChapter ? _self.indexInChapter : indexInChapter // ignore: cast_nullable_to_non_nullable
as int,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ComicImage].
extension ComicImagePatterns on ComicImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComicImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComicImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComicImage value)  $default,){
final _that = this;
switch (_that) {
case _ComicImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComicImage value)?  $default,){
final _that = this;
switch (_that) {
case _ComicImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String comicId,  String chapterId,  int indexInChapter,  String path,  int width,  int height,  String format,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComicImage() when $default != null:
return $default(_that.id,_that.comicId,_that.chapterId,_that.indexInChapter,_that.path,_that.width,_that.height,_that.format,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String comicId,  String chapterId,  int indexInChapter,  String path,  int width,  int height,  String format,  String status)  $default,) {final _that = this;
switch (_that) {
case _ComicImage():
return $default(_that.id,_that.comicId,_that.chapterId,_that.indexInChapter,_that.path,_that.width,_that.height,_that.format,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String comicId,  String chapterId,  int indexInChapter,  String path,  int width,  int height,  String format,  String status)?  $default,) {final _that = this;
switch (_that) {
case _ComicImage() when $default != null:
return $default(_that.id,_that.comicId,_that.chapterId,_that.indexInChapter,_that.path,_that.width,_that.height,_that.format,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _ComicImage implements ComicImage {
  const _ComicImage({required this.id, required this.comicId, required this.chapterId, required this.indexInChapter, required this.path, required this.width, required this.height, required this.format, required this.status});
  

@override final  String id;
@override final  String comicId;
@override final  String chapterId;
@override final  int indexInChapter;
@override final  String path;
@override final  int width;
@override final  int height;
@override final  String format;
@override final  String status;

/// Create a copy of ComicImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComicImageCopyWith<_ComicImage> get copyWith => __$ComicImageCopyWithImpl<_ComicImage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComicImage&&(identical(other.id, id) || other.id == id)&&(identical(other.comicId, comicId) || other.comicId == comicId)&&(identical(other.chapterId, chapterId) || other.chapterId == chapterId)&&(identical(other.indexInChapter, indexInChapter) || other.indexInChapter == indexInChapter)&&(identical(other.path, path) || other.path == path)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.format, format) || other.format == format)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,comicId,chapterId,indexInChapter,path,width,height,format,status);

@override
String toString() {
  return 'ComicImage(id: $id, comicId: $comicId, chapterId: $chapterId, indexInChapter: $indexInChapter, path: $path, width: $width, height: $height, format: $format, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ComicImageCopyWith<$Res> implements $ComicImageCopyWith<$Res> {
  factory _$ComicImageCopyWith(_ComicImage value, $Res Function(_ComicImage) _then) = __$ComicImageCopyWithImpl;
@override @useResult
$Res call({
 String id, String comicId, String chapterId, int indexInChapter, String path, int width, int height, String format, String status
});




}
/// @nodoc
class __$ComicImageCopyWithImpl<$Res>
    implements _$ComicImageCopyWith<$Res> {
  __$ComicImageCopyWithImpl(this._self, this._then);

  final _ComicImage _self;
  final $Res Function(_ComicImage) _then;

/// Create a copy of ComicImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? comicId = null,Object? chapterId = null,Object? indexInChapter = null,Object? path = null,Object? width = null,Object? height = null,Object? format = null,Object? status = null,}) {
  return _then(_ComicImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,comicId: null == comicId ? _self.comicId : comicId // ignore: cast_nullable_to_non_nullable
as String,chapterId: null == chapterId ? _self.chapterId : chapterId // ignore: cast_nullable_to_non_nullable
as String,indexInChapter: null == indexInChapter ? _self.indexInChapter : indexInChapter // ignore: cast_nullable_to_non_nullable
as int,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
