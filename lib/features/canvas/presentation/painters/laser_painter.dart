import 'package:flutter/material.dart';

class LaserPoint {
  const LaserPoint({required this.point, required this.time});
  final Offset point;
  final DateTime time;
}

class LaserPainter {
  static void draw(Canvas canvas, List<LaserPoint> trail, Color laserColor) {
    if (trail.isEmpty) return;
    final now = DateTime.now();

    for (var i = 1; i < trail.length; i++) {
      final p1 = trail[i - 1];
      final p2 = trail[i];
      final ageMs = now.difference(p2.time).inMilliseconds;
      if (ageMs > 1500) continue;

      final opacity = (1.0 - (ageMs / 1500)).clamp(0.0, 1.0);
      final width = (6.0 * opacity).clamp(1.5, 6.0);

      final paint = Paint()
        ..color = laserColor.withValues(alpha: opacity * 0.9)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawLine(p1.point, p2.point, paint);
    }
  }
}
