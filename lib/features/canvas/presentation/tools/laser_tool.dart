import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import '../../../../painters/laser_painter.dart';
import 'canvas_tool.dart';
import 'canvas_tool_context.dart';

class LaserTool implements CanvasTool {
  final List<LaserPoint> _trail = [];

  @override
  Tool get toolType => Tool.laser;

  @override
  MouseCursor get cursor => SystemMouseCursors.precise;

  @override
  void onPointerDown(Offset worldPos, CanvasToolContext context) {
    _trail.clear();
    _trail.add(LaserPoint(point: worldPos, time: DateTime.now()));
    context.setLaserTrail(List.unmodifiable(_trail));
  }

  @override
  void onPointerMove(Offset worldPos, CanvasToolContext context) {
    _trail.add(LaserPoint(point: worldPos, time: DateTime.now()));
    // Keep last 40 points
    if (_trail.length > 40) {
      _trail.removeAt(0);
    }
    context.setLaserTrail(List.unmodifiable(_trail));
  }

  @override
  void onPointerUp(Offset worldPos, CanvasToolContext context) {
    _trail.clear();
    context.setLaserTrail(const []);
  }

  @override
  void onPointerCancel(CanvasToolContext context) {
    _trail.clear();
    context.setLaserTrail(const []);
  }
}
