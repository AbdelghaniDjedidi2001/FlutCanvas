import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';

part 'tool_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class ToolState with _$ToolState {
  const factory ToolState({
    @Default(Tool.rectangle) Tool currentTool,
    @Default(kInk) Color strokeColor,
    @Default(Colors.transparent) Color fillColor,
    @Default(2.5) double strokeWidth,
    @Default(StrokeStyle.solid) StrokeStyle strokeStyle,
    @Default(FillStyle.none) FillStyle fillStyle,
    @Default(DrawStyle.clean) DrawStyle drawStyle,
    @Default(22.0) double fontSize,
    @Default(1.0) double opacity,
    @Default(0.0) double rotation,
    @Default(ConnectorStyle.straight) ConnectorStyle connectorStyle,
    @Default('dart') String codeLanguage,
    @Default(false) bool gridSnap,
    @Default(true) bool smartGuides,
    @Default(true) bool autoShapeRecognition,
    @Default(false) bool isPropertiesOpen,
    @Default(false) bool isLayersOpen,
  }) = _ToolState;
}
