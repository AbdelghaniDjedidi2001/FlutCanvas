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
    if (rawPoints.length < 5) return null;

    // 1. Clean & resample points with uniform arc length
    final points = _preprocessPoints(rawPoints);
    if (points.length < 8) return null;

    final bounds = _computeBounds(points);
    final width = bounds.width;
    final height = bounds.height;
    final diagonal = math.sqrt(width * width + height * height);

    // Minimum size threshold (avoid snapping tiny accidental dots)
    if (width < 18 || height < 18 || diagonal < 26) return null;

    final totalLength = _computeTotalLength(points);
    if (totalLength <= 0) return null;

    final startEndDistance = (points.first - points.last).distance;
    final isClosed = (startEndDistance / diagonal < 0.32) || (startEndDistance / totalLength < 0.22);

    // ── 1. Open Stroke Classifiers (Straight Line & Arrow) ────────────────
    if (!isClosed) {
      final lineResult = _classifyLineOrArrow(points, bounds, totalLength, startEndDistance);
      if (lineResult != null) return lineResult;
    }

    // ── 2. Closed Stroke Classifiers (Circle, Rect, Triangle, Diamond, Star) ──
    final area = _computePolygonArea(points);
    final boxArea = width * height;
    final areaRatio = boxArea > 0 ? area / boxArea : 0.0;

    // A. Circle & Ellipse
    final ellipseResult = _classifyCircleOrEllipse(points, bounds, areaRatio);
    if (ellipseResult != null) return ellipseResult;

    // B. Polygon simplification (RDP algorithm)
    final simplified = _douglasPeucker(points, math.max(diagonal * 0.045, 6.0));
    final vertexCount = simplified.length <= 1 ? 0 : simplified.length - 1; // last point closes on first

    // C. Diamond (4 cardinal vertices near edge centers)
    final diamondResult = _classifyDiamond(simplified, bounds, areaRatio, vertexCount);
    if (diamondResult != null) return diamondResult;

    // D. Triangle (3 prominent vertices)
    final triangleResult = _classifyTriangle(simplified, bounds, areaRatio, vertexCount);
    if (triangleResult != null) return triangleResult;

    // E. Rectangle / Rounded Rectangle (4 corners near 90 degrees)
    final rectResult = _classifyRectangle(points, simplified, bounds, areaRatio, vertexCount);
    if (rectResult != null) return rectResult;

    // F. Star (5 or 10 alternating points)
    final starResult = _classifyStar(points, simplified, bounds, areaRatio, vertexCount);
    if (starResult != null) return starResult;

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
    if (straightnessRatio <= 1.20) {
      return RecognizedShapeResult(
        shapeType: ShapeType.line,
        start: points.first,
        end: points.last,
        confidence: math.min(1.0, 1.25 / straightnessRatio),
        label: 'Line',
      );
    }

    return null;
  }

  static RecognizedShapeResult? _classifyCircleOrEllipse(
    List<Offset> points,
    Rect bounds,
    double areaRatio,
  ) {
    final center = bounds.center;
    final halfW = bounds.width / 2;
    final halfH = bounds.height / 2;
    if (halfW <= 0 || halfH <= 0) return null;

    // Ideal ellipse area ratio is pi / 4 ~ 0.785
    if (areaRatio < 0.55 || areaRatio > 0.95) return null;

    // Compute ellipse fitting error
    double totalError = 0.0;
    for (final p in points) {
      final dx = (p.dx - center.dx) / halfW;
      final dy = (p.dy - center.dy) / halfH;
      final distFromPerimeter = (math.sqrt(dx * dx + dy * dy) - 1.0).abs();
      totalError += distFromPerimeter;
    }
    final avgError = totalError / points.length;

    if (avgError < 0.22) {
      final aspectRatio = bounds.width / bounds.height;
      final isPerfectCircle = aspectRatio >= 0.82 && aspectRatio <= 1.22;

      Rect finalBounds = bounds;
      if (isPerfectCircle) {
        final avgRadius = (bounds.width + bounds.height) / 4;
        finalBounds = Rect.fromCircle(center: center, radius: avgRadius);
      }

      return RecognizedShapeResult(
        shapeType: ShapeType.ellipse,
        start: finalBounds.topLeft,
        end: finalBounds.bottomRight,
        confidence: math.min(1.0, 1.0 - avgError),
        label: isPerfectCircle ? 'Circle' : 'Ellipse',
      );
    }

    return null;
  }

  static RecognizedShapeResult? _classifyTriangle(
    List<Offset> simplified,
    Rect bounds,
    double areaRatio,
    int vertexCount,
  ) {
    // Triangles have 3 prominent vertices and an area ratio ~ 0.28 - 0.68
    if (vertexCount == 3 && areaRatio >= 0.28 && areaRatio <= 0.68) {
      // Find apex vertex (highest, lowest, leftmost, or rightmost)
      Offset apex = simplified.first;
      for (final p in simplified) {
        if (p.dy < apex.dy) apex = p;
      }

      // Check if apex is near horizontal center
      final apexXRatio = (apex.dx - bounds.left) / bounds.width;
      final isUpright = apexXRatio >= 0.25 && apexXRatio <= 0.75 && (apex.dy - bounds.top).abs() < bounds.height * 0.3;

      return RecognizedShapeResult(
        shapeType: ShapeType.triangle,
        start: isUpright ? Offset(bounds.center.dx, bounds.top) : bounds.topLeft,
        end: bounds.bottomRight,
        confidence: 0.85,
        label: 'Triangle',
      );
    }
    return null;
  }

  static RecognizedShapeResult? _classifyDiamond(
    List<Offset> simplified,
    Rect bounds,
    double areaRatio,
    int vertexCount,
  ) {
    // Diamond has 4 vertices with area ratio around 0.38 - 0.65
    if ((vertexCount == 4 || vertexCount == 5) && areaRatio >= 0.38 && areaRatio <= 0.65) {
      final center = bounds.center;
      var topMatch = false;
      var bottomMatch = false;
      var leftMatch = false;
      var rightMatch = false;

      for (final p in simplified) {
        if ((p.dy - bounds.top).abs() < bounds.height * 0.25 && (p.dx - center.dx).abs() < bounds.width * 0.3) {
          topMatch = true;
        }
        if ((p.dy - bounds.bottom).abs() < bounds.height * 0.25 && (p.dx - center.dx).abs() < bounds.width * 0.3) {
          bottomMatch = true;
        }
        if ((p.dx - bounds.left).abs() < bounds.width * 0.25 && (p.dy - center.dy).abs() < bounds.height * 0.3) {
          leftMatch = true;
        }
        if ((p.dx - bounds.right).abs() < bounds.width * 0.25 && (p.dy - center.dy).abs() < bounds.height * 0.3) {
          rightMatch = true;
        }
      }

      if (topMatch && bottomMatch && (leftMatch || rightMatch)) {
        return RecognizedShapeResult(
          shapeType: ShapeType.diamond,
          start: bounds.topLeft,
          end: bounds.bottomRight,
          confidence: 0.88,
          label: 'Diamond',
        );
      }
    }
    return null;
  }

  static RecognizedShapeResult? _classifyRectangle(
    List<Offset> points,
    List<Offset> simplified,
    Rect bounds,
    double areaRatio,
    int vertexCount,
  ) {
    // Rectangles have area ratio >= 0.72
    if (areaRatio >= 0.70 && areaRatio <= 1.05) {
      if (vertexCount >= 3 && vertexCount <= 7) {
        // Check corner curvature to differentiate Rectangle vs Rounded Rectangle
        final isRounded = _detectRoundedCorners(points, bounds);

        return RecognizedShapeResult(
          shapeType: isRounded ? ShapeType.roundedRectangle : ShapeType.rectangle,
          start: bounds.topLeft,
          end: bounds.bottomRight,
          confidence: math.min(1.0, areaRatio),
          label: isRounded ? 'Rounded Box' : 'Rectangle',
        );
      }
    }
    return null;
  }

  static RecognizedShapeResult? _classifyStar(
    List<Offset> points,
    List<Offset> simplified,
    Rect bounds,
    double areaRatio,
    int vertexCount,
  ) {
    // Star has 5 outward tips (vertex count 8 to 14) and low area ratio 0.20 - 0.52
    if (vertexCount >= 5 && vertexCount <= 14 && areaRatio >= 0.20 && areaRatio <= 0.52) {
      final center = bounds.center;
      var outerTips = 0;
      final maxRadius = math.max(bounds.width, bounds.height) / 2;

      for (final p in simplified) {
        final dist = (p - center).distance;
        if (dist > maxRadius * 0.70) {
          outerTips++;
        }
      }

      if (outerTips >= 4 && outerTips <= 7) {
        return RecognizedShapeResult(
          shapeType: ShapeType.star,
          start: bounds.topLeft,
          end: bounds.bottomRight,
          confidence: 0.82,
          label: 'Star',
        );
      }
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

    if (deduplicated.length < 4) return deduplicated;

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
