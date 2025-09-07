// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettings {

 PlatformInt64 get id; String get theme; String get darkTheme; bool get copySkipConfirm; String get copyComicTitleTemplate; bool get autoFullScreenIntoReader; String get bookListType; int get fontScalePercent; int get coverWidth; int get coverHeight; bool get annotation; bool get fullScreenRemoveBars; bool get enableVolumeControl;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.darkTheme, darkTheme) || other.darkTheme == darkTheme)&&(identical(other.copySkipConfirm, copySkipConfirm) || other.copySkipConfirm == copySkipConfirm)&&(identical(other.copyComicTitleTemplate, copyComicTitleTemplate) || other.copyComicTitleTemplate == copyComicTitleTemplate)&&(identical(other.autoFullScreenIntoReader, autoFullScreenIntoReader) || other.autoFullScreenIntoReader == autoFullScreenIntoReader)&&(identical(other.bookListType, bookListType) || other.bookListType == bookListType)&&(identical(other.fontScalePercent, fontScalePercent) || other.fontScalePercent == fontScalePercent)&&(identical(other.coverWidth, coverWidth) || other.coverWidth == coverWidth)&&(identical(other.coverHeight, coverHeight) || other.coverHeight == coverHeight)&&(identical(other.annotation, annotation) || other.annotation == annotation)&&(identical(other.fullScreenRemoveBars, fullScreenRemoveBars) || other.fullScreenRemoveBars == fullScreenRemoveBars)&&(identical(other.enableVolumeControl, enableVolumeControl) || other.enableVolumeControl == enableVolumeControl));
}


@override
int get hashCode => Object.hash(runtimeType,id,theme,darkTheme,copySkipConfirm,copyComicTitleTemplate,autoFullScreenIntoReader,bookListType,fontScalePercent,coverWidth,coverHeight,annotation,fullScreenRemoveBars,enableVolumeControl);

