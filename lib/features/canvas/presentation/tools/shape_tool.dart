import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/board_element.dart';
import '../../domain/models/shape_type.dart';
import '../../domain/models/tool.dart';
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

  @override
  void onPointerDown(Offset worldPos, CanvasToolContext context) {
    _startPoint = worldPos;
    final id = context.generateElementId();
    _currentDraft = BoardElement(
      id: id,
      type: shapeType,
      start: worldPos,
      end: worldPos,
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
    _currentDraft = _currentDraft!.copyWith(end: worldPos);
    context.setDraft(_currentDraft);
  }

  @override
  void onPointerUp(Offset worldPos, CanvasToolContext context) {
    if (_startPoint == null || _currentDraft == null) return;

    final dx = (worldPos.dx - _startPoint!.dx).abs();
    final dy = (worldPos.dy - _startPoint!.dy).abs();
    final minDimension = math.max(dx, dy);

    if (minDimension >= 5.0) {
      context.commitElement(_currentDraft!.copyWith(end: worldPos));
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
}
