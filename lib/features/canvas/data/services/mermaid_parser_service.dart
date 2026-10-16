import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connection_binding.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';

class _MermaidStyle {
  final Color? fillColor;
  final Color? strokeColor;
  final double? strokeWidth;
  final Color? textColor;

  const _MermaidStyle({
    this.fillColor,
    this.strokeColor,
    this.strokeWidth,
    this.textColor,
  });
}

class _MermaidNode {
  final String id;
  String text;
  ShapeType shapeType;
  int rank = 0;
  int orderInRank = 0;
  String? subgraphId;
  String? className;
  _MermaidStyle? directStyle;
  double width = 160.0;
  double height = 64.0;
  Offset position = Offset.zero;

  _MermaidNode({
    required this.id,
    required this.text,
    this.shapeType = ShapeType.rectangle,
    this.subgraphId,
    this.className,
    this.directStyle,
  });
}

class _MermaidEdge {
  final String fromId;
  final String toId;
  final String? label;
  final ConnectorStyle connectorStyle;
  final StrokeStyle strokeStyle;
  final double strokeWidth;
  final bool hasStartArrow;
  final bool hasEndArrow;

  _MermaidEdge({
    required this.fromId,
    required this.toId,
    this.label,
    this.connectorStyle = ConnectorStyle.orthogonal,
    this.strokeStyle = StrokeStyle.solid,
    this.strokeWidth = 2.0,
    this.hasStartArrow = false,
    this.hasEndArrow = true,
  });
}

class _MermaidSubgraph {
  final String id;
  final String title;
  final List<String> nodeIds = [];

  _MermaidSubgraph({required this.id, required this.title});
}

class MermaidParserService {
  /// Checks if the input text matches Mermaid syntax
  static bool isMermaidSyntax(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final firstLine = trimmed.split('\n').first.trim().toLowerCase();
    return firstLine.startsWith('graph') ||
        firstLine.startsWith('flowchart') ||
        firstLine.startsWith('sequencediagram') ||
        firstLine.startsWith('classdiagram') ||
        firstLine.startsWith('erdiagram') ||
        firstLine.startsWith('subgraph') ||
        firstLine.startsWith('classdef') ||
        (trimmed.contains('-->') || trimmed.contains('---') || trimmed.contains('==>'));
  }

