// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'board_element.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BoardElement {

 String get id; ShapeType get type;@OffsetConverter() Offset get start;@OffsetConverter() Offset get end;@OffsetListConverter() List<Offset> get points;@ColorConverter() Color get color; double get strokeWidth; StrokeStyle get strokeStyle; FillStyle get fillStyle;@ColorConverter() Color get fillColor; String get text; double get fontSize; double get opacity; double get rotation; ConnectionBinding? get startBinding; ConnectionBinding? get endBinding; String? get imageBase64; String? get groupId; DrawStyle get drawStyle; String? get frameTitle; int? get frameIndex; bool get isLocked; bool get isVisible; String? get customName; ConnectorStyle get connectorStyle; String? get label; String? get codeLanguage; bool get showLineNumbers;@TableDataConverter() List<List<String>>? get tableData; bool get tableHasHeader; String? get iconName; String? get iconCategory;
/// Create a copy of BoardElement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardElementCopyWith<BoardElement> get copyWith => _$BoardElementCopyWithImpl<BoardElement>(this as BoardElement, _$identity);

  /// Serializes this BoardElement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardElement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.color, color) || other.color == color)&&(identical(other.strokeWidth, strokeWidth) || other.strokeWidth == strokeWidth)&&(identical(other.strokeStyle, strokeStyle) || other.strokeStyle == strokeStyle)&&(identical(other.fillStyle, fillStyle) || other.fillStyle == fillStyle)&&(identical(other.fillColor, fillColor) || other.fillColor == fillColor)&&(identical(other.text, text) || other.text == text)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.startBinding, startBinding) || other.startBinding == startBinding)&&(identical(other.endBinding, endBinding) || other.endBinding == endBinding)&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.drawStyle, drawStyle) || other.drawStyle == drawStyle)&&(identical(other.frameTitle, frameTitle) || other.frameTitle == frameTitle)&&(identical(other.frameIndex, frameIndex) || other.frameIndex == frameIndex)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.customName, customName) || other.customName == customName)&&(identical(other.connectorStyle, connectorStyle) || other.connectorStyle == connectorStyle)&&(identical(other.label, label) || other.label == label)&&(identical(other.codeLanguage, codeLanguage) || other.codeLanguage == codeLanguage)&&(identical(other.showLineNumbers, showLineNumbers) || other.showLineNumbers == showLineNumbers)&&const DeepCollectionEquality().equals(other.tableData, tableData)&&(identical(other.tableHasHeader, tableHasHeader) || other.tableHasHeader == tableHasHeader)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.iconCategory, iconCategory) || other.iconCategory == iconCategory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,start,end,const DeepCollectionEquality().hash(points),color,strokeWidth,strokeStyle,fillStyle,fillColor,text,fontSize,opacity,rotation,startBinding,endBinding,imageBase64,groupId,drawStyle,frameTitle,frameIndex,isLocked,isVisible,customName,connectorStyle,label,codeLanguage,showLineNumbers,const DeepCollectionEquality().hash(tableData),tableHasHeader,iconName,iconCategory]);

@override
String toString() {
  return 'BoardElement(id: $id, type: $type, start: $start, end: $end, points: $points, color: $color, strokeWidth: $strokeWidth, strokeStyle: $strokeStyle, fillStyle: $fillStyle, fillColor: $fillColor, text: $text, fontSize: $fontSize, opacity: $opacity, rotation: $rotation, startBinding: $startBinding, endBinding: $endBinding, imageBase64: $imageBase64, groupId: $groupId, drawStyle: $drawStyle, frameTitle: $frameTitle, frameIndex: $frameIndex, isLocked: $isLocked, isVisible: $isVisible, customName: $customName, connectorStyle: $connectorStyle, label: $label, codeLanguage: $codeLanguage, showLineNumbers: $showLineNumbers, tableData: $tableData, tableHasHeader: $tableHasHeader, iconName: $iconName, iconCategory: $iconCategory)';
}


}

