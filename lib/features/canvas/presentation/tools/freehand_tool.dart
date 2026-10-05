import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutcanvas/core/constants/board_colors.dart';
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
  Offset? _lastPointerMovePos;

  FreehandTool({
    required this.toolType,
    this.isHighlighter = false,
  });

  @override
  MouseCursor get cursor => SystemMouseCursors.precise;

  @override
  void onPointerDown(Offset worldPos, CanvasToolContext context) {
    _shapeSnapTimer?.cancel();
    _didSnapCurrentStroke = false;
    _lastPointerMovePos = worldPos;
    _points.clear();
    _points.add(worldPos);

    final id = context.generateElementId();
    final strokeColor = isHighlighter
        ? (BoardColors.isMonochromeOrInk(context.strokeColor)
            ? BoardColors.highlighterDefault
            : context.strokeColor)
        : context.strokeColor;
    final strokeWidth = isHighlighter
        ? (context.strokeWidth < 12.0 ? 24.0 : context.strokeWidth)
        : context.strokeWidth;

    _currentDraft = BoardElement(
      id: id,
      type: isHighlighter ? ShapeType.highlighter : ShapeType.pen,
      start: worldPos,
      end: worldPos,
      points: List.unmodifiable(_points),
      color: strokeColor,
      strokeWidth: strokeWidth,
      strokeStyle: context.strokeStyle,
      opacity: context.opacity,
    );
    context.setDraft(_currentDraft);
  }

  void _trySnapCurrentStroke(CanvasToolContext context) {
    if (_currentDraft == null || _didSnapCurrentStroke || isHighlighter) return;
    if (_points.length < 5) return;

    final recognized = ShapeRecognitionService.recognizeShape(_points);
    if (recognized != null && recognized.confidence >= 0.55) {
      _currentDraft = _currentDraft!.copyWith(
        type: recognized.shapeType,
        start: recognized.start,
        end: recognized.end,
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
      _currentDraft = _currentDraft!.copyWith(end: worldPos);
      context.setDraft(_currentDraft);
      return;
    }

    if (_points.isEmpty) return;

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

      // Auto Shape Recognition pause timer (380ms)
      if (!isHighlighter &&
          context.autoShapeRecognition &&
          _points.length >= 6) {
        final moveDist = (_lastPointerMovePos != null)
            ? (worldPos - _lastPointerMovePos!).distance
            : 0.0;
        if (moveDist > 6.0) {
          _lastPointerMovePos = worldPos;
        }
        _shapeSnapTimer?.cancel();
        _shapeSnapTimer = Timer(const Duration(milliseconds: 380), () {
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
        context.commitElement(_currentDraft!.copyWith(end: worldPos));
      } else if (_points.length >= 2) {
        _points.add(worldPos);

        var finalElement = _currentDraft!.copyWith(
          end: worldPos,
          points: List.unmodifiable(_points),
        );

        // Auto Shape Recognition fallback on pointer up
        if (!isHighlighter &&
            context.autoShapeRecognition &&
            _points.length >= 5) {
          final recognized = ShapeRecognitionService.recognizeShape(_points);
          if (recognized != null && recognized.confidence >= 0.55) {
            finalElement = finalElement.copyWith(
              type: recognized.shapeType,
              start: recognized.start,
              end: recognized.end,
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
