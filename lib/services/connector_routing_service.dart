import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/board_element.dart';
import '../models/connection_binding.dart';
import '../models/connector_style.dart';

class ConnectorRoute {
  const ConnectorRoute({
    required this.path,
    required this.waypoints,
    required this.midpoint,
    required this.startAngle,
    required this.endAngle,
  });

  final Path path;
  final List<Offset> waypoints;
  final Offset midpoint;
  final double startAngle;
  final double endAngle;
}

class ConnectorRoutingService {
  static ConnectorRoute computeRoute(
    BoardElement el, {
    double cornerRadius = 10.0,
  }) {
    final start = el.start;
    final end = el.end;
    final style = el.connectorStyle;

    switch (style) {
      case ConnectorStyle.straight:
        return _computeStraightRoute(start, end);
      case ConnectorStyle.orthogonal:
        return _computeOrthogonalRoute(
          start,
          end,
          el.startBinding,
          el.endBinding,
          cornerRadius,
        );
      case ConnectorStyle.curved:
        return _computeCurvedRoute(
          start,
          end,
          el.startBinding,
          el.endBinding,
        );
    }
  }

  static ConnectorRoute _computeStraightRoute(Offset start, Offset end) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

    return ConnectorRoute(
      path: path,
      waypoints: [start, end],
      midpoint: mid,
      startAngle: angle + math.pi,
      endAngle: angle,
    );
  }

  static ConnectorRoute _computeCurvedRoute(
    Offset start,
    Offset end,
    ConnectionBinding? startBinding,
    ConnectionBinding? endBinding,
  ) {
    final dist = (end - start).distance;
    final curvature = (dist * 0.45).clamp(24.0, 180.0);

    Offset c1;
    Offset c2;

    final startDir = _getAnchorNormal(startBinding?.anchor);
    final endDir = _getAnchorNormal(endBinding?.anchor);

    if (startDir != null && endDir != null) {
      c1 = start + startDir * curvature;
      c2 = end + endDir * curvature;
    } else if (startDir != null) {
      c1 = start + startDir * curvature;
      c2 = end - startDir * (curvature * 0.5);
    } else if (endDir != null) {
      c1 = start - endDir * (curvature * 0.5);
      c2 = end + endDir * curvature;
    } else {
      // Freeform Bézier: generate subtle vertical or horizontal arch
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      if (dx.abs() >= dy.abs()) {
        c1 = Offset(start.dx + dx * 0.5, start.dy);
        c2 = Offset(start.dx + dx * 0.5, end.dy);
      } else {
        c1 = Offset(start.dx, start.dy + dy * 0.5);
        c2 = Offset(end.dx, start.dy + dy * 0.5);
      }
    }

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);

    // Evaluate cubic Bézier point at t=0.5: B(0.5) = 1/8*P0 + 3/8*P1 + 3/8*P2 + 1/8*P3
    final mid = Offset(
      0.125 * start.dx + 0.375 * c1.dx + 0.375 * c2.dx + 0.125 * end.dx,
      0.125 * start.dy + 0.375 * c1.dy + 0.375 * c2.dy + 0.125 * end.dy,
    );

    // Tangents at start and end
    final startAngle = math.atan2(start.dy - c1.dy, start.dx - c1.dx);
    final endAngle = math.atan2(end.dy - c2.dy, end.dx - c2.dx);

    return ConnectorRoute(
      path: path,
      waypoints: [start, c1, c2, end],
      midpoint: mid,
      startAngle: startAngle,
      endAngle: endAngle,
    );
  }

  static ConnectorRoute _computeOrthogonalRoute(
    Offset start,
    Offset end,
    ConnectionBinding? startBinding,
    ConnectionBinding? endBinding,
    double cornerRadius,
  ) {
    final waypoints = <Offset>[start];
    const stub = 20.0;

    final startDir = _getAnchorNormal(startBinding?.anchor);
    final endDir = _getAnchorNormal(endBinding?.anchor);

    if (startDir != null && endDir != null) {
      final p1 = start + startDir * stub;
      final pLast = end + endDir * stub;
      waypoints.add(p1);

      // Route between p1 and pLast
      final midX = (p1.dx + pLast.dx) / 2;
      final midY = (p1.dy + pLast.dy) / 2;

      final sIsHoriz = startDir.dx.abs() > 0.5;
      final eIsHoriz = endDir.dx.abs() > 0.5;

      if (sIsHoriz && eIsHoriz) {
        // Both horizontal anchors (e.g. Right to Left)
        waypoints.add(Offset(midX, p1.dy));
        waypoints.add(Offset(midX, pLast.dy));
      } else if (!sIsHoriz && !eIsHoriz) {
        // Both vertical anchors (e.g. Bottom to Top)
        waypoints.add(Offset(p1.dx, midY));
        waypoints.add(Offset(pLast.dx, midY));
      } else if (sIsHoriz && !eIsHoriz) {
        // Horizontal to Vertical (e.g. Right to Top)
        waypoints.add(Offset(pLast.dx, p1.dy));
      } else {
        // Vertical to Horizontal (e.g. Bottom to Left)
        waypoints.add(Offset(p1.dx, pLast.dy));
      }

      waypoints.add(pLast);
    } else if (startDir != null) {
      final p1 = start + startDir * stub;
      waypoints.add(p1);
      if (startDir.dx.abs() > 0.5) {
        waypoints.add(Offset(end.dx, p1.dy));
      } else {
        waypoints.add(Offset(p1.dx, end.dy));
      }
    } else if (endDir != null) {
      final pLast = end + endDir * stub;
      if (endDir.dx.abs() > 0.5) {
        waypoints.add(Offset(start.dx, pLast.dy));
      } else {
        waypoints.add(Offset(pLast.dx, start.dy));
      }
      waypoints.add(pLast);
    } else {
      // Freeform orthogonal step
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      if (dx.abs() >= dy.abs()) {
        final midX = start.dx + dx / 2;
        waypoints.add(Offset(midX, start.dy));
        waypoints.add(Offset(midX, end.dy));
      } else {
        final midY = start.dy + dy / 2;
        waypoints.add(Offset(start.dx, midY));
        waypoints.add(Offset(end.dx, midY));
      }
    }

    waypoints.add(end);

    // Clean up consecutive identical or collinear points
    final cleanWaypoints = _simplifyWaypoints(waypoints);

    // Build rounded path from waypoints
    final path = _buildRoundedPath(cleanWaypoints, cornerRadius);

    // Midpoint calculation along waypoint path
    final mid = _findMidpointOnWaypoints(cleanWaypoints);

    // Terminal angles
    final p0 = cleanWaypoints[0];
    final p1 = cleanWaypoints[1];
    final pPenult = cleanWaypoints[cleanWaypoints.length - 2];
    final pLast = cleanWaypoints.last;

    final startAngle = math.atan2(p0.dy - p1.dy, p0.dx - p1.dx);
    final endAngle = math.atan2(pLast.dy - pPenult.dy, pLast.dx - pPenult.dx);

    return ConnectorRoute(
      path: path,
      waypoints: cleanWaypoints,
      midpoint: mid,
      startAngle: startAngle,
      endAngle: endAngle,
    );
  }

  static Offset? _getAnchorNormal(AnchorPoint? anchor) {
    if (anchor == null) return null;
    return switch (anchor) {
      AnchorPoint.top => const Offset(0, -1),
      AnchorPoint.right => const Offset(1, 0),
      AnchorPoint.bottom => const Offset(0, 1),
      AnchorPoint.left => const Offset(-1, 0),
      AnchorPoint.center => null,
    };
  }

  static List<Offset> _simplifyWaypoints(List<Offset> points) {
    if (points.length < 3) return points;
    final result = <Offset>[points.first];

    for (var i = 1; i < points.length; i++) {
      final p = points[i];
      final prev = result.last;
      if ((p - prev).distance < 1.0) continue; // skip duplicates

      if (result.length >= 2) {
        final prevPrev = result[result.length - 2];
        // Check if prev is collinear between prevPrev and p
        final isHorizCollinear = (prevPrev.dy == prev.dy) && (prev.dy == p.dy);
        final isVertCollinear = (prevPrev.dx == prev.dx) && (prev.dx == p.dx);
        if (isHorizCollinear || isVertCollinear) {
          result.removeLast(); // collapse collinear step
        }
      }
      result.add(p);
    }
    return result;
  }

  static Path _buildRoundedPath(List<Offset> points, double radius) {
    final path = Path();
    if (points.isEmpty) return path;
    if (points.length < 3) {
      path.moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      return path;
    }

    path.moveTo(points[0].dx, points[0].dy);

    for (var i = 1; i < points.length - 1; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final next = points[i + 1];

      final v1 = prev - curr;
      final v2 = next - curr;
      final len1 = v1.distance;
      final len2 = v2.distance;

      final r = math.min(radius, math.min(len1 / 2, len2 / 2));
      if (r < 1.5) {
        path.lineTo(curr.dx, curr.dy);
      } else {
        final startArc = curr + (v1 / len1) * r;
        final endArc = curr + (v2 / len2) * r;

        path.lineTo(startArc.dx, startArc.dy);
        path.quadraticBezierTo(curr.dx, curr.dy, endArc.dx, endArc.dy);
      }
    }

    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  static Offset _findMidpointOnWaypoints(List<Offset> points) {
    if (points.isEmpty) return Offset.zero;
    if (points.length == 1) return points.first;

    var totalLength = 0.0;
    final lengths = <double>[];
    for (var i = 0; i < points.length - 1; i++) {
      final segLen = (points[i + 1] - points[i]).distance;
      lengths.add(segLen);
      totalLength += segLen;
    }

    if (totalLength == 0.0) return points.first;

    final target = totalLength / 2;
    var accum = 0.0;

    for (var i = 0; i < lengths.length; i++) {
      if (accum + lengths[i] >= target) {
        final remaining = target - accum;
        final ratio = lengths[i] > 0 ? (remaining / lengths[i]) : 0.0;
        return points[i] + (points[i + 1] - points[i]) * ratio;
      }
      accum += lengths[i];
    }

    return points.last;
  }

  static bool hitTestRoute(BoardElement el, Offset testPoint, double maxDistance) {
    final route = computeRoute(el);
    final waypoints = route.waypoints;

    if (waypoints.length >= 2) {
      for (var i = 0; i < waypoints.length - 1; i++) {
        final p1 = waypoints[i];
        final p2 = waypoints[i + 1];
        final dist = _distToSegment(testPoint, p1, p2);
        if (dist <= maxDistance) return true;
      }
    }

    // Check label hit-test if label is present
    if (el.label != null && el.label!.trim().isNotEmpty) {
      final labelBounds = Rect.fromCenter(
        center: route.midpoint,
        width: 100,
        height: 32,
      );
      if (labelBounds.contains(testPoint)) return true;
    }

    return false;
  }

  static double _distToSegment(Offset p, Offset v, Offset w) {
    final l2 = (v.dx - w.dx) * (v.dx - w.dx) + (v.dy - w.dy) * (v.dy - w.dy);
    if (l2 == 0) return (p - v).distance;
    final t = math.max(
      0.0,
      math.min(
        1.0,
        ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2,
      ),
    );
    final projection = Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy));
    return (p - projection).distance;
  }
}
