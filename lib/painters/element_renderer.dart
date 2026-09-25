import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/board_colors.dart';
import '../models/board_element.dart';
import '../models/shape_type.dart';
import '../models/stroke_fill_style.dart';
import '../services/image_service.dart';
import 'rough_sketch_painter.dart';

class ElementRenderer {
  static void draw(Canvas canvas, BoardElement el, BoardColors colors) {
    canvas.save();

    // 1. Rotation transform around element bounds center
    if (el.rotation != 0.0) {
      final c = el.bounds.center;
      canvas.translate(c.dx, c.dy);
      canvas.rotate(el.rotation);
      canvas.translate(-c.dx, -c.dy);
    }

    // 2. Element specific rendering
    _drawElementContent(canvas, el, colors);

    canvas.restore();
  }

  static void _drawElementContent(Canvas canvas, BoardElement el, BoardColors colors) {
    final strokeColor = colors.display(el.color).withValues(alpha: el.opacity);
    final isFillable = el.type == ShapeType.rectangle ||
        el.type == ShapeType.roundedRectangle ||
        el.type == ShapeType.ellipse ||
        el.type == ShapeType.diamond ||
        el.type == ShapeType.triangle ||
        el.type == ShapeType.star;

    // 1. Draw Fill (if applicable)
    if (isFillable && el.fillStyle != FillStyle.none) {
      final baseFill = el.fillColor != Colors.transparent ? el.fillColor : el.color;
      final displayFill = colors.display(baseFill);

      if (el.fillStyle == FillStyle.hatch || el.drawStyle == DrawStyle.sketch) {
        final path = _getShapePath(el);
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
        _drawShapePath(canvas, el, fillPaint);
      }
    }

    // 2. Draw Stroke
    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = el.type == ShapeType.highlighter
          ? math.max(el.strokeWidth * 3.5, 18.0)
          : el.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (el.type == ShapeType.highlighter) {
      strokePaint.color = el.color.withValues(alpha: 0.35 * el.opacity);
      strokePaint.strokeCap = StrokeCap.square;
    }

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

    switch (el.type) {
      case ShapeType.rectangle:
      case ShapeType.roundedRectangle:
      case ShapeType.ellipse:
      case ShapeType.diamond:
      case ShapeType.triangle:
      case ShapeType.star:
        _drawStrokedShape(canvas, el, strokePaint);
        break;

      case ShapeType.line:
        _drawStrokedPath(
          canvas,
          Path()..moveTo(el.start.dx, el.start.dy)..lineTo(el.end.dx, el.end.dy),
          strokePaint,
          el.strokeStyle,
        );
        break;

      case ShapeType.arrow:
      case ShapeType.doubleArrow:
        _drawArrow(canvas, el, strokePaint, strokeColor);
        break;

      case ShapeType.pen:
      case ShapeType.highlighter:
        _drawFreehand(canvas, el, strokePaint, strokeColor);
        break;

      case ShapeType.text:
        _drawText(canvas, el, strokeColor);
        break;

      case ShapeType.stickyNote:
        _drawStickyNote(canvas, el, colors);
        break;

      case ShapeType.image:
        _drawImage(canvas, el);
        break;

      case ShapeType.frame:
        _drawFrame(canvas, el, colors);
        break;
    }
  }

  static void _drawShapePath(Canvas canvas, BoardElement el, Paint paint) {
    final path = _getShapePath(el);
    canvas.drawPath(path, paint);
  }

