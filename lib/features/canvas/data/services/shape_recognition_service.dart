import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';

class RecognizedShapeResult {
  final ShapeType shapeType;
  final Offset start;
  final Offset end;
  final double confidence;
  final String label;

  const RecognizedShapeResult({
    required this.shapeType,
    required this.start,
    required this.end,
    required this.confidence,
    required this.label,
  });
}

class ShapeRecognitionService {
  /// Analyzes a set of freehand points and recognizes geometric shapes:
  /// Circle, Ellipse, Rectangle, Rounded Rectangle, Triangle, Diamond, Star, Line, Arrow.
  static RecognizedShapeResult? recognizeShape(List<Offset> rawPoints) {
    if (rawPoints.length < 2) return null;

    // 1. Clean & resample points with uniform arc length
    final points = _preprocessPoints(rawPoints);
    if (points.length < 2) return null;

    final bounds = _computeBounds(points);
    final width = bounds.width;
    final height = bounds.height;
    final diagonal = math.sqrt(width * width + height * height);

    final totalLength = _computeTotalLength(points);
    if (totalLength <= 0) return null;

    // Minimum size threshold (avoid snapping tiny accidental dots)
    if (diagonal < 18 && totalLength < 18) return null;

    final startEndDistance = (points.first - points.last).distance;
    final isClosed = (startEndDistance / diagonal < 0.38) || (startEndDistance / totalLength < 0.25);

    // ── 1. Open Stroke Classifiers (Straight Line & Arrow) ────────────────
    // Open strokes must NOT fall through to closed shape classifiers.
    if (!isClosed) {
      return _classifyLineOrArrow(points, bounds, totalLength, startEndDistance);
    }

    // Closed shapes require a minimum 2D bounding area
    if (width < 14 || height < 14) return null;

    // ── 2. Feature Extraction for Closed Shapes ─────────────────────────
    final area = _computePolygonArea(points);
    final boxArea = width * height;
    final areaRatio = boxArea > 0 ? area / boxArea : 0.0;

    final center = bounds.center;
    final halfW = width / 2;
    final halfH = height / 2;
    final minHalf = math.min(halfW, halfH);

    // Compute radial distances normalized by half-extents
    var maxRadialDev = 0.0;
    var sumRadialDev = 0.0;
    final rList = <double>[];
    for (final p in points) {
      final dx = (p.dx - center.dx) / (halfW > 0 ? halfW : 1.0);
      final dy = (p.dy - center.dy) / (halfH > 0 ? halfH : 1.0);
      final r = math.sqrt(dx * dx + dy * dy);
      rList.add(r);
      final dev = (r - 1.0).abs();
      sumRadialDev += dev;
      if (dev > maxRadialDev) maxRadialDev = dev;
    }
    final avgRadialDev = sumRadialDev / points.length;
    final meanR = rList.reduce((a, b) => a + b) / rList.length;
    final stdRadialDev = math.sqrt(
      rList.map((r) => (r - meanR) * (r - meanR)).reduce((a, b) => a + b) / rList.length,
    );

    // Distances to 4 bounding box corners
    final corners = [bounds.topLeft, bounds.topRight, bounds.bottomRight, bounds.bottomLeft];
    final cornerDists = corners.map((c) {
      return points.map((p) => (p - c).distance).reduce(math.min) / (minHalf > 0 ? minHalf : 1.0);
    }).toList();
    final avgCornerDist = cornerDists.reduce((a, b) => a + b) / 4.0;
    final cornersNear = cornerDists.where((d) => d < 0.32).length;

    // Distances to 4 cardinal points (top, right, bottom, left center)
    final cardinals = [
      Offset(center.dx, bounds.top),
      Offset(bounds.right, center.dy),
      Offset(center.dx, bounds.bottom),
      Offset(bounds.left, center.dy),
    ];
    final cardinalDists = cardinals.map((c) {
      return points.map((p) => (p - c).distance).reduce(math.min) / (minHalf > 0 ? minHalf : 1.0);
    }).toList();
    final allCardinalsNear = cardinalDists.every((d) => d < 0.28);

    // Polygon simplification
    final simplified = _simplifyClosedPolygon(points, math.max(diagonal * 0.045, 6.0));
    final vertexCount = simplified.length <= 1 ? 0 : simplified.length - 1;

    // Edge distance for rectangle
    double totalEdgeDist = 0.0;
    for (final p in points) {
      final dLeft = (p.dx - bounds.left).abs();
      final dRight = (p.dx - bounds.right).abs();
      final dTop = (p.dy - bounds.top).abs();
      final dBottom = (p.dy - bounds.bottom).abs();
      totalEdgeDist += math.min(math.min(dLeft, dRight), math.min(dTop, dBottom));
    }
    final avgEdgeDist = totalEdgeDist / points.length;
    final edgeDistRatio = avgEdgeDist / math.max(width, height);

    // ── 3. Closed Shape Classifiers in Priority Order ────────────────────

    // A. Star
    final starResult = _classifyStar(points, simplified, bounds, areaRatio, vertexCount, center, width, height);
    if (starResult != null) return starResult;

    // B. Diamond (cardinal centers touched, corners empty, area ~ 0.5)
    final diamondResult = _classifyDiamond(bounds, areaRatio, allCardinalsNear, avgCornerDist);
    if (diamondResult != null) return diamondResult;

    // C. Triangle (3 prominent corners, area ~ 0.22 - 0.70)
    final triangleResult = _classifyTriangle(simplified, bounds, areaRatio, vertexCount, cardinalDists);
    if (triangleResult != null) return triangleResult;

    // D. Circle / Ellipse (strictly uniform radius from center, all 4 corners empty)
    final ellipseResult = _classifyCircleOrEllipse(
      bounds,
      center,
      width,
      height,
      areaRatio,
      avgRadialDev,
      maxRadialDev,
      stdRadialDev,
      avgCornerDist,
      cornersNear,
    );
    if (ellipseResult != null) return ellipseResult;

    // E. Rectangle / Rounded Rectangle (stroke hugs box edges, corners occupied)
    final rectResult = _classifyRectangle(
      points,
      bounds,
      areaRatio,
      edgeDistRatio,
      avgCornerDist,
      cornersNear,
    );
    if (rectResult != null) return rectResult;

    return null;
  }

