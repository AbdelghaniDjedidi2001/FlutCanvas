import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/board_colors.dart';
import '../../../../painters/rough_sketch_painter.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'shape_renderer.dart';

class BasicShapeRenderer implements ShapeRenderer {
  @override
  bool canRender(ShapeType type) =>
      type == ShapeType.rectangle ||
      type == ShapeType.roundedRectangle ||
      type == ShapeType.ellipse ||
      type == ShapeType.diamond ||
      type == ShapeType.triangle ||
      type == ShapeType.star ||
      type == ShapeType.frame;

  @override
  void render(Canvas canvas, BoardElement el, BoardColors colors) {
    final strokeColor = colors.display(el.color).withValues(alpha: el.opacity);

    // 1. Draw Fill
    if (el.fillStyle != FillStyle.none &&
        el.fillColor != Colors.transparent &&
        el.type != ShapeType.frame) {
      final displayFill = colors.display(el.fillColor);

      if (el.fillStyle == FillStyle.hatch || el.drawStyle == DrawStyle.sketch) {
        final path = getShapePath(el);
        RoughSketchPainter.drawHachureFill(
          canvas,
          path,
          el.bounds,
          displayFill.withValues(alpha: 0.6 * el.opacity),
          seed: el.id.hashCode,
        );
      } else {
        final fillOpacity = el.fillStyle == FillStyle.semi ? 0.25 : 1.0;
        final fillPaint = Paint()
          ..color = displayFill.withValues(alpha: fillOpacity * el.opacity)
          ..style = PaintingStyle.fill;
        final path = getShapePath(el);
        canvas.drawPath(path, fillPaint);
      }
    }

    // 2. Draw Stroke
    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = el.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (el.drawStyle == DrawStyle.sketch &&
        (el.type == ShapeType.rectangle || el.type == ShapeType.diamond)) {
      RoughSketchPainter.drawSketchRect(
        canvas,
        el.bounds,
        strokePaint,
        seed: el.id.hashCode,
        roughness: 1.3,
      );
      return;
    }

    final path = getShapePath(el);
    canvas.drawPath(path, strokePaint);
  }

  Path getShapePath(BoardElement el) {
    final b = el.bounds;
    final path = Path();

    switch (el.type) {
      case ShapeType.rectangle:
      case ShapeType.frame:
        path.addRect(b);
        break;
      case ShapeType.roundedRectangle:
        path.addRRect(RRect.fromRectAndRadius(b, const Radius.circular(12)));
        break;
      case ShapeType.ellipse:
        path.addOval(b);
        break;
      case ShapeType.diamond:
        path.moveTo(b.center.dx, b.top);
        path.lineTo(b.right, b.center.dy);
        path.lineTo(b.center.dx, b.bottom);
        path.lineTo(b.left, b.center.dy);
        path.close();
        break;
      case ShapeType.triangle:
        path.moveTo(b.center.dx, b.top);
        path.lineTo(b.right, b.bottom);
        path.lineTo(b.left, b.bottom);
        path.close();
        break;
      case ShapeType.star:
        final cx = b.center.dx;
        final cy = b.center.dy;
        final outerR = math.min(b.width, b.height) / 2;
        final innerR = outerR * 0.4;
        for (var i = 0; i < 10; i++) {
          final r = i.isEven ? outerR : innerR;
          final angle = -math.pi / 2 + i * (math.pi / 5);
          final x = cx + r * math.cos(angle);
          final y = cy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        break;
      default:
        path.addRect(b);
    }
    return path;
  }
}
