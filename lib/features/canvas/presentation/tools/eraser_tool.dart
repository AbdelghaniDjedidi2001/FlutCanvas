import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'canvas_tool.dart';
import 'canvas_tool_context.dart';

class EraserTool implements CanvasTool {
  @override
  Tool get toolType => Tool.eraser;

  @override
  MouseCursor get cursor => SystemMouseCursors.click;

  void _eraseAt(Offset worldPos, CanvasToolContext context) {
    final tolerance = 12.0 / context.zoom;
    final toDelete = <String>{};

    for (final el in context.elements.reversed) {
      if (!el.isLocked && el.hitTest(worldPos, tolerance)) {
        toDelete.add(el.id);
        break; // Erase topmost element per stroke sample
      }
    }

    if (toDelete.isNotEmpty) {
      context.deleteElements(toDelete);
    }
  }

  @override
  void onPointerDown(Offset worldPos, CanvasToolContext context) {
    _eraseAt(worldPos, context);
  }

  @override
  void onPointerMove(Offset worldPos, CanvasToolContext context) {
    _eraseAt(worldPos, context);
  }

  @override
  void onPointerUp(Offset worldPos, CanvasToolContext context) {}

  @override
  void onPointerCancel(CanvasToolContext context) {}
}