  /// Converts a freehand BoardElement into a recognized vector BoardElement
  static BoardElement? morphToRecognizedShape({
    required BoardElement freehandElement,
    double minConfidence = 0.55,
  }) {
    if (freehandElement.points.length < 5) return null;

    final recognized = recognizeShape(freehandElement.points);
    if (recognized == null || recognized.confidence < minConfidence) return null;

    return freehandElement.copyWith(
      type: recognized.shapeType,
      start: recognized.start,
      end: recognized.end,
      points: const [], // Clean up freehand points for vector rendering
    );
  }

  // ── Classifiers ───────────────────────────────────────────────────

  static RecognizedShapeResult? _classifyLineOrArrow(
    List<Offset> points,
    Rect bounds,
    double totalLength,
    double startEndDistance,
  ) {
    if (points.length < 3) return null;
    if (startEndDistance < 10) return null;

    final straightnessRatio = totalLength / startEndDistance;

    // Check for arrowheads
    final hasArrowEnd = _detectArrowhead(points);
    final hasArrowStart = _detectArrowhead(points.reversed.toList());

    if (hasArrowEnd || hasArrowStart) {
      var maxDist = 0.0;
      var tipEnd = points.last;
      for (final p in points) {
        final d = (p - points.first).distance;
        if (d > maxDist) {
          maxDist = d;
          tipEnd = p;
        }
      }

      final shapeType = (hasArrowStart && hasArrowEnd)
          ? ShapeType.doubleArrow
          : (hasArrowEnd ? ShapeType.arrow : ShapeType.line);

      return RecognizedShapeResult(
        shapeType: shapeType,
        start: points.first,
        end: tipEnd,
        confidence: 0.88,
        label: shapeType == ShapeType.doubleArrow ? 'Double Arrow' : 'Arrow',
      );
    }

    // Check if overall stroke is approximately straight
    if (straightnessRatio <= 1.32) {
      Offset start = points.first;
      Offset end = points.last;

      // Snap near horizontal/vertical lines to exact axis
      final dx = (end.dx - start.dx).abs();
      final dy = (end.dy - start.dy).abs();
      if (dy < 14.0 || dy / (dx + 0.001) < 0.12) {
        end = Offset(end.dx, start.dy);
      } else if (dx < 14.0 || dx / (dy + 0.001) < 0.12) {
        end = Offset(start.dx, end.dy);
      }

      return RecognizedShapeResult(
        shapeType: ShapeType.line,
        start: start,
        end: end,
        confidence: math.min(1.0, 1.35 / straightnessRatio),
        label: 'Line',
      );
    }

    return null;
  }