/// @nodoc
abstract mixin class $BoardElementCopyWith<$Res>  {
  factory $BoardElementCopyWith(BoardElement value, $Res Function(BoardElement) _then) = _$BoardElementCopyWithImpl;
@useResult
$Res call({
 String id, ShapeType type,@OffsetConverter() Offset start,@OffsetConverter() Offset end,@OffsetListConverter() List<Offset> points,@ColorConverter() Color color, double strokeWidth, StrokeStyle strokeStyle, FillStyle fillStyle,@ColorConverter() Color fillColor, String text, double fontSize, double opacity, double rotation, ConnectionBinding? startBinding, ConnectionBinding? endBinding, String? imageBase64, String? groupId, DrawStyle drawStyle, String? frameTitle, int? frameIndex, bool isLocked, bool isVisible, String? customName, ConnectorStyle connectorStyle, String? label, String? codeLanguage, bool showLineNumbers,@TableDataConverter() List<List<String>>? tableData, bool tableHasHeader, String? iconName, String? iconCategory
});


$ConnectionBindingCopyWith<$Res>? get startBinding;$ConnectionBindingCopyWith<$Res>? get endBinding;

}
/// @nodoc
class _$BoardElementCopyWithImpl<$Res>
    implements $BoardElementCopyWith<$Res> {
  _$BoardElementCopyWithImpl(this._self, this._then);

  final BoardElement _self;
  final $Res Function(BoardElement) _then;

/// Create a copy of BoardElement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? start = null,Object? end = null,Object? points = null,Object? color = null,Object? strokeWidth = null,Object? strokeStyle = null,Object? fillStyle = null,Object? fillColor = null,Object? text = null,Object? fontSize = null,Object? opacity = null,Object? rotation = null,Object? startBinding = freezed,Object? endBinding = freezed,Object? imageBase64 = freezed,Object? groupId = freezed,Object? drawStyle = null,Object? frameTitle = freezed,Object? frameIndex = freezed,Object? isLocked = null,Object? isVisible = null,Object? customName = freezed,Object? connectorStyle = null,Object? label = freezed,Object? codeLanguage = freezed,Object? showLineNumbers = null,Object? tableData = freezed,Object? tableHasHeader = null,Object? iconName = freezed,Object? iconCategory = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ShapeType,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Offset,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Offset,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,strokeWidth: null == strokeWidth ? _self.strokeWidth : strokeWidth // ignore: cast_nullable_to_non_nullable
as double,strokeStyle: null == strokeStyle ? _self.strokeStyle : strokeStyle // ignore: cast_nullable_to_non_nullable
as StrokeStyle,fillStyle: null == fillStyle ? _self.fillStyle : fillStyle // ignore: cast_nullable_to_non_nullable
as FillStyle,fillColor: null == fillColor ? _self.fillColor : fillColor // ignore: cast_nullable_to_non_nullable
as Color,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,startBinding: freezed == startBinding ? _self.startBinding : startBinding // ignore: cast_nullable_to_non_nullable
as ConnectionBinding?,endBinding: freezed == endBinding ? _self.endBinding : endBinding // ignore: cast_nullable_to_non_nullable
as ConnectionBinding?,imageBase64: freezed == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,drawStyle: null == drawStyle ? _self.drawStyle : drawStyle // ignore: cast_nullable_to_non_nullable
as DrawStyle,frameTitle: freezed == frameTitle ? _self.frameTitle : frameTitle // ignore: cast_nullable_to_non_nullable
as String?,frameIndex: freezed == frameIndex ? _self.frameIndex : frameIndex // ignore: cast_nullable_to_non_nullable
as int?,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,customName: freezed == customName ? _self.customName : customName // ignore: cast_nullable_to_non_nullable
as String?,connectorStyle: null == connectorStyle ? _self.connectorStyle : connectorStyle // ignore: cast_nullable_to_non_nullable
as ConnectorStyle,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,codeLanguage: freezed == codeLanguage ? _self.codeLanguage : codeLanguage // ignore: cast_nullable_to_non_nullable
as String?,showLineNumbers: null == showLineNumbers ? _self.showLineNumbers : showLineNumbers // ignore: cast_nullable_to_non_nullable
as bool,tableData: freezed == tableData ? _self.tableData : tableData // ignore: cast_nullable_to_non_nullable
as List<List<String>>?,tableHasHeader: null == tableHasHeader ? _self.tableHasHeader : tableHasHeader // ignore: cast_nullable_to_non_nullable
as bool,iconName: freezed == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String?,iconCategory: freezed == iconCategory ? _self.iconCategory : iconCategory // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of BoardElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionBindingCopyWith<$Res>? get startBinding {
    if (_self.startBinding == null) {
    return null;
  }

  return $ConnectionBindingCopyWith<$Res>(_self.startBinding!, (value) {
    return _then(_self.copyWith(startBinding: value));
  });
}/// Create a copy of BoardElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionBindingCopyWith<$Res>? get endBinding {
    if (_self.endBinding == null) {
    return null;
  }

  return $ConnectionBindingCopyWith<$Res>(_self.endBinding!, (value) {
    return _then(_self.copyWith(endBinding: value));
  });
}
}


