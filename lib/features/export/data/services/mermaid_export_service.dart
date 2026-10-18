import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/tech_icons.dart';

enum MermaidDirection {
  auto,
  td, // Top to Down
  lr, // Left to Right
  bt, // Bottom to Top
  rl, // Right to Left
}

/// Service that serializes canvas BoardElements into Mermaid flowchart syntax.
class MermaidExportService {
  /// Converts a collection of board elements into a clean Mermaid flowchart script.
  static String exportToMermaid({
    required List<BoardElement> elements,
    MermaidDirection direction = MermaidDirection.auto,
    bool includeStyles = true,
  }) {
    final visibleElements = elements.where((e) => e.isVisible).toList();
    if (visibleElements.isEmpty) {
      return 'flowchart TD\n  empty["Empty Canvas"]\n';
    }

    final buffer = StringBuffer();

    // 1. Determine direction
    final effectiveDir = _resolveDirection(visibleElements, direction);
    buffer.writeln('flowchart $effectiveDir');

    // 2. Separate into frames, nodes, and connectors
    final frames = visibleElements.where((e) => e.type == ShapeType.frame).toList();
    final connectors = visibleElements.where((e) =>
        e.type == ShapeType.arrow ||
        e.type == ShapeType.line ||
        e.type == ShapeType.doubleArrow).toList();
    final nodes = visibleElements.where((e) =>
        e.type != ShapeType.frame &&
        e.type != ShapeType.arrow &&
        e.type != ShapeType.line &&
        e.type != ShapeType.doubleArrow).toList();

    // Map each element ID to a safe Mermaid node identifier
    final idMap = <String, String>{};
    var nodeCounter = 1;

    for (final node in nodes) {
      final safeId = _generateSafeId(node, nodeCounter++);
      idMap[node.id] = safeId;
    }

    // Track which nodes are placed inside subgraphs
    final placedNodeIds = <String>{};

    // 3. Render Frames as Subgraphs
    var subgraphCounter = 1;
    for (final frame in frames) {
      final frameBounds = frame.bounds;
      final containedNodes = nodes.where((n) {
        // Element is considered inside frame if its center or bounds intersect frame
        return frameBounds.contains(n.bounds.center) ||
            frameBounds.inflate(10).contains(n.bounds.topLeft);
      }).toList();

      if (containedNodes.isEmpty) continue;

      final frameTitle = (frame.frameTitle?.trim().isNotEmpty ?? false)
          ? frame.frameTitle!.trim()
          : (frame.text.trim().isNotEmpty ? frame.text.trim() : 'Frame $subgraphCounter');

      final subgraphId = 'subgraph_${subgraphCounter++}';
      buffer.writeln('  subgraph $subgraphId ["${_escape(frameTitle)}"]');

      for (final node in containedNodes) {
        final nodeId = idMap[node.id]!;
        placedNodeIds.add(node.id);
        buffer.writeln('    ${_formatNode(nodeId, node)}');
      }

      buffer.writeln('  end');
      buffer.writeln();
    }

    // 4. Render top-level nodes (not inside any frame)
    for (final node in nodes) {
      if (placedNodeIds.contains(node.id)) continue;
      final nodeId = idMap[node.id]!;
      buffer.writeln('  ${_formatNode(nodeId, node)}');
    }

    if (connectors.isNotEmpty) {
      buffer.writeln();
    }

    // 5. Render Connectors / Edges
    for (final conn in connectors) {
      String? startId = conn.startBinding?.elementId;
      String? endId = conn.endBinding?.elementId;

      // Fallback: If no explicit binding, hit-test nodes closest to start/end point
      startId ??= _findClosestNode(conn.start, nodes);
      endId ??= _findClosestNode(conn.end, nodes);

      if (startId == null || endId == null || startId == endId) {
        continue;
      }

      final startMermaidId = idMap[startId];
      final endMermaidId = idMap[endId];

      if (startMermaidId == null || endMermaidId == null) {
        continue;
      }

      final edgeSyntax = _formatEdge(conn);
      buffer.writeln('  $startMermaidId $edgeSyntax $endMermaidId');
    }

    // 6. Optional Styles
    if (includeStyles) {
      final styleBuffer = StringBuffer();
      for (final node in nodes) {
        final nodeId = idMap[node.id]!;
        final style = _generateStyle(nodeId, node);
        if (style != null) {
          styleBuffer.writeln('  $style');
        }
      }
      if (styleBuffer.isNotEmpty) {
        buffer.writeln();
        buffer.write(styleBuffer.toString());
      }
    }

    return buffer.toString();
  }

  static String _resolveDirection(List<BoardElement> elements, MermaidDirection dir) {
    if (dir != MermaidDirection.auto) {
      return dir.name.toUpperCase();
    }

    // Calculate aspect ratio of bounding box
    Rect bounds = elements.first.bounds;
    for (var i = 1; i < elements.length; i++) {
      bounds = bounds.expandToInclude(elements[i].bounds);
    }

    if (bounds.width > bounds.height * 1.3) {
      return 'LR';
    }
    return 'TD';
  }