  static RecognizedShapeResult? _classifyStar(
    List<Offset> points,
    List<Offset> simplified,
    Rect bounds,
    double areaRatio,
    int vertexCount,
    Offset center,
    double width,
    double height,
  ) {
    if (vertexCount >= 7 && vertexCount <= 14 && areaRatio >= 0.18 && areaRatio <= 0.50) {
      var outerTips = 0;
      final maxRadius = math.max(width, height) / 2;
      for (final p in simplified) {
        if ((p - center).distance > maxRadius * 0.65) outerTips++;
      }
      if (outerTips >= 4 && outerTips <= 7) {
        return RecognizedShapeResult(
          shapeType: ShapeType.star,
          start: bounds.topLeft,
          end: bounds.bottomRight,
          confidence: 0.85,
          label: 'Star',
        );
      }
    }
    return null;
  }

  static RecognizedShapeResult? _classifyDiamond(
    Rect bounds,
    double areaRatio,
    bool allCardinalsNear,
    double avgCornerDist,
  ) {
    if (allCardinalsNear && avgCornerDist > 0.40 && areaRatio >= 0.35 && areaRatio <= 0.68) {
      return RecognizedShapeResult(
        shapeType: ShapeType.diamond,
        start: bounds.topLeft,
        end: bounds.bottomRight,
        confidence: 0.88,
        label: 'Diamond',
      );
    }
    return null;
  }

  static RecognizedShapeResult? _classifyTriangle(
    List<Offset> simplified,
    Rect bounds,
    double areaRatio,
    int vertexCount,
    List<double> cardinalDists,
  ) {
    if (areaRatio < 0.22 || areaRatio > 0.70) return null;
    final cardinalsNear = cardinalDists.where((d) => d < 0.25).length;
    if (cardinalsNear >= 4) return null;

    var isTriangle = vertexCount == 3;

    if (!isTriangle && vertexCount >= 4 && vertexCount <= 6) {
      var sharpCorners = 0;
      final n = simplified.length - 1;
      for (var i = 0; i < n; i++) {
        final prev = simplified[(i - 1 + n) % n];
        final curr = simplified[i];
        final next = simplified[(i + 1) % n];
        final v1 = prev - curr;
        final v2 = next - curr;
        final dot = v1.dx * v2.dx + v1.dy * v2.dy;
        final mag = v1.distance * v2.distance;
        if (mag > 0) {
          final cosAngle = (dot / mag).clamp(-1.0, 1.0);
          final angleDeg = math.acos(cosAngle) * 180 / math.pi;
          if (angleDeg < 130.0) sharpCorners++;
        }
      }
      if (sharpCorners == 3) isTriangle = true;
    }

    if (isTriangle) {
      return RecognizedShapeResult(
        shapeType: ShapeType.triangle,
        start: bounds.topLeft,
        end: bounds.bottomRight,
        confidence: 0.85,
        label: 'Triangle',
      );
    }

    return null;
  }

