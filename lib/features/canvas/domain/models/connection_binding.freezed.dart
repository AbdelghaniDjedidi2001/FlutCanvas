// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_binding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConnectionBinding {

 String get elementId; AnchorPoint get anchor;
/// Create a copy of ConnectionBinding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionBindingCopyWith<ConnectionBinding> get copyWith => _$ConnectionBindingCopyWithImpl<ConnectionBinding>(this as ConnectionBinding, _$identity);

  /// Serializes this ConnectionBinding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionBinding&&(identical(other.elementId, elementId) || other.elementId == elementId)&&(identical(other.anchor, anchor) || other.anchor == anchor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,elementId,anchor);

@override
String toString() {
  return 'ConnectionBinding(elementId: $elementId, anchor: $anchor)';
}


}

/// @nodoc
abstract mixin class $ConnectionBindingCopyWith<$Res>  {
  factory $ConnectionBindingCopyWith(ConnectionBinding value, $Res Function(ConnectionBinding) _then) = _$ConnectionBindingCopyWithImpl;
@useResult
$Res call({
 String elementId, AnchorPoint anchor
});




}
/// @nodoc
class _$ConnectionBindingCopyWithImpl<$Res>
    implements $ConnectionBindingCopyWith<$Res> {
  _$ConnectionBindingCopyWithImpl(this._self, this._then);

  final ConnectionBinding _self;
  final $Res Function(ConnectionBinding) _then;

/// Create a copy of ConnectionBinding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? elementId = null,Object? anchor = null,}) {
  return _then(_self.copyWith(
elementId: null == elementId ? _self.elementId : elementId // ignore: cast_nullable_to_non_nullable
as String,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as AnchorPoint,
  ));
}

}


/// Adds pattern-matching-related methods to [ConnectionBinding].
extension ConnectionBindingPatterns on ConnectionBinding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionBinding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionBinding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionBinding value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionBinding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionBinding value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionBinding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String elementId,  AnchorPoint anchor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionBinding() when $default != null:
return $default(_that.elementId,_that.anchor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String elementId,  AnchorPoint anchor)  $default,) {final _that = this;
switch (_that) {
case _ConnectionBinding():
return $default(_that.elementId,_that.anchor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String elementId,  AnchorPoint anchor)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionBinding() when $default != null:
return $default(_that.elementId,_that.anchor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConnectionBinding extends ConnectionBinding {
  const _ConnectionBinding({required this.elementId, required this.anchor}): super._();
  factory _ConnectionBinding.fromJson(Map<String, dynamic> json) => _$ConnectionBindingFromJson(json);

@override final  String elementId;
@override final  AnchorPoint anchor;

/// Create a copy of ConnectionBinding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionBindingCopyWith<_ConnectionBinding> get copyWith => __$ConnectionBindingCopyWithImpl<_ConnectionBinding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectionBindingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionBinding&&(identical(other.elementId, elementId) || other.elementId == elementId)&&(identical(other.anchor, anchor) || other.anchor == anchor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,elementId,anchor);

@override
String toString() {
  return 'ConnectionBinding(elementId: $elementId, anchor: $anchor)';
}


}

/// @nodoc
abstract mixin class _$ConnectionBindingCopyWith<$Res> implements $ConnectionBindingCopyWith<$Res> {
  factory _$ConnectionBindingCopyWith(_ConnectionBinding value, $Res Function(_ConnectionBinding) _then) = __$ConnectionBindingCopyWithImpl;
@override @useResult
$Res call({
 String elementId, AnchorPoint anchor
});




}
/// @nodoc
class __$ConnectionBindingCopyWithImpl<$Res>
    implements _$ConnectionBindingCopyWith<$Res> {
  __$ConnectionBindingCopyWithImpl(this._self, this._then);

  final _ConnectionBinding _self;
  final $Res Function(_ConnectionBinding) _then;

/// Create a copy of ConnectionBinding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? elementId = null,Object? anchor = null,}) {
  return _then(_ConnectionBinding(
elementId: null == elementId ? _self.elementId : elementId // ignore: cast_nullable_to_non_nullable
as String,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as AnchorPoint,
  ));
}


}

// dart format on
