// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'layers_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LayersState {

 String get searchQuery; int get activeTab;
/// Create a copy of LayersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LayersStateCopyWith<LayersState> get copyWith => _$LayersStateCopyWithImpl<LayersState>(this as LayersState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LayersState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.activeTab, activeTab) || other.activeTab == activeTab));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,activeTab);

@override
String toString() {
  return 'LayersState(searchQuery: $searchQuery, activeTab: $activeTab)';
}


}

/// @nodoc
abstract mixin class $LayersStateCopyWith<$Res>  {
  factory $LayersStateCopyWith(LayersState value, $Res Function(LayersState) _then) = _$LayersStateCopyWithImpl;
@useResult
$Res call({
 String searchQuery, int activeTab
});




}
/// @nodoc
class _$LayersStateCopyWithImpl<$Res>
    implements $LayersStateCopyWith<$Res> {
  _$LayersStateCopyWithImpl(this._self, this._then);

  final LayersState _self;
  final $Res Function(LayersState) _then;

/// Create a copy of LayersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = null,Object? activeTab = null,}) {
  return _then(_self.copyWith(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,activeTab: null == activeTab ? _self.activeTab : activeTab // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LayersState].
extension LayersStatePatterns on LayersState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LayersState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LayersState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LayersState value)  $default,){
final _that = this;
switch (_that) {
case _LayersState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LayersState value)?  $default,){
final _that = this;
switch (_that) {
case _LayersState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchQuery,  int activeTab)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LayersState() when $default != null:
return $default(_that.searchQuery,_that.activeTab);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchQuery,  int activeTab)  $default,) {final _that = this;
switch (_that) {
case _LayersState():
return $default(_that.searchQuery,_that.activeTab);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchQuery,  int activeTab)?  $default,) {final _that = this;
switch (_that) {
case _LayersState() when $default != null:
return $default(_that.searchQuery,_that.activeTab);case _:
  return null;

}
}

}

/// @nodoc


class _LayersState implements LayersState {
  const _LayersState({this.searchQuery = '', this.activeTab = 0});
  

@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  int activeTab;

/// Create a copy of LayersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LayersStateCopyWith<_LayersState> get copyWith => __$LayersStateCopyWithImpl<_LayersState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LayersState&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.activeTab, activeTab) || other.activeTab == activeTab));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,activeTab);

@override
String toString() {
  return 'LayersState(searchQuery: $searchQuery, activeTab: $activeTab)';
}


}

/// @nodoc
abstract mixin class _$LayersStateCopyWith<$Res> implements $LayersStateCopyWith<$Res> {
  factory _$LayersStateCopyWith(_LayersState value, $Res Function(_LayersState) _then) = __$LayersStateCopyWithImpl;
@override @useResult
$Res call({
 String searchQuery, int activeTab
});




}
/// @nodoc
class __$LayersStateCopyWithImpl<$Res>
    implements _$LayersStateCopyWith<$Res> {
  __$LayersStateCopyWithImpl(this._self, this._then);

  final _LayersState _self;
  final $Res Function(_LayersState) _then;

/// Create a copy of LayersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = null,Object? activeTab = null,}) {
  return _then(_LayersState(
searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,activeTab: null == activeTab ? _self.activeTab : activeTab // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
