import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connection_binding.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';

class _MermaidNode {
  final String id;
  String text;
  ShapeType shapeType;
  int rank = 0;
  int orderInRank = 0;
  String? subgraphId;

  _MermaidNode({
    required this.id,
    required this.text,
    this.shapeType = ShapeType.rectangle,
    this.subgraphId,
  });
}

class _MermaidEdge {
  final String fromId;
  final String toId;
  final String? label;
  final ConnectorStyle connectorStyle;
  final StrokeStyle strokeStyle;
  final bool hasStartArrow;
  final bool hasEndArrow;

  _MermaidEdge({
    required this.fromId,
    required this.toId,
    this.label,
    this.connectorStyle = ConnectorStyle.orthogonal,
    this.strokeStyle = StrokeStyle.solid,
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
        (trimmed.contains('-->') || trimmed.contains('---') || trimmed.contains('==>'));
  }

  /// Parses Mermaid flowchart code and generates positioned BoardElements
  static List<BoardElement> parseToElements({
    required String script,
    Offset origin = const Offset(100, 100),
    Color defaultColor = const Color(0xFF1971C2),
  }) {
    final lines = script.split('\n');
    String direction = 'TD'; // default Top-Down
    final nodes = <String, _MermaidNode>{};
    final edges = <_MermaidEdge>[];
    final subgraphs = <String, _MermaidSubgraph>{};
    String? currentSubgraphId;

    for (var rawLine in lines) {
      var line = rawLine.trim();
      // Remove comments
      if (line.startsWith('%%')) continue;
      if (line.isEmpty) continue;

      // Header: graph TD / flowchart LR
      final headerMatch = RegExp(r'^(?:graph|flowchart)\s+([A-Za-z]+)', caseSensitive: false)
          .firstMatch(line);
      if (headerMatch != null) {
        direction = headerMatch.group(1)!.toUpperCase();
        continue;
      }

      // Subgraph start: subgraph Title or subgraph id [Title]
      final subgraphStartMatch = RegExp(r'^subgraph\s+(?:([A-Za-z0-9_\-]+)\s*(?:\[(.*?)\])?|(.*?))$', caseSensitive: false)
          .firstMatch(line);
      if (subgraphStartMatch != null && !line.startsWith('end')) {
        final idOrTitle = (subgraphStartMatch.group(1) ?? subgraphStartMatch.group(3) ?? 'subgraph_${subgraphs.length + 1}').trim();
        final title = subgraphStartMatch.group(2) ?? idOrTitle;
        final subId = 'sub_${subgraphs.length + 1}';
        subgraphs[subId] = _MermaidSubgraph(id: subId, title: title);
        currentSubgraphId = subId;
        continue;
      }

      if (line.toLowerCase() == 'end') {
        currentSubgraphId = null;
        continue;
      }

      // Parse edge or node definitions on this line
      _parseLine(
        line: line,
        nodes: nodes,
        edges: edges,
        currentSubgraphId: currentSubgraphId,
        subgraphs: subgraphs,
      );
    }

    if (nodes.isEmpty) return [];

    // Layout graph using Hierarchical Layered Digraph Algorithm
    return _layoutElements(
      nodes: nodes.values.toList(),
      edges: edges,
      subgraphs: subgraphs.values.toList(),
      direction: direction,
      origin: origin,
      defaultColor: defaultColor,
    );
  }

  static void _parseLine({
    required String line,
    required Map<String, _MermaidNode> nodes,
    required List<_MermaidEdge> edges,
    required String? currentSubgraphId,
    required Map<String, _MermaidSubgraph> subgraphs,
  }) {
    // Edge regex patterns:
    // A --> B
    // A -->|Text| B
    // A -- Text --> B
    // A -.-> B
    // A ==> B
    // A --- B
    final edgeRegex = RegExp(
      r'([A-Za-z0-9_\-]+(?:\s*\[.*?\]|\s*\(.*?\)|s*\{.*?\}|\s*\[\(.*?\)\]|\s*\(\(.*?\)\))?)\s*'
      r'(-->|---|==>|-\.->|<-->|<==>|--\s*.*?\s*-->|-\.\s*.*?\s*\.->|==\s*.*?\s*==>|-->\|.*?\||==>\|.*?\||-\.->\|.*?\|)\s*'
      r'([A-Za-z0-9_\-]+(?:\s*\[.*?\]|\s*\(.*?\)|s*\{.*?\}|\s*\[\(.*?\)\]|\s*\(\(.*?\)\))?)',
    );

    final matches = edgeRegex.allMatches(line);
    if (matches.isNotEmpty) {
      for (final match in matches) {
        final fromRaw = match.group(1)!.trim();
        final arrowRaw = match.group(2)!.trim();
        final toRaw = match.group(3)!.trim();

        final fromNode = _getOrCreateNode(fromRaw, nodes, currentSubgraphId, subgraphs);
        final toNode = _getOrCreateNode(toRaw, nodes, currentSubgraphId, subgraphs);

        // Parse arrow type, style, and label
        String? label;
        var connectorStyle = ConnectorStyle.orthogonal;
        var strokeStyle = StrokeStyle.solid;
        var hasStartArrow = false;
        var hasEndArrow = true;

        if (arrowRaw.contains('|')) {
          final parts = arrowRaw.split('|');
          if (parts.length >= 2) label = parts[1].trim();
        } else if (arrowRaw.startsWith('-- ') || arrowRaw.startsWith('-. ') || arrowRaw.startsWith('== ')) {
          final textMatch = RegExp(r'(?:--|-\.|==)\s*(.*?)\s*(?:-->|\.->|==>)').firstMatch(arrowRaw);
          if (textMatch != null) label = textMatch.group(1);
        }

        if (arrowRaw.contains('-.->') || arrowRaw.contains('-.') || arrowRaw.contains('.-')) {
          strokeStyle = StrokeStyle.dashed;
          connectorStyle = ConnectorStyle.curved;
        } else if (arrowRaw.contains('==>') || arrowRaw.contains('==')) {
          connectorStyle = ConnectorStyle.orthogonal;
        } else if (arrowRaw.contains('---')) {
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
    // Test node shapes:
    // Stadium / Pill: A([Text])
    // Subroutine: A[[Text]]
    // Database: A[(Text)]
    // Circle: A((Text))
    // Diamond: A{Text}
    // Rounded: A(Text)
    // Rectangle: A[Text]
    // Raw: A

    final pattern = RegExp(
      r'^([A-Za-z0-9_\-]+)\s*(?:'
      r'\[\((.*?)\)\]|' // Database [(Text)]
      r'\[\[(.*?)\]\]|' // Subroutine [[Text]]
      r'\(\[(.*?)\]\)|' // Stadium ([Text])
      r'\(\((.*?)\)\)|' // Circle ((Text))
      r'\{(.*?)\}|'     // Diamond {Text}
      r'\((.*?)\)|'     // Rounded (Text)
      r'\[(.*?)\]'      // Rectangle [Text]
      r')?$',
    );

    final match = pattern.firstMatch(raw.trim());
    if (match != null) {
      final id = match.group(1)!;
      final dbText = match.group(2);
      final subText = match.group(3);
      final stadiumText = match.group(4);
      final circleText = match.group(5);
      final diamondText = match.group(6);
      final roundText = match.group(7);
      final rectText = match.group(8);

      var text = id;
      var shape = ShapeType.rectangle;

      if (dbText != null) {
        text = dbText;
        shape = ShapeType.roundedRectangle;
      } else if (subText != null) {
        text = subText;
        shape = ShapeType.rectangle;
      } else if (stadiumText != null) {
        text = stadiumText;
        shape = ShapeType.roundedRectangle;
      } else if (circleText != null) {
        text = circleText;
        shape = ShapeType.ellipse;
      } else if (diamondText != null) {
        text = diamondText;
        shape = ShapeType.diamond;
      } else if (roundText != null) {
        text = roundText;
        shape = ShapeType.roundedRectangle;
      } else if (rectText != null) {
        text = rectText;
        shape = ShapeType.rectangle;
      }

      if (nodes.containsKey(id)) {
        final existing = nodes[id]!;
        if (text != id && existing.text == id) existing.text = text;
        if (shape != ShapeType.rectangle && existing.shapeType == ShapeType.rectangle) {
          existing.shapeType = shape;
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
      );
      nodes[id] = node;
      if (currentSubgraphId != null) {
        subgraphs[currentSubgraphId]?.nodeIds.add(id);
      }
      return node;
    }

    // Fallback simple node ID
    final id = raw.trim();
    return nodes.putIfAbsent(id, () => _MermaidNode(id: id, text: id));
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

    // 1. Calculate in-degrees and build adjacency map
    final nodeMap = {for (final n in nodes) n.id: n};
    final outgoing = <String, List<String>>{};
    final incoming = <String, List<String>>{};

    for (final n in nodes) {
      outgoing[n.id] = [];
      incoming[n.id] = [];
    }

    for (final e in edges) {
      if (nodeMap.containsKey(e.fromId) && nodeMap.containsKey(e.toId)) {
        outgoing[e.fromId]!.add(e.toId);
        incoming[e.toId]!.add(e.fromId);
      }
    }

    // 2. Assign ranks using longest path layering
    final visited = <String>{};
    void assignRank(String nodeId, int currentRank) {
      final node = nodeMap[nodeId]!;
      node.rank = math.max(node.rank, currentRank);
      for (final nextId in outgoing[nodeId]!) {
        assignRank(nextId, currentRank + 1);
      }
    }

    // Start with root nodes (in-degree 0)
    final roots = nodes.where((n) => incoming[n.id]!.isEmpty).toList();
    if (roots.isEmpty && nodes.isNotEmpty) {
      roots.add(nodes.first);
    }

    for (final root in roots) {
      assignRank(root.id, 0);
    }

    // Ensure disconnected nodes have rank 0
    for (final node in nodes) {
      if (!visited.contains(node.id) && incoming[node.id]!.isEmpty) {
        assignRank(node.id, 0);
      }
    }

    // 3. Group nodes by rank
    final rankGroups = <int, List<_MermaidNode>>{};
    for (final node in nodes) {
      rankGroups.putIfAbsent(node.rank, () => []).add(node);
    }

    final maxRank = rankGroups.keys.isEmpty ? 0 : rankGroups.keys.reduce(math.max);

    // 4. Position nodes
    const nodeWidth = 160.0;
    const nodeHeight = 64.0;
    const rankSpacing = 110.0;
    const nodeSpacing = 48.0;

    final elementMap = <String, BoardElement>{};
    final elements = <BoardElement>[];

    for (final entry in rankGroups.entries) {
      final rankIndex = isReversed ? (maxRank - entry.key) : entry.key;
      final group = entry.value;
      final totalBreadth = group.length * nodeWidth + (group.length - 1) * nodeSpacing;

      for (var i = 0; i < group.length; i++) {
        final node = group[i];
        final breadthPos = i * (nodeWidth + nodeSpacing) - totalBreadth / 2 + nodeWidth / 2;
        final depthPos = rankIndex * (nodeHeight + rankSpacing);

        final center = isHorizontal
            ? Offset(origin.dx + depthPos + 100, origin.dy + breadthPos + 200)
            : Offset(origin.dx + breadthPos + 300, origin.dy + depthPos + 50);

        final start = center - const Offset(nodeWidth / 2, nodeHeight / 2);
        final end = center + const Offset(nodeWidth / 2, nodeHeight / 2);

        final el = BoardElement(
          id: 'mermaid_${node.id}',
          type: node.shapeType,
          start: start,
          end: end,
          color: defaultColor,
          fillColor: defaultColor.withValues(alpha: 0.08),
          fillStyle: FillStyle.solid,
          text: node.text,
          fontSize: 14.0,
        );

        elementMap[node.id] = el;
        elements.add(el);
      }
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
        startAnchor = isReversed ? AnchorPoint.left : AnchorPoint.right;
        endAnchor = isReversed ? AnchorPoint.right : AnchorPoint.left;
      } else {
        startAnchor = isReversed ? AnchorPoint.top : AnchorPoint.bottom;
        endAnchor = isReversed ? AnchorPoint.bottom : AnchorPoint.top;
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
        strokeWidth: 2.0,
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
        bounds = bounds.inflate(28.0);

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
}
