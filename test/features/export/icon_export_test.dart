import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/export/data/services/mermaid_export_service.dart';
import 'package:flutcanvas/features/export/data/services/svg_export_service.dart';

void main() {
  group('Icon Export Tests', () {
    test('SvgExportService renders ShapeType.icon with SVG rect and text badge', () {
      final iconElement = BoardElement(
        id: 'icon_docker',
        type: ShapeType.icon,
        start: const Offset(100, 100),
        end: const Offset(220, 190),
        iconName: 'docker',
        iconCategory: 'devops',
        text: 'Docker Host',
        color: const Color(0xFF2496ED),
        fillColor: Colors.white,
        strokeWidth: 1.5,
      );

      final svg = SvgExportService.exportToSvg(
        elements: [iconElement],
        includeBackground: false,
        colors: BoardColors.light,
      );

      expect(svg, contains('<svg'));
      expect(svg, contains('Docker Host'));
      expect(svg, contains('🐋'));
      expect(svg, contains('#2496ed'));
    });

    test('MermaidExportService formats ShapeType.icon with brand emoji and custom style class', () {
      final iconElement = BoardElement(
        id: 'icon_postgres',
        type: ShapeType.icon,
        start: const Offset(50, 50),
        end: const Offset(170, 140),
        iconName: 'postgresql',
        iconCategory: 'databases',
        text: 'Postgres DB',
        color: const Color(0xFF4169E1),
      );

      final mermaid = MermaidExportService.exportToMermaid(
        elements: [iconElement],
      );

      expect(mermaid, contains('🐘 Postgres DB'));
      expect(mermaid, contains('style icon_1 stroke:#4169E1'));
    });
  });
}
