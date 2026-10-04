import 'dart:math' as math;
import 'package:flutter/material.dart';

extension OffsetGeometryX on Offset {
  /// Distance between this offset and [other].
  double distanceTo(Offset other) {
    final dx = other.dx - this.dx;
    final dy = other.dy - this.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Rotates this offset around [center] by [angleInRadians].
  Offset rotateAround(Offset center, double angleInRadians) {
    if (angleInRadians == 0.0) return this;
    final cosA = math.cos(angleInRadians);
    final sinA = math.sin(angleInRadians);
    final dx = this.dx - center.dx;
    final dy = this.dy - center.dy;
    return Offset(
      center.dx + dx * cosA - dy * sinA,
      center.dy + dx * sinA + dy * cosA,
    );
  }
}
