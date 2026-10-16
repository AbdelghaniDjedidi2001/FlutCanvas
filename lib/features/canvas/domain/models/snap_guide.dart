import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'board_element.dart';
import 'transform_handle.dart';

enum SnapGuideType { vertical, horizontal }

class SnapGuide {
  const SnapGuide({
    required this.type,
    required this.position,
    required this.minCross,
    required this.maxCross,
  });

  final SnapGuideType type;
  final double position;
  final double minCross;
  final double maxCross;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SnapGuide &&
          type == other.type &&
          position == other.position &&
          minCross == other.minCross &&
          maxCross == other.maxCross;

  @override
  int get hashCode => Object.hash(type, position, minCross, maxCross);
}

class SnapResult {
  const SnapResult({
    required this.snappedDisplacement,
    required this.guides,
  });

  final Offset snappedDisplacement;
  final List<SnapGuide> guides;
}

class SnapResizeResult {
  const SnapResizeResult({
    required this.snappedBounds,
    required this.guides,
  });

  final Rect snappedBounds;
  final List<SnapGuide> guides;
}

class SnapService {
  /// Calculates magnetic snap displacement and guidelines for moving elements.
  static SnapResult calculateSnap({
    required Rect initialBounds,
    required Offset rawDisplacement,
    required List<BoardElement> otherElements,
    required double zoom,
    double snapThresholdPx = 10.0,
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

    final validOthers = otherElements.where((e) {
      if (!e.isVisible) return false;
      final b = e.bounds;
      return !(b.width == 0 && b.height == 0) && b.width >= 0 && b.height >= 0;
    }).toList();

    if (validOthers.isEmpty) {
      return SnapResult(snappedDisplacement: rawDisplacement, guides: const []);
    }

    double? bestSnapDx;
    double minScoreX = thresholdWorld;

    double? bestSnapDy;
    double minScoreY = thresholdWorld;

    for (final other in validOthers) {
      final ob = other.bounds;
      final otherXPoints = [ob.left, ob.center.dx, ob.right];
      final otherYPoints = [ob.top, ob.center.dy, ob.bottom];
      final crossDistY = (targetBounds.center.dy - ob.center.dy).abs();
      final crossDistX = (targetBounds.center.dx - ob.center.dx).abs();

      for (final tx in targetXPoints) {
        for (final ox in otherXPoints) {
          final diff = (tx - ox).abs();
          if (diff < thresholdWorld) {
            // Proximity scoring: prefer closest diff, penalize distant off-screen objects
            final score = diff + crossDistY * 0.0005;
            if (score < minScoreX) {
              minScoreX = score;
              bestSnapDx = ox - tx;
            }
          }
        }
      }

      for (final ty in targetYPoints) {
        for (final oy in otherYPoints) {
          final diff = (ty - oy).abs();
          if (diff < thresholdWorld) {
            final score = diff + crossDistX * 0.0005;
            if (score < minScoreY) {
              minScoreY = score;
              bestSnapDy = oy - ty;
            }
          }
        }
      }
    }

    final finalDx = rawDisplacement.dx + (bestSnapDx ?? 0.0);
    final finalDy = rawDisplacement.dy + (bestSnapDy ?? 0.0);
    final snappedTargetBounds = initialBounds.shift(Offset(finalDx, finalDy));

    final guides = <SnapGuide>[];

    // Generate vertical guide(s) if snapped on X
    if (bestSnapDx != null) {
      final snappedXPoints = [
        snappedTargetBounds.left,
        snappedTargetBounds.center.dx,
        snappedTargetBounds.right,
      ];

      final matchedPositions = <double>{};

      for (final sx in snappedXPoints) {
        double? matchedOx;
        double minY = snappedTargetBounds.top;
        double maxY = snappedTargetBounds.bottom;
        bool found = false;

        for (final other in validOthers) {
          final ob = other.bounds;
          final otherXPoints = [ob.left, ob.center.dx, ob.right];
          for (final ox in otherXPoints) {
            if ((sx - ox).abs() < 0.5) {
              matchedOx = ox;
              found = true;
              minY = math.min(minY, ob.top);
              maxY = math.max(maxY, ob.bottom);
            }
          }
        }

        if (found && matchedOx != null && !matchedPositions.contains(matchedOx)) {
          matchedPositions.add(matchedOx);
          guides.add(SnapGuide(
            type: SnapGuideType.vertical,
            position: matchedOx,
            minCross: minY - 12.0 / zoom,
            maxCross: maxY + 12.0 / zoom,
          ));
        }
      }
    }

    // Generate horizontal guide(s) if snapped on Y
    if (bestSnapDy != null) {
      final snappedYPoints = [
        snappedTargetBounds.top,
        snappedTargetBounds.center.dy,
        snappedTargetBounds.bottom,
      ];

      final matchedPositions = <double>{};

      for (final sy in snappedYPoints) {
        double? matchedOy;
        double minX = snappedTargetBounds.left;
        double maxX = snappedTargetBounds.right;
        bool found = false;

        for (final other in validOthers) {
          final ob = other.bounds;
          final otherYPoints = [ob.top, ob.center.dy, ob.bottom];
          for (final oy in otherYPoints) {
            if ((sy - oy).abs() < 0.5) {
              matchedOy = oy;
              found = true;
              minX = math.min(minX, ob.left);
              maxX = math.max(maxX, ob.right);
            }
          }
        }

        if (found && matchedOy != null && !matchedPositions.contains(matchedOy)) {
          matchedPositions.add(matchedOy);
          guides.add(SnapGuide(
            type: SnapGuideType.horizontal,
            position: matchedOy,
            minCross: minX - 12.0 / zoom,
            maxCross: maxX + 12.0 / zoom,
          ));
        }
      }
    }

    return SnapResult(
      snappedDisplacement: Offset(finalDx, finalDy),
      guides: guides,
    );
  }

  /// Calculates magnetic snap bounds and guidelines for handle resizing.
  static SnapResizeResult calculateResizeSnap({
    required Rect newBounds,
    required HandleType handle,
    required List<BoardElement> otherElements,
    required double zoom,
    double snapThresholdPx = 10.0,
  }) {
    if (otherElements.isEmpty || handle == HandleType.rotation) {
      return SnapResizeResult(snappedBounds: newBounds, guides: const []);
    }

    final thresholdWorld = snapThresholdPx / math.max(0.1, zoom);

    final bool movesLeft = handle == HandleType.topLeft ||
        handle == HandleType.centerLeft ||
        handle == HandleType.bottomLeft;
    final bool movesRight = handle == HandleType.topRight ||
        handle == HandleType.centerRight ||
        handle == HandleType.bottomRight;
    final bool movesTop = handle == HandleType.topLeft ||
        handle == HandleType.topCenter ||
        handle == HandleType.topRight;
    final bool movesBottom = handle == HandleType.bottomLeft ||
        handle == HandleType.bottomCenter ||
        handle == HandleType.bottomRight;

    double left = newBounds.left;
    double top = newBounds.top;
    double right = newBounds.right;
    double bottom = newBounds.bottom;

    final guides = <SnapGuide>[];

    final validOthers = otherElements.where((e) {
      if (!e.isVisible) return false;
      final b = e.bounds;
      return !(b.width == 0 && b.height == 0) && b.width >= 0 && b.height >= 0;
    }).toList();

    if (validOthers.isEmpty) {
      return SnapResizeResult(snappedBounds: newBounds, guides: const []);
    }

    // Snap Horizontal (X axis)
    if (movesLeft || movesRight) {
      final targetX = movesLeft ? left : right;
      double minScoreX = thresholdWorld;
      double? bestSnapX;

      for (final other in validOthers) {
        final ob = other.bounds;
        final otherXPoints = [ob.left, ob.center.dx, ob.right];
        final crossDist = (newBounds.center.dy - ob.center.dy).abs();

        for (final ox in otherXPoints) {
          final diff = (targetX - ox).abs();
          if (diff < thresholdWorld) {
            final score = diff + crossDist * 0.0005;
            if (score < minScoreX) {
              minScoreX = score;
              bestSnapX = ox;
            }
          }
        }
      }

      if (bestSnapX != null) {
        if (movesLeft) {
          if (bestSnapX < right - 5.0) {
            left = bestSnapX;
          }
        } else {
          if (bestSnapX > left + 5.0) {
            right = bestSnapX;
          }
        }

        double minY = top;
        double maxY = bottom;
        for (final other in validOthers) {
          final ob = other.bounds;
          final otherXPoints = [ob.left, ob.center.dx, ob.right];
          if (otherXPoints.any((ox) => (ox - bestSnapX!).abs() < 0.5)) {
            minY = math.min(minY, ob.top);
            maxY = math.max(maxY, ob.bottom);
          }
        }

        guides.add(SnapGuide(
          type: SnapGuideType.vertical,
          position: bestSnapX,
          minCross: minY - 12.0 / zoom,
          maxCross: maxY + 12.0 / zoom,
        ));
      }
    }

    // Snap Vertical (Y axis)
    if (movesTop || movesBottom) {
      final targetY = movesTop ? top : bottom;
      double minScoreY = thresholdWorld;
      double? bestSnapY;

      for (final other in validOthers) {
        final ob = other.bounds;
        final otherYPoints = [ob.top, ob.center.dy, ob.bottom];
        final crossDist = (newBounds.center.dx - ob.center.dx).abs();

        for (final oy in otherYPoints) {
          final diff = (targetY - oy).abs();
          if (diff < thresholdWorld) {
            final score = diff + crossDist * 0.0005;
            if (score < minScoreY) {
              minScoreY = score;
              bestSnapY = oy;
            }
          }
        }
      }

      if (bestSnapY != null) {
        if (movesTop) {
          if (bestSnapY < bottom - 5.0) {
            top = bestSnapY;
          }
        } else {
          if (bestSnapY > top + 5.0) {
            bottom = bestSnapY;
          }
        }

        double minX = left;
        double maxX = right;
        for (final other in validOthers) {
          final ob = other.bounds;
          final otherYPoints = [ob.top, ob.center.dy, ob.bottom];
          if (otherYPoints.any((oy) => (oy - bestSnapY!).abs() < 0.5)) {
            minX = math.min(minX, ob.left);
            maxX = math.max(maxX, ob.right);
          }
        }

        guides.add(SnapGuide(
          type: SnapGuideType.horizontal,
          position: bestSnapY,
          minCross: minX - 12.0 / zoom,
          maxCross: maxX + 12.0 / zoom,
        ));
      }
    }

    return SnapResizeResult(
      snappedBounds: Rect.fromLTRB(left, top, right, bottom),
      guides: guides,
    );
  }
}
