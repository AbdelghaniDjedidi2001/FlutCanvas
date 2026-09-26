import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'connection_binding.dart';
import 'connector_style.dart';
import 'shape_type.dart';
import 'stroke_fill_style.dart';
import '../services/connector_routing_service.dart';

@immutable
class BoardElement {
  const BoardElement({
    required this.id,
    required this.type,
    required this.start,
    required this.end,
    this.points = const [],
    required this.color,
    this.strokeWidth = 2.5,
    this.strokeStyle = StrokeStyle.solid,
    this.fillStyle = FillStyle.none,
    this.fillColor = Colors.transparent,
    this.text = '',
    this.fontSize = 22.0,
    this.opacity = 1.0,
    this.rotation = 0.0,
    this.startBinding,
    this.endBinding,
    this.imageBase64,
    this.groupId,
    this.drawStyle = DrawStyle.clean,
    this.frameTitle,
    this.frameIndex,
    this.isLocked = false,
    this.isVisible = true,
    this.customName,
    this.connectorStyle = ConnectorStyle.straight,
    this.label,
  });

  final String id;
  final ShapeType type;
  final Offset start; // world coordinates
  final Offset end;
  final List<Offset> points; // used by pen and highlighter
  final Color color;
  final double strokeWidth;
  final StrokeStyle strokeStyle;
  final FillStyle fillStyle;
  final Color fillColor;
  final String text;
  final double fontSize;
  final double opacity;
  final double rotation; // in radians
  final ConnectionBinding? startBinding;
  final ConnectionBinding? endBinding;
  final String? imageBase64;
  final String? groupId;
  final DrawStyle drawStyle;
  final String? frameTitle;
  final int? frameIndex;
  final bool isLocked;
  final bool isVisible;
  final String? customName;
  final ConnectorStyle connectorStyle;
  final String? label;

  String get displayName {
    if (customName != null && customName!.trim().isNotEmpty) {
      return customName!;
    }
    if (frameTitle != null && frameTitle!.isNotEmpty) {
      return frameTitle!;
    }
    if (label != null && label!.trim().isNotEmpty) {
      final preview = label!.replaceAll('\n', ' ').trim();
      return preview.length > 20 ? '${preview.substring(0, 18)}...' : preview;
    }
    if (text.isNotEmpty) {
      final preview = text.replaceAll('\n', ' ').trim();
      return preview.length > 20 ? '${preview.substring(0, 18)}...' : preview;
    }
    return switch (type) {
      ShapeType.rectangle => 'Rectangle',
      ShapeType.roundedRectangle => 'Rounded Box',
      ShapeType.ellipse => 'Ellipse',
      ShapeType.diamond => 'Diamond',
      ShapeType.triangle => 'Triangle',
      ShapeType.star => 'Star',
      ShapeType.line => 'Line',
      ShapeType.arrow => 'Arrow',
      ShapeType.doubleArrow => 'Double Arrow',
      ShapeType.pen => 'Sketch',
      ShapeType.highlighter => 'Highlight',
      ShapeType.text => 'Text',
      ShapeType.stickyNote => 'Sticky Note',
      ShapeType.frame => 'Frame',
      ShapeType.image => 'Image',
    };
  }

  BoardElement copyWith({
    String? id,
    ShapeType? type,
    Offset? start,
    Offset? end,
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    StrokeStyle? strokeStyle,
    FillStyle? fillStyle,
    Color? fillColor,
    String? text,
    double? fontSize,
    double? opacity,
    double? rotation,
    ConnectionBinding? startBinding,
    ConnectionBinding? endBinding,
    String? imageBase64,
    String? groupId,
    DrawStyle? drawStyle,
    String? frameTitle,
    int? frameIndex,
    bool? isLocked,
    bool? isVisible,
    String? customName,
    ConnectorStyle? connectorStyle,
    String? label,
    bool clearStartBinding = false,
    bool clearEndBinding = false,
    bool clearGroupId = false,
    bool clearCustomName = false,
    bool clearLabel = false,
  }) {
    return BoardElement(
      id: id ?? this.id,
      type: type ?? this.type,
      start: start ?? this.start,
      end: end ?? this.end,
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeStyle: strokeStyle ?? this.strokeStyle,
      fillStyle: fillStyle ?? this.fillStyle,
      fillColor: fillColor ?? this.fillColor,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
      opacity: opacity ?? this.opacity,
      rotation: rotation ?? this.rotation,
      startBinding:
          clearStartBinding ? null : (startBinding ?? this.startBinding),
      endBinding: clearEndBinding ? null : (endBinding ?? this.endBinding),
      imageBase64: imageBase64 ?? this.imageBase64,
      groupId: clearGroupId ? null : (groupId ?? this.groupId),
      drawStyle: drawStyle ?? this.drawStyle,
      frameTitle: frameTitle ?? this.frameTitle,
      frameIndex: frameIndex ?? this.frameIndex,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
      customName: clearCustomName ? null : (customName ?? this.customName),
      connectorStyle: connectorStyle ?? this.connectorStyle,
      label: clearLabel ? null : (label ?? this.label),
    );
  }

