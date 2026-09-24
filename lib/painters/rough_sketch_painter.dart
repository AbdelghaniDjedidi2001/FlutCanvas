import 'dart:math' as math;
import 'package:flutter/material.dart';

class RoughSketchPainter {
  /// Deterministic pseudo-random jitter offset based on index and seed
  static double _jitter(int seed, int index, double maxDelta) {
    final v = math.sin(seed * 997.0 + index * 33.1) * 43758.5453;
    final frac = v - v.floor();
    return (frac * 2.0 - 1.0) * maxDelta;
  }

  /// Draws a sketchy hand-drawn double stroke between point A and point B
  static void drawSketchLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint, {
    int seed = 42,
    double roughness = 1.2,
  }) {
    final len = (b - a).distance;
    final steps = math.max((len / 18.0).ceil(), 2);
    final dx = (b.dx - a.dx) / steps;
    final dy = (b.dy - a.dy) / steps;

    // Pass 1
    final path1 = Path()..moveTo(a.dx, a.dy);
    for (var i = 1; i <= steps; i++) {
      final curX = a.dx + dx * i + (i == steps ? 0 : _jitter(seed, i, roughness));
      final curY = a.dy + dy * i + (i == steps ? 0 : _jitter(seed + 1, i, roughness));
      path1.lineTo(curX, curY);
    }
    canvas.drawPath(path1, paint);

    // Pass 2 (subtle double-line overlap characteristic of Excalidraw)
    final path2 = Path()..moveTo(a.dx + _jitter(seed + 3, 0, roughness * 0.7), a.dy + _jitter(seed + 4, 0, roughness * 0.7));
    for (var i = 1; i <= steps; i++) {
      final curX = a.dx + dx * i + (i == steps ? 0 : _jitter(seed + 5, i, roughness * 0.8));
      final curY = a.dy + dy * i + (i == steps ? 0 : _jitter(seed + 6, i, roughness * 0.8));
      path2.lineTo(curX, curY);
    }
    canvas.drawPath(path2, paint);
  }

  /// Draws a hand-drawn rectangle with slightly bowed corners
  static void drawSketchRect(
    Canvas canvas,
    Rect rect,
    Paint strokePaint, {
    int seed = 42,
    double roughness = 1.4,
  }) {
    drawSketchLine(canvas, rect.topLeft, rect.topRight, strokePaint, seed: seed, roughness: roughness);
    drawSketchLine(canvas, rect.topRight, rect.bottomRight, strokePaint, seed: seed + 10, roughness: roughness);
    drawSketchLine(canvas, rect.bottomRight, rect.bottomLeft, strokePaint, seed: seed + 20, roughness: roughness);
    drawSketchLine(canvas, rect.bottomLeft, rect.topLeft, strokePaint, seed: seed + 30, roughness: roughness);
  }

  /// Draws hand-drawn hachure (angled crosshatch) fill lines inside a shape
  static void drawHachureFill(
    Canvas canvas,
    Path clipPath,
    Rect bounds,
    Color fillColor, {
    double angle = math.pi / 4, // 45 degrees
    double gap = 9.0,
    double strokeWidth = 1.4,
    int seed = 100,
  }) {
    canvas.save();
    canvas.clipPath(clipPath);

    final hatchPaint = Paint()
      ..color = fillColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final diag = math.sqrt(bounds.width * bounds.width + bounds.height * bounds.height);
    final count = (diag / gap).ceil();
    final center = bounds.center;

    for (var i = -count; i <= count; i++) {
      final offset = i * gap;
      final start = Offset(
        center.dx + offset * math.cos(angle) - diag * math.sin(angle),
        center.dy + offset * math.sin(angle) + diag * math.cos(angle),
      );
      final end = Offset(
        center.dx + offset * math.cos(angle) + diag * math.sin(angle),
        center.dy + offset * math.sin(angle) - diag * math.cos(angle),
      );

      drawSketchLine(canvas, start, end, hatchPaint, seed: seed + i, roughness: 0.8);
    }

    canvas.restore();
  }
}
