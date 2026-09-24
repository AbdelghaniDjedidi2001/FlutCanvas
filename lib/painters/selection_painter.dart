import 'package:flutter/material.dart';
import '../models/board_colors.dart';
import '../models/board_element.dart';
import '../models/transform_handle.dart';

class SelectionPainter {
  /// Draws marquee selection box while dragging on canvas
  static void drawMarquee(Canvas canvas, Rect marqueeRect, double zoom, BoardColors colors) {
    final fillPaint = Paint()
      ..color = colors.selection.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRect(marqueeRect, fillPaint);

    final borderPaint = Paint()
      ..color = colors.selection.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / zoom;
    canvas.drawRect(marqueeRect, borderPaint);
  }

  /// Draws bounding box and 9 transform & rotation handles for selected elements
  static void drawSelection(
    Canvas canvas,
    List<BoardElement> selectedElements,
    double zoom,
    BoardColors colors,
  ) {
    if (selectedElements.isEmpty) return;

    // Calculate combined bounding box of all selected elements
    Rect combined = selectedElements.first.bounds;
    for (var i = 1; i < selectedElements.length; i++) {
      combined = combined.expandToInclude(selectedElements[i].bounds);
    }

    final box = combined.inflate(8.0 / zoom);

    // 1. Draw outer selection rectangle
    final boxPaint = Paint()
      ..color = colors.selection
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / zoom;
    canvas.drawRect(box, boxPaint);

    // 2. Draw Rotation Handle Stem line
    final rotHandlePos = Offset(box.center.dx, box.top - 20.0 / zoom);
    final stemPaint = Paint()
      ..color = colors.selection
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 / zoom;
    canvas.drawLine(Offset(box.center.dx, box.top), rotHandlePos, stemPaint);

    // 3. Draw 8 corner/edge resize handles & 1 circular rotation handle
    final handleFill = Paint()..color = Colors.white;
    final handleStroke = Paint()
      ..color = colors.selection
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 / zoom;

    final handleSize = 7.0 / zoom;

    for (final handle in TransformHandle.getHandlesForRect(box, zoom)) {
      if (handle.type == HandleType.rotation) {
        canvas.drawCircle(handle.position, 4.5 / zoom, handleFill);
        canvas.drawCircle(handle.position, 4.5 / zoom, handleStroke);
      } else {
        final handleRect = Rect.fromCenter(
          center: handle.position,
          width: handleSize,
          height: handleSize,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(handleRect, Radius.circular(2.0 / zoom)),
          handleFill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(handleRect, Radius.circular(2.0 / zoom)),
          handleStroke,
        );
      }
    }

    // 4. Draw subtle dimension indicator below bounding box
    final dimText = '${combined.width.round()} × ${combined.height.round()}';
    final textPainter = TextPainter(
      text: TextSpan(
        text: dimText,
        style: TextStyle(
          color: colors.selection,
          fontSize: 9.5 / zoom,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeOffset = Offset(
      box.center.dx - textPainter.width / 2,
      box.bottom + 6.0 / zoom,
    );
    final badgeRect = Rect.fromCenter(
      center: Offset(box.center.dx, box.bottom + 6.0 / zoom + textPainter.height / 2),
      width: textPainter.width + 10.0 / zoom,
      height: textPainter.height + 4.0 / zoom,
    );
    final badgeBgPaint = Paint()
      ..color = colors.background.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    final badgeBorderPaint = Paint()
      ..color = colors.selection.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / zoom;
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, Radius.circular(4.0 / zoom)),
      badgeBgPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, Radius.circular(4.0 / zoom)),
      badgeBorderPaint,
    );
    textPainter.paint(canvas, badgeOffset);
  }
}
