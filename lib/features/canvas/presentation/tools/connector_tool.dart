import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connection_binding.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'canvas_tool.dart';
import 'canvas_tool_context.dart';

class ConnectorTool implements CanvasTool {
  @override
  final Tool toolType;
  final ShapeType shapeType;

  Offset? _startPoint;
  ConnectionBinding? _startBinding;
  ConnectionBinding? _endBinding;
  BoardElement? _currentDraft;

  ConnectorTool({
    required this.toolType,
    required this.shapeType,
  });

  @override
  MouseCursor get cursor => SystemMouseCursors.precise;

  (BoardElement, AnchorPoint, Offset)? _findNearestAnchor(
    Offset world,
    CanvasToolContext context,
  ) {
    for (final el in context.elements.reversed) {
      if (!el.isVisible) continue;
      if (el.type == ShapeType.line ||
          el.type == ShapeType.arrow ||
          el.type == ShapeType.doubleArrow) {
        continue;
      }
      final anchorMatch = ConnectionBinding.findNearestAnchor(
        el,
        world,
        maxDistance: 28.0 / math.max(0.1, context.zoom),
      );
      if (anchorMatch != null) {
        return (el, anchorMatch.$1, anchorMatch.$2);
      }
    }
    return null;
  }

  @override
  void onPointerDown(Offset worldPos, CanvasToolContext context) {
    var startPos = worldPos;
    ConnectionBinding? startBinding;
    final match = _findNearestAnchor(worldPos, context);
    if (match != null) {
      startPos = match.$3;
      startBinding = ConnectionBinding(
        elementId: match.$1.id,
        anchor: match.$2,
      );
      context.setConnectionAnchor(element: match.$1, point: match.$3);
    } else {
      context.setConnectionAnchor(element: null, point: null);
    }

    _startPoint = startPos;
    _startBinding = startBinding;
    _endBinding = null;

    final id = context.generateElementId();
    _currentDraft = BoardElement(
      id: id,
      type: shapeType,
      start: startPos,
      end: startPos,
      color: context.strokeColor,
      strokeWidth: context.strokeWidth,
      strokeStyle: context.strokeStyle,
      connectorStyle: context.connectorStyle,
      opacity: context.opacity,
      startBinding: startBinding,
    );
    context.setDraft(_currentDraft);
  }

  @override
  void onPointerMove(Offset worldPos, CanvasToolContext context) {
    if (_startPoint == null || _currentDraft == null) return;

    var endPos = worldPos;
    ConnectionBinding? endBinding;
    final match = _findNearestAnchor(worldPos, context);
    if (match != null) {
      endPos = match.$3;
      endBinding = ConnectionBinding(
        elementId: match.$1.id,
        anchor: match.$2,
      );
      context.setConnectionAnchor(element: match.$1, point: match.$3);
    } else {
      context.setConnectionAnchor(element: null, point: null);
    }
    _endBinding = endBinding;

    _currentDraft = _currentDraft!.copyWith(
      end: endPos,
      endBinding: endBinding,
    );
    context.setDraft(_currentDraft);
  }

  @override
  void onPointerUp(Offset worldPos, CanvasToolContext context) {
    if (_startPoint == null || _currentDraft == null) return;

    var endPos = worldPos;
    var endBinding = _endBinding;
    final match = _findNearestAnchor(worldPos, context);
    if (match != null) {
      endPos = match.$3;
      endBinding = ConnectionBinding(
        elementId: match.$1.id,
        anchor: match.$2,
      );
    }

    final dist = (_currentDraft!.start - endPos).distance;
    if (dist >= 6.0) {
      context.commitElement(
        _currentDraft!.copyWith(
          end: endPos,
          startBinding: _startBinding,
          endBinding: endBinding,
        ),
      );
    }

    _startPoint = null;
    _startBinding = null;
    _endBinding = null;
    _currentDraft = null;
    context.setDraft(null);
    context.setConnectionAnchor(element: null, point: null);
  }

  @override
  void onPointerCancel(CanvasToolContext context) {
    _startPoint = null;
    _startBinding = null;
    _endBinding = null;
    _currentDraft = null;
    context.setDraft(null);
    context.setConnectionAnchor(element: null, point: null);
  }

  @override
  void onPointerHover(Offset worldPos, CanvasToolContext context) {
    final match = _findNearestAnchor(worldPos, context);
    if (match != null) {
      context.setConnectionAnchor(element: match.$1, point: match.$3);
    } else {
      context.setConnectionAnchor(element: null, point: null);
    }
  }
}