@override
String toString() {
  return 'AppSettings(id: $id, theme: $theme, darkTheme: $darkTheme, copySkipConfirm: $copySkipConfirm, copyComicTitleTemplate: $copyComicTitleTemplate, autoFullScreenIntoReader: $autoFullScreenIntoReader, bookListType: $bookListType, fontScalePercent: $fontScalePercent, coverWidth: $coverWidth, coverHeight: $coverHeight, annotation: $annotation, fullScreenRemoveBars: $fullScreenRemoveBars, enableVolumeControl: $enableVolumeControl)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 PlatformInt64 id, String theme, String darkTheme, bool copySkipConfirm, String copyComicTitleTemplate, bool autoFullScreenIntoReader, String bookListType, int fontScalePercent, int coverWidth, int coverHeight, bool annotation, bool fullScreenRemoveBars, bool enableVolumeControl
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? theme = null,Object? darkTheme = null,Object? copySkipConfirm = null,Object? copyComicTitleTemplate = null,Object? autoFullScreenIntoReader = null,Object? bookListType = null,Object? fontScalePercent = null,Object? coverWidth = null,Object? coverHeight = null,Object? annotation = null,Object? fullScreenRemoveBars = null,Object? enableVolumeControl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PlatformInt64,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,darkTheme: null == darkTheme ? _self.darkTheme : darkTheme // ignore: cast_nullable_to_non_nullable
as String,copySkipConfirm: null == copySkipConfirm ? _self.copySkipConfirm : copySkipConfirm // ignore: cast_nullable_to_non_nullable
as bool,copyComicTitleTemplate: null == copyComicTitleTemplate ? _self.copyComicTitleTemplate : copyComicTitleTemplate // ignore: cast_nullable_to_non_nullable
as String,autoFullScreenIntoReader: null == autoFullScreenIntoReader ? _self.autoFullScreenIntoReader : autoFullScreenIntoReader // ignore: cast_nullable_to_non_nullable
as bool,bookListType: null == bookListType ? _self.bookListType : bookListType // ignore: cast_nullable_to_non_nullable
as String,fontScalePercent: null == fontScalePercent ? _self.fontScalePercent : fontScalePercent // ignore: cast_nullable_to_non_nullable
as int,coverWidth: null == coverWidth ? _self.coverWidth : coverWidth // ignore: cast_nullable_to_non_nullable
as int,coverHeight: null == coverHeight ? _self.coverHeight : coverHeight // ignore: cast_nullable_to_non_nullable
as int,annotation: null == annotation ? _self.annotation : annotation // ignore: cast_nullable_to_non_nullable
as bool,fullScreenRemoveBars: null == fullScreenRemoveBars ? _self.fullScreenRemoveBars : fullScreenRemoveBars // ignore: cast_nullable_to_non_nullable
as bool,enableVolumeControl: null == enableVolumeControl ? _self.enableVolumeControl : enableVolumeControl // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlatformInt64 id,  String theme,  String darkTheme,  bool copySkipConfirm,  String copyComicTitleTemplate,  bool autoFullScreenIntoReader,  String bookListType,  int fontScalePercent,  int coverWidth,  int coverHeight,  bool annotation,  bool fullScreenRemoveBars,  bool enableVolumeControl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.id,_that.theme,_that.darkTheme,_that.copySkipConfirm,_that.copyComicTitleTemplate,_that.autoFullScreenIntoReader,_that.bookListType,_that.fontScalePercent,_that.coverWidth,_that.coverHeight,_that.annotation,_that.fullScreenRemoveBars,_that.enableVolumeControl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlatformInt64 id,  String theme,  String darkTheme,  bool copySkipConfirm,  String copyComicTitleTemplate,  bool autoFullScreenIntoReader,  String bookListType,  int fontScalePercent,  int coverWidth,  int coverHeight,  bool annotation,  bool fullScreenRemoveBars,  bool enableVolumeControl)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.id,_that.theme,_that.darkTheme,_that.copySkipConfirm,_that.copyComicTitleTemplate,_that.autoFullScreenIntoReader,_that.bookListType,_that.fontScalePercent,_that.coverWidth,_that.coverHeight,_that.annotation,_that.fullScreenRemoveBars,_that.enableVolumeControl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlatformInt64 id,  String theme,  String darkTheme,  bool copySkipConfirm,  String copyComicTitleTemplate,  bool autoFullScreenIntoReader,  String bookListType,  int fontScalePercent,  int coverWidth,  int coverHeight,  bool annotation,  bool fullScreenRemoveBars,  bool enableVolumeControl)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.id,_that.theme,_that.darkTheme,_that.copySkipConfirm,_that.copyComicTitleTemplate,_that.autoFullScreenIntoReader,_that.bookListType,_that.fontScalePercent,_that.coverWidth,_that.coverHeight,_that.annotation,_that.fullScreenRemoveBars,_that.enableVolumeControl);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings implements AppSettings {
  const _AppSettings({required this.id, required this.theme, required this.darkTheme, required this.copySkipConfirm, required this.copyComicTitleTemplate, required this.autoFullScreenIntoReader, required this.bookListType, required this.fontScalePercent, required this.coverWidth, required this.coverHeight, required this.annotation, required this.fullScreenRemoveBars, required this.enableVolumeControl});
  

@override final  PlatformInt64 id;
@override final  String theme;
@override final  String darkTheme;
@override final  bool copySkipConfirm;
@override final  String copyComicTitleTemplate;
@override final  bool autoFullScreenIntoReader;
@override final  String bookListType;
@override final  int fontScalePercent;
@override final  int coverWidth;
@override final  int coverHeight;
@override final  bool annotation;
@override final  bool fullScreenRemoveBars;
@override final  bool enableVolumeControl;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.darkTheme, darkTheme) || other.darkTheme == darkTheme)&&(identical(other.copySkipConfirm, copySkipConfirm) || other.copySkipConfirm == copySkipConfirm)&&(identical(other.copyComicTitleTemplate, copyComicTitleTemplate) || other.copyComicTitleTemplate == copyComicTitleTemplate)&&(identical(other.autoFullScreenIntoReader, autoFullScreenIntoReader) || other.autoFullScreenIntoReader == autoFullScreenIntoReader)&&(identical(other.bookListType, bookListType) || other.bookListType == bookListType)&&(identical(other.fontScalePercent, fontScalePercent) || other.fontScalePercent == fontScalePercent)&&(identical(other.coverWidth, coverWidth) || other.coverWidth == coverWidth)&&(identical(other.coverHeight, coverHeight) || other.coverHeight == coverHeight)&&(identical(other.annotation, annotation) || other.annotation == annotation)&&(identical(other.fullScreenRemoveBars, fullScreenRemoveBars) || other.fullScreenRemoveBars == fullScreenRemoveBars)&&(identical(other.enableVolumeControl, enableVolumeControl) || other.enableVolumeControl == enableVolumeControl));
}


