import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'canvas_tool.dart';
import 'canvas_tool_context.dart';

class ConnectorTool implements CanvasTool {
  @override
  final Tool toolType;
  final ShapeType shapeType;

  Offset? _startPoint;
  BoardElement? _currentDraft;

  ConnectorTool({
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
      strokeWidth: context.strokeWidth,
      strokeStyle: context.strokeStyle,
      connectorStyle: context.connectorStyle,
      opacity: context.opacity,
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

    final dist = math.sqrt(
      math.pow(worldPos.dx - _startPoint!.dx, 2) +
          math.pow(worldPos.dy - _startPoint!.dy, 2),
    );

    if (dist >= 6.0) {
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