  static String _generateSafeId(BoardElement node, int index) {
    if (node.customName != null &&
        node.customName!.trim().isNotEmpty &&
        RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(node.customName!.trim())) {
      return node.customName!.trim();
    }
    final prefix = switch (node.type) {
      ShapeType.diamond => 'dec',
      ShapeType.stickyNote => 'note',
      ShapeType.ellipse => 'circ',
      ShapeType.table => 'tbl',
      ShapeType.codeBlock => 'code',
      ShapeType.icon => 'icon',
      _ => 'node',
    };
    return '${prefix}_$index';
  }

  static String _formatNode(String id, BoardElement node) {
    var rawText = node.text.trim();
    if (rawText.isEmpty) {
      if (node.customName != null && node.customName!.trim().isNotEmpty) {
        rawText = node.customName!.trim();
      } else if (node.type == ShapeType.stickyNote) {
        rawText = 'Sticky Note';
      } else if (node.type == ShapeType.icon) {
        final def = node.iconName != null ? TechIconRegistry.findById(node.iconName!) : null;
        rawText = def?.defaultLabel ?? 'Architecture Node';
      } else {
        rawText = _capitalize(node.type.name);
      }
    }

    final text = _escape(rawText);

    return switch (node.type) {
      ShapeType.rectangle => '$id["$text"]',
      ShapeType.roundedRectangle => '$id("$text")',
      ShapeType.ellipse => '$id(["$text"])',
      ShapeType.diamond => '$id{"$text"}',
      ShapeType.asymmetric => '$id>"$text"]',
      ShapeType.triangle => '$id[/"$text"\\]',
      ShapeType.star => '$id{{"$text"}}',
      ShapeType.stickyNote => '$id["📝 $text"]',
      ShapeType.codeBlock => '$id["`$text`"]',
      ShapeType.table => '$id["📊 $text"]',
      ShapeType.icon => () {
        final def = node.iconName != null ? TechIconRegistry.findById(node.iconName!) : null;
        final emoji = def?.emoji ?? '🔷';
        return '$id["$emoji $text"]';
      }(),
      _ => '$id["$text"]',
    };
  }

  static String _formatEdge(BoardElement conn) {
    final rawLabel = (conn.label != null && conn.label!.trim().isNotEmpty)
        ? conn.label!.trim()
        : conn.text.trim();
    final hasLabel = rawLabel.isNotEmpty;
    final escapedLabel = hasLabel ? _escape(rawLabel) : null;

    final isDashed = conn.strokeStyle == StrokeStyle.dashed ||
        conn.strokeStyle == StrokeStyle.dotted;
    final isThick = conn.strokeWidth >= 3.5;

    if (conn.type == ShapeType.doubleArrow) {
      if (hasLabel) {
        if (isDashed) return '<-. "$escapedLabel" .->';
        if (isThick) return '<== "$escapedLabel" ==>';
        return '<-- "$escapedLabel" -->';
      } else {
        if (isDashed) return '<-.->';
        if (isThick) return '<==>';
        return '<-->';
      }
    } else if (conn.type == ShapeType.line) {
      if (hasLabel) {
        if (isDashed) return '-.- |"$escapedLabel"|';
        if (isThick) return '=== |"$escapedLabel"|';
        return '--- |"$escapedLabel"|';
      } else {
        if (isDashed) return '-.-';
        if (isThick) return '===';
        return '---';
      }
    } else {
      // Default: arrow
      if (hasLabel) {
        if (isDashed) return '-. "$escapedLabel" .->';
        if (isThick) return '== "$escapedLabel" ==>';
        return '-->|"$escapedLabel"|';
      } else {
        if (isDashed) return '-.->';
        if (isThick) return '==>';
        return '-->';
      }
    }
  }

  static String? _generateStyle(String nodeId, BoardElement node) {
    final styles = <String>[];

    // Background fill
    if (node.fillStyle != FillStyle.none && node.fillColor.a > 0) {
      styles.add('fill:${_colorToHex(node.fillColor)}');
    }

    // Stroke
    if (node.color.a > 0) {
      styles.add('stroke:${_colorToHex(node.color)}');
      styles.add('stroke-width:${node.strokeWidth.round().clamp(1, 6)}px');
    }

    // Text color
    if (styles.isNotEmpty) {
      if (node.fillStyle == FillStyle.solid && node.fillColor.computeLuminance() < 0.3) {
        styles.add('color:#FFFFFF');
      }
      return 'style $nodeId ${styles.join(',')}';
    }

    return null;
  }

  static String? _findClosestNode(Offset point, List<BoardElement> nodes, {double maxDist = 60.0}) {
    BoardElement? closest;
    var minDist = double.infinity;

    for (final node in nodes) {
      final bounds = node.bounds;
      // Distance to bounds rect
      final dx = math.max(0.0, math.max(bounds.left - point.dx, point.dx - bounds.right));
      final dy = math.max(0.0, math.max(bounds.top - point.dy, point.dy - bounds.bottom));
      final dist = math.sqrt(dx * dx + dy * dy);

      if (dist < minDist && dist <= maxDist) {
        minDist = dist;
        closest = node;
      }
    }

    return closest?.id;
  }

  static String _escape(String raw) {
    return raw
        .replaceAll('"', "'")
        .replaceAll('\n', '<br/>')
        .replaceAll('\r', '');
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String _colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }
}