  /// Parses Mermaid flowchart code and generates positioned BoardElements
  static List<BoardElement> parseToElements({
    required String script,
    Offset origin = const Offset(100, 100),
    Color defaultColor = const Color(0xFF1971C2),
  }) {
    final rawLines = script.split('\n');
    String direction = 'TD'; // default Top-Down
    final nodes = <String, _MermaidNode>{};
    final edges = <_MermaidEdge>[];
    final subgraphs = <String, _MermaidSubgraph>{};
    final classStyles = <String, _MermaidStyle>{};
    String? currentSubgraphId;

    for (var rawLine in rawLines) {
      // 1. Remove comments
      var line = rawLine;
      if (line.contains('%%')) {
        line = line.split('%%').first;
      }
      line = line.trim();
      if (line.isEmpty) continue;

      // 2. Header: graph TD / graph TB / flowchart LR
      final headerMatch = RegExp(r'^(?:graph|flowchart)\s+([A-Za-z]+)', caseSensitive: false)
          .firstMatch(line);
      if (headerMatch != null) {
        direction = headerMatch.group(1)!.toUpperCase();
        if (direction == 'TB') direction = 'TD';
        continue;
      }

      // 3. classDef definition: classDef green fill:#9f6,stroke:#333,stroke-width:2px;
      final classDefMatch = RegExp(
        r'^classDef\s+([A-Za-z0-9_\-]+)\s+(.+?);?$',
        caseSensitive: false,
      ).firstMatch(line);
      if (classDefMatch != null) {
        final className = classDefMatch.group(1)!.trim();
        final stylesStr = classDefMatch.group(2)!.trim();
        classStyles[className] = _parseStyleString(stylesStr);
        continue;
      }

      // 4. class assignment: class sq,e green;
      final classAssignMatch = RegExp(
        r'^class\s+([A-Za-z0-9_\-,\s]+?)\s+([A-Za-z0-9_\-]+);?$',
        caseSensitive: false,
      ).firstMatch(line);
      if (classAssignMatch != null) {
        final nodeIdsStr = classAssignMatch.group(1)!.trim();
        final className = classAssignMatch.group(2)!.trim();
        final ids = nodeIdsStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
        for (final id in ids) {
          final node = _getOrCreateNode(id, nodes, currentSubgraphId, subgraphs);
          node.className = className;
        }
        continue;
      }

      // 5. style directive: style sq fill:#9f6,stroke:#333;
      final styleMatch = RegExp(
        r'^style\s+([A-Za-z0-9_\-]+)\s+(.+?);?$',
        caseSensitive: false,
      ).firstMatch(line);
      if (styleMatch != null) {
        final nodeId = styleMatch.group(1)!.trim();
        final stylesStr = styleMatch.group(2)!.trim();
        final node = _getOrCreateNode(nodeId, nodes, currentSubgraphId, subgraphs);
        node.directStyle = _parseStyleString(stylesStr);
        continue;
      }

      // 6. Subgraph start: subgraph Title or subgraph id [Title]
      final subgraphStartMatch = RegExp(
        r'^subgraph\s+(?:([A-Za-z0-9_\-]+)\s*(?:\[(.*?)\])?|(.*?))$',
        caseSensitive: false,
      ).firstMatch(line);
      if (subgraphStartMatch != null && !line.startsWith('end')) {
        final idOrTitle = (subgraphStartMatch.group(1) ??
                subgraphStartMatch.group(3) ??
                'subgraph_${subgraphs.length + 1}')
            .trim();
        final title = subgraphStartMatch.group(2) ?? idOrTitle;
        final subId = 'sub_${subgraphs.length + 1}';
        subgraphs[subId] = _MermaidSubgraph(id: subId, title: title);
        currentSubgraphId = subId;
        continue;
      }

      // 7. Subgraph end
      if (line.toLowerCase() == 'end' || line.toLowerCase() == 'end;') {
        currentSubgraphId = null;
        continue;
      }

      // 8. Strip trailing semicolon if present
      if (line.endsWith(';')) {
        line = line.substring(0, line.length - 1).trim();
      }
      if (line.isEmpty) continue;

      // 9. Parse edge(s) or single node on this line
      _parseLine(
        line: line,
        nodes: nodes,
        edges: edges,
        currentSubgraphId: currentSubgraphId,
        subgraphs: subgraphs,
      );
    }

    if (nodes.isEmpty) return [];

    // Apply class styles to nodes
    for (final node in nodes.values) {
      if (node.className != null && classStyles.containsKey(node.className)) {
        node.directStyle = classStyles[node.className];
      }
    }

    // Layout graph using Hierarchical Layered Digraph Algorithm with Component Separation
    return _layoutElements(
      nodes: nodes.values.toList(),
      edges: edges,
      subgraphs: subgraphs.values.toList(),
      direction: direction,
      origin: origin,
      defaultColor: defaultColor,
    );
  }

  static _MermaidStyle _parseStyleString(String raw) {
    Color? fill;
    Color? stroke;
    double? strokeWidth;
    Color? text;

    // Split by commas or semicolons
    final parts = raw.split(RegExp(r'[,;]'));
    for (var part in parts) {
      part = part.trim();
      if (part.isEmpty) continue;
      final kv = part.split(':');
      if (kv.length < 2) continue;
      final key = kv[0].trim().toLowerCase();
      final val = kv.sublist(1).join(':').trim();

      if (key == 'fill') {
        fill = _parseCssColor(val);
      } else if (key == 'stroke') {
        stroke = _parseCssColor(val);
      } else if (key == 'stroke-width') {
        final numStr = val.replaceAll(RegExp(r'[^\d.]'), '');
        final d = double.tryParse(numStr);
        if (d != null) strokeWidth = d;
      } else if (key == 'color') {
        text = _parseCssColor(val);
      }
    }

    return _MermaidStyle(
      fillColor: fill,
      strokeColor: stroke,
      strokeWidth: strokeWidth,
      textColor: text,
    );
  }

