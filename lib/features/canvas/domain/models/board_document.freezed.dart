// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'board_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BoardDocument {

 String get id; String get title; List<BoardElement> get elements; List<BoardComment> get comments;@OffsetConverter() Offset get pan; double get zoom; DateTime? get updatedAt;
/// Create a copy of BoardDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardDocumentCopyWith<BoardDocument> get copyWith => _$BoardDocumentCopyWithImpl<BoardDocument>(this as BoardDocument, _$identity);

  /// Serializes this BoardDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.elements, elements)&&const DeepCollectionEquality().equals(other.comments, comments)&&(identical(other.pan, pan) || other.pan == pan)&&(identical(other.zoom, zoom) || other.zoom == zoom)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(elements),const DeepCollectionEquality().hash(comments),pan,zoom,updatedAt);

@override
String toString() {
  return 'BoardDocument(id: $id, title: $title, elements: $elements, comments: $comments, pan: $pan, zoom: $zoom, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BoardDocumentCopyWith<$Res>  {
  factory $BoardDocumentCopyWith(BoardDocument value, $Res Function(BoardDocument) _then) = _$BoardDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String title, List<BoardElement> elements, List<BoardComment> comments,@OffsetConverter() Offset pan, double zoom, DateTime? updatedAt
});




}
/// @nodoc
class _$BoardDocumentCopyWithImpl<$Res>
    implements $BoardDocumentCopyWith<$Res> {
  _$BoardDocumentCopyWithImpl(this._self, this._then);

  final BoardDocument _self;
  final $Res Function(BoardDocument) _then;

/// Create a copy of BoardDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? elements = null,Object? comments = null,Object? pan = null,Object? zoom = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,elements: null == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<BoardElement>,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<BoardComment>,pan: null == pan ? _self.pan : pan // ignore: cast_nullable_to_non_nullable
as Offset,zoom: null == zoom ? _self.zoom : zoom // ignore: cast_nullable_to_non_nullable
as double,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BoardDocument].
extension BoardDocumentPatterns on BoardDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoardDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoardDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoardDocument value)  $default,){
final _that = this;
switch (_that) {
case _BoardDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoardDocument value)?  $default,){
final _that = this;
switch (_that) {
case _BoardDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  List<BoardElement> elements,  List<BoardComment> comments, @OffsetConverter()  Offset pan,  double zoom,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoardDocument() when $default != null:
return $default(_that.id,_that.title,_that.elements,_that.comments,_that.pan,_that.zoom,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  List<BoardElement> elements,  List<BoardComment> comments, @OffsetConverter()  Offset pan,  double zoom,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BoardDocument():
return $default(_that.id,_that.title,_that.elements,_that.comments,_that.pan,_that.zoom,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  List<BoardElement> elements,  List<BoardComment> comments, @OffsetConverter()  Offset pan,  double zoom,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BoardDocument() when $default != null:
return $default(_that.id,_that.title,_that.elements,_that.comments,_that.pan,_that.zoom,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@OffsetConverter()
class _BoardDocument extends BoardDocument {
  const _BoardDocument({required this.id, required this.title, this.elements = const [], this.comments = const [], @OffsetConverter() this.pan = Offset.zero, this.zoom = 1.0, this.updatedAt}): super._();
  factory _BoardDocument.fromJson(Map<String, dynamic> json) => _$BoardDocumentFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  List<BoardElement> elements;
@override@JsonKey() final  List<BoardComment> comments;
@override@JsonKey()@OffsetConverter() final  Offset pan;
@override@JsonKey() final  double zoom;
@override final  DateTime? updatedAt;

/// Create a copy of BoardDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardDocumentCopyWith<_BoardDocument> get copyWith => __$BoardDocumentCopyWithImpl<_BoardDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoardDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoardDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.elements, elements)&&const DeepCollectionEquality().equals(other.comments, comments)&&(identical(other.pan, pan) || other.pan == pan)&&(identical(other.zoom, zoom) || other.zoom == zoom)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(elements),const DeepCollectionEquality().hash(comments),pan,zoom,updatedAt);

@override
String toString() {
  return 'BoardDocument(id: $id, title: $title, elements: $elements, comments: $comments, pan: $pan, zoom: $zoom, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BoardDocumentCopyWith<$Res> implements $BoardDocumentCopyWith<$Res> {
  factory _$BoardDocumentCopyWith(_BoardDocument value, $Res Function(_BoardDocument) _then) = __$BoardDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, List<BoardElement> elements, List<BoardComment> comments,@OffsetConverter() Offset pan, double zoom, DateTime? updatedAt
});




}
/// @nodoc
class __$BoardDocumentCopyWithImpl<$Res>
    implements _$BoardDocumentCopyWith<$Res> {
  __$BoardDocumentCopyWithImpl(this._self, this._then);

  final _BoardDocument _self;
  final $Res Function(_BoardDocument) _then;

/// Create a copy of BoardDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? elements = null,Object? comments = null,Object? pan = null,Object? zoom = null,Object? updatedAt = freezed,}) {
  return _then(_BoardDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,elements: null == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<BoardElement>,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<BoardComment>,pan: null == pan ? _self.pan : pan // ignore: cast_nullable_to_non_nullable
as Offset,zoom: null == zoom ? _self.zoom : zoom // ignore: cast_nullable_to_non_nullable
as double,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
