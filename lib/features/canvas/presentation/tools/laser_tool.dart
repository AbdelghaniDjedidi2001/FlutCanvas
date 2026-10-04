import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/laser_painter.dart';
import 'canvas_tool.dart';
import 'canvas_tool_context.dart';

class LaserTool implements CanvasTool {
  final List<LaserPoint> _trail = [];
  Timer? _decayTimer;

  @override
  Tool get toolType => Tool.laser;

  @override
  MouseCursor get cursor => SystemMouseCursors.precise;

  void _ensureDecayTicker(CanvasToolContext context) {
    if (_decayTimer != null) return;
    _decayTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (_trail.isEmpty) {
        timer.cancel();
        _decayTimer = null;
        return;
      }
      final now = DateTime.now();
      _trail.removeWhere((p) => now.difference(p.time).inMilliseconds >= 1500);
      context.setLaserTrail(List.unmodifiable(_trail));
      if (_trail.isEmpty) {
        timer.cancel();
        _decayTimer = null;
      }
    });
  }

  @override
  void onPointerDown(Offset worldPos, CanvasToolContext context) {
    _trail.clear();
    _trail.add(LaserPoint(point: worldPos, time: DateTime.now()));
    context.setLaserTrail(List.unmodifiable(_trail));
    _ensureDecayTicker(context);
  }

  @override
  void onPointerMove(Offset worldPos, CanvasToolContext context) {
    _trail.add(LaserPoint(point: worldPos, time: DateTime.now()));
    if (_trail.length > 50) {
      _trail.removeAt(0);
    }
    context.setLaserTrail(List.unmodifiable(_trail));
    _ensureDecayTicker(context);
  }

  @override
  void onPointerUp(Offset worldPos, CanvasToolContext context) {
    // The trail naturally decays over 1.5s via ticker
    _ensureDecayTicker(context);
  }

  @override
  void onPointerCancel(CanvasToolContext context) {
    _trail.clear();
    _decayTimer?.cancel();
    _decayTimer = null;
    context.setLaserTrail(const []);
  }

  @override
  void onPointerHover(Offset worldPos, CanvasToolContext context) {}
}