@override
int get hashCode => Object.hash(runtimeType,id,theme,darkTheme,copySkipConfirm,copyComicTitleTemplate,autoFullScreenIntoReader,bookListType,fontScalePercent,coverWidth,coverHeight,annotation,fullScreenRemoveBars,enableVolumeControl);

@override
String toString() {
  return 'AppSettings(id: $id, theme: $theme, darkTheme: $darkTheme, copySkipConfirm: $copySkipConfirm, copyComicTitleTemplate: $copyComicTitleTemplate, autoFullScreenIntoReader: $autoFullScreenIntoReader, bookListType: $bookListType, fontScalePercent: $fontScalePercent, coverWidth: $coverWidth, coverHeight: $coverHeight, annotation: $annotation, fullScreenRemoveBars: $fullScreenRemoveBars, enableVolumeControl: $enableVolumeControl)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 PlatformInt64 id, String theme, String darkTheme, bool copySkipConfirm, String copyComicTitleTemplate, bool autoFullScreenIntoReader, String bookListType, int fontScalePercent, int coverWidth, int coverHeight, bool annotation, bool fullScreenRemoveBars, bool enableVolumeControl
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? theme = null,Object? darkTheme = null,Object? copySkipConfirm = null,Object? copyComicTitleTemplate = null,Object? autoFullScreenIntoReader = null,Object? bookListType = null,Object? fontScalePercent = null,Object? coverWidth = null,Object? coverHeight = null,Object? annotation = null,Object? fullScreenRemoveBars = null,Object? enableVolumeControl = null,}) {
  return _then(_AppSettings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PlatformInt64,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,darkTheme: null == darkTheme ? _self.darkTheme : darkTheme // ignore: cast_nullable_to_non_nullable
as String,copySkipConfirm: null == copySkipConfirm ? _self.copySkipConfirm : copySkipConfirm // ignore: cast_nullable_to_non_nullable
as bool,copyComicTitleTemplate: null == copyComicTitleTemplate ? _self.copyComicTitleTemplate : copyComicTitleTemplate // ignore: cast_nullable_to_non_nullable
as String,autoFullScreenIntoReader: null == autoFullScreenIntoReader ? _self.autoFullScreenIntoReader : autoFullScreenIntoReader // ignore: cast_nullable_to_non_nullable
as bool,bookListType: null == bookListType ? _self.bookListType : bookListType // ignore: cast_nullable_to_non_nullable
as String,fontScalePercent: null == fontScalePercent ? _self.fontScalePercent : fontScalePercent // ignore: cast_nullable_to_non_nullable
as int,coverWidth: null == coverWidth ? _self.coverWidth : coverWidth // ignore: cast_nullable_to_non_nullable
as int,coverHeight: null == coverHeight ? _self.coverHeight : coverHeight // ignore: cast_nullable_to_non_nullable
as int,annotation: null == annotation ? _self.annotation : annotation // ignore: cast_nullable_to_non_nullable
as bool,fullScreenRemoveBars: null == fullScreenRemoveBars ? _self.fullScreenRemoveBars : fullScreenRemoveBars // ignore: cast_nullable_to_non_nullable
as bool,enableVolumeControl: null == enableVolumeControl ? _self.enableVolumeControl : enableVolumeControl // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
