import 'package:flutter/material.dart';
import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connection_binding.dart';

class ConnectionAnchorPainter {
  static void drawAnchors(
    Canvas canvas,
    BoardElement element,
    Offset? activeSnappedPoint,
    double zoom,
    BoardColors colors,
  ) {
    final dotRadius = 4.5 / zoom;
    final activeRadius = 6.5 / zoom;

    for (final anchor in [
      AnchorPoint.top,
      AnchorPoint.right,
      AnchorPoint.bottom,
      AnchorPoint.left
    ]) {
      final pos = ConnectionBinding.getAnchorPosition(element, anchor);
      final isHovered = activeSnappedPoint != null &&
          (pos - activeSnappedPoint).distance < 8.0 / zoom;

      final fillPaint = Paint()
        ..color = isHovered ? const Color(0xFF2F9E44) : Colors.white
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = isHovered ? Colors.white : colors.selection
        ..strokeWidth = 1.5 / zoom
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(pos, isHovered ? activeRadius : dotRadius, fillPaint);
      canvas.drawCircle(pos, isHovered ? activeRadius : dotRadius, borderPaint);
    }
  }
}