  static RecognizedShapeResult? _classifyCircleOrEllipse(
    Rect bounds,
    Offset center,
    double width,
    double height,
    double areaRatio,
    double avgRadialDev,
    double maxRadialDev,
    double stdRadialDev,
    double avgCornerDist,
    int cornersNear,
  ) {
    // Circle/ellipse points have low radial variance, and the 4 bounding box
    // corners remain completely empty (unlike rectangles/boxes where corners are touched).
    final isCircleOrEllipse = avgRadialDev < 0.12 &&
        maxRadialDev < 0.35 &&
        stdRadialDev < 0.095 &&
        avgCornerDist > 0.30 &&
        cornersNear <= 1 &&
        areaRatio >= 0.58 &&
        areaRatio <= 0.94;

    if (isCircleOrEllipse) {
      final aspectRatio = width / height;
      final isPerfectCircle = aspectRatio >= 0.78 && aspectRatio <= 1.28;

      Rect finalBounds = bounds;
      if (isPerfectCircle) {
        final avgRadius = (width + height) / 4;
        finalBounds = Rect.fromCircle(center: center, radius: avgRadius);
      }

      return RecognizedShapeResult(
        shapeType: ShapeType.ellipse,
        start: finalBounds.topLeft,
        end: finalBounds.bottomRight,
        confidence: math.min(1.0, 1.0 - avgRadialDev),
        label: isPerfectCircle ? 'Circle' : 'Ellipse',
      );
    }

    return null;
  }

  static RecognizedShapeResult? _classifyRectangle(
    List<Offset> points,
    Rect bounds,
    double areaRatio,
    double edgeDistRatio,
    double avgCornerDist,
    int cornersNear,
  ) {
    final isBoxLike = (cornersNear >= 2 && areaRatio >= 0.60 && areaRatio <= 1.15) ||
        (edgeDistRatio < 0.20 && areaRatio >= 0.65 && areaRatio <= 1.15) ||
        (avgCornerDist < 0.30 && areaRatio >= 0.65);

    if (isBoxLike) {
      final isRounded = avgCornerDist > 0.15 || _detectRoundedCorners(points, bounds);

      return RecognizedShapeResult(
        shapeType: isRounded ? ShapeType.roundedRectangle : ShapeType.rectangle,
        start: bounds.topLeft,
        end: bounds.bottomRight,
        confidence: math.min(1.0, math.max(0.70, areaRatio)),
        label: isRounded ? 'Rounded Box' : 'Rectangle',
      );
    }

    return null;
  }

  // ── Helper Algorithms ─────────────────────────────────────────────

  static List<Offset> _preprocessPoints(List<Offset> rawPoints) {
    if (rawPoints.isEmpty) return const [];
    final deduplicated = <Offset>[rawPoints.first];

    for (var i = 1; i < rawPoints.length; i++) {
      if ((rawPoints[i] - deduplicated.last).distance >= 2.0) {
        deduplicated.add(rawPoints[i]);
      }
    }

    if (deduplicated.length < 2) return deduplicated;

    // Arc-length equidistant resampling to 64 points
    const targetCount = 64;
    final totalLen = _computeTotalLength(deduplicated);
    if (totalLen <= 0) return deduplicated;

    final segmentLen = totalLen / (targetCount - 1);
    final resampled = <Offset>[deduplicated.first];

    var currentDist = 0.0;
    var targetDist = segmentLen;
    var idx = 0;

    while (idx < deduplicated.length - 1 && resampled.length < targetCount - 1) {
      final p1 = deduplicated[idx];
      final p2 = deduplicated[idx + 1];
      final d = (p2 - p1).distance;

      if (currentDist + d >= targetDist) {
        final t = (targetDist - currentDist) / (d > 0 ? d : 1.0);
        final newPt = Offset(p1.dx + t * (p2.dx - p1.dx), p1.dy + t * (p2.dy - p1.dy));
        resampled.add(newPt);
        targetDist += segmentLen;
      } else {
        currentDist += d;
        idx++;
      }
    }

    resampled.add(deduplicated.last);
    return resampled;
  }

