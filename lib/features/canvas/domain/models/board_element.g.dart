// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_element.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BoardElement _$BoardElementFromJson(
  Map json,
) => $checkedCreate('_BoardElement', json, ($checkedConvert) {
  final val = _BoardElement(
    id: $checkedConvert('id', (v) => v as String),
    type: $checkedConvert('type', (v) => $enumDecode(_$ShapeTypeEnumMap, v)),
    start: $checkedConvert(
      'start',
      (v) => const OffsetConverter().fromJson(v as Map<String, dynamic>),
    ),
    end: $checkedConvert(
      'end',
      (v) => const OffsetConverter().fromJson(v as Map<String, dynamic>),
    ),
    points: $checkedConvert(
      'points',
      (v) => v == null
          ? const []
          : const OffsetListConverter().fromJson(v as List),
    ),
    color: $checkedConvert(
      'color',
      (v) => v == null
          ? const Color(0xFF1F2430)
          : const ColorConverter().fromJson((v as num).toInt()),
    ),
    strokeWidth: $checkedConvert(
      'strokeWidth',
      (v) => (v as num?)?.toDouble() ?? 2.5,
    ),
    strokeStyle: $checkedConvert(
      'strokeStyle',
      (v) => $enumDecodeNullable(_$StrokeStyleEnumMap, v) ?? StrokeStyle.solid,
    ),
    fillStyle: $checkedConvert(
      'fillStyle',
      (v) => $enumDecodeNullable(_$FillStyleEnumMap, v) ?? FillStyle.none,
    ),
    fillColor: $checkedConvert(
      'fillColor',
      (v) => v == null
          ? const Color(0x00000000)
          : const ColorConverter().fromJson((v as num).toInt()),
    ),
    text: $checkedConvert('text', (v) => v as String? ?? ''),
    fontSize: $checkedConvert(
      'fontSize',
      (v) => (v as num?)?.toDouble() ?? 22.0,
    ),
    opacity: $checkedConvert('opacity', (v) => (v as num?)?.toDouble() ?? 1.0),
    rotation: $checkedConvert(
      'rotation',
      (v) => (v as num?)?.toDouble() ?? 0.0,
    ),
    startBinding: $checkedConvert(
      'startBinding',
      (v) => v == null
          ? null
          : ConnectionBinding.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    endBinding: $checkedConvert(
      'endBinding',
      (v) => v == null
          ? null
          : ConnectionBinding.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    imageBase64: $checkedConvert('imageBase64', (v) => v as String?),
    groupId: $checkedConvert('groupId', (v) => v as String?),
    drawStyle: $checkedConvert(
      'drawStyle',
      (v) => $enumDecodeNullable(_$DrawStyleEnumMap, v) ?? DrawStyle.clean,
    ),
    frameTitle: $checkedConvert('frameTitle', (v) => v as String?),
    frameIndex: $checkedConvert('frameIndex', (v) => (v as num?)?.toInt()),
    isLocked: $checkedConvert('isLocked', (v) => v as bool? ?? false),
    isVisible: $checkedConvert('isVisible', (v) => v as bool? ?? true),
    customName: $checkedConvert('customName', (v) => v as String?),
    connectorStyle: $checkedConvert(
      'connectorStyle',
      (v) =>
          $enumDecodeNullable(_$ConnectorStyleEnumMap, v) ??
          ConnectorStyle.straight,
    ),
    label: $checkedConvert('label', (v) => v as String?),
    codeLanguage: $checkedConvert('codeLanguage', (v) => v as String?),
    showLineNumbers: $checkedConvert(
      'showLineNumbers',
      (v) => v as bool? ?? true,
    ),
    tableData: $checkedConvert(
      'tableData',
      (v) => const TableDataConverter().fromJson(v as List?),
    ),
    tableHasHeader: $checkedConvert(
      'tableHasHeader',
      (v) => v as bool? ?? true,
    ),
  );
  return val;
});

Map<String, dynamic> _$BoardElementToJson(_BoardElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ShapeTypeEnumMap[instance.type]!,
      'start': const OffsetConverter().toJson(instance.start),
      'end': const OffsetConverter().toJson(instance.end),
      'points': const OffsetListConverter().toJson(instance.points),
      'color': const ColorConverter().toJson(instance.color),
      'strokeWidth': instance.strokeWidth,
      'strokeStyle': _$StrokeStyleEnumMap[instance.strokeStyle]!,
      'fillStyle': _$FillStyleEnumMap[instance.fillStyle]!,
      'fillColor': const ColorConverter().toJson(instance.fillColor),
      'text': instance.text,
      'fontSize': instance.fontSize,
      'opacity': instance.opacity,
      'rotation': instance.rotation,
      'startBinding': instance.startBinding?.toJson(),
      'endBinding': instance.endBinding?.toJson(),
      'imageBase64': instance.imageBase64,
      'groupId': instance.groupId,
      'drawStyle': _$DrawStyleEnumMap[instance.drawStyle]!,
      'frameTitle': instance.frameTitle,
      'frameIndex': instance.frameIndex,
      'isLocked': instance.isLocked,
      'isVisible': instance.isVisible,
      'customName': instance.customName,
      'connectorStyle': _$ConnectorStyleEnumMap[instance.connectorStyle]!,
      'label': instance.label,
      'codeLanguage': instance.codeLanguage,
      'showLineNumbers': instance.showLineNumbers,
      'tableData': const TableDataConverter().toJson(instance.tableData),
      'tableHasHeader': instance.tableHasHeader,
    };

const _$ShapeTypeEnumMap = {
  ShapeType.rectangle: 'rectangle',
  ShapeType.roundedRectangle: 'roundedRectangle',
  ShapeType.ellipse: 'ellipse',
  ShapeType.diamond: 'diamond',
  ShapeType.triangle: 'triangle',
  ShapeType.star: 'star',
  ShapeType.line: 'line',
  ShapeType.arrow: 'arrow',
  ShapeType.doubleArrow: 'doubleArrow',
  ShapeType.pen: 'pen',
  ShapeType.highlighter: 'highlighter',
  ShapeType.text: 'text',
  ShapeType.stickyNote: 'stickyNote',
  ShapeType.image: 'image',
  ShapeType.frame: 'frame',
  ShapeType.codeBlock: 'codeBlock',
  ShapeType.table: 'table',
};

const _$StrokeStyleEnumMap = {
  StrokeStyle.solid: 'solid',
  StrokeStyle.dashed: 'dashed',
  StrokeStyle.dotted: 'dotted',
};

const _$FillStyleEnumMap = {
  FillStyle.none: 'none',
  FillStyle.semi: 'semi',
  FillStyle.solid: 'solid',
  FillStyle.hatch: 'hatch',
};

const _$DrawStyleEnumMap = {
  DrawStyle.clean: 'clean',
  DrawStyle.sketch: 'sketch',
};

const _$ConnectorStyleEnumMap = {
  ConnectorStyle.straight: 'straight',
  ConnectorStyle.orthogonal: 'orthogonal',
  ConnectorStyle.curved: 'curved',
};