/// Adds pattern-matching-related methods to [BoardElement].
extension BoardElementPatterns on BoardElement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoardElement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoardElement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoardElement value)  $default,){
final _that = this;
switch (_that) {
case _BoardElement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoardElement value)?  $default,){
final _that = this;
switch (_that) {
case _BoardElement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ShapeType type, @OffsetConverter()  Offset start, @OffsetConverter()  Offset end, @OffsetListConverter()  List<Offset> points, @ColorConverter()  Color color,  double strokeWidth,  StrokeStyle strokeStyle,  FillStyle fillStyle, @ColorConverter()  Color fillColor,  String text,  double fontSize,  double opacity,  double rotation,  ConnectionBinding? startBinding,  ConnectionBinding? endBinding,  String? imageBase64,  String? groupId,  DrawStyle drawStyle,  String? frameTitle,  int? frameIndex,  bool isLocked,  bool isVisible,  String? customName,  ConnectorStyle connectorStyle,  String? label,  String? codeLanguage,  bool showLineNumbers, @TableDataConverter()  List<List<String>>? tableData,  bool tableHasHeader,  String? iconName,  String? iconCategory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoardElement() when $default != null:
return $default(_that.id,_that.type,_that.start,_that.end,_that.points,_that.color,_that.strokeWidth,_that.strokeStyle,_that.fillStyle,_that.fillColor,_that.text,_that.fontSize,_that.opacity,_that.rotation,_that.startBinding,_that.endBinding,_that.imageBase64,_that.groupId,_that.drawStyle,_that.frameTitle,_that.frameIndex,_that.isLocked,_that.isVisible,_that.customName,_that.connectorStyle,_that.label,_that.codeLanguage,_that.showLineNumbers,_that.tableData,_that.tableHasHeader,_that.iconName,_that.iconCategory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ShapeType type, @OffsetConverter()  Offset start, @OffsetConverter()  Offset end, @OffsetListConverter()  List<Offset> points, @ColorConverter()  Color color,  double strokeWidth,  StrokeStyle strokeStyle,  FillStyle fillStyle, @ColorConverter()  Color fillColor,  String text,  double fontSize,  double opacity,  double rotation,  ConnectionBinding? startBinding,  ConnectionBinding? endBinding,  String? imageBase64,  String? groupId,  DrawStyle drawStyle,  String? frameTitle,  int? frameIndex,  bool isLocked,  bool isVisible,  String? customName,  ConnectorStyle connectorStyle,  String? label,  String? codeLanguage,  bool showLineNumbers, @TableDataConverter()  List<List<String>>? tableData,  bool tableHasHeader,  String? iconName,  String? iconCategory)  $default,) {final _that = this;
switch (_that) {
case _BoardElement():
return $default(_that.id,_that.type,_that.start,_that.end,_that.points,_that.color,_that.strokeWidth,_that.strokeStyle,_that.fillStyle,_that.fillColor,_that.text,_that.fontSize,_that.opacity,_that.rotation,_that.startBinding,_that.endBinding,_that.imageBase64,_that.groupId,_that.drawStyle,_that.frameTitle,_that.frameIndex,_that.isLocked,_that.isVisible,_that.customName,_that.connectorStyle,_that.label,_that.codeLanguage,_that.showLineNumbers,_that.tableData,_that.tableHasHeader,_that.iconName,_that.iconCategory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ShapeType type, @OffsetConverter()  Offset start, @OffsetConverter()  Offset end, @OffsetListConverter()  List<Offset> points, @ColorConverter()  Color color,  double strokeWidth,  StrokeStyle strokeStyle,  FillStyle fillStyle, @ColorConverter()  Color fillColor,  String text,  double fontSize,  double opacity,  double rotation,  ConnectionBinding? startBinding,  ConnectionBinding? endBinding,  String? imageBase64,  String? groupId,  DrawStyle drawStyle,  String? frameTitle,  int? frameIndex,  bool isLocked,  bool isVisible,  String? customName,  ConnectorStyle connectorStyle,  String? label,  String? codeLanguage,  bool showLineNumbers, @TableDataConverter()  List<List<String>>? tableData,  bool tableHasHeader,  String? iconName,  String? iconCategory)?  $default,) {final _that = this;
switch (_that) {
case _BoardElement() when $default != null:
return $default(_that.id,_that.type,_that.start,_that.end,_that.points,_that.color,_that.strokeWidth,_that.strokeStyle,_that.fillStyle,_that.fillColor,_that.text,_that.fontSize,_that.opacity,_that.rotation,_that.startBinding,_that.endBinding,_that.imageBase64,_that.groupId,_that.drawStyle,_that.frameTitle,_that.frameIndex,_that.isLocked,_that.isVisible,_that.customName,_that.connectorStyle,_that.label,_that.codeLanguage,_that.showLineNumbers,_that.tableData,_that.tableHasHeader,_that.iconName,_that.iconCategory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()
@OffsetConverter()
@ColorConverter()
@OffsetListConverter()
@TableDataConverter()
class _BoardElement extends BoardElement {
  const _BoardElement({required this.id, required this.type, @OffsetConverter() required this.start, @OffsetConverter() required this.end, @OffsetListConverter() this.points = const [], @ColorConverter() this.color = const Color(0xFF1F2430), this.strokeWidth = 2.5, this.strokeStyle = StrokeStyle.solid, this.fillStyle = FillStyle.none, @ColorConverter() this.fillColor = const Color(0x00000000), this.text = '', this.fontSize = 22.0, this.opacity = 1.0, this.rotation = 0.0, this.startBinding, this.endBinding, this.imageBase64, this.groupId, this.drawStyle = DrawStyle.clean, this.frameTitle, this.frameIndex, this.isLocked = false, this.isVisible = true, this.customName, this.connectorStyle = ConnectorStyle.straight, this.label, this.codeLanguage, this.showLineNumbers = true, @TableDataConverter() this.tableData, this.tableHasHeader = true, this.iconName, this.iconCategory}): super._();
  factory _BoardElement.fromJson(Map<String, dynamic> json) => _$BoardElementFromJson(json);

@override final  String id;
@override final  ShapeType type;
@override@OffsetConverter() final  Offset start;
@override@OffsetConverter() final  Offset end;
@override@JsonKey()@OffsetListConverter() final  List<Offset> points;
@override@JsonKey()@ColorConverter() final  Color color;
@override@JsonKey() final  double strokeWidth;
@override@JsonKey() final  StrokeStyle strokeStyle;
@override@JsonKey() final  FillStyle fillStyle;
@override@JsonKey()@ColorConverter() final  Color fillColor;
@override@JsonKey() final  String text;
@override@JsonKey() final  double fontSize;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  double rotation;
@override final  ConnectionBinding? startBinding;
@override final  ConnectionBinding? endBinding;
@override final  String? imageBase64;
@override final  String? groupId;
@override@JsonKey() final  DrawStyle drawStyle;
@override final  String? frameTitle;
@override final  int? frameIndex;
@override@JsonKey() final  bool isLocked;
@override@JsonKey() final  bool isVisible;
@override final  String? customName;
@override@JsonKey() final  ConnectorStyle connectorStyle;
@override final  String? label;
@override final  String? codeLanguage;
@override@JsonKey() final  bool showLineNumbers;
@override@TableDataConverter() final  List<List<String>>? tableData;
@override@JsonKey() final  bool tableHasHeader;
@override final  String? iconName;
@override final  String? iconCategory;

/// Create a copy of BoardElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardElementCopyWith<_BoardElement> get copyWith => __$BoardElementCopyWithImpl<_BoardElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoardElementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoardElement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.color, color) || other.color == color)&&(identical(other.strokeWidth, strokeWidth) || other.strokeWidth == strokeWidth)&&(identical(other.strokeStyle, strokeStyle) || other.strokeStyle == strokeStyle)&&(identical(other.fillStyle, fillStyle) || other.fillStyle == fillStyle)&&(identical(other.fillColor, fillColor) || other.fillColor == fillColor)&&(identical(other.text, text) || other.text == text)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.startBinding, startBinding) || other.startBinding == startBinding)&&(identical(other.endBinding, endBinding) || other.endBinding == endBinding)&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.drawStyle, drawStyle) || other.drawStyle == drawStyle)&&(identical(other.frameTitle, frameTitle) || other.frameTitle == frameTitle)&&(identical(other.frameIndex, frameIndex) || other.frameIndex == frameIndex)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.customName, customName) || other.customName == customName)&&(identical(other.connectorStyle, connectorStyle) || other.connectorStyle == connectorStyle)&&(identical(other.label, label) || other.label == label)&&(identical(other.codeLanguage, codeLanguage) || other.codeLanguage == codeLanguage)&&(identical(other.showLineNumbers, showLineNumbers) || other.showLineNumbers == showLineNumbers)&&const DeepCollectionEquality().equals(other.tableData, tableData)&&(identical(other.tableHasHeader, tableHasHeader) || other.tableHasHeader == tableHasHeader)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.iconCategory, iconCategory) || other.iconCategory == iconCategory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,start,end,const DeepCollectionEquality().hash(points),color,strokeWidth,strokeStyle,fillStyle,fillColor,text,fontSize,opacity,rotation,startBinding,endBinding,imageBase64,groupId,drawStyle,frameTitle,frameIndex,isLocked,isVisible,customName,connectorStyle,label,codeLanguage,showLineNumbers,const DeepCollectionEquality().hash(tableData),tableHasHeader,iconName,iconCategory]);

@override
String toString() {
  return 'BoardElement(id: $id, type: $type, start: $start, end: $end, points: $points, color: $color, strokeWidth: $strokeWidth, strokeStyle: $strokeStyle, fillStyle: $fillStyle, fillColor: $fillColor, text: $text, fontSize: $fontSize, opacity: $opacity, rotation: $rotation, startBinding: $startBinding, endBinding: $endBinding, imageBase64: $imageBase64, groupId: $groupId, drawStyle: $drawStyle, frameTitle: $frameTitle, frameIndex: $frameIndex, isLocked: $isLocked, isVisible: $isVisible, customName: $customName, connectorStyle: $connectorStyle, label: $label, codeLanguage: $codeLanguage, showLineNumbers: $showLineNumbers, tableData: $tableData, tableHasHeader: $tableHasHeader, iconName: $iconName, iconCategory: $iconCategory)';
}


}

/// @nodoc
abstract mixin class _$BoardElementCopyWith<$Res> implements $BoardElementCopyWith<$Res> {
  factory _$BoardElementCopyWith(_BoardElement value, $Res Function(_BoardElement) _then) = __$BoardElementCopyWithImpl;
@override @useResult
$Res call({
 String id, ShapeType type,@OffsetConverter() Offset start,@OffsetConverter() Offset end,@OffsetListConverter() List<Offset> points,@ColorConverter() Color color, double strokeWidth, StrokeStyle strokeStyle, FillStyle fillStyle,@ColorConverter() Color fillColor, String text, double fontSize, double opacity, double rotation, ConnectionBinding? startBinding, ConnectionBinding? endBinding, String? imageBase64, String? groupId, DrawStyle drawStyle, String? frameTitle, int? frameIndex, bool isLocked, bool isVisible, String? customName, ConnectorStyle connectorStyle, String? label, String? codeLanguage, bool showLineNumbers,@TableDataConverter() List<List<String>>? tableData, bool tableHasHeader, String? iconName, String? iconCategory
});


@override $ConnectionBindingCopyWith<$Res>? get startBinding;@override $ConnectionBindingCopyWith<$Res>? get endBinding;

}
/// @nodoc
class __$BoardElementCopyWithImpl<$Res>
    implements _$BoardElementCopyWith<$Res> {
  __$BoardElementCopyWithImpl(this._self, this._then);

  final _BoardElement _self;
  final $Res Function(_BoardElement) _then;

/// Create a copy of BoardElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? start = null,Object? end = null,Object? points = null,Object? color = null,Object? strokeWidth = null,Object? strokeStyle = null,Object? fillStyle = null,Object? fillColor = null,Object? text = null,Object? fontSize = null,Object? opacity = null,Object? rotation = null,Object? startBinding = freezed,Object? endBinding = freezed,Object? imageBase64 = freezed,Object? groupId = freezed,Object? drawStyle = null,Object? frameTitle = freezed,Object? frameIndex = freezed,Object? isLocked = null,Object? isVisible = null,Object? customName = freezed,Object? connectorStyle = null,Object? label = freezed,Object? codeLanguage = freezed,Object? showLineNumbers = null,Object? tableData = freezed,Object? tableHasHeader = null,Object? iconName = freezed,Object? iconCategory = freezed,}) {
  return _then(_BoardElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ShapeType,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Offset,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Offset,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,strokeWidth: null == strokeWidth ? _self.strokeWidth : strokeWidth // ignore: cast_nullable_to_non_nullable
as double,strokeStyle: null == strokeStyle ? _self.strokeStyle : strokeStyle // ignore: cast_nullable_to_non_nullable
as StrokeStyle,fillStyle: null == fillStyle ? _self.fillStyle : fillStyle // ignore: cast_nullable_to_non_nullable
as FillStyle,fillColor: null == fillColor ? _self.fillColor : fillColor // ignore: cast_nullable_to_non_nullable
as Color,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,startBinding: freezed == startBinding ? _self.startBinding : startBinding // ignore: cast_nullable_to_non_nullable
as ConnectionBinding?,endBinding: freezed == endBinding ? _self.endBinding : endBinding // ignore: cast_nullable_to_non_nullable
as ConnectionBinding?,imageBase64: freezed == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,drawStyle: null == drawStyle ? _self.drawStyle : drawStyle // ignore: cast_nullable_to_non_nullable
as DrawStyle,frameTitle: freezed == frameTitle ? _self.frameTitle : frameTitle // ignore: cast_nullable_to_non_nullable
as String?,frameIndex: freezed == frameIndex ? _self.frameIndex : frameIndex // ignore: cast_nullable_to_non_nullable
as int?,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,customName: freezed == customName ? _self.customName : customName // ignore: cast_nullable_to_non_nullable
as String?,connectorStyle: null == connectorStyle ? _self.connectorStyle : connectorStyle // ignore: cast_nullable_to_non_nullable
as ConnectorStyle,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,codeLanguage: freezed == codeLanguage ? _self.codeLanguage : codeLanguage // ignore: cast_nullable_to_non_nullable
as String?,showLineNumbers: null == showLineNumbers ? _self.showLineNumbers : showLineNumbers // ignore: cast_nullable_to_non_nullable
as bool,tableData: freezed == tableData ? _self.tableData : tableData // ignore: cast_nullable_to_non_nullable
as List<List<String>>?,tableHasHeader: null == tableHasHeader ? _self.tableHasHeader : tableHasHeader // ignore: cast_nullable_to_non_nullable
as bool,iconName: freezed == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String?,iconCategory: freezed == iconCategory ? _self.iconCategory : iconCategory // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of BoardElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionBindingCopyWith<$Res>? get startBinding {
    if (_self.startBinding == null) {
    return null;
  }

  return $ConnectionBindingCopyWith<$Res>(_self.startBinding!, (value) {
    return _then(_self.copyWith(startBinding: value));
  });
}/// Create a copy of BoardElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionBindingCopyWith<$Res>? get endBinding {
    if (_self.endBinding == null) {
    return null;
  }

  return $ConnectionBindingCopyWith<$Res>(_self.endBinding!, (value) {
    return _then(_self.copyWith(endBinding: value));
  });
}
}

// dart format on
