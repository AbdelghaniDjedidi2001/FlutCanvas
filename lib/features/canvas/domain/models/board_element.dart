import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'connection_binding.dart';
import 'connector_style.dart';
import 'shape_type.dart';
import 'stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/data/services/connector_routing_service.dart';

part 'board_element.freezed.dart';
part 'board_element.g.dart';

class OffsetConverter implements JsonConverter<Offset, Map<String, dynamic>> {
  const OffsetConverter();
  @override
  Offset fromJson(Map<String, dynamic> json) =>
      Offset((json['x'] as num).toDouble(), (json['y'] as num).toDouble());
  @override
  Map<String, dynamic> toJson(Offset o) => {'x': o.dx, 'y': o.dy};
}

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();
  @override
  Color fromJson(int json) => Color(json);
  @override
  int toJson(Color c) => c.toARGB32();
}

class OffsetListConverter
    implements JsonConverter<List<Offset>, List<dynamic>> {
  const OffsetListConverter();
  @override
  List<Offset> fromJson(List<dynamic> json) => json
      .map((e) =>
          Offset((e['x'] as num).toDouble(), (e['y'] as num).toDouble()))
      .toList();
  @override
  List<dynamic> toJson(List<Offset> list) =>
      list.map((o) => {'x': o.dx, 'y': o.dy}).toList();
}

class TableDataConverter
    implements JsonConverter<List<List<String>>?, List<dynamic>?> {
  const TableDataConverter();
  @override
  List<List<String>>? fromJson(List<dynamic>? json) => json
      ?.map((row) =>
          (row as List<dynamic>).map((cell) => cell.toString()).toList())
      .toList();
  @override
  List<dynamic>? toJson(List<List<String>>? data) => data;
}

@freezed
abstract class BoardElement with _$BoardElement {
  @OffsetConverter()
  @ColorConverter()
  @OffsetListConverter()
  @TableDataConverter()
  const factory BoardElement({
    required String id,
    required ShapeType type,
    @OffsetConverter() required Offset start,
    @OffsetConverter() required Offset end,
    @OffsetListConverter() @Default([]) List<Offset> points,
    @ColorConverter() @Default(Color(0xFF1F2430)) Color color,
    @Default(2.5) double strokeWidth,
    @Default(StrokeStyle.solid) StrokeStyle strokeStyle,
    @Default(FillStyle.none) FillStyle fillStyle,
    @ColorConverter() @Default(Color(0x00000000)) Color fillColor,
    @Default('') String text,
    @Default(22.0) double fontSize,
    @Default(1.0) double opacity,
    @Default(0.0) double rotation,
    ConnectionBinding? startBinding,
    ConnectionBinding? endBinding,
    String? imageBase64,
    String? groupId,
    @Default(DrawStyle.clean) DrawStyle drawStyle,
    String? frameTitle,
    int? frameIndex,
    @Default(false) bool isLocked,
    @Default(true) bool isVisible,
    String? customName,
    @Default(ConnectorStyle.straight) ConnectorStyle connectorStyle,
    String? label,
    String? codeLanguage,
    @Default(true) bool showLineNumbers,
    @TableDataConverter() List<List<String>>? tableData,
    @Default(true) bool tableHasHeader,
  }) = _BoardElement;

  const BoardElement._();

  factory BoardElement.fromJson(Map<String, dynamic> json) =>
      _$BoardElementFromJson(json);

  List<List<String>> get safeTableData {
    if (tableData != null && tableData!.isNotEmpty) return tableData!;
    return const [
      ['Column 1', 'Column 2', 'Column 3'],
      ['Row 1', 'Data A', 'Data B'],
      ['Row 2', 'Data C', 'Data D'],
    ];
  }

  int get tableRowCount => safeTableData.length;
  int get tableColCount =>
      safeTableData.isNotEmpty ? safeTableData.first.length : 1;

  Rect getCellRect(int row, int col) {
    final b = bounds;
    final rows = math.max(1, tableRowCount);
    final cols = math.max(1, tableColCount);
    final cellW = b.width / cols;
    final cellH = b.height / rows;
    return Rect.fromLTWH(
      b.left + col * cellW,
      b.top + row * cellH,
      cellW,
      cellH,
    );
  }

  (int, int)? hitTestCell(Offset worldPos) {
    if (type != ShapeType.table) return null;
    final b = bounds;
    if (!b.contains(worldPos)) return null;
    final rows = math.max(1, tableRowCount);
    final cols = math.max(1, tableColCount);
    final cellW = b.width / cols;
    final cellH = b.height / rows;
    final col = ((worldPos.dx - b.left) / cellW).floor().clamp(0, cols - 1);
    final row = ((worldPos.dy - b.top) / cellH).floor().clamp(0, rows - 1);
    return (row, col);
  }

