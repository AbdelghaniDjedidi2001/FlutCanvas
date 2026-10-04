import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutcanvas/core/constants/board_colors.dart';

class GridPainter {
  static void draw(Canvas canvas, Size size, Offset pan, double zoom, BoardColors colors) {
    if (zoom < 0.25) return; // avoid dense dot overdraw when heavily zoomed out

    const spacing = 24.0;
    final tl = (Offset.zero - pan) / zoom;
    final br = (Offset(size.width, size.height) - pan) / zoom;
    final pts = <Offset>[];

    final startX = (tl.dx / spacing).floor() * spacing;
    final startY = (tl.dy / spacing).floor() * spacing;

    for (var x = startX; x <= br.dx; x += spacing) {
      for (var y = startY; y <= br.dy; y += spacing) {
        pts.add(Offset(x, y));
      }
    }

    final dotPaint = Paint()
      ..color = colors.grid
      ..strokeWidth = 2.0 / zoom
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(ui.PointMode.points, pts, dotPaint);
  }
}
