import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Painter that renders an animated circular theme reveal:
/// - When activating Light Mode ([isDarkToLight] = true): The sunshine spreads
///   outwards from the button across the entire screen.
/// - When activating Dark Mode ([isDarkToLight] = false): All the light contracts
///   back from the screen edges into the button.
class CircularThemeRevealPainter extends CustomPainter {
  final ui.Image? oldImage;
  final Offset origin;
  final double progress;
  final bool isDarkToLight;
  final Color targetBgColor;

  CircularThemeRevealPainter({
    required this.oldImage,
    required this.origin,
    required this.progress,
    required this.isDarkToLight,
    required this.targetBgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final maxRadius = [
      (origin - Offset.zero).distance,
      (origin - Offset(size.width, 0)).distance,
      (origin - Offset(0, size.height)).distance,
      (origin - Offset(size.width, size.height)).distance,
    ].reduce(math.max) * 1.05;

    // Radius calculation based on direction:
    // Light mode: spreads outward from button (0 -> maxRadius)
    // Dark mode: contracts inward to button (maxRadius -> 0)
    final radius = isDarkToLight
        ? maxRadius * progress
        : maxRadius * (1.0 - progress);

    if (oldImage != null) {
      canvas.save();
      if (isDarkToLight) {
        // Spreading light: old dark image is OUTSIDE the expanding circle
        if (radius > 0.0) {
          final clipPath = Path()
            ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
            ..addOval(Rect.fromCircle(center: origin, radius: radius))
            ..fillType = PathFillType.evenOdd;
          canvas.clipPath(clipPath);
        }
      } else {
        // Contracting dark: old light image is INSIDE the shrinking circle
        if (radius > 0.0) {
          final clipPath = Path()
            ..addOval(Rect.fromCircle(center: origin, radius: radius));
          canvas.clipPath(clipPath);
        } else {
          // Circle has fully shrunk to zero at button
          canvas.restore();
          return;
        }
      }

      final srcRect = Rect.fromLTWH(
        0,
        0,
        oldImage!.width.toDouble(),
        oldImage!.height.toDouble(),
      );
      final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(
        oldImage!,
        srcRect,
        dstRect,
        Paint()..filterQuality = FilterQuality.medium,
      );
      canvas.restore();
    } else {
      // Fallback if snapshot image is unavailable:
      if (isDarkToLight) {
        // Expanding circle of light background color
        final fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = targetBgColor;
        canvas.drawCircle(origin, radius, fillPaint);
      } else {
        // Darkness filling screen outside the shrinking circle
        final fillPath = Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        if (radius > 0.0) {
          fillPath.addOval(Rect.fromCircle(center: origin, radius: radius));
        }
        fillPath.fillType = PathFillType.evenOdd;
        canvas.drawPath(fillPath, Paint()..color = targetBgColor);
      }
    }

    // Luminous leading-edge ripple ring
    if (progress > 0.0 && progress < 1.0 && radius > 0.0) {
      final ringColor = isDarkToLight
          ? const Color(0xFFFFD43B) // Warm sun gold
          : const Color(0xFF748FFC); // Starlight / moonlight indigo

      final double alpha;
      if (isDarkToLight) {
        // Fades as it spreads to screen corners
        alpha = ((1.0 - progress) * 0.9).clamp(0.0, 1.0);
      } else {
        // Stays bright as it pulls light back into button, then snaps shut at end
        alpha = progress < 0.85
            ? 0.85
            : (((1.0 - progress) / 0.15) * 0.85).clamp(0.0, 1.0);
      }

      // Soft aura glow
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..color = ringColor.withValues(alpha: alpha * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(origin, radius, glowPaint);

      // Sharp halo ring
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = ringColor.withValues(alpha: alpha);
      canvas.drawCircle(origin, radius, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CircularThemeRevealPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.oldImage != oldImage ||
        oldDelegate.origin != origin ||
        oldDelegate.isDarkToLight != isDarkToLight;
  }
}
