// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_binding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConnectionBinding _$ConnectionBindingFromJson(Map json) =>
    $checkedCreate('_ConnectionBinding', json, ($checkedConvert) {
      final val = _ConnectionBinding(
        elementId: $checkedConvert('elementId', (v) => v as String),
        anchor: $checkedConvert(
          'anchor',
          (v) => $enumDecode(_$AnchorPointEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ConnectionBindingToJson(_ConnectionBinding instance) =>
    <String, dynamic>{
      'elementId': instance.elementId,
      'anchor': _$AnchorPointEnumMap[instance.anchor]!,
    };

const _$AnchorPointEnumMap = {
  AnchorPoint.top: 'top',
  AnchorPoint.right: 'right',
  AnchorPoint.bottom: 'bottom',
  AnchorPoint.left: 'left',
  AnchorPoint.center: 'center',
};
