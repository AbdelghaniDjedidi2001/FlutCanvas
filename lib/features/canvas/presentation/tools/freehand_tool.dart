import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/data/services/shape_recognition_service.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'canvas_tool.dart';
import 'canvas_tool_context.dart';

class FreehandTool implements CanvasTool {
  @override
  final Tool toolType;
  final bool isHighlighter;

  final List<Offset> _points = [];
  BoardElement? _currentDraft;
  Timer? _shapeSnapTimer;
  bool _didSnapCurrentStroke = false;

  FreehandTool({
    required this.toolType,
    this.isHighlighter = false,
  });

  @override
  MouseCursor get cursor => SystemMouseCursors.precise;

  // Helper: snap a world-space point to the nearest 24px grid intersection.
  static Offset _snapToGrid(Offset pos) {
    const snap = 24.0;
    return Offset(
      (pos.dx / snap).roundToDouble() * snap,
      (pos.dy / snap).roundToDouble() * snap,
    );
  }

  @override
  void onPointerDown(Offset worldPos, CanvasToolContext context) {
    _shapeSnapTimer?.cancel();
    _didSnapCurrentStroke = false;
    _points.clear();

    // Snap the very first point to the 24px grid when grid-snap is active.
    final startPos =
        (!isHighlighter && context.gridSnap) ? _snapToGrid(worldPos) : worldPos;
    _points.add(startPos);

    final id = context.generateElementId();
    final strokeWidth = isHighlighter
        ? (context.strokeWidth < 12.0 ? 24.0 : context.strokeWidth)
        : context.strokeWidth;

    _currentDraft = BoardElement(
      id: id,
      type: isHighlighter ? ShapeType.highlighter : ShapeType.pen,
      start: startPos,
      end: startPos,
      points: List.unmodifiable(_points),
      color: context.strokeColor,
      strokeWidth: strokeWidth,
      strokeStyle: context.strokeStyle,
      opacity: context.opacity,
    );
    context.setDraft(_currentDraft);
  }

  void _trySnapCurrentStroke(CanvasToolContext context) {
    if (_currentDraft == null || _didSnapCurrentStroke || isHighlighter) return;
    if (_points.length < 3) return;

    final recognized = ShapeRecognitionService.recognizeShape(_points);
    if (recognized != null && recognized.confidence >= 0.50) {
      var start = recognized.start;
      var end = recognized.end;
      if (context.gridSnap) {
        start = _snapToGrid(start);
        end = _snapToGrid(end);
      }
      _currentDraft = _currentDraft!.copyWith(
        type: recognized.shapeType,
        start: start,
        end: end,
        points: const [],
      );
      _didSnapCurrentStroke = true;
      context.setDraft(_currentDraft);
    }
  }

  @override
  void onPointerMove(Offset worldPos, CanvasToolContext context) {
    if (_currentDraft == null) return;

    if (_didSnapCurrentStroke) {
      // After mid-stroke snap: only update the endpoint for line/arrow types.
      if (_currentDraft!.type == ShapeType.line ||
          _currentDraft!.type == ShapeType.arrow ||
          _currentDraft!.type == ShapeType.doubleArrow) {
        final endPos = context.gridSnap ? _snapToGrid(worldPos) : worldPos;
        _currentDraft = _currentDraft!.copyWith(end: endPos);
        context.setDraft(_currentDraft);
      }
      return;
    }

    if (_points.isEmpty) return;

    // Apply grid snap to every stroke point when enabled (non-highlighter only).
    final effectivePos =
        (!isHighlighter && context.gridSnap) ? _snapToGrid(worldPos) : worldPos;

    final last = _points.last;
    final distSq = (effectivePos.dx - last.dx) * (effectivePos.dx - last.dx) +
        (effectivePos.dy - last.dy) * (effectivePos.dy - last.dy);

    // Only add a new point if it's sufficiently far from the previous one.
    // (Prevents duplicate snapped grid positions from inflating _points.)
    if (distSq >= 4.0) {
      _points.add(effectivePos);
      _currentDraft = _currentDraft!.copyWith(
        end: effectivePos,
        points: List.unmodifiable(_points),
      );
      context.setDraft(_currentDraft);

      // Auto Shape Recognition: cancel + restart the timer on every new point.
      // This ensures it fires exactly 320 ms after the LAST stroke point,
      // i.e., when the user pauses or finishes drawing.
      if (!isHighlighter &&
          context.autoShapeRecognition &&
          _points.length >= 3) {
        _shapeSnapTimer?.cancel();
        _shapeSnapTimer = Timer(const Duration(milliseconds: 320), () {
          _trySnapCurrentStroke(context);
        });
      }
    }
  }

  @override
  void onPointerUp(Offset worldPos, CanvasToolContext context) {
    _shapeSnapTimer?.cancel();
    if (_currentDraft != null) {
      if (_didSnapCurrentStroke) {
        // Mid-stroke snap already applied — commit the snapped element.
        final endPos = context.gridSnap ? _snapToGrid(worldPos) : worldPos;
        final elementToCommit = (_currentDraft!.type == ShapeType.line ||
                _currentDraft!.type == ShapeType.arrow ||
                _currentDraft!.type == ShapeType.doubleArrow)
            ? _currentDraft!.copyWith(end: endPos)
            : _currentDraft!;
        context.commitElement(elementToCommit);
      } else if (_points.length >= 2) {
        // Snap the final pointer-up position if grid snap is active.
        final finalPos =
            (!isHighlighter && context.gridSnap) ? _snapToGrid(worldPos) : worldPos;
        _points.add(finalPos);

        var finalElement = _currentDraft!.copyWith(
          end: finalPos,
          points: List.unmodifiable(_points),
        );

        // Auto Shape Recognition fallback: attempt recognition on the full stroke.
        if (!isHighlighter &&
            context.autoShapeRecognition &&
            _points.length >= 2) {
          final recognized = ShapeRecognitionService.recognizeShape(_points);
          if (recognized != null && recognized.confidence >= 0.50) {
            var start = recognized.start;
            var end = recognized.end;
            if (context.gridSnap) {
              start = _snapToGrid(start);
              end = _snapToGrid(end);
            }
            finalElement = finalElement.copyWith(
              type: recognized.shapeType,
              start: start,
              end: end,
              points: const [],
            );
          }
        }

        context.commitElement(finalElement);
      }
    }
    _points.clear();
    _currentDraft = null;
    _didSnapCurrentStroke = false;
    context.setDraft(null);
  }

  @override
  void onPointerCancel(CanvasToolContext context) {
    _shapeSnapTimer?.cancel();
    _points.clear();
    _currentDraft = null;
    _didSnapCurrentStroke = false;
    context.setDraft(null);
  }

  @override
  void onPointerHover(Offset worldPos, CanvasToolContext context) {}
}