  BoardElement updateTableCell(int row, int col, String value) {
    final current = [for (final r in safeTableData) [...r]];
    if (row >= 0 &&
        row < current.length &&
        col >= 0 &&
        col < current[row].length) {
      current[row][col] = value;
    }
    return copyWith(tableData: current);
  }

  BoardElement addTableRow() {
    final current = [for (final r in safeTableData) [...r]];
    final cols = tableColCount;
    final newRow = List.generate(
        cols, (i) => 'Cell ${current.length + 1}-${i + 1}');
    current.add(newRow);
    final rowHeight = bounds.height / math.max(1, current.length - 1);
    return copyWith(
      tableData: current,
      end: Offset(end.dx, end.dy + rowHeight),
    );
  }

  BoardElement removeTableRow() {
    final current = [for (final r in safeTableData) [...r]];
    if (current.length <= 1) return this;
    final rowHeight = bounds.height / current.length;
    current.removeLast();
    return copyWith(
      tableData: current,
      end: Offset(end.dx, end.dy - rowHeight),
    );
  }

  BoardElement addTableColumn() {
    final current = [for (final r in safeTableData) [...r]];
    for (var r = 0; r < current.length; r++) {
      final lbl = (r == 0 && tableHasHeader)
          ? 'Header ${current[r].length + 1}'
          : 'Data';
      current[r].add(lbl);
    }
    final colWidth = bounds.width / math.max(1, tableColCount);
    return copyWith(
      tableData: current,
      end: Offset(end.dx + colWidth, end.dy),
    );
  }

  BoardElement removeTableColumn() {
    final current = [for (final r in safeTableData) [...r]];
    if (tableColCount <= 1) return this;
    final colWidth = bounds.width / tableColCount;
    for (var r = 0; r < current.length; r++) {
      if (current[r].isNotEmpty) current[r].removeLast();
    }
    return copyWith(
      tableData: current,
      end: Offset(end.dx - colWidth, end.dy),
    );
  }

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
      ShapeType.codeBlock => 'Code (${codeLanguage ?? "Dart"})',
      ShapeType.table => 'Table (${tableRowCount}x$tableColCount)',
    };
  }

  BoardElement translated(Offset d) => copyWith(
        start: start + d,
        end: end + d,
        points: [for (final p in points) p + d],
      );

  BoardElement rotated(double deltaAngle) => copyWith(
        rotation: (rotation + deltaAngle) % (2 * math.pi),
      );

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
      final sample = text.isEmpty ? 'Type text...' : text;
      final lines = sample.split('\n');
      var maxLineLen = 0;
      for (final l in lines) {
        if (l.length > maxLineLen) maxLineLen = l.length;
      }
      final estimatedWidth = math.max(60.0, maxLineLen * (fontSize * 0.58) + 16.0);
      final estimatedHeight = math.max(30.0, lines.length * (fontSize * 1.3) + 8.0);
      return Rect.fromLTWH(start.dx, start.dy, estimatedWidth, estimatedHeight);
    }

    return Rect.fromPoints(start, end);
  }

  bool hitTest(Offset p, double tol) {
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
    final shapeTol = math.min(tol, 2.0) + strokeWidth / 2;
    switch (type) {
      case ShapeType.rectangle:
      case ShapeType.roundedRectangle:
      case ShapeType.stickyNote:
      case ShapeType.codeBlock:
      case ShapeType.table:
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
          if (distToSegment(testPoint, points[i - 1], points[i]) <= hitTol) {
            return true;
          }
        }
        return false;
    }
  }

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
      'codeLanguage': codeLanguage,
      'showLineNumbers': showLineNumbers,
      'tableData': tableData,
      'tableHasHeader': tableHasHeader,
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

    List<List<String>>? parsedTableData;
    if (map['tableData'] is List) {
      parsedTableData = (map['tableData'] as List<dynamic>)
          .map((row) =>
              (row as List<dynamic>).map((cell) => cell.toString()).toList())
          .toList();
    }

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
      codeLanguage: map['codeLanguage'] as String?,
      showLineNumbers: map['showLineNumbers'] as bool? ?? true,
      tableData: parsedTableData,
      tableHasHeader: map['tableHasHeader'] as bool? ?? true,
    );
  }

  String toJsonString() => jsonEncode(toMap());
  static BoardElement fromJsonString(String source) =>
      BoardElement.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

double distToSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return (p - a).distance;
  final t =
      (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}