  static Path _getShapePath(BoardElement el) {
    final path = Path();
    final rect = el.bounds;

    switch (el.type) {
      case ShapeType.rectangle:
        path.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)));
        break;
      case ShapeType.roundedRectangle:
        path.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)));
        break;
      case ShapeType.ellipse:
        path.addOval(rect);
        break;
      case ShapeType.diamond:
        path.moveTo(rect.center.dx, rect.top);
        path.lineTo(rect.right, rect.center.dy);
        path.lineTo(rect.center.dx, rect.bottom);
        path.lineTo(rect.left, rect.center.dy);
        path.close();
        break;
      case ShapeType.triangle:
        path.moveTo(rect.center.dx, rect.top);
        path.lineTo(rect.right, rect.bottom);
        path.lineTo(rect.left, rect.bottom);
        path.close();
        break;
      case ShapeType.star:
        _addStarPath(path, rect);
        break;
      default:
        path.addRect(rect);
    }
    return path;
  }

  static void _addStarPath(Path path, Rect rect) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final rOuter = math.min(rect.width, rect.height) / 2;
    final rInner = rOuter * 0.45;
    const points = 5;
    final step = math.pi / points;

    var angle = -math.pi / 2;
    path.moveTo(cx + rOuter * math.cos(angle), cy + rOuter * math.sin(angle));

    for (var i = 0; i < points; i++) {
      angle += step;
      path.lineTo(cx + rInner * math.cos(angle), cy + rInner * math.sin(angle));
      angle += step;
      path.lineTo(cx + rOuter * math.cos(angle), cy + rOuter * math.sin(angle));
    }
    path.close();
  }

  static void _drawStrokedShape(Canvas canvas, BoardElement el, Paint paint) {
    final path = _getShapePath(el);
    _drawStrokedPath(canvas, path, paint, el.strokeStyle);
  }

  static void _drawStrokedPath(Canvas canvas, Path path, Paint paint, StrokeStyle style) {
    if (style == StrokeStyle.solid) {
      canvas.drawPath(path, paint);
      return;
    }

    final dashWidth = style == StrokeStyle.dashed ? 10.0 : 3.0;
    final dashSpace = style == StrokeStyle.dashed ? 7.0 : 4.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final length = math.min(dashWidth, metric.length - distance);
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  static void _drawArrow(Canvas canvas, BoardElement el, Paint strokePaint, Color color) {
    _drawStrokedPath(
      canvas,
      Path()..moveTo(el.start.dx, el.start.dy)..lineTo(el.end.dx, el.end.dy),
      strokePaint,
      el.strokeStyle,
    );

    final angle = math.atan2(el.end.dy - el.start.dy, el.end.dx - el.start.dx);
    final headLen = math.max(el.strokeWidth * 4.5, 14.0);
    const spread = 0.48;

    final headPaint = Paint()
      ..color = color
      ..strokeWidth = el.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final s in [-spread, spread]) {
      final tip = el.end - Offset(math.cos(angle + s), math.sin(angle + s)) * headLen;
      canvas.drawLine(el.end, tip, headPaint);
    }

    if (el.type == ShapeType.doubleArrow) {
      final startAngle = angle + math.pi;
      for (final s in [-spread, spread]) {
        final tip = el.start - Offset(math.cos(startAngle + s), math.sin(startAngle + s)) * headLen;
        canvas.drawLine(el.start, tip, headPaint);
      }
    }
  }

  static void _drawFreehand(Canvas canvas, BoardElement el, Paint strokePaint, Color color) {
    final pts = el.points;
    if (pts.isEmpty) return;

    if (pts.length < 2) {
      canvas.drawCircle(
        pts.first,
        strokePaint.strokeWidth / 2,
        Paint()..color = strokePaint.color,
      );
      return;
    }

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final mid = (pts[i - 1] + pts[i]) / 2;
      path.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);

    _drawStrokedPath(canvas, path, strokePaint, el.strokeStyle);
  }

  static void _drawText(Canvas canvas, BoardElement el, Color color) {
    final content = el.text.isEmpty ? 'Type text...' : el.text;
    final textPainter = TextPainter(
      text: TextSpan(
        text: content,
        style: GoogleFonts.caveat(
          color: el.text.isEmpty ? color.withValues(alpha: 0.4) : color,
          fontSize: el.fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, el.start + const Offset(4, 4));
  }

  static void _drawStickyNote(Canvas canvas, BoardElement el, BoardColors colors) {
    final rect = el.bounds;
    final noteColor = el.fillColor != Colors.transparent
        ? el.fillColor
        : BoardColors.stickyNoteColors[0];

    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x28000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(2, 4)), const Radius.circular(8)),
      shadowPaint,
    );

    // Note card body
    final cardPaint = Paint()
      ..color = noteColor.withValues(alpha: el.opacity)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      cardPaint,
    );

    // Subtle border
    final borderPaint = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      borderPaint,
    );

    // Sticky note text
    if (el.text.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: el.text,
          style: GoogleFonts.caveat(
            color: const Color(0xFF212529),
            fontSize: el.fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 12,
        ellipsis: '...',
      )..layout(maxWidth: math.max(rect.width - 20, 20));

      textPainter.paint(canvas, rect.topLeft + const Offset(10, 10));
    }
  }

  static void _drawImage(Canvas canvas, BoardElement el) {
    final rect = el.bounds;
    if (el.imageBase64 != null && el.imageBase64!.isNotEmpty) {
      final img = ImageService.getImage(el.imageBase64!);
      if (img != null) {
        final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
        canvas.drawImageRect(img, src, rect, Paint());
        return;
      }
    }

    // Fallback placeholder while loading
    final placeholderPaint = Paint()
      ..color = const Color(0xFFE9ECEF)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), placeholderPaint);
    final border = Paint()
      ..color = const Color(0xFFCED4DA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), border);
  }

  static void _drawFrame(Canvas canvas, BoardElement el, BoardColors colors) {
    final rect = el.bounds;

    // Subtle slide background
    final bgPaint = Paint()
      ..color = colors.background.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, bgPaint);

    // Frame Border
    final borderPaint = Paint()
      ..color = colors.selection.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(rect, borderPaint);

    // Slide header badge
    final title = el.frameTitle ?? 'Slide ${el.frameIndex ?? 1}';
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: colors.selection,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = Rect.fromLTWH(
      rect.left,
      rect.top - 24,
      textPainter.width + 16,
      22,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)),
      Paint()..color = colors.selection.withValues(alpha: 0.15),
    );
    textPainter.paint(canvas, Offset(badgeRect.left + 8, badgeRect.top + 3));
  }
}
