import 'dart:math' as math;
import 'package:flutter/material.dart';

extension RectGeometryX on Rect {
  /// Expands this rect to include [other].
  Rect expandTo(Rect other) {
    return Rect.fromLTRB(
      math.min(left, other.left),
      math.min(top, other.top),
      math.max(right, other.right),
      math.max(bottom, other.bottom),
    );
  }

  /// Clamps this rect inside [boundary].
  Rect clamped(Rect boundary) {
    final w = width;
    final h = height;
    final clLeft = left.clamp(boundary.left, boundary.right - w);
    final clTop = top.clamp(boundary.top, boundary.bottom - h);
    return Rect.fromLTWH(clLeft, clTop, w, h);
  }
}
