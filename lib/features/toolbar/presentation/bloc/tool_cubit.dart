import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'tool_state.dart';

@injectable
class ToolCubit extends Cubit<ToolState> {
  ToolCubit() : super(const ToolState());

  void setTool(Tool tool) {
    if (tool == Tool.highlighter) {
      final isMono = BoardColors.isMonochromeOrInk(state.strokeColor);
      emit(state.copyWith(
        currentTool: tool,
        strokeColor: isMono ? BoardColors.highlighterDefault : state.strokeColor,
        strokeWidth: state.strokeWidth < 12.0 ? 24.0 : state.strokeWidth,
      ));
      return;
    }
    if (state.currentTool == Tool.highlighter && tool != Tool.highlighter) {
      if (state.strokeColor == BoardColors.highlighterDefault ||
          state.strokeColor == const Color(0xFFFFE066)) {
        emit(state.copyWith(
          currentTool: tool,
          strokeColor: kInk,
          strokeWidth: state.strokeWidth >= 16.0 ? 2.5 : state.strokeWidth,
        ));
        return;
      }
    }
    emit(state.copyWith(currentTool: tool));
  }

  void setStrokeColor(Color color) => emit(state.copyWith(strokeColor: color));

  void setFillColor(Color color) => emit(state.copyWith(fillColor: color));

  void setStrokeWidth(double width) => emit(state.copyWith(strokeWidth: width));

  void setStrokeStyle(StrokeStyle style) =>
      emit(state.copyWith(strokeStyle: style));

  void setFillStyle(FillStyle style) => emit(state.copyWith(fillStyle: style));

  void setDrawStyle(DrawStyle style) => emit(state.copyWith(drawStyle: style));

  void setFontSize(double size) => emit(state.copyWith(fontSize: size));

  void setOpacity(double opacity) => emit(state.copyWith(opacity: opacity));

  void setRotation(double rotation) => emit(state.copyWith(rotation: rotation));

  void setConnectorStyle(ConnectorStyle style) =>
      emit(state.copyWith(connectorStyle: style));

  void setCodeLanguage(String language) =>
      emit(state.copyWith(codeLanguage: language));

  void toggleGridSnap() => emit(state.copyWith(gridSnap: !state.gridSnap));

  void toggleSmartGuides() =>
      emit(state.copyWith(smartGuides: !state.smartGuides));

  void toggleAutoShapeRecognition() =>
      emit(state.copyWith(autoShapeRecognition: !state.autoShapeRecognition));

  void togglePropertiesPanel() =>
      emit(state.copyWith(isPropertiesOpen: !state.isPropertiesOpen));

  void setPropertiesOpen(bool open) =>
      emit(state.copyWith(isPropertiesOpen: open));

  void toggleLayersSidebar() =>
      emit(state.copyWith(isLayersOpen: !state.isLayersOpen));

  void setLayersOpen(bool open) => emit(state.copyWith(isLayersOpen: open));
}
