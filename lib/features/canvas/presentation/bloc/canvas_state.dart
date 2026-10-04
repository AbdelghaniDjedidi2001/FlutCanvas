import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/snap_guide.dart';

part 'canvas_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class CanvasState with _$CanvasState {
  const factory CanvasState({
    @Default([]) List<BoardElement> elements,
    @Default({}) Set<String> selectedIds,
    BoardElement? draft,
    Rect? marqueeRect,
    @Default([]) List<SnapGuide> snapGuides,
    @Default(false) bool canUndo,
    @Default(false) bool canRedo,
  }) = _CanvasState;

  const CanvasState._();

  List<BoardElement> get selectedElements =>
      elements.where((e) => selectedIds.contains(e.id)).toList();

  bool get hasSelection => selectedIds.isNotEmpty;
  bool get isSingleSelection => selectedIds.length == 1;

  BoardElement? get singleSelectedElement =>
      isSingleSelection ? selectedElements.firstOrNull : null;
}