  BoardElement translated(Offset d) => copyWith(
        start: start + d,
        end: end + d,
        points: [for (final p in points) p + d],
      );

  BoardElement rotated(double deltaAngle) => copyWith(
        rotation: (rotation + deltaAngle) % (2 * math.pi),
      );

  /// Scales the element from its [oldBounds] to [newBounds].
  BoardElement scaled(Rect oldBounds, Rect newBounds) {
    if (oldBounds.width == 0 || oldBounds.height == 0) return this;

    Offset mapPoint(Offset p) {
      final nx = (p.dx - oldBounds.left) / oldBounds.width;
      final ny = (p.dy - oldBounds.top) / oldBounds.height;
      return Offset(
        newBounds.left + nx * newBounds.width,
        newBounds.top + ny * newBounds.height,
      );
    }

    return copyWith(
      start: mapPoint(start),
      end: mapPoint(end),
      points: [for (final p in points) mapPoint(p)],
    );
  }

  Rect get bounds {
    if ((type == ShapeType.pen || type == ShapeType.highlighter) &&
        points.isNotEmpty) {
      var minX = points.first.dx, maxX = minX;
      var minY = points.first.dy, maxY = minY;
      for (final p in points) {
        minX = math.min(minX, p.dx);
        maxX = math.max(maxX, p.dx);
        minY = math.min(minY, p.dy);
        maxY = math.max(maxY, p.dy);
      }
      return Rect.fromLTRB(minX, minY, maxX, maxY);
    }

    if (type == ShapeType.line ||
        type == ShapeType.arrow ||
        type == ShapeType.doubleArrow) {
      final route = ConnectorRoutingService.computeRoute(this);
      var minX = math.min(start.dx, end.dx);
      var maxX = math.max(start.dx, end.dx);
      var minY = math.min(start.dy, end.dy);
      var maxY = math.max(start.dy, end.dy);
      for (final p in route.waypoints) {
        minX = math.min(minX, p.dx);
        maxX = math.max(maxX, p.dx);
        minY = math.min(minY, p.dy);
        maxY = math.max(maxY, p.dy);
      }
      return Rect.fromLTRB(minX, minY, maxX, maxY);
    }

    if (type == ShapeType.text) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text.isEmpty ? 'Type text...' : text,
          style: GoogleFonts.caveat(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      return Rect.fromLTWH(
          start.dx, start.dy, textPainter.width + 12, textPainter.height + 8);
    }

    return Rect.fromPoints(start, end);
  }

  /// Is the world point [p] on/inside this element? [tol] is in world units.
  bool hitTest(Offset p, double tol) {
    // If rotated, un-rotate query point around bounds center
    Offset testPoint = p;
    if (rotation != 0.0) {
      final center = bounds.center;
      final rad = -rotation;
      final dx = p.dx - center.dx;
      final dy = p.dy - center.dy;
      testPoint = Offset(
        center.dx + dx * math.cos(rad) - dy * math.sin(rad),
        center.dy + dx * math.sin(rad) + dy * math.cos(rad),
      );
    }

    final t = tol + strokeWidth / 2;
    // For 2D filled/closed shapes, keep hit-testing precise so adjacent touching shapes don't overlap
    final shapeTol = math.min(tol, 2.0) + strokeWidth / 2;
    switch (type) {
      case ShapeType.rectangle:
      case ShapeType.roundedRectangle:
      case ShapeType.stickyNote:
      case ShapeType.text:
      case ShapeType.image:
      case ShapeType.frame:
        return bounds.inflate(shapeTol).contains(testPoint);

      case ShapeType.ellipse:
        final r = bounds;
        final rx = r.width / 2 + shapeTol;
        final ry = r.height / 2 + shapeTol;
        if (rx <= 0 || ry <= 0) return false;
        final dx = (testPoint.dx - r.center.dx) / rx;
        final dy = (testPoint.dy - r.center.dy) / ry;
        return dx * dx + dy * dy <= 1;

      case ShapeType.diamond:
        final r = bounds.inflate(shapeTol);
        final c = r.center;
        final dx = (testPoint.dx - c.dx).abs() / (r.width / 2);
        final dy = (testPoint.dy - c.dy).abs() / (r.height / 2);
        return dx + dy <= 1;

      case ShapeType.triangle:
        return bounds.inflate(shapeTol).contains(testPoint);

      case ShapeType.star:
        return bounds.inflate(shapeTol).contains(testPoint);

      case ShapeType.line:
      case ShapeType.arrow:
      case ShapeType.doubleArrow:
        return ConnectorRoutingService.hitTestRoute(this, testPoint, t);

      case ShapeType.pen:
      case ShapeType.highlighter:
        final hitTol = type == ShapeType.highlighter ? t + 10.0 : t;
        if (points.length <= 1) {
          final pt = points.isNotEmpty ? points.first : start;
          return (pt - testPoint).distance <= hitTol;
        }
        for (var i = 1; i < points.length; i++) {
          if (_distToSegment(testPoint, points[i - 1], points[i]) <= hitTol) {
            return true;
          }
        }
        return false;
    }
  }

