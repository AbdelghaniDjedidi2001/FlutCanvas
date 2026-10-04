import 'package:flutter/material.dart';
import '../../domain/models/board_element.dart';
import '../../domain/models/shape_type.dart';
import '../../domain/models/tool.dart';
import 'canvas_tool.dart';
import 'canvas_tool_context.dart';

class FreehandTool implements CanvasTool {
  @override
  final Tool toolType;
  final bool isHighlighter;

  final List<Offset> _points = [];
  BoardElement? _currentDraft;

  FreehandTool({
    required this.toolType,
    this.isHighlighter = false,
  });

  @override
  MouseCursor get cursor => SystemMouseCursors.precise;

  @override
  void onPointerDown(Offset worldPos, CanvasToolContext context) {
    _points.clear();
    _points.add(worldPos);

    final id = context.generateElementId();
    _currentDraft = BoardElement(
      id: id,
      type: isHighlighter ? ShapeType.highlighter : ShapeType.pen,
      start: worldPos,
      end: worldPos,
      points: List.unmodifiable(_points),
      color: isHighlighter
          ? context.strokeColor.withValues(alpha: 0.35)
          : context.strokeColor,
      strokeWidth: isHighlighter ? 24.0 : context.strokeWidth,
      strokeStyle: context.strokeStyle,
      opacity: isHighlighter ? 0.4 : context.opacity,
    );
    context.setDraft(_currentDraft);
  }

  @override
  void onPointerMove(Offset worldPos, CanvasToolContext context) {
    if (_currentDraft == null || _points.isEmpty) return;

    final last = _points.last;
    final distSq = (worldPos.dx - last.dx) * (worldPos.dx - last.dx) +
        (worldPos.dy - last.dy) * (worldPos.dy - last.dy);

    // Filter points that are too close (smooth stroke)
    if (distSq >= 4.0) {
      _points.add(worldPos);
      _currentDraft = _currentDraft!.copyWith(
        end: worldPos,
        points: List.unmodifiable(_points),
      );
      context.setDraft(_currentDraft);
    }
  }

  @override
  void onPointerUp(Offset worldPos, CanvasToolContext context) {
    if (_currentDraft != null && _points.length >= 2) {
      _points.add(worldPos);
      context.commitElement(
        _currentDraft!.copyWith(
          end: worldPos,
          points: List.unmodifiable(_points),
        ),
      );
    }
    _points.clear();
    _currentDraft = null;
    context.setDraft(null);
  }

  @override
  void onPointerCancel(CanvasToolContext context) {
    _points.clear();
    _currentDraft = null;
    context.setDraft(null);
  }
}
