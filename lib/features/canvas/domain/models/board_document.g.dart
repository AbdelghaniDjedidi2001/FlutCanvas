// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BoardDocument _$BoardDocumentFromJson(
  Map json,
) => $checkedCreate('_BoardDocument', json, ($checkedConvert) {
  final val = _BoardDocument(
    id: $checkedConvert('id', (v) => v as String),
    title: $checkedConvert('title', (v) => v as String),
    elements: $checkedConvert(
      'elements',
      (v) =>
          (v as List<dynamic>?)
              ?.map(
                (e) =>
                    BoardElement.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
    ),
    comments: $checkedConvert(
      'comments',
      (v) =>
          (v as List<dynamic>?)
              ?.map(
                (e) =>
                    BoardComment.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
    ),
    pan: $checkedConvert(
      'pan',
      (v) => v == null
          ? Offset.zero
          : const OffsetConverter().fromJson(v as Map<String, dynamic>),
    ),
    zoom: $checkedConvert('zoom', (v) => (v as num?)?.toDouble() ?? 1.0),
    updatedAt: $checkedConvert(
      'updatedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$BoardDocumentToJson(_BoardDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'elements': instance.elements.map((e) => e.toJson()).toList(),
      'comments': instance.comments.map((e) => e.toJson()).toList(),
      'pan': const OffsetConverter().toJson(instance.pan),
      'zoom': instance.zoom,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
