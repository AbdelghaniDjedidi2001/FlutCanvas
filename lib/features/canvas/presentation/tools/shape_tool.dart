import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'canvas_tool.dart';
import 'canvas_tool_context.dart';

class ShapeTool implements CanvasTool {
  @override
  final Tool toolType;
  final ShapeType shapeType;

  Offset? _startPoint;
  BoardElement? _currentDraft;

  ShapeTool({
    required this.toolType,
    required this.shapeType,
  });

  @override
  MouseCursor get cursor => SystemMouseCursors.precise;

  Offset _snap(Offset pos, bool snapEnabled) {
    if (!snapEnabled) return pos;
    const snap = 24.0;
    return Offset(
      (pos.dx / snap).roundToDouble() * snap,
      (pos.dy / snap).roundToDouble() * snap,
    );
  }

  @override
  void onPointerDown(Offset worldPos, CanvasToolContext context) {
    final snappedPos = _snap(worldPos, context.gridSnap);
    _startPoint = snappedPos;
    final id = context.generateElementId();
    _currentDraft = BoardElement(
      id: id,
      type: shapeType,
      start: snappedPos,
      end: snappedPos,
      color: context.strokeColor,
      fillColor: context.fillColor,
      strokeWidth: context.strokeWidth,
      strokeStyle: context.strokeStyle,
      fillStyle: context.fillStyle,
      drawStyle: context.drawStyle,
      opacity: context.opacity,
      frameTitle: shapeType == ShapeType.frame ? 'Frame' : null,
    );
    context.setDraft(_currentDraft);
  }

  @override
  void onPointerMove(Offset worldPos, CanvasToolContext context) {
    if (_startPoint == null || _currentDraft == null) return;
    final snappedPos = _snap(worldPos, context.gridSnap);
    _currentDraft = _currentDraft!.copyWith(end: snappedPos);
    context.setDraft(_currentDraft);
  }

  @override
  void onPointerUp(Offset worldPos, CanvasToolContext context) {
    if (_startPoint == null || _currentDraft == null) return;
    final snappedPos = _snap(worldPos, context.gridSnap);

    final dx = (snappedPos.dx - _startPoint!.dx).abs();
    final dy = (snappedPos.dy - _startPoint!.dy).abs();
    final minDimension = math.max(dx, dy);

    if (minDimension >= 5.0) {
      context.commitElement(_currentDraft!.copyWith(end: snappedPos));
    }

    _startPoint = null;
    _currentDraft = null;
    context.setDraft(null);
  }

  @override
  void onPointerCancel(CanvasToolContext context) {
    _startPoint = null;
    _currentDraft = null;
    context.setDraft(null);
  }

  @override
  void onPointerHover(Offset worldPos, CanvasToolContext context) {}
}
