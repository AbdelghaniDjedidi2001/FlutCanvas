import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'board_element.dart';

enum SnapGuideType { vertical, horizontal }

class SnapGuide {
  const SnapGuide({
    required this.type,
    required this.position,
    required this.minCross,
    required this.maxCross,
  });

  final SnapGuideType type;
  /// The world coordinate of the alignment line (X for vertical, Y for horizontal)
  final double position;
  /// The starting coordinate along the perpendicular axis
  final double minCross;
  /// The ending coordinate along the perpendicular axis
  final double maxCross;
}

class SnapResult {
  const SnapResult({
    required this.snappedDisplacement,
    required this.guides,
  });

  final Offset snappedDisplacement;
  final List<SnapGuide> guides;
}

class SnapService {
  /// Calculates magnetic snapping for [initialBounds] displaced by [rawDisplacement].
  /// [otherElements] are candidate shapes to snap against.
  static SnapResult calculateSnap({
    required Rect initialBounds,
    required Offset rawDisplacement,
    required List<BoardElement> otherElements,
    required double zoom,
    double snapThresholdPx = 6.0,
  }) {
    if (otherElements.isEmpty) {
      return SnapResult(snappedDisplacement: rawDisplacement, guides: const []);
    }

    final thresholdWorld = snapThresholdPx / math.max(0.1, zoom);
    final targetBounds = initialBounds.shift(rawDisplacement);

    final targetXPoints = [
      targetBounds.left,
      targetBounds.center.dx,
      targetBounds.right,
    ];

    final targetYPoints = [
      targetBounds.top,
      targetBounds.center.dy,
      targetBounds.bottom,
    ];

    double? bestSnapDx;
    double minDiffX = thresholdWorld;
    SnapGuide? bestGuideX;

    double? bestSnapDy;
    double minDiffY = thresholdWorld;
    SnapGuide? bestGuideY;

    for (final other in otherElements) {
      final ob = other.bounds;
      if (ob.isEmpty) continue;

      final otherXPoints = [ob.left, ob.center.dx, ob.right];
      final otherYPoints = [ob.top, ob.center.dy, ob.bottom];

      // Check X alignment (vertical guide lines)
      for (final tx in targetXPoints) {
        for (final ox in otherXPoints) {
          final diff = (tx - ox).abs();
          if (diff < minDiffX) {
            minDiffX = diff;
            bestSnapDx = ox - tx;
            final minY = math.min(targetBounds.top, ob.top) - 12.0 / zoom;
            final maxY = math.max(targetBounds.bottom, ob.bottom) + 12.0 / zoom;
            bestGuideX = SnapGuide(
              type: SnapGuideType.vertical,
              position: ox,
              minCross: minY,
              maxCross: maxY,
            );
          }
        }
      }

      // Check Y alignment (horizontal guide lines)
      for (final ty in targetYPoints) {
        for (final oy in otherYPoints) {
          final diff = (ty - oy).abs();
          if (diff < minDiffY) {
            minDiffY = diff;
            bestSnapDy = oy - ty;
            final minX = math.min(targetBounds.left, ob.left) - 12.0 / zoom;
            final maxX = math.max(targetBounds.right, ob.right) + 12.0 / zoom;
            bestGuideY = SnapGuide(
              type: SnapGuideType.horizontal,
              position: oy,
              minCross: minX,
              maxCross: maxX,
            );
          }
        }
      }
    }

    final finalDx = rawDisplacement.dx + (bestSnapDx ?? 0.0);
    final finalDy = rawDisplacement.dy + (bestSnapDy ?? 0.0);

    final guides = <SnapGuide>[];
    if (bestGuideX != null) guides.add(bestGuideX);
    if (bestGuideY != null) guides.add(bestGuideY);

    return SnapResult(
      snappedDisplacement: Offset(finalDx, finalDy),
      guides: guides,
    );
  }
}
