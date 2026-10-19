// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'broadcast_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BroadcastState {

 bool get isBroadcasting; bool get isStarting; int get port; String? get localIp; String? get serverUrl; int get viewersCount; String? get errorMessage;
/// Create a copy of BroadcastState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BroadcastStateCopyWith<BroadcastState> get copyWith => _$BroadcastStateCopyWithImpl<BroadcastState>(this as BroadcastState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BroadcastState&&(identical(other.isBroadcasting, isBroadcasting) || other.isBroadcasting == isBroadcasting)&&(identical(other.isStarting, isStarting) || other.isStarting == isStarting)&&(identical(other.port, port) || other.port == port)&&(identical(other.localIp, localIp) || other.localIp == localIp)&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.viewersCount, viewersCount) || other.viewersCount == viewersCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isBroadcasting,isStarting,port,localIp,serverUrl,viewersCount,errorMessage);

@override
String toString() {
  return 'BroadcastState(isBroadcasting: $isBroadcasting, isStarting: $isStarting, port: $port, localIp: $localIp, serverUrl: $serverUrl, viewersCount: $viewersCount, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $BroadcastStateCopyWith<$Res>  {
  factory $BroadcastStateCopyWith(BroadcastState value, $Res Function(BroadcastState) _then) = _$BroadcastStateCopyWithImpl;
@useResult
$Res call({
 bool isBroadcasting, bool isStarting, int port, String? localIp, String? serverUrl, int viewersCount, String? errorMessage
});




}
/// @nodoc
class _$BroadcastStateCopyWithImpl<$Res>
    implements $BroadcastStateCopyWith<$Res> {
  _$BroadcastStateCopyWithImpl(this._self, this._then);

  final BroadcastState _self;
  final $Res Function(BroadcastState) _then;

/// Create a copy of BroadcastState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isBroadcasting = null,Object? isStarting = null,Object? port = null,Object? localIp = freezed,Object? serverUrl = freezed,Object? viewersCount = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isBroadcasting: null == isBroadcasting ? _self.isBroadcasting : isBroadcasting // ignore: cast_nullable_to_non_nullable
as bool,isStarting: null == isStarting ? _self.isStarting : isStarting // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,localIp: freezed == localIp ? _self.localIp : localIp // ignore: cast_nullable_to_non_nullable
as String?,serverUrl: freezed == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String?,viewersCount: null == viewersCount ? _self.viewersCount : viewersCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BroadcastState].
extension BroadcastStatePatterns on BroadcastState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BroadcastState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BroadcastState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BroadcastState value)  $default,){
final _that = this;
switch (_that) {
case _BroadcastState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BroadcastState value)?  $default,){
final _that = this;
switch (_that) {
case _BroadcastState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isBroadcasting,  bool isStarting,  int port,  String? localIp,  String? serverUrl,  int viewersCount,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BroadcastState() when $default != null:
return $default(_that.isBroadcasting,_that.isStarting,_that.port,_that.localIp,_that.serverUrl,_that.viewersCount,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isBroadcasting,  bool isStarting,  int port,  String? localIp,  String? serverUrl,  int viewersCount,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _BroadcastState():
return $default(_that.isBroadcasting,_that.isStarting,_that.port,_that.localIp,_that.serverUrl,_that.viewersCount,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isBroadcasting,  bool isStarting,  int port,  String? localIp,  String? serverUrl,  int viewersCount,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _BroadcastState() when $default != null:
return $default(_that.isBroadcasting,_that.isStarting,_that.port,_that.localIp,_that.serverUrl,_that.viewersCount,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _BroadcastState extends BroadcastState {
  const _BroadcastState({this.isBroadcasting = false, this.isStarting = false, this.port = 4040, this.localIp, this.serverUrl, this.viewersCount = 0, this.errorMessage}): super._();
  

@override@JsonKey() final  bool isBroadcasting;
@override@JsonKey() final  bool isStarting;
@override@JsonKey() final  int port;
@override final  String? localIp;
@override final  String? serverUrl;
@override@JsonKey() final  int viewersCount;
@override final  String? errorMessage;

/// Create a copy of BroadcastState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BroadcastStateCopyWith<_BroadcastState> get copyWith => __$BroadcastStateCopyWithImpl<_BroadcastState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BroadcastState&&(identical(other.isBroadcasting, isBroadcasting) || other.isBroadcasting == isBroadcasting)&&(identical(other.isStarting, isStarting) || other.isStarting == isStarting)&&(identical(other.port, port) || other.port == port)&&(identical(other.localIp, localIp) || other.localIp == localIp)&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.viewersCount, viewersCount) || other.viewersCount == viewersCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isBroadcasting,isStarting,port,localIp,serverUrl,viewersCount,errorMessage);

@override
String toString() {
  return 'BroadcastState(isBroadcasting: $isBroadcasting, isStarting: $isStarting, port: $port, localIp: $localIp, serverUrl: $serverUrl, viewersCount: $viewersCount, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$BroadcastStateCopyWith<$Res> implements $BroadcastStateCopyWith<$Res> {
  factory _$BroadcastStateCopyWith(_BroadcastState value, $Res Function(_BroadcastState) _then) = __$BroadcastStateCopyWithImpl;
@override @useResult
$Res call({
 bool isBroadcasting, bool isStarting, int port, String? localIp, String? serverUrl, int viewersCount, String? errorMessage
});




}
/// @nodoc
class __$BroadcastStateCopyWithImpl<$Res>
    implements _$BroadcastStateCopyWith<$Res> {
  __$BroadcastStateCopyWithImpl(this._self, this._then);

  final _BroadcastState _self;
  final $Res Function(_BroadcastState) _then;

/// Create a copy of BroadcastState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isBroadcasting = null,Object? isStarting = null,Object? port = null,Object? localIp = freezed,Object? serverUrl = freezed,Object? viewersCount = null,Object? errorMessage = freezed,}) {
  return _then(_BroadcastState(
isBroadcasting: null == isBroadcasting ? _self.isBroadcasting : isBroadcasting // ignore: cast_nullable_to_non_nullable
as bool,isStarting: null == isStarting ? _self.isStarting : isStarting // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,localIp: freezed == localIp ? _self.localIp : localIp // ignore: cast_nullable_to_non_nullable
as String?,serverUrl: freezed == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String?,viewersCount: null == viewersCount ? _self.viewersCount : viewersCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
