// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'canvas_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CanvasState {

 List<BoardElement> get elements; Set<String> get selectedIds; BoardElement? get draft; Rect? get marqueeRect; List<SnapGuide> get snapGuides; bool get canUndo; bool get canRedo;
/// Create a copy of CanvasState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CanvasStateCopyWith<CanvasState> get copyWith => _$CanvasStateCopyWithImpl<CanvasState>(this as CanvasState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CanvasState&&const DeepCollectionEquality().equals(other.elements, elements)&&const DeepCollectionEquality().equals(other.selectedIds, selectedIds)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.marqueeRect, marqueeRect) || other.marqueeRect == marqueeRect)&&const DeepCollectionEquality().equals(other.snapGuides, snapGuides)&&(identical(other.canUndo, canUndo) || other.canUndo == canUndo)&&(identical(other.canRedo, canRedo) || other.canRedo == canRedo));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(elements),const DeepCollectionEquality().hash(selectedIds),draft,marqueeRect,const DeepCollectionEquality().hash(snapGuides),canUndo,canRedo);

@override
String toString() {
  return 'CanvasState(elements: $elements, selectedIds: $selectedIds, draft: $draft, marqueeRect: $marqueeRect, snapGuides: $snapGuides, canUndo: $canUndo, canRedo: $canRedo)';
}


}

