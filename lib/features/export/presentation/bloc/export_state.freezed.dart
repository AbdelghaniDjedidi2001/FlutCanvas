// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExportState {

 ExportFormat get format; PdfExportMode get pdfMode; bool get includeBackground; double get scale; double get padding; bool get isExporting; String get statusMessage; String? get errorMessage;
/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportStateCopyWith<ExportState> get copyWith => _$ExportStateCopyWithImpl<ExportState>(this as ExportState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportState&&(identical(other.format, format) || other.format == format)&&(identical(other.pdfMode, pdfMode) || other.pdfMode == pdfMode)&&(identical(other.includeBackground, includeBackground) || other.includeBackground == includeBackground)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.padding, padding) || other.padding == padding)&&(identical(other.isExporting, isExporting) || other.isExporting == isExporting)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,format,pdfMode,includeBackground,scale,padding,isExporting,statusMessage,errorMessage);

@override
String toString() {
  return 'ExportState(format: $format, pdfMode: $pdfMode, includeBackground: $includeBackground, scale: $scale, padding: $padding, isExporting: $isExporting, statusMessage: $statusMessage, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ExportStateCopyWith<$Res>  {
  factory $ExportStateCopyWith(ExportState value, $Res Function(ExportState) _then) = _$ExportStateCopyWithImpl;
@useResult
$Res call({
 ExportFormat format, PdfExportMode pdfMode, bool includeBackground, double scale, double padding, bool isExporting, String statusMessage, String? errorMessage
});




}
/// @nodoc
class _$ExportStateCopyWithImpl<$Res>
    implements $ExportStateCopyWith<$Res> {
  _$ExportStateCopyWithImpl(this._self, this._then);

  final ExportState _self;
  final $Res Function(ExportState) _then;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? format = null,Object? pdfMode = null,Object? includeBackground = null,Object? scale = null,Object? padding = null,Object? isExporting = null,Object? statusMessage = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,pdfMode: null == pdfMode ? _self.pdfMode : pdfMode // ignore: cast_nullable_to_non_nullable
as PdfExportMode,includeBackground: null == includeBackground ? _self.includeBackground : includeBackground // ignore: cast_nullable_to_non_nullable
as bool,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,padding: null == padding ? _self.padding : padding // ignore: cast_nullable_to_non_nullable
as double,isExporting: null == isExporting ? _self.isExporting : isExporting // ignore: cast_nullable_to_non_nullable
as bool,statusMessage: null == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportState].
extension ExportStatePatterns on ExportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportState value)  $default,){
final _that = this;
switch (_that) {
case _ExportState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportState value)?  $default,){
final _that = this;
switch (_that) {
case _ExportState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ExportFormat format,  PdfExportMode pdfMode,  bool includeBackground,  double scale,  double padding,  bool isExporting,  String statusMessage,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportState() when $default != null:
return $default(_that.format,_that.pdfMode,_that.includeBackground,_that.scale,_that.padding,_that.isExporting,_that.statusMessage,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ExportFormat format,  PdfExportMode pdfMode,  bool includeBackground,  double scale,  double padding,  bool isExporting,  String statusMessage,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ExportState():
return $default(_that.format,_that.pdfMode,_that.includeBackground,_that.scale,_that.padding,_that.isExporting,_that.statusMessage,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ExportFormat format,  PdfExportMode pdfMode,  bool includeBackground,  double scale,  double padding,  bool isExporting,  String statusMessage,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ExportState() when $default != null:
return $default(_that.format,_that.pdfMode,_that.includeBackground,_that.scale,_that.padding,_that.isExporting,_that.statusMessage,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ExportState implements ExportState {
  const _ExportState({this.format = ExportFormat.png, this.pdfMode = PdfExportMode.currentBoard, this.includeBackground = true, this.scale = 2.0, this.padding = 40.0, this.isExporting = false, this.statusMessage = '', this.errorMessage});
  

@override@JsonKey() final  ExportFormat format;
@override@JsonKey() final  PdfExportMode pdfMode;
@override@JsonKey() final  bool includeBackground;
@override@JsonKey() final  double scale;
@override@JsonKey() final  double padding;
@override@JsonKey() final  bool isExporting;
@override@JsonKey() final  String statusMessage;
@override final  String? errorMessage;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportStateCopyWith<_ExportState> get copyWith => __$ExportStateCopyWithImpl<_ExportState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportState&&(identical(other.format, format) || other.format == format)&&(identical(other.pdfMode, pdfMode) || other.pdfMode == pdfMode)&&(identical(other.includeBackground, includeBackground) || other.includeBackground == includeBackground)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.padding, padding) || other.padding == padding)&&(identical(other.isExporting, isExporting) || other.isExporting == isExporting)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,format,pdfMode,includeBackground,scale,padding,isExporting,statusMessage,errorMessage);

@override
String toString() {
  return 'ExportState(format: $format, pdfMode: $pdfMode, includeBackground: $includeBackground, scale: $scale, padding: $padding, isExporting: $isExporting, statusMessage: $statusMessage, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ExportStateCopyWith<$Res> implements $ExportStateCopyWith<$Res> {
  factory _$ExportStateCopyWith(_ExportState value, $Res Function(_ExportState) _then) = __$ExportStateCopyWithImpl;
@override @useResult
$Res call({
 ExportFormat format, PdfExportMode pdfMode, bool includeBackground, double scale, double padding, bool isExporting, String statusMessage, String? errorMessage
});




}
/// @nodoc
class __$ExportStateCopyWithImpl<$Res>
    implements _$ExportStateCopyWith<$Res> {
  __$ExportStateCopyWithImpl(this._self, this._then);

  final _ExportState _self;
  final $Res Function(_ExportState) _then;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = null,Object? pdfMode = null,Object? includeBackground = null,Object? scale = null,Object? padding = null,Object? isExporting = null,Object? statusMessage = null,Object? errorMessage = freezed,}) {
  return _then(_ExportState(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,pdfMode: null == pdfMode ? _self.pdfMode : pdfMode // ignore: cast_nullable_to_non_nullable
as PdfExportMode,includeBackground: null == includeBackground ? _self.includeBackground : includeBackground // ignore: cast_nullable_to_non_nullable
as bool,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,padding: null == padding ? _self.padding : padding // ignore: cast_nullable_to_non_nullable
as double,isExporting: null == isExporting ? _self.isExporting : isExporting // ignore: cast_nullable_to_non_nullable
as bool,statusMessage: null == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
