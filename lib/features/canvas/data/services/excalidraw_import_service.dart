import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';

class ExcalidrawImportService {
  /// Checks if string is a valid Excalidraw JSON file or clipboard payload
  static bool isExcalidrawJson(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        final type = decoded['type'] as String?;
        if (type == 'excalidraw' || type == 'excalidraw/clipboard') {
          return true;
        }
        if (decoded.containsKey('elements') && decoded['elements'] is List) {
          return true;
        }
      } else if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map && first.containsKey('type') && first.containsKey('id')) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Parses .excalidraw JSON format into FlutCanvas BoardElements
  static List<BoardElement> importFromExcalidraw({
    required String jsonStr,
    Offset offset = Offset.zero,
  }) {
    try {
      final decoded = jsonDecode(jsonStr);
      List<dynamic> rawElements = [];
      Map<String, dynamic> filesMap = {};

      if (decoded is Map<String, dynamic>) {
        rawElements = decoded['elements'] as List<dynamic>? ?? [];
        if (decoded['files'] is Map<String, dynamic>) {
          filesMap = decoded['files'] as Map<String, dynamic>;
        }
      } else if (decoded is List) {
        rawElements = decoded;
      }

      if (rawElements.isEmpty) return [];

      final result = <BoardElement>[];

      for (final item in rawElements) {
        if (item is! Map<String, dynamic>) continue;
        if (item['isDeleted'] == true) continue;

        final el = _parseExcalidrawElement(item, offset, filesMap);
        if (el != null) {
          result.add(el);
        }
      }

      // Sort elements by Z-index hierarchy:
      // 1. Frames (background container)
      // 2. Filled geometric shapes
      // 3. Connectors & Arrows
      // 4. Freehand drawings & Images
      // 5. Text & Sticky Notes (top layer for legibility)
      result.sort((a, b) {
        final rankA = _getZOrderRank(a.type);
        final rankB = _getZOrderRank(b.type);
        return rankA.compareTo(rankB);
      });

      return result;
    } catch (e) {
      debugPrint('Failed to parse Excalidraw: $e');
      return [];
    }
  }

  static int _getZOrderRank(ShapeType type) {
    return switch (type) {
      ShapeType.frame => 0,
      ShapeType.rectangle ||
      ShapeType.roundedRectangle ||
      ShapeType.ellipse ||
      ShapeType.diamond ||
      ShapeType.triangle ||
      ShapeType.star ||
      ShapeType.asymmetric => 10,
      ShapeType.line ||
      ShapeType.arrow ||
      ShapeType.doubleArrow => 20,
      ShapeType.pen ||
      ShapeType.highlighter ||
      ShapeType.image => 30,
      ShapeType.stickyNote ||
      ShapeType.codeBlock ||
      ShapeType.table ||
      ShapeType.text => 40,
    };
  }

  static BoardElement? _parseExcalidrawElement(
    Map<String, dynamic> map,
    Offset offset,
    Map<String, dynamic> filesMap,
  ) {
    final typeStr = (map['type'] as String? ?? 'rectangle').toLowerCase().trim();
    final id = map['id'] as String? ?? 'excal_${DateTime.now().microsecondsSinceEpoch}';

    final rawX = (map['x'] as num?)?.toDouble() ?? 0.0;
    final rawY = (map['y'] as num?)?.toDouble() ?? 0.0;
    final rawW = (map['width'] as num?)?.toDouble() ?? 100.0;
    final rawH = (map['height'] as num?)?.toDouble() ?? 100.0;
    final angle = (map['angle'] as num?)?.toDouble() ?? 0.0;
    final opacity = (((map['opacity'] as num?)?.toDouble() ?? 100.0) / 100.0).clamp(0.0, 1.0);

    // Normalize coordinates for bounding-box shapes
    final minX = rawW < 0 ? rawX + rawW : rawX;
    final minY = rawH < 0 ? rawY + rawH : rawY;
    final absW = rawW.abs();
    final absH = rawH.abs();

    final start = Offset(minX + offset.dx, minY + offset.dy);
    final end = Offset(minX + absW + offset.dx, minY + absH + offset.dy);

    // Colors & Styling
    final strokeColorHex = map['strokeColor'] as String? ?? '#000000';
    final backgroundColorHex = map['backgroundColor'] as String? ?? 'transparent';
    final strokeColor = _parseColor(strokeColorHex, defaultColor: Colors.black);
    final fillColor = _parseColor(backgroundColorHex, defaultColor: Colors.transparent);

    final strokeWidth = (map['strokeWidth'] as num?)?.toDouble() ?? 2.0;
    final strokeStyleStr = map['strokeStyle'] as String? ?? 'solid';
    final fillStyleStr = map['fillStyle'] as String? ?? 'solid';

    final strokeStyle = switch (strokeStyleStr) {
      'dashed' => StrokeStyle.dashed,
      'dotted' => StrokeStyle.dotted,
      _ => StrokeStyle.solid,
    };

    final hasFill = fillColor != Colors.transparent;
    final fillStyle = switch (fillStyleStr) {
      'solid' => hasFill ? FillStyle.solid : FillStyle.none,
      'hachure' || 'cross-hatch' => hasFill ? FillStyle.semi : FillStyle.none,
      _ => hasFill ? FillStyle.solid : FillStyle.none,
    };

    final roundness = map['roundness'] != null;
    final isLocked = map['locked'] == true;

    switch (typeStr) {
      case 'rectangle':
        return BoardElement(
          id: id,
          type: roundness ? ShapeType.roundedRectangle : ShapeType.rectangle,
          start: start,
          end: end,
          color: strokeColor,
          fillColor: fillColor,
          strokeWidth: strokeWidth,
          strokeStyle: strokeStyle,
          fillStyle: fillStyle,
          opacity: opacity,
          rotation: angle,
          isLocked: isLocked,
        );

      case 'ellipse':
        return BoardElement(
          id: id,
          type: ShapeType.ellipse,
          start: start,
          end: end,
          color: strokeColor,
          fillColor: fillColor,
          strokeWidth: strokeWidth,
          strokeStyle: strokeStyle,
          fillStyle: fillStyle,
          opacity: opacity,
          rotation: angle,
          isLocked: isLocked,
        );

      case 'diamond':
        return BoardElement(
          id: id,
          type: ShapeType.diamond,
          start: start,
          end: end,
          color: strokeColor,
          fillColor: fillColor,
          strokeWidth: strokeWidth,
          strokeStyle: strokeStyle,
          fillStyle: fillStyle,
          opacity: opacity,
          rotation: angle,
          isLocked: isLocked,
        );

      case 'line':
      case 'arrow':
        final pointsRaw = map['points'] as List<dynamic>? ?? [];
        Offset arrowStart = Offset(rawX + offset.dx, rawY + offset.dy);
        Offset arrowEnd = Offset(rawX + rawW + offset.dx, rawY + rawH + offset.dy);

        if (pointsRaw.length >= 2) {
          final firstP = pointsRaw.first;
          final lastP = pointsRaw.last;
          if (firstP is List && firstP.length >= 2) {
            arrowStart = Offset(
              rawX + (firstP[0] as num).toDouble() + offset.dx,
              rawY + (firstP[1] as num).toDouble() + offset.dy,
            );
          }
          if (lastP is List && lastP.length >= 2) {
            arrowEnd = Offset(
              rawX + (lastP[0] as num).toDouble() + offset.dx,
              rawY + (lastP[1] as num).toDouble() + offset.dy,
            );
          }
        }

        final endArrowhead = map['endArrowhead'] as String?;
        final startArrowhead = map['startArrowhead'] as String?;

        ShapeType arrowType = ShapeType.line;
        if (endArrowhead != null && startArrowhead != null) {
          arrowType = ShapeType.doubleArrow;
        } else if (endArrowhead != null || typeStr == 'arrow') {
          arrowType = ShapeType.arrow;
        }

        return BoardElement(
          id: id,
          type: arrowType,
          start: arrowStart,
          end: arrowEnd,
          color: strokeColor == Colors.transparent ? Colors.black : strokeColor,
          strokeWidth: strokeWidth,
          strokeStyle: strokeStyle,
          connectorStyle: roundness ? ConnectorStyle.curved : ConnectorStyle.straight,
          opacity: opacity,
          isLocked: isLocked,
        );

      case 'text':
        final text = (map['text'] as String? ?? map['originalText'] as String? ?? '').trim();
        final fontSize = (map['fontSize'] as num?)?.toDouble() ?? 20.0;
        return BoardElement(
          id: id,
          type: ShapeType.text,
          start: start,
          end: end,
          text: text,
          color: strokeColor == Colors.transparent ? Colors.black : strokeColor,
          fontSize: fontSize,
          opacity: opacity,
          rotation: angle,
          isLocked: isLocked,
        );

      case 'freedraw':
      case 'draw':
        final pointsRaw = map['points'] as List<dynamic>? ?? [];
        final points = <Offset>[];
        for (final p in pointsRaw) {
          if (p is List && p.length >= 2) {
            points.add(Offset(
              rawX + (p[0] as num).toDouble() + offset.dx,
              rawY + (p[1] as num).toDouble() + offset.dy,
            ));
          }
        }
        return BoardElement(
          id: id,
          type: ShapeType.pen,
          start: start,
          end: end,
          points: points,
          color: strokeColor == Colors.transparent ? Colors.black : strokeColor,
          strokeWidth: strokeWidth,
          opacity: opacity,
          isLocked: isLocked,
        );

      case 'frame':
      case 'magicframe':
        final isMagic = typeStr == 'magicframe';
        final name = (map['name'] as String? ?? (isMagic ? 'AI Frame' : 'Frame')).trim();
        final frameStroke = strokeColor == Colors.transparent
            ? (isMagic ? const Color(0xFF2F9E44) : const Color(0xFFCED4DA))
            : strokeColor;
        final frameFill = fillColor != Colors.transparent
            ? fillColor
            : (isMagic ? const Color(0x332F9E44) : Colors.transparent);
        return BoardElement(
          id: id,
          type: ShapeType.frame,
          start: start,
          end: end,
          color: frameStroke,
          fillColor: frameFill,
          frameTitle: name.isNotEmpty ? name : (isMagic ? 'AI Frame' : 'Frame'),
          isLocked: isLocked,
        );

      case 'embeddable':
      case 'iframe':
        final link = (map['link'] as String? ?? '').trim();
        return BoardElement(
          id: id,
          type: ShapeType.roundedRectangle,
          start: start,
          end: end,
          color: strokeColor == Colors.transparent ? const Color(0xFFADB5BD) : strokeColor,
          fillColor: fillColor != Colors.transparent ? fillColor : const Color(0x18ADB5BD),
          strokeWidth: strokeWidth,
          strokeStyle: StrokeStyle.dashed,
          fillStyle: FillStyle.solid,
          text: link.isNotEmpty ? link : 'Web Embed',
          opacity: opacity,
          rotation: angle,
          isLocked: isLocked,
        );

      case 'sticky':
      case 'note':
        final text = (map['text'] as String? ?? '').trim();
        return BoardElement(
          id: id,
          type: ShapeType.stickyNote,
          start: start,
          end: end,
          text: text,
          color: strokeColor,
          fillColor: fillColor != Colors.transparent ? fillColor : const Color(0xFFFFF9DB),
          opacity: opacity,
          isLocked: isLocked,
        );

      case 'image':
        final fileId = map['fileId'] as String?;
        String? base64Data;
        if (fileId != null && filesMap.containsKey(fileId)) {
          final fileObj = filesMap[fileId];
          if (fileObj is Map) {
            final dataUrl = fileObj['dataURL'] as String? ?? '';
            if (dataUrl.contains(',')) {
              base64Data = dataUrl.split(',').last;
            } else if (dataUrl.isNotEmpty) {
              base64Data = dataUrl;
            }
          }
        }
        return BoardElement(
          id: id,
          type: ShapeType.image,
          start: start,
          end: end,
          color: Colors.transparent,
          imageBase64: base64Data,
          opacity: opacity,
          rotation: angle,
          isLocked: isLocked,
        );

      default:
        return null;
    }
  }

  static Color _parseColor(String colorStr, {Color defaultColor = Colors.transparent}) {
    final str = colorStr.trim().toLowerCase();
    if (str.isEmpty || str == 'transparent' || str == 'none' || str == 'rgba(0,0,0,0)') {
      return Colors.transparent;
    }

    // 1. rgba(r, g, b, a) or rgb(r, g, b)
    if (str.startsWith('rgba(') && str.endsWith(')')) {
      final inner = str.substring(5, str.length - 1);
      final parts = inner.split(',').map((p) => p.trim()).toList();
      if (parts.length >= 4) {
        final r = int.tryParse(parts[0]) ?? 0;
        final g = int.tryParse(parts[1]) ?? 0;
        final b = int.tryParse(parts[2]) ?? 0;
        final a = double.tryParse(parts[3]) ?? 1.0;
        return Color.fromRGBO(r, g, b, a);
      }
    } else if (str.startsWith('rgb(') && str.endsWith(')')) {
      final inner = str.substring(4, str.length - 1);
      final parts = inner.split(',').map((p) => p.trim()).toList();
      if (parts.length >= 3) {
        final r = int.tryParse(parts[0]) ?? 0;
        final g = int.tryParse(parts[1]) ?? 0;
        final b = int.tryParse(parts[2]) ?? 0;
        return Color.fromARGB(255, r, g, b);
      }
    }

    // 2. Hex color parsing
    var clean = str.replaceAll('#', '').trim();
    if (clean.length == 3) {
      clean = clean.split('').map((c) => '$c$c').join();
    }
    if (clean.length == 6) {
      clean = 'FF$clean';
    } else if (clean.length == 8) {
      // Excalidraw hex can be RRGGBBAA -> convert to AARRGGBB
      final rrggbb = clean.substring(0, 6);
      final aa = clean.substring(6, 8);
      clean = '$aa$rrggbb';
    }

    final val = int.tryParse(clean, radix: 16);
    return val != null ? Color(val) : defaultColor;
  }
}