  // ── JSON Serialization ─────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'start': {'x': start.dx, 'y': start.dy},
      'end': {'x': end.dx, 'y': end.dy},
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'color': color.toARGB32(),
      'strokeWidth': strokeWidth,
      'strokeStyle': strokeStyle.name,
      'fillStyle': fillStyle.name,
      'fillColor': fillColor.toARGB32(),
      'text': text,
      'fontSize': fontSize,
      'opacity': opacity,
      'rotation': rotation,
      'startBinding': startBinding?.toMap(),
      'endBinding': endBinding?.toMap(),
      'imageBase64': imageBase64,
      'groupId': groupId,
      'drawStyle': drawStyle.name,
      'frameTitle': frameTitle,
      'frameIndex': frameIndex,
      'isLocked': isLocked,
      'isVisible': isVisible,
      'customName': customName,
      'connectorStyle': connectorStyle.name,
      'label': label,
    };
  }

  factory BoardElement.fromMap(Map<String, dynamic> map) {
    Offset parseOffset(dynamic val) {
      if (val is Map) {
        return Offset(
            (val['x'] as num).toDouble(), (val['y'] as num).toDouble());
      }
      return Offset.zero;
    }

    final pts = (map['points'] as List<dynamic>? ?? [])
        .map((p) => parseOffset(p))
        .toList();

    return BoardElement(
      id: map['id'] as String? ??
          'el_${DateTime.now().millisecondsSinceEpoch}',
      type: ShapeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ShapeType.rectangle,
      ),
      start: parseOffset(map['start']),
      end: parseOffset(map['end']),
      points: pts,
      color: Color(map['color'] as int? ?? 0xFF1F2430),
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 2.5,
      strokeStyle: StrokeStyle.values.firstWhere(
        (e) => e.name == map['strokeStyle'],
        orElse: () => StrokeStyle.solid,
      ),
      fillStyle: FillStyle.values.firstWhere(
        (e) => e.name == map['fillStyle'],
        orElse: () => FillStyle.none,
      ),
      fillColor: Color(map['fillColor'] as int? ?? 0x00000000),
      text: map['text'] as String? ?? '',
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 22.0,
      opacity: (map['opacity'] as num?)?.toDouble() ?? 1.0,
      rotation: (map['rotation'] as num?)?.toDouble() ?? 0.0,
      startBinding: map['startBinding'] != null
          ? ConnectionBinding.fromMap(
              map['startBinding'] as Map<String, dynamic>)
          : null,
      endBinding: map['endBinding'] != null
          ? ConnectionBinding.fromMap(
              map['endBinding'] as Map<String, dynamic>)
          : null,
      imageBase64: map['imageBase64'] as String?,
      groupId: map['groupId'] as String?,
      drawStyle: DrawStyle.values.firstWhere(
        (e) => e.name == map['drawStyle'],
        orElse: () => DrawStyle.clean,
      ),
      frameTitle: map['frameTitle'] as String?,
      frameIndex: map['frameIndex'] as int?,
      isLocked: map['isLocked'] as bool? ?? false,
      isVisible: map['isVisible'] as bool? ?? true,
      customName: map['customName'] as String?,
      connectorStyle: ConnectorStyle.values.firstWhere(
        (e) => e.name == map['connectorStyle'],
        orElse: () => ConnectorStyle.straight,
      ),
      label: map['label'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory BoardElement.fromJson(String source) =>
      BoardElement.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

double _distToSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return (p - a).distance;
  final t =
      (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}
