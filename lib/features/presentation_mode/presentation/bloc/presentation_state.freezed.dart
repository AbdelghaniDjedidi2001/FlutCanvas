// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presentation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PresentationState {

 bool get isPresenting; int get currentSlideIndex; List<BoardElement> get slides;
/// Create a copy of PresentationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresentationStateCopyWith<PresentationState> get copyWith => _$PresentationStateCopyWithImpl<PresentationState>(this as PresentationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresentationState&&(identical(other.isPresenting, isPresenting) || other.isPresenting == isPresenting)&&(identical(other.currentSlideIndex, currentSlideIndex) || other.currentSlideIndex == currentSlideIndex)&&const DeepCollectionEquality().equals(other.slides, slides));
}


@override
int get hashCode => Object.hash(runtimeType,isPresenting,currentSlideIndex,const DeepCollectionEquality().hash(slides));

@override
String toString() {
  return 'PresentationState(isPresenting: $isPresenting, currentSlideIndex: $currentSlideIndex, slides: $slides)';
}


}

/// @nodoc
abstract mixin class $PresentationStateCopyWith<$Res>  {
  factory $PresentationStateCopyWith(PresentationState value, $Res Function(PresentationState) _then) = _$PresentationStateCopyWithImpl;
@useResult
$Res call({
 bool isPresenting, int currentSlideIndex, List<BoardElement> slides
});




}
/// @nodoc
class _$PresentationStateCopyWithImpl<$Res>
    implements $PresentationStateCopyWith<$Res> {
  _$PresentationStateCopyWithImpl(this._self, this._then);

  final PresentationState _self;
  final $Res Function(PresentationState) _then;

/// Create a copy of PresentationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isPresenting = null,Object? currentSlideIndex = null,Object? slides = null,}) {
  return _then(_self.copyWith(
isPresenting: null == isPresenting ? _self.isPresenting : isPresenting // ignore: cast_nullable_to_non_nullable
as bool,currentSlideIndex: null == currentSlideIndex ? _self.currentSlideIndex : currentSlideIndex // ignore: cast_nullable_to_non_nullable
as int,slides: null == slides ? _self.slides : slides // ignore: cast_nullable_to_non_nullable
as List<BoardElement>,
  ));
}

}


/// Adds pattern-matching-related methods to [PresentationState].
extension PresentationStatePatterns on PresentationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresentationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresentationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresentationState value)  $default,){
final _that = this;
switch (_that) {
case _PresentationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresentationState value)?  $default,){
final _that = this;
switch (_that) {
case _PresentationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isPresenting,  int currentSlideIndex,  List<BoardElement> slides)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresentationState() when $default != null:
return $default(_that.isPresenting,_that.currentSlideIndex,_that.slides);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isPresenting,  int currentSlideIndex,  List<BoardElement> slides)  $default,) {final _that = this;
switch (_that) {
case _PresentationState():
return $default(_that.isPresenting,_that.currentSlideIndex,_that.slides);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isPresenting,  int currentSlideIndex,  List<BoardElement> slides)?  $default,) {final _that = this;
switch (_that) {
case _PresentationState() when $default != null:
return $default(_that.isPresenting,_that.currentSlideIndex,_that.slides);case _:
  return null;

}
}

}

/// @nodoc


class _PresentationState extends PresentationState {
  const _PresentationState({this.isPresenting = false, this.currentSlideIndex = 0, this.slides = const []}): super._();
  

@override@JsonKey() final  bool isPresenting;
@override@JsonKey() final  int currentSlideIndex;
@override@JsonKey() final  List<BoardElement> slides;

/// Create a copy of PresentationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresentationStateCopyWith<_PresentationState> get copyWith => __$PresentationStateCopyWithImpl<_PresentationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresentationState&&(identical(other.isPresenting, isPresenting) || other.isPresenting == isPresenting)&&(identical(other.currentSlideIndex, currentSlideIndex) || other.currentSlideIndex == currentSlideIndex)&&const DeepCollectionEquality().equals(other.slides, slides));
}


@override
int get hashCode => Object.hash(runtimeType,isPresenting,currentSlideIndex,const DeepCollectionEquality().hash(slides));

@override
String toString() {
  return 'PresentationState(isPresenting: $isPresenting, currentSlideIndex: $currentSlideIndex, slides: $slides)';
}


}

/// @nodoc
abstract mixin class _$PresentationStateCopyWith<$Res> implements $PresentationStateCopyWith<$Res> {
  factory _$PresentationStateCopyWith(_PresentationState value, $Res Function(_PresentationState) _then) = __$PresentationStateCopyWithImpl;
@override @useResult
$Res call({
 bool isPresenting, int currentSlideIndex, List<BoardElement> slides
});




}
/// @nodoc
class __$PresentationStateCopyWithImpl<$Res>
    implements _$PresentationStateCopyWith<$Res> {
  __$PresentationStateCopyWithImpl(this._self, this._then);

  final _PresentationState _self;
  final $Res Function(_PresentationState) _then;

/// Create a copy of PresentationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isPresenting = null,Object? currentSlideIndex = null,Object? slides = null,}) {
  return _then(_PresentationState(
isPresenting: null == isPresenting ? _self.isPresenting : isPresenting // ignore: cast_nullable_to_non_nullable
as bool,currentSlideIndex: null == currentSlideIndex ? _self.currentSlideIndex : currentSlideIndex // ignore: cast_nullable_to_non_nullable
as int,slides: null == slides ? _self.slides : slides // ignore: cast_nullable_to_non_nullable
as List<BoardElement>,
  ));
}


}

// dart format on