  static Color? _parseCssColor(String raw) {
    var str = raw.trim().toLowerCase();
    if (str.isEmpty) return null;

    if (str.startsWith('#')) {
      var hex = str.substring(1);
      if (hex.length == 3) {
        hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
      } else if (hex.length == 4) {
        hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}${hex[3]}${hex[3]}';
      }
      if (hex.length == 6) {
        final val = int.tryParse(hex, radix: 16);
        if (val != null) return Color(0xFF000000 | val);
      } else if (hex.length == 8) {
        final val = int.tryParse(hex, radix: 16);
        if (val != null) return Color(val);
      }
      return null;
    }

    const namedColors = <String, Color>{
      'red': Color(0xFFE03131),
      'pink': Color(0xFFE64980),
      'grape': Color(0xFFBE4BDB),
      'violet': Color(0xFF7950F2),
      'indigo': Color(0xFF4C6EF5),
      'blue': Color(0xFF1971C2),
      'cyan': Color(0xFF1098AD),
      'teal': Color(0xFF0CA678),
      'green': Color(0xFF2F9E44),
      'lime': Color(0xFF74B816),
      'yellow': Color(0xFFF59F00),
      'orange': Color(0xFFF76707),
      'black': Color(0xFF000000),
      'white': Color(0xFFFFFFFF),
      'gray': Color(0xFF868E96),
      'grey': Color(0xFF868E96),
      'transparent': Color(0x00000000),
    };
    if (namedColors.containsKey(str)) {
      return namedColors[str];
    }

    final rgbMatch = RegExp(r'rgba?\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)').firstMatch(str);
    if (rgbMatch != null) {
      final r = int.tryParse(rgbMatch.group(1)!) ?? 0;
      final g = int.tryParse(rgbMatch.group(2)!) ?? 0;
      final b = int.tryParse(rgbMatch.group(3)!) ?? 0;
      return Color.fromARGB(255, r, g, b);
    }

