import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connection_binding.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/export/data/services/mermaid_export_service.dart';

void main() {
  group('MermaidExportService', () {
    test('exports empty elements list with fallback empty node', () {
      final mermaid = MermaidExportService.exportToMermaid(elements: []);
      expect(mermaid, contains('flowchart TD'));
      expect(mermaid, contains('empty["Empty Canvas"]'));
    });

    test('exports simple flowchart with nodes and connected arrow', () {
      final nodeA = BoardElement(
        id: 'node_a',
        type: ShapeType.rectangle,
        start: const Offset(50, 50),
        end: const Offset(150, 100),
        text: 'Start Process',
      );

      final nodeB = BoardElement(
        id: 'node_b',
        type: ShapeType.diamond,
        start: const Offset(50, 200),
        end: const Offset(150, 280),
        text: 'Is Valid?',
      );

      final connector = BoardElement(
        id: 'conn_1',
        type: ShapeType.arrow,
        start: const Offset(100, 100),
        end: const Offset(100, 200),
        startBinding: const ConnectionBinding(elementId: 'node_a', anchor: AnchorPoint.bottom),
        endBinding: const ConnectionBinding(elementId: 'node_b', anchor: AnchorPoint.top),
        label: 'Submit',
      );

      final mermaid = MermaidExportService.exportToMermaid(
        elements: [nodeA, nodeB, connector],
      );

      expect(mermaid, contains('flowchart TD'));
      expect(mermaid, contains('["Start Process"]'));
      expect(mermaid, contains('{"Is Valid?"}'));
      expect(mermaid, contains('-->|"Submit"|'));
    });

    test('exports frames as subgraphs grouping child elements', () {
      final frame = BoardElement(
        id: 'frame_1',
        type: ShapeType.frame,
        start: const Offset(0, 0),
        end: const Offset(500, 400),
        frameTitle: 'Backend Architecture',
      );

      final serviceA = BoardElement(
        id: 'srv_a',
        type: ShapeType.roundedRectangle,
        start: const Offset(50, 50),
        end: const Offset(150, 100),
        text: 'Auth Service',
      );

      final serviceB = BoardElement(
        id: 'srv_b',
        type: ShapeType.roundedRectangle,
        start: const Offset(200, 50),
        end: const Offset(300, 100),
        text: 'User DB',
      );

      final mermaid = MermaidExportService.exportToMermaid(
        elements: [frame, serviceA, serviceB],
      );

      expect(mermaid, contains('subgraph subgraph_1 ["Backend Architecture"]'));
      expect(mermaid, contains('("Auth Service")'));
      expect(mermaid, contains('("User DB")'));
      expect(mermaid, contains('end'));
    });

    test('escapes special characters and newlines correctly', () {
      final node = BoardElement(
        id: 'n1',
        type: ShapeType.rectangle,
        start: const Offset(10, 10),
        end: const Offset(100, 50),
        text: 'Hello "World"\nNext Line',
      );

      final mermaid = MermaidExportService.exportToMermaid(elements: [node]);
      expect(mermaid, contains("Hello 'World'<br/>Next Line"));
    });

    test('exports connector styles: dashed, double arrow, and lines', () {
      final n1 = BoardElement(
        id: 'n1',
        type: ShapeType.ellipse,
        start: const Offset(0, 0),
        end: const Offset(60, 60),
        text: 'Client',
      );
      final n2 = BoardElement(
        id: 'n2',
        type: ShapeType.ellipse,
        start: const Offset(200, 0),
        end: const Offset(260, 60),
        text: 'Server',
      );

      final dashedConn = BoardElement(
        id: 'c1',
        type: ShapeType.doubleArrow,
        start: const Offset(60, 30),
        end: const Offset(200, 30),
        startBinding: const ConnectionBinding(elementId: 'n1', anchor: AnchorPoint.right),
        endBinding: const ConnectionBinding(elementId: 'n2', anchor: AnchorPoint.left),
        strokeStyle: StrokeStyle.dashed,
      );

      final mermaid = MermaidExportService.exportToMermaid(
        elements: [n1, n2, dashedConn],
      );

      expect(mermaid, contains('circ_1(["Client"])'));
      expect(mermaid, contains('circ_2(["Server"])'));
      expect(mermaid, contains('circ_1 <-.-> circ_2'));
    });
  });
}
