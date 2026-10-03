// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'boards_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BoardsState {

 List<BoardDocument> get boards; int get activeBoardIndex; bool get isLoading;
/// Create a copy of BoardsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardsStateCopyWith<BoardsState> get copyWith => _$BoardsStateCopyWithImpl<BoardsState>(this as BoardsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardsState&&const DeepCollectionEquality().equals(other.boards, boards)&&(identical(other.activeBoardIndex, activeBoardIndex) || other.activeBoardIndex == activeBoardIndex)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(boards),activeBoardIndex,isLoading);

@override
String toString() {
  return 'BoardsState(boards: $boards, activeBoardIndex: $activeBoardIndex, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $BoardsStateCopyWith<$Res>  {
  factory $BoardsStateCopyWith(BoardsState value, $Res Function(BoardsState) _then) = _$BoardsStateCopyWithImpl;
@useResult
$Res call({
 List<BoardDocument> boards, int activeBoardIndex, bool isLoading
});




}
/// @nodoc
class _$BoardsStateCopyWithImpl<$Res>
    implements $BoardsStateCopyWith<$Res> {
  _$BoardsStateCopyWithImpl(this._self, this._then);

  final BoardsState _self;
  final $Res Function(BoardsState) _then;

/// Create a copy of BoardsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? boards = null,Object? activeBoardIndex = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
boards: null == boards ? _self.boards : boards // ignore: cast_nullable_to_non_nullable
as List<BoardDocument>,activeBoardIndex: null == activeBoardIndex ? _self.activeBoardIndex : activeBoardIndex // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BoardsState].
extension BoardsStatePatterns on BoardsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoardsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoardsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoardsState value)  $default,){
final _that = this;
switch (_that) {
case _BoardsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoardsState value)?  $default,){
final _that = this;
switch (_that) {
case _BoardsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BoardDocument> boards,  int activeBoardIndex,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoardsState() when $default != null:
return $default(_that.boards,_that.activeBoardIndex,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BoardDocument> boards,  int activeBoardIndex,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _BoardsState():
return $default(_that.boards,_that.activeBoardIndex,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BoardDocument> boards,  int activeBoardIndex,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _BoardsState() when $default != null:
return $default(_that.boards,_that.activeBoardIndex,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _BoardsState extends BoardsState {
  const _BoardsState({this.boards = const [BoardDocument(id: 'board_1', title: 'Main Board', elements: [])], this.activeBoardIndex = 0, this.isLoading = false}): super._();
  

@override@JsonKey() final  List<BoardDocument> boards;
@override@JsonKey() final  int activeBoardIndex;
@override@JsonKey() final  bool isLoading;

/// Create a copy of BoardsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardsStateCopyWith<_BoardsState> get copyWith => __$BoardsStateCopyWithImpl<_BoardsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoardsState&&const DeepCollectionEquality().equals(other.boards, boards)&&(identical(other.activeBoardIndex, activeBoardIndex) || other.activeBoardIndex == activeBoardIndex)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(boards),activeBoardIndex,isLoading);

@override
String toString() {
  return 'BoardsState(boards: $boards, activeBoardIndex: $activeBoardIndex, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$BoardsStateCopyWith<$Res> implements $BoardsStateCopyWith<$Res> {
  factory _$BoardsStateCopyWith(_BoardsState value, $Res Function(_BoardsState) _then) = __$BoardsStateCopyWithImpl;
@override @useResult
$Res call({
 List<BoardDocument> boards, int activeBoardIndex, bool isLoading
});




}
/// @nodoc
class __$BoardsStateCopyWithImpl<$Res>
    implements _$BoardsStateCopyWith<$Res> {
  __$BoardsStateCopyWithImpl(this._self, this._then);

  final _BoardsState _self;
  final $Res Function(_BoardsState) _then;

/// Create a copy of BoardsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? boards = null,Object? activeBoardIndex = null,Object? isLoading = null,}) {
  return _then(_BoardsState(
boards: null == boards ? _self.boards : boards // ignore: cast_nullable_to_non_nullable
as List<BoardDocument>,activeBoardIndex: null == activeBoardIndex ? _self.activeBoardIndex : activeBoardIndex // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
