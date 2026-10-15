import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutcanvas/core/constants/board_colors.dart';

class GridPainter {
  /// Draws an infinite dot grid in WORLD SPACE.
  ///
  /// The [canvas] is assumed to be transformed into world space via:
  ///   canvas.translate(pan.dx, pan.dy);
  ///   canvas.scale(zoom);
  ///
  /// [size] is the widget's viewport size in screen pixels.
  /// [pan] and [zoom] are used to compute the visible world rectangle.
  /// Dots are drawn at exact 24-world-unit multiples.
  static void draw(
    Canvas canvas,
    Size size,
    Offset pan,
    double zoom,
    BoardColors colors,
  ) {
    if (zoom < 0.25) return; // avoid dense dot overdraw when heavily zoomed out
    if (size.width <= 0 ||
        size.height <= 0 ||
        size.width.isInfinite ||
        size.height.isInfinite) {
      return;
    }

    const spacing = 24.0;

    // Viewport bounds in world coordinates
    final worldLeft = -pan.dx / zoom;
    final worldTop = -pan.dy / zoom;
    final worldRight = (size.width - pan.dx) / zoom;
    final worldBottom = (size.height - pan.dy) / zoom;

    // Margin of 1 grid unit on all sides so panning never reveals blank edges
    final startX = (worldLeft / spacing).floor() * spacing - spacing;
    final startY = (worldTop / spacing).floor() * spacing - spacing;
    final endX = (worldRight / spacing).ceil() * spacing + spacing;
    final endY = (worldBottom / spacing).ceil() * spacing + spacing;

    final pts = <Offset>[];
    for (var x = startX; x <= endX; x += spacing) {
      for (var y = startY; y <= endY; y += spacing) {
        pts.add(Offset(x, y));
      }
    }

    final dotPaint = Paint()
      ..color = colors.grid
      ..strokeWidth = 2.0 / zoom // Constant 2.0px diameter on screen at any zoom
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(ui.PointMode.points, pts, dotPaint);
  }
}
