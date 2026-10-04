import 'package:flutter/material.dart';
import '../../domain/models/board_element.dart';
import '../../domain/models/tool.dart';
import 'canvas_tool.dart';
import 'canvas_tool_context.dart';

enum _SelectSubMode {
  none,
  moving,
  marquee,
}

class SelectTool implements CanvasTool {
  _SelectSubMode _subMode = _SelectSubMode.none;
  Offset? _startPoint;
  Offset? _lastPoint;
  bool _hasMoved = false;

  @override
  Tool get toolType => Tool.select;

  @override
  MouseCursor get cursor => switch (_subMode) {
        _SelectSubMode.moving => SystemMouseCursors.move,
        _SelectSubMode.marquee => SystemMouseCursors.basic,
        _SelectSubMode.none => SystemMouseCursors.basic,
      };

  @override
  void onPointerDown(Offset worldPos, CanvasToolContext context) {
    _startPoint = worldPos;
    _lastPoint = worldPos;
    _hasMoved = false;

    final hit = context.hitTestTopmost(worldPos);

    if (hit != null) {
      // Check if clicking an already-selected element
      if (!context.selectedIds.contains(hit.id)) {
        // Expand group if grouped
        final toSelect = <String>{hit.id};
        if (hit.groupId != null) {
          for (final el in context.elements) {
            if (el.groupId == hit.groupId) toSelect.add(el.id);
          }
        }
        context.selectElements(toSelect);
      }
      _subMode = _SelectSubMode.moving;
    } else {
      // Clicked on empty canvas -> clear selection & start marquee
      context.clearSelection();
      _subMode = _SelectSubMode.marquee;
      context.setMarquee(Rect.fromPoints(worldPos, worldPos));
    }
  }

  @override
  void onPointerMove(Offset worldPos, CanvasToolContext context) {
    if (_startPoint == null || _lastPoint == null) return;

    if (_subMode == _SelectSubMode.marquee) {
      final marqueeRect = Rect.fromPoints(_startPoint!, worldPos);
      context.setMarquee(marqueeRect);

      // Multi-select elements whose bounds intersect marquee
      final selectedInMarquee = <String>{};
      for (final el in context.elements) {
        if (!el.isLocked && el.bounds.overlaps(marqueeRect)) {
          selectedInMarquee.add(el.id);
        }
      }
      context.selectElements(selectedInMarquee);
    } else if (_subMode == _SelectSubMode.moving) {
      final delta = worldPos - _lastPoint!;
      if (delta.dx != 0 || delta.dy != 0) {
        _hasMoved = true;
        // Translate all selected elements
        for (final el in context.elements) {
          if (context.selectedIds.contains(el.id) && !el.isLocked) {
            context.updateElement(el.translated(delta));
          }
        }
        _lastPoint = worldPos;
      }
    }
  }

  @override
  void onPointerUp(Offset worldPos, CanvasToolContext context) {
    if (_subMode == _SelectSubMode.marquee) {
      context.setMarquee(null);
    }
    _subMode = _SelectSubMode.none;
    _startPoint = null;
    _lastPoint = null;
    _hasMoved = false;
  }

  @override
  void onPointerCancel(CanvasToolContext context) {
    if (_subMode == _SelectSubMode.marquee) {
      context.setMarquee(null);
    }
    _subMode = _SelectSubMode.none;
    _startPoint = null;
    _lastPoint = null;
  }
}