  static Rect _computeBounds(List<Offset> points) {
    if (points.isEmpty) return Rect.zero;
    var minX = points.first.dx;
    var maxX = points.first.dx;
    var minY = points.first.dy;
    var maxY = points.first.dy;

    for (var i = 1; i < points.length; i++) {
      final p = points[i];
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  static double _computeTotalLength(List<Offset> points) {
    var len = 0.0;
    for (var i = 1; i < points.length; i++) {
      len += (points[i] - points[i - 1]).distance;
    }
    return len;
  }

  static double _computePolygonArea(List<Offset> points) {
    if (points.length < 3) return 0.0;
    double area = 0.0;
    final n = points.length;
    for (var i = 0; i < n; i++) {
      final j = (i + 1) % n;
      area += points[i].dx * points[j].dy;
      area -= points[j].dx * points[i].dy;
    }
    return (area / 2.0).abs();
  }

  /// Simplifies a closed curve by finding the furthest point from start,
  /// splitting the loop into two open polylines, simplifying each with RDP, and recombining.
  static List<Offset> _simplifyClosedPolygon(List<Offset> points, double epsilon) {
    if (points.length < 5) return points;

    var maxDist = 0.0;
    var farIndex = 0;
    for (var i = 1; i < points.length; i++) {
      final d = (points[i] - points.first).distance;
      if (d > maxDist) {
        maxDist = d;
        farIndex = i;
      }
    }

    if (farIndex <= 2 || farIndex >= points.length - 3) {
      return _douglasPeucker(points, epsilon);
    }

    final half1 = _douglasPeucker(points.sublist(0, farIndex + 1), epsilon);
    final half2 = _douglasPeucker(points.sublist(farIndex), epsilon);

    return [...half1.sublist(0, half1.length - 1), ...half2];
  }

  /// Ramer-Douglas-Peucker line simplification
  static List<Offset> _douglasPeucker(List<Offset> points, double epsilon) {
    if (points.length < 3) return points;

    double maxDistance = 0.0;
    int index = 0;
    final start = points.first;
    final end = points.last;

    for (var i = 1; i < points.length - 1; i++) {
      final d = _perpendicularDistance(points[i], start, end);
      if (d > maxDistance) {
        maxDistance = d;
        index = i;
      }
    }

    if (maxDistance > epsilon) {
      final left = _douglasPeucker(points.sublist(0, index + 1), epsilon);
      final right = _douglasPeucker(points.sublist(index), epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [start, end];
    }
  }

  static double _perpendicularDistance(Offset p, Offset lineStart, Offset lineEnd) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;
    final lineMag = math.sqrt(dx * dx + dy * dy);
    if (lineMag == 0) return (p - lineStart).distance;

    final num = ((p.dx - lineStart.dx) * dy - (p.dy - lineStart.dy) * dx).abs();
    return num / lineMag;
  }

  static bool _detectArrowhead(List<Offset> points) {
    if (points.length < 8) return false;
    // Find point furthest from start (the arrowhead tip)
    var maxDist = 0.0;
    var maxIdx = 0;
    for (var i = 0; i < points.length; i++) {
      final d = (points[i] - points.first).distance;
      if (d > maxDist) {
        maxDist = d;
        maxIdx = i;
      }
    }

    // Arrowhead tip occurs between 55% and 96% of the stroke
    if (maxIdx >= (points.length * 0.55).toInt() && maxIdx < points.length - 1) {
      final shaftVector = points[maxIdx] - points.first;
      final barbVector = points.last - points[maxIdx];
      final dot = shaftVector.dx * barbVector.dx + shaftVector.dy * barbVector.dy;
      if (dot < 0) return true; // Barb folds backward relative to shaft
    }
    return false;
  }

  static bool _detectRoundedCorners(List<Offset> points, Rect bounds) {
    // Check if points skip the extreme sharp corners of the bounding box
    final corners = [
      bounds.topLeft,
      bounds.topRight,
      bounds.bottomRight,
      bounds.bottomLeft,
    ];

    var cornerNearness = 0;
    final threshold = math.min(bounds.width, bounds.height) * 0.14;

    for (final corner in corners) {
      for (final p in points) {
        if ((p - corner).distance < threshold) {
          cornerNearness++;
          break;
        }
      }
    }

    // If fewer than 2 tight corners are touched, the shape has rounded corners
    return cornerNearness <= 2;
  }
}
