// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'board_comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommentReply {

 String get id; String get author; String get text; DateTime get createdAt;
/// Create a copy of CommentReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentReplyCopyWith<CommentReply> get copyWith => _$CommentReplyCopyWithImpl<CommentReply>(this as CommentReply, _$identity);

  /// Serializes this CommentReply to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentReply&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,text,createdAt);

@override
String toString() {
  return 'CommentReply(id: $id, author: $author, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CommentReplyCopyWith<$Res>  {
  factory $CommentReplyCopyWith(CommentReply value, $Res Function(CommentReply) _then) = _$CommentReplyCopyWithImpl;
@useResult
$Res call({
 String id, String author, String text, DateTime createdAt
});




}
/// @nodoc
class _$CommentReplyCopyWithImpl<$Res>
    implements $CommentReplyCopyWith<$Res> {
  _$CommentReplyCopyWithImpl(this._self, this._then);

  final CommentReply _self;
  final $Res Function(CommentReply) _then;

/// Create a copy of CommentReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? author = null,Object? text = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentReply].
extension CommentReplyPatterns on CommentReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentReply value)  $default,){
final _that = this;
switch (_that) {
case _CommentReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentReply value)?  $default,){
final _that = this;
switch (_that) {
case _CommentReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String author,  String text,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentReply() when $default != null:
return $default(_that.id,_that.author,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String author,  String text,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CommentReply():
return $default(_that.id,_that.author,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String author,  String text,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CommentReply() when $default != null:
return $default(_that.id,_that.author,_that.text,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommentReply extends CommentReply {
  const _CommentReply({required this.id, required this.author, required this.text, required this.createdAt}): super._();
  factory _CommentReply.fromJson(Map<String, dynamic> json) => _$CommentReplyFromJson(json);

@override final  String id;
@override final  String author;
@override final  String text;
@override final  DateTime createdAt;

/// Create a copy of CommentReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentReplyCopyWith<_CommentReply> get copyWith => __$CommentReplyCopyWithImpl<_CommentReply>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentReplyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentReply&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,text,createdAt);

@override
String toString() {
  return 'CommentReply(id: $id, author: $author, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CommentReplyCopyWith<$Res> implements $CommentReplyCopyWith<$Res> {
  factory _$CommentReplyCopyWith(_CommentReply value, $Res Function(_CommentReply) _then) = __$CommentReplyCopyWithImpl;
@override @useResult
$Res call({
 String id, String author, String text, DateTime createdAt
});




}
/// @nodoc
class __$CommentReplyCopyWithImpl<$Res>
    implements _$CommentReplyCopyWith<$Res> {
  __$CommentReplyCopyWithImpl(this._self, this._then);

  final _CommentReply _self;
  final $Res Function(_CommentReply) _then;

/// Create a copy of CommentReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? author = null,Object? text = null,Object? createdAt = null,}) {
  return _then(_CommentReply(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$BoardComment {

 String get id;@OffsetConverter() Offset get worldPosition; int get pinNumber; String get author; String get text; DateTime get createdAt; bool get isResolved; List<CommentReply> get replies; int? get colorValue;
/// Create a copy of BoardComment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardCommentCopyWith<BoardComment> get copyWith => _$BoardCommentCopyWithImpl<BoardComment>(this as BoardComment, _$identity);

  /// Serializes this BoardComment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardComment&&(identical(other.id, id) || other.id == id)&&(identical(other.worldPosition, worldPosition) || other.worldPosition == worldPosition)&&(identical(other.pinNumber, pinNumber) || other.pinNumber == pinNumber)&&(identical(other.author, author) || other.author == author)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isResolved, isResolved) || other.isResolved == isResolved)&&const DeepCollectionEquality().equals(other.replies, replies)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,worldPosition,pinNumber,author,text,createdAt,isResolved,const DeepCollectionEquality().hash(replies),colorValue);

@override
String toString() {
  return 'BoardComment(id: $id, worldPosition: $worldPosition, pinNumber: $pinNumber, author: $author, text: $text, createdAt: $createdAt, isResolved: $isResolved, replies: $replies, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class $BoardCommentCopyWith<$Res>  {
  factory $BoardCommentCopyWith(BoardComment value, $Res Function(BoardComment) _then) = _$BoardCommentCopyWithImpl;
@useResult
$Res call({
 String id,@OffsetConverter() Offset worldPosition, int pinNumber, String author, String text, DateTime createdAt, bool isResolved, List<CommentReply> replies, int? colorValue
});




}
/// @nodoc
class _$BoardCommentCopyWithImpl<$Res>
    implements $BoardCommentCopyWith<$Res> {
  _$BoardCommentCopyWithImpl(this._self, this._then);

  final BoardComment _self;
  final $Res Function(BoardComment) _then;

/// Create a copy of BoardComment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? worldPosition = null,Object? pinNumber = null,Object? author = null,Object? text = null,Object? createdAt = null,Object? isResolved = null,Object? replies = null,Object? colorValue = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,worldPosition: null == worldPosition ? _self.worldPosition : worldPosition // ignore: cast_nullable_to_non_nullable
as Offset,pinNumber: null == pinNumber ? _self.pinNumber : pinNumber // ignore: cast_nullable_to_non_nullable
as int,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isResolved: null == isResolved ? _self.isResolved : isResolved // ignore: cast_nullable_to_non_nullable
as bool,replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as List<CommentReply>,colorValue: freezed == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [BoardComment].
extension BoardCommentPatterns on BoardComment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoardComment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoardComment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoardComment value)  $default,){
final _that = this;
switch (_that) {
case _BoardComment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoardComment value)?  $default,){
final _that = this;
switch (_that) {
case _BoardComment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @OffsetConverter()  Offset worldPosition,  int pinNumber,  String author,  String text,  DateTime createdAt,  bool isResolved,  List<CommentReply> replies,  int? colorValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoardComment() when $default != null:
return $default(_that.id,_that.worldPosition,_that.pinNumber,_that.author,_that.text,_that.createdAt,_that.isResolved,_that.replies,_that.colorValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @OffsetConverter()  Offset worldPosition,  int pinNumber,  String author,  String text,  DateTime createdAt,  bool isResolved,  List<CommentReply> replies,  int? colorValue)  $default,) {final _that = this;
switch (_that) {
case _BoardComment():
return $default(_that.id,_that.worldPosition,_that.pinNumber,_that.author,_that.text,_that.createdAt,_that.isResolved,_that.replies,_that.colorValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @OffsetConverter()  Offset worldPosition,  int pinNumber,  String author,  String text,  DateTime createdAt,  bool isResolved,  List<CommentReply> replies,  int? colorValue)?  $default,) {final _that = this;
switch (_that) {
case _BoardComment() when $default != null:
return $default(_that.id,_that.worldPosition,_that.pinNumber,_that.author,_that.text,_that.createdAt,_that.isResolved,_that.replies,_that.colorValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@OffsetConverter()
class _BoardComment extends BoardComment {
  const _BoardComment({required this.id, @OffsetConverter() required this.worldPosition, required this.pinNumber, required this.author, required this.text, required this.createdAt, this.isResolved = false, this.replies = const [], this.colorValue}): super._();
  factory _BoardComment.fromJson(Map<String, dynamic> json) => _$BoardCommentFromJson(json);

@override final  String id;
@override@OffsetConverter() final  Offset worldPosition;
@override final  int pinNumber;
@override final  String author;
@override final  String text;
@override final  DateTime createdAt;
@override@JsonKey() final  bool isResolved;
@override@JsonKey() final  List<CommentReply> replies;
@override final  int? colorValue;

/// Create a copy of BoardComment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardCommentCopyWith<_BoardComment> get copyWith => __$BoardCommentCopyWithImpl<_BoardComment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoardCommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoardComment&&(identical(other.id, id) || other.id == id)&&(identical(other.worldPosition, worldPosition) || other.worldPosition == worldPosition)&&(identical(other.pinNumber, pinNumber) || other.pinNumber == pinNumber)&&(identical(other.author, author) || other.author == author)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isResolved, isResolved) || other.isResolved == isResolved)&&const DeepCollectionEquality().equals(other.replies, replies)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,worldPosition,pinNumber,author,text,createdAt,isResolved,const DeepCollectionEquality().hash(replies),colorValue);

@override
String toString() {
  return 'BoardComment(id: $id, worldPosition: $worldPosition, pinNumber: $pinNumber, author: $author, text: $text, createdAt: $createdAt, isResolved: $isResolved, replies: $replies, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class _$BoardCommentCopyWith<$Res> implements $BoardCommentCopyWith<$Res> {
  factory _$BoardCommentCopyWith(_BoardComment value, $Res Function(_BoardComment) _then) = __$BoardCommentCopyWithImpl;
@override @useResult
$Res call({
 String id,@OffsetConverter() Offset worldPosition, int pinNumber, String author, String text, DateTime createdAt, bool isResolved, List<CommentReply> replies, int? colorValue
});




}
/// @nodoc
class __$BoardCommentCopyWithImpl<$Res>
    implements _$BoardCommentCopyWith<$Res> {
  __$BoardCommentCopyWithImpl(this._self, this._then);

  final _BoardComment _self;
  final $Res Function(_BoardComment) _then;

/// Create a copy of BoardComment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? worldPosition = null,Object? pinNumber = null,Object? author = null,Object? text = null,Object? createdAt = null,Object? isResolved = null,Object? replies = null,Object? colorValue = freezed,}) {
  return _then(_BoardComment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,worldPosition: null == worldPosition ? _self.worldPosition : worldPosition // ignore: cast_nullable_to_non_nullable
as Offset,pinNumber: null == pinNumber ? _self.pinNumber : pinNumber // ignore: cast_nullable_to_non_nullable
as int,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isResolved: null == isResolved ? _self.isResolved : isResolved // ignore: cast_nullable_to_non_nullable
as bool,replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as List<CommentReply>,colorValue: freezed == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