/// @nodoc
abstract mixin class $CanvasStateCopyWith<$Res>  {
  factory $CanvasStateCopyWith(CanvasState value, $Res Function(CanvasState) _then) = _$CanvasStateCopyWithImpl;
@useResult
$Res call({
 List<BoardElement> elements, Set<String> selectedIds, BoardElement? draft, Rect? marqueeRect, List<SnapGuide> snapGuides, bool canUndo, bool canRedo
});


$BoardElementCopyWith<$Res>? get draft;

}
/// @nodoc
class _$CanvasStateCopyWithImpl<$Res>
    implements $CanvasStateCopyWith<$Res> {
  _$CanvasStateCopyWithImpl(this._self, this._then);

  final CanvasState _self;
  final $Res Function(CanvasState) _then;

/// Create a copy of CanvasState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? elements = null,Object? selectedIds = null,Object? draft = freezed,Object? marqueeRect = freezed,Object? snapGuides = null,Object? canUndo = null,Object? canRedo = null,}) {
  return _then(_self.copyWith(
elements: null == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<BoardElement>,selectedIds: null == selectedIds ? _self.selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as BoardElement?,marqueeRect: freezed == marqueeRect ? _self.marqueeRect : marqueeRect // ignore: cast_nullable_to_non_nullable
as Rect?,snapGuides: null == snapGuides ? _self.snapGuides : snapGuides // ignore: cast_nullable_to_non_nullable
as List<SnapGuide>,canUndo: null == canUndo ? _self.canUndo : canUndo // ignore: cast_nullable_to_non_nullable
as bool,canRedo: null == canRedo ? _self.canRedo : canRedo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of CanvasState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardElementCopyWith<$Res>? get draft {
    if (_self.draft == null) {
    return null;
  }

  return $BoardElementCopyWith<$Res>(_self.draft!, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}


/// Adds pattern-matching-related methods to [CanvasState].
extension CanvasStatePatterns on CanvasState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CanvasState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CanvasState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CanvasState value)  $default,){
final _that = this;
switch (_that) {
case _CanvasState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CanvasState value)?  $default,){
final _that = this;
switch (_that) {
case _CanvasState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BoardElement> elements,  Set<String> selectedIds,  BoardElement? draft,  Rect? marqueeRect,  List<SnapGuide> snapGuides,  bool canUndo,  bool canRedo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CanvasState() when $default != null:
return $default(_that.elements,_that.selectedIds,_that.draft,_that.marqueeRect,_that.snapGuides,_that.canUndo,_that.canRedo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BoardElement> elements,  Set<String> selectedIds,  BoardElement? draft,  Rect? marqueeRect,  List<SnapGuide> snapGuides,  bool canUndo,  bool canRedo)  $default,) {final _that = this;
switch (_that) {
case _CanvasState():
return $default(_that.elements,_that.selectedIds,_that.draft,_that.marqueeRect,_that.snapGuides,_that.canUndo,_that.canRedo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BoardElement> elements,  Set<String> selectedIds,  BoardElement? draft,  Rect? marqueeRect,  List<SnapGuide> snapGuides,  bool canUndo,  bool canRedo)?  $default,) {final _that = this;
switch (_that) {
case _CanvasState() when $default != null:
return $default(_that.elements,_that.selectedIds,_that.draft,_that.marqueeRect,_that.snapGuides,_that.canUndo,_that.canRedo);case _:
  return null;

}
}

}

/// @nodoc


class _CanvasState extends CanvasState {
  const _CanvasState({this.elements = const [], this.selectedIds = const {}, this.draft, this.marqueeRect, this.snapGuides = const [], this.canUndo = false, this.canRedo = false}): super._();
  

@override@JsonKey() final  List<BoardElement> elements;
@override@JsonKey() final  Set<String> selectedIds;
@override final  BoardElement? draft;
@override final  Rect? marqueeRect;
@override@JsonKey() final  List<SnapGuide> snapGuides;
@override@JsonKey() final  bool canUndo;
@override@JsonKey() final  bool canRedo;

/// Create a copy of CanvasState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CanvasStateCopyWith<_CanvasState> get copyWith => __$CanvasStateCopyWithImpl<_CanvasState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CanvasState&&const DeepCollectionEquality().equals(other.elements, elements)&&const DeepCollectionEquality().equals(other.selectedIds, selectedIds)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.marqueeRect, marqueeRect) || other.marqueeRect == marqueeRect)&&const DeepCollectionEquality().equals(other.snapGuides, snapGuides)&&(identical(other.canUndo, canUndo) || other.canUndo == canUndo)&&(identical(other.canRedo, canRedo) || other.canRedo == canRedo));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(elements),const DeepCollectionEquality().hash(selectedIds),draft,marqueeRect,const DeepCollectionEquality().hash(snapGuides),canUndo,canRedo);

@override
String toString() {
  return 'CanvasState(elements: $elements, selectedIds: $selectedIds, draft: $draft, marqueeRect: $marqueeRect, snapGuides: $snapGuides, canUndo: $canUndo, canRedo: $canRedo)';
}


}

/// @nodoc
abstract mixin class _$CanvasStateCopyWith<$Res> implements $CanvasStateCopyWith<$Res> {
  factory _$CanvasStateCopyWith(_CanvasState value, $Res Function(_CanvasState) _then) = __$CanvasStateCopyWithImpl;
@override @useResult
$Res call({
 List<BoardElement> elements, Set<String> selectedIds, BoardElement? draft, Rect? marqueeRect, List<SnapGuide> snapGuides, bool canUndo, bool canRedo
});


@override $BoardElementCopyWith<$Res>? get draft;

}
/// @nodoc
class __$CanvasStateCopyWithImpl<$Res>
    implements _$CanvasStateCopyWith<$Res> {
  __$CanvasStateCopyWithImpl(this._self, this._then);

  final _CanvasState _self;
  final $Res Function(_CanvasState) _then;

/// Create a copy of CanvasState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? elements = null,Object? selectedIds = null,Object? draft = freezed,Object? marqueeRect = freezed,Object? snapGuides = null,Object? canUndo = null,Object? canRedo = null,}) {
  return _then(_CanvasState(
elements: null == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<BoardElement>,selectedIds: null == selectedIds ? _self.selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as BoardElement?,marqueeRect: freezed == marqueeRect ? _self.marqueeRect : marqueeRect // ignore: cast_nullable_to_non_nullable
as Rect?,snapGuides: null == snapGuides ? _self.snapGuides : snapGuides // ignore: cast_nullable_to_non_nullable
as List<SnapGuide>,canUndo: null == canUndo ? _self.canUndo : canUndo // ignore: cast_nullable_to_non_nullable
as bool,canRedo: null == canRedo ? _self.canRedo : canRedo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of CanvasState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardElementCopyWith<$Res>? get draft {
    if (_self.draft == null) {
    return null;
  }

  return $BoardElementCopyWith<$Res>(_self.draft!, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

// dart format on