    return null;
  }

  static void _parseLine({
    required String line,
    required Map<String, _MermaidNode> nodes,
    required List<_MermaidEdge> edges,
    required String? currentSubgraphId,
    required Map<String, _MermaidSubgraph> subgraphs,
  }) {
    // Arrow regex to match any connector in between nodes:
    // Solid: -->, --->, -- text -->, -->|text|
    // Thick: ==>, ===>, == text ==>, ==>|text|
    // Dashed: -.->, -. text .->, -.->|text|
    // Plain line: ---, -- text ---, ---|text|, ===, -.-
    // Bidirectional: <--> , <==>
    final arrowRegex = RegExp(
      r'(<==>|<-->|'
      r'==\s*.*?==>|--\s*.*?-->|-\.\s*.*?\.-?>|'
      r'==\s*.*?===|--\s*.*?---|-\.\s*.*?\.-|'
      r'==>\|.*?\||-->\|.*?\||-\.->\|.*?\||'
      r'==>|-->|-\.->|===|---|'
      r'-\.-|<--|<==)',
    );

    final matches = arrowRegex.allMatches(line).toList();
    if (matches.isNotEmpty) {
      // Line contains one or more edge connectors (e.g. A --> B or A --> B --> C)
      var lastEnd = 0;
      _MermaidNode? previousNode;

      for (var i = 0; i < matches.length; i++) {
        final match = matches[i];
        final nodePartBefore = line.substring(lastEnd, match.start).trim();
        final arrowRaw = match.group(0)!.trim();
        lastEnd = match.end;

        final fromNode = previousNode ??
            _getOrCreateNode(nodePartBefore, nodes, currentSubgraphId, subgraphs);

        String nodePartAfter;
        if (i + 1 < matches.length) {
          nodePartAfter = line.substring(lastEnd, matches[i + 1].start).trim();
        } else {
          nodePartAfter = line.substring(lastEnd).trim();
        }

        final toNode = _getOrCreateNode(nodePartAfter, nodes, currentSubgraphId, subgraphs);
        previousNode = toNode;

        // Parse arrow properties
        String? label;
        var connectorStyle = ConnectorStyle.orthogonal;
        var strokeStyle = StrokeStyle.solid;
        var strokeWidth = 2.0;
        var hasStartArrow = false;
        var hasEndArrow = true;

        if (arrowRaw.contains('|')) {
          final parts = arrowRaw.split('|');
          if (parts.length >= 2) label = parts[1].trim();
        } else if (arrowRaw.startsWith('-- ') ||
            arrowRaw.startsWith('-. ') ||
            arrowRaw.startsWith('== ') ||
            arrowRaw.startsWith('--') ||
            arrowRaw.startsWith('==')) {
          final textMatch = RegExp(r'(?:--|-\.|==)\s*(.*?)\s*(?:-->|\.->|==>|---|===|\.-)').firstMatch(arrowRaw);
          if (textMatch != null && textMatch.group(1)!.trim().isNotEmpty) {
            label = textMatch.group(1)!.trim();
          }
        }

        if (label != null) {
          label = label.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n').trim();
        }

        if (arrowRaw.contains('-.->') || arrowRaw.contains('-.') || arrowRaw.contains('.-')) {
          strokeStyle = StrokeStyle.dashed;
          connectorStyle = ConnectorStyle.curved;
        } else if (arrowRaw.contains('==>') || arrowRaw.contains('==')) {
          connectorStyle = ConnectorStyle.orthogonal;
          strokeWidth = 3.5;
        } else if (arrowRaw.contains('---') || arrowRaw.contains('===') || arrowRaw == '-.-') {
          hasEndArrow = false;
          connectorStyle = ConnectorStyle.straight;
        }

        if (arrowRaw.contains('<-->') || arrowRaw.contains('<==>')) {
          hasStartArrow = true;
          hasEndArrow = true;
        }

        edges.add(_MermaidEdge(
          fromId: fromNode.id,
          toId: toNode.id,
          label: label,
          connectorStyle: connectorStyle,
          strokeStyle: strokeStyle,
          strokeWidth: strokeWidth,
          hasStartArrow: hasStartArrow,
          hasEndArrow: hasEndArrow,
        ));
      }
    } else {
      // Single node declaration (e.g. `nodeA[My Node]`)
      _getOrCreateNode(line, nodes, currentSubgraphId, subgraphs);
    }
  }

  static _MermaidNode _getOrCreateNode(
    String raw,
    Map<String, _MermaidNode> nodes,
    String? currentSubgraphId,
    Map<String, _MermaidSubgraph> subgraphs,
  ) {
    var str = raw.trim();
    if (str.endsWith(';')) str = str.substring(0, str.length - 1).trim();

    // Check for :::className suffix
    String? inlineClass;
    final classSuffixMatch = RegExp(r':::([A-Za-z0-9_\-]+)$').firstMatch(str);
    if (classSuffixMatch != null) {
      inlineClass = classSuffixMatch.group(1);
      str = str.substring(0, classSuffixMatch.start).trim();
    }

    // Pattern to capture:
    // 1. Node ID
    // 2. Shape enclosure
    // Shapes supported:
    // Asymmetric:   id>Text]
    // Circle:       id((Text)) or id(((Text)))
    // Database:     id[(Text)]
    // Subroutine:   id[[Text]]
    // Stadium:      id([Text])
    // Diamond:      id{Text} or id{{Text}}
    // Rounded:      id(Text)
    // Rectangle:    id[Text]
    // Raw:          id

    final idMatch = RegExp(r'^([^\s\[\(\{\>\<\;]+)(.*)$', dotAll: true).firstMatch(str);
    if (idMatch != null) {
      final id = idMatch.group(1)!.trim();
      var rest = idMatch.group(2)!.trim();

      var text = id;
      var shape = ShapeType.rectangle;
      var hasExplicitShape = false;

      if (rest.isNotEmpty) {
        if (rest.startsWith('>') && rest.endsWith(']')) {
          text = rest.substring(1, rest.length - 1).trim();
          shape = ShapeType.asymmetric;
          hasExplicitShape = true;
        } else if ((rest.startsWith('(((') && rest.endsWith(')))')) ||
            (rest.startsWith('((') && rest.endsWith('))'))) {
          final prefixLen = rest.startsWith('(((') ? 3 : 2;
          text = rest.substring(prefixLen, rest.length - prefixLen).trim();
          shape = ShapeType.ellipse;
          hasExplicitShape = true;
        } else if (rest.startsWith('[(') && rest.endsWith(')]')) {
          text = rest.substring(2, rest.length - 2).trim();
          shape = ShapeType.roundedRectangle;
          hasExplicitShape = true;
        } else if (rest.startsWith('[[') && rest.endsWith(']]')) {
          text = rest.substring(2, rest.length - 2).trim();
          shape = ShapeType.rectangle;
          hasExplicitShape = true;
        } else if (rest.startsWith('([') && rest.endsWith('])')) {
          text = rest.substring(2, rest.length - 2).trim();
          shape = ShapeType.roundedRectangle;
          hasExplicitShape = true;
        } else if ((rest.startsWith('{{') && rest.endsWith('}}')) ||
            (rest.startsWith('{') && rest.endsWith('}'))) {
          final prefixLen = rest.startsWith('{{') ? 2 : 1;
          text = rest.substring(prefixLen, rest.length - prefixLen).trim();
          shape = ShapeType.diamond;
          hasExplicitShape = true;
        } else if (rest.startsWith('(') && rest.endsWith(')')) {
          text = rest.substring(1, rest.length - 1).trim();
          shape = ShapeType.roundedRectangle;
          hasExplicitShape = true;
        } else if (rest.startsWith('[') && rest.endsWith(']')) {
          text = rest.substring(1, rest.length - 1).trim();
          shape = ShapeType.rectangle;
          hasExplicitShape = true;
        }
      }

      // Convert <br>, <br/>, <br /> to \n
      text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n').trim();

      if (nodes.containsKey(id)) {
        final existing = nodes[id]!;
        if (text != id && (existing.text == id || existing.text.isEmpty)) {
          existing.text = text;
        }
        if (hasExplicitShape) {
          existing.shapeType = shape;
        }
        if (inlineClass != null) {
          existing.className = inlineClass;
        }
        if (currentSubgraphId != null && existing.subgraphId == null) {
          existing.subgraphId = currentSubgraphId;
          subgraphs[currentSubgraphId]?.nodeIds.add(id);
        }
        return existing;
      }

      final node = _MermaidNode(
        id: id,
        text: text,
        shapeType: shape,
        subgraphId: currentSubgraphId,
        className: inlineClass,
      );
      nodes[id] = node;
      if (currentSubgraphId != null) {
        subgraphs[currentSubgraphId]?.nodeIds.add(id);
      }
      return node;
    }

    final fallbackId = str;
    return nodes.putIfAbsent(fallbackId, () => _MermaidNode(id: fallbackId, text: fallbackId));
  }

  /// Assigns ranks (topological layers) and positions all elements cleanly
  static List<BoardElement> _layoutElements({
    required List<_MermaidNode> nodes,
    required List<_MermaidEdge> edges,
    required List<_MermaidSubgraph> subgraphs,
    required String direction,
    required Offset origin,
    required Color defaultColor,
  }) {
    final isHorizontal = direction == 'LR' || direction == 'RL';
    final isReversed = direction == 'BT' || direction == 'RL';

    // 1. Calculate dynamic width and height for each node based on text and shape
    for (final node in nodes) {
      final lines = node.text.split('\n');
      var maxLineLen = 0;
      for (final l in lines) {
        if (l.length > maxLineLen) maxLineLen = l.length;
      }

      final baseWidth = math.max(140.0, maxLineLen * 9.5 + 44.0);
      final baseHeight = math.max(62.0, lines.length * 22.0 + 34.0);

      if (node.shapeType == ShapeType.ellipse) {
        final diam = math.max(baseWidth, baseHeight);
        node.width = diam.clamp(100.0, 150.0);
        node.height = node.width; // circle
      } else if (node.shapeType == ShapeType.diamond) {
        node.width = (baseWidth * 1.25).clamp(160.0, 240.0);
        node.height = (baseHeight * 1.25).clamp(80.0, 130.0);
      } else if (node.shapeType == ShapeType.asymmetric) {
        node.width = (baseWidth + 30.0).clamp(160.0, 280.0);
        node.height = baseHeight.clamp(62.0, 100.0);
      } else {
        node.width = baseWidth.clamp(140.0, 260.0);
        node.height = baseHeight.clamp(62.0, 96.0);
      }
    }

    // 2. Partition into Weakly Connected Components (including Subgraph grouping)
    // Using Disjoint Set (Union-Find)
    final parent = <String, String>{};
    String find(String x) {
      if (!parent.containsKey(x)) parent[x] = x;
      if (parent[x] != x) parent[x] = find(parent[x]!);
      return parent[x]!;
    }

    void union(String x, String y) {
      final rootX = find(x);
      final rootY = find(y);
      if (rootX != rootY) parent[rootX] = rootY;
    }

    for (final n in nodes) {
      find(n.id);
    }

    for (final e in edges) {
      union(e.fromId, e.toId);
    }

    for (final sub in subgraphs) {
      if (sub.nodeIds.length > 1) {
        for (var i = 1; i < sub.nodeIds.length; i++) {
          union(sub.nodeIds[0], sub.nodeIds[i]);
        }
      }
    }

    final componentMap = <String, List<_MermaidNode>>{};
    for (final n in nodes) {
      final root = find(n.id);
      componentMap.putIfAbsent(root, () => []).add(n);
    }

    // Sort components by first appearance of their nodes
    final nodeOrder = {for (var i = 0; i < nodes.length; i++) nodes[i].id: i};
    final components = componentMap.values.toList()
      ..sort((a, b) {
        final minA = a.map((n) => nodeOrder[n.id] ?? 99999).reduce(math.min);
        final minB = b.map((n) => nodeOrder[n.id] ?? 99999).reduce(math.min);
        return minA.compareTo(minB);
      });

    // 3. Layout each component independently
    var cursorX = origin.dx;
    var cursorY = origin.dy;
    const componentSpacing = 80.0;

    for (final compNodes in components) {
      _layoutSingleComponent(
        compNodes: compNodes,
        allEdges: edges,
        isHorizontal: isHorizontal,
        isReversed: isReversed,
      );

      // Shift component to current cursor position
      var minX = double.infinity;
      var maxX = -double.infinity;
      var minY = double.infinity;
      var maxY = -double.infinity;

      for (final n in compNodes) {
        final left = n.position.dx - n.width / 2;
        final right = n.position.dx + n.width / 2;
        final top = n.position.dy - n.height / 2;
        final bottom = n.position.dy + n.height / 2;

        if (left < minX) minX = left;
        if (right > maxX) maxX = right;
        if (top < minY) minY = top;
        if (bottom > maxY) maxY = bottom;
      }

      // If component has a subgraph, include its padding in bounds
      final compHasSubgraph = compNodes.any((n) => n.subgraphId != null);
      if (compHasSubgraph) {
        minX -= 28.0;
        maxX += 28.0;
        minY -= 36.0;
        maxY += 28.0;
      }

      final shiftX = cursorX - minX;
      final shiftY = isHorizontal ? (cursorY - minY) : (origin.dy - minY);

      for (final n in compNodes) {
        n.position += Offset(shiftX, shiftY);
      }

      if (isHorizontal) {
        cursorY += (maxY - minY) + componentSpacing;
      } else {
        cursorX += (maxX - minX) + componentSpacing;
      }
    }

    // 4. Generate BoardElements for Nodes
    final elementMap = <String, BoardElement>{};
    final elements = <BoardElement>[];

    for (final node in nodes) {
      final start = node.position - Offset(node.width / 2, node.height / 2);
      final end = node.position + Offset(node.width / 2, node.height / 2);

      final style = node.directStyle;
      final strokeColor = style?.strokeColor ?? defaultColor;
      final fillColor = style?.fillColor ?? defaultColor.withValues(alpha: 0.08);
      final strokeWidth = style?.strokeWidth ?? 2.0;

      final el = BoardElement(
        id: 'mermaid_${node.id}',
        type: node.shapeType,
        start: start,
        end: end,
        color: strokeColor,
        strokeWidth: strokeWidth,
        fillColor: fillColor,
        fillStyle: FillStyle.solid,
        text: node.text,
        fontSize: 13.5,
      );

      elementMap[node.id] = el;
      elements.add(el);
    }

    // 5. Generate Connectors with ConnectionBindings
    for (var i = 0; i < edges.length; i++) {
      final edge = edges[i];
      final fromEl = elementMap[edge.fromId];
      final toEl = elementMap[edge.toId];

      if (fromEl == null || toEl == null) continue;

      AnchorPoint startAnchor;
      AnchorPoint endAnchor;

      if (isHorizontal) {
        if (fromEl.bounds.center.dx < toEl.bounds.center.dx) {
          startAnchor = AnchorPoint.right;
          endAnchor = AnchorPoint.left;
        } else if (fromEl.bounds.center.dx > toEl.bounds.center.dx) {
          startAnchor = AnchorPoint.left;
          endAnchor = AnchorPoint.right;
        } else {
          startAnchor = fromEl.bounds.center.dy < toEl.bounds.center.dy
              ? AnchorPoint.bottom
              : AnchorPoint.top;
          endAnchor = fromEl.bounds.center.dy < toEl.bounds.center.dy
              ? AnchorPoint.top
              : AnchorPoint.bottom;
        }
      } else {
        if (fromEl.bounds.center.dy < toEl.bounds.center.dy - 10) {
          startAnchor = AnchorPoint.bottom;
          endAnchor = AnchorPoint.top;
        } else if (fromEl.bounds.center.dy > toEl.bounds.center.dy + 10) {
          startAnchor = AnchorPoint.top;
          endAnchor = AnchorPoint.bottom;
        } else {
          startAnchor = fromEl.bounds.center.dx < toEl.bounds.center.dx
              ? AnchorPoint.right
              : AnchorPoint.left;
          endAnchor = fromEl.bounds.center.dx < toEl.bounds.center.dx
              ? AnchorPoint.left
              : AnchorPoint.right;
        }
      }

      final startPos = ConnectionBinding.getAnchorPosition(fromEl, startAnchor);
      final endPos = ConnectionBinding.getAnchorPosition(toEl, endAnchor);

      final shapeType = edge.hasStartArrow && edge.hasEndArrow
          ? ShapeType.doubleArrow
          : (edge.hasEndArrow ? ShapeType.arrow : ShapeType.line);

      final connector = BoardElement(
        id: 'mermaid_edge_${i + 1}',
        type: shapeType,
        start: startPos,
        end: endPos,
        color: defaultColor,
        strokeWidth: edge.strokeWidth,
        strokeStyle: edge.strokeStyle,
        connectorStyle: edge.connectorStyle,
        label: edge.label,
        startBinding: ConnectionBinding(elementId: fromEl.id, anchor: startAnchor),
        endBinding: ConnectionBinding(elementId: toEl.id, anchor: endAnchor),
      );

      elements.add(connector);
    }

    // 6. Generate Subgraph Frames
    for (final sub in subgraphs) {
      final subElements = sub.nodeIds
          .map((id) => elementMap[id])
          .whereType<BoardElement>()
          .toList();

      if (subElements.isNotEmpty) {
        Rect bounds = subElements.first.bounds;
        for (var j = 1; j < subElements.length; j++) {
          bounds = bounds.expandToInclude(subElements[j].bounds);
        }
        // Add padding around child nodes: extra top for frame title bar
        bounds = Rect.fromLTRB(
          bounds.left - 24.0,
          bounds.top - 34.0,
          bounds.right + 24.0,
          bounds.bottom + 24.0,
        );

        final frameEl = BoardElement(
          id: 'mermaid_sub_${sub.id}',
          type: ShapeType.frame,
          start: bounds.topLeft,
          end: bounds.bottomRight,
          color: const Color(0xFF748FFC),
          frameTitle: sub.title,
          strokeWidth: 1.5,
          strokeStyle: StrokeStyle.dashed,
        );

        // Put frame at the beginning of elements so it renders behind its children
        elements.insert(0, frameEl);
      }
    }

    return elements;
  }

  static void _layoutSingleComponent({
    required List<_MermaidNode> compNodes,
    required List<_MermaidEdge> allEdges,
    required bool isHorizontal,
    required bool isReversed,
  }) {
    final compIds = compNodes.map((n) => n.id).toSet();
    final nodeMap = {for (final n in compNodes) n.id: n};

    final outgoing = <String, List<String>>{};
    final incoming = <String, List<String>>{};
    for (final n in compNodes) {
      outgoing[n.id] = [];
      incoming[n.id] = [];
    }

    for (final e in allEdges) {
      if (compIds.contains(e.fromId) && compIds.contains(e.toId)) {
        outgoing[e.fromId]!.add(e.toId);
        incoming[e.toId]!.add(e.fromId);
      }
    }

    // Longest path rank assignment
    for (final n in compNodes) {
      n.rank = 0;
    }

    final visited = <String>{};
    void assignRank(String nodeId, int curRank) {
      if (visited.contains(nodeId)) {
        nodeMap[nodeId]!.rank = math.max(nodeMap[nodeId]!.rank, curRank);
        return;
      }
      visited.add(nodeId);
      nodeMap[nodeId]!.rank = math.max(nodeMap[nodeId]!.rank, curRank);
      for (final nextId in outgoing[nodeId]!) {
        assignRank(nextId, curRank + 1);
      }
      visited.remove(nodeId);
    }

    final roots = compNodes.where((n) => incoming[n.id]!.isEmpty).toList();
    if (roots.isEmpty && compNodes.isNotEmpty) {
      roots.add(compNodes.first);
    }

    for (final root in roots) {
      assignRank(root.id, 0);
    }

    // Group nodes by rank
    final rankGroups = <int, List<_MermaidNode>>{};
    for (final node in compNodes) {
      rankGroups.putIfAbsent(node.rank, () => []).add(node);
    }

    final sortedRanks = rankGroups.keys.toList()..sort();
    const rankSpacing = 90.0;
    const nodeSpacing = 36.0;

    // Position ranks
    var depthPos = 0.0;

    for (final r in sortedRanks) {
      final group = rankGroups[r]!;

      // Calculate max depth in this rank
      var maxDepthInRank = 0.0;
      var totalBreadth = 0.0;

      for (var i = 0; i < group.length; i++) {
        final node = group[i];
        final breadth = isHorizontal ? node.height : node.width;
        final depth = isHorizontal ? node.width : node.height;
        if (depth > maxDepthInRank) maxDepthInRank = depth;
        totalBreadth += breadth;
        if (i > 0) totalBreadth += nodeSpacing;
      }

      var currentBreadth = -totalBreadth / 2;

      for (final node in group) {
        final breadth = isHorizontal ? node.height : node.width;
        final nodeBreadthCenter = currentBreadth + breadth / 2;
        final nodeDepthCenter = depthPos + maxDepthInRank / 2;

        node.position = isHorizontal
            ? Offset(nodeDepthCenter, nodeBreadthCenter)
            : Offset(nodeBreadthCenter, nodeDepthCenter);

        currentBreadth += breadth + nodeSpacing;
      }

      depthPos += maxDepthInRank + rankSpacing;
    }
  }
}
