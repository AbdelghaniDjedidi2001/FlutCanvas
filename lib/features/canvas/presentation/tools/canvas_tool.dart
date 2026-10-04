import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'canvas_tool_context.dart';

abstract interface class CanvasTool {
  Tool get toolType;
  MouseCursor get cursor;

  void onPointerDown(Offset worldPos, CanvasToolContext context);
  void onPointerMove(Offset worldPos, CanvasToolContext context);
  void onPointerUp(Offset worldPos, CanvasToolContext context);
  void onPointerCancel(CanvasToolContext context);
}
