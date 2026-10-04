import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/services/svg_export_service.dart';
import 'package:flutcanvas/ui/inline_text_editor.dart';
import 'package:flutcanvas/ui/toolbar/properties_panel.dart';

void main() {
  group('Table Data Model & Geometry Tests', () {
    test('creates table element with default and custom cell data', () {
      final table = BoardElement(
        id: 'tbl_1',
        type: ShapeType.table,
        start: const Offset(100, 100),
        end: const Offset(400, 250), // w=300, h=150
        color: Colors.black,
        tableData: const [
          ['Col 1', 'Col 2', 'Col 3'],
          ['A', 'B', 'C'],
          ['D', 'E', 'F'],
        ],
        tableHasHeader: true,
      );

      expect(table.type, ShapeType.table);
      expect(table.tableRowCount, 3);
      expect(table.tableColCount, 3);
      expect(table.tableHasHeader, isTrue);
      expect(table.displayName, 'Table (3x3)');
    });

    test('calculates cell rect correctly across rows and columns', () {
      final table = BoardElement(
        id: 'tbl_1',
        type: ShapeType.table,
        start: const Offset(100, 100),
        end: const Offset(400, 250), // w=300 (colWidth=100), h=150 (rowHeight=50)
        color: Colors.black,
        tableData: const [
          ['H1', 'H2', 'H3'],
          ['A', 'B', 'C'],
          ['D', 'E', 'F'],
        ],
      );

      final r0c0 = table.getCellRect(0, 0);
      expect(r0c0, const Rect.fromLTWH(100, 100, 100, 50));

      final r1c2 = table.getCellRect(1, 2);
      expect(r1c2, const Rect.fromLTWH(300, 150, 100, 50));

      final r2c1 = table.getCellRect(2, 1);
      expect(r2c1, const Rect.fromLTWH(200, 200, 100, 50));
    });

    test('hitTestCell accurately identifies which cell was clicked', () {
      final table = BoardElement(
        id: 'tbl_1',
        type: ShapeType.table,
        start: const Offset(100, 100),
        end: const Offset(400, 250), // w=300 (colWidth=100), h=150 (rowHeight=50)
        color: Colors.black,
        tableData: const [
          ['H1', 'H2', 'H3'],
          ['A', 'B', 'C'],
          ['D', 'E', 'F'],
        ],
      );

      expect(table.hitTestCell(const Offset(150, 125)), const (0, 0));
      expect(table.hitTestCell(const Offset(350, 175)), const (1, 2));
      expect(table.hitTestCell(const Offset(250, 225)), const (2, 1));
      expect(table.hitTestCell(const Offset(50, 50)), isNull);
    });

    test('updateTableCell modifies specific cell content without mutating other cells', () {
      final table = BoardElement(
        id: 'tbl_1',
        type: ShapeType.table,
        start: const Offset(100, 100),
        end: const Offset(400, 250),
        color: Colors.black,
        tableData: const [
          ['H1', 'H2'],
          ['A', 'B'],
        ],
      );

      final updated = table.updateTableCell(1, 1, 'New Value');
      expect(updated.safeTableData[1][1], 'New Value');
      expect(updated.safeTableData[1][0], 'A');
      expect(updated.safeTableData[0][1], 'H2');
    });

    test('adds and removes rows with boundary checks', () {
      final table = BoardElement(
        id: 'tbl_1',
        type: ShapeType.table,
        start: const Offset(100, 100),
        end: const Offset(400, 250),
        color: Colors.black,
        tableData: const [
          ['H1', 'H2'],
          ['A', 'B'],
        ],
      );

      final withRow = table.addTableRow();
      expect(withRow.tableRowCount, 3);
      expect(withRow.safeTableData[2].length, 2);

      final backToTwo = withRow.removeTableRow();
      expect(backToTwo.tableRowCount, 2);

      final oneRow = backToTwo.removeTableRow();
      expect(oneRow.tableRowCount, 1);

      // Cannot remove below 1 row
      final clamped = oneRow.removeTableRow();
      expect(clamped.tableRowCount, 1);
    });

    test('adds and removes columns with boundary checks', () {
      final table = BoardElement(
        id: 'tbl_1',
        type: ShapeType.table,
        start: const Offset(100, 100),
        end: const Offset(400, 250),
        color: Colors.black,
        tableData: const [
          ['H1', 'H2'],
          ['A', 'B'],
        ],
      );

      final withCol = table.addTableColumn();
      expect(withCol.tableColCount, 3);
      expect(withCol.safeTableData[0][2], 'Header 3');

      final backToTwo = withCol.removeTableColumn();
      expect(backToTwo.tableColCount, 2);

      final oneCol = backToTwo.removeTableColumn();
      expect(oneCol.tableColCount, 1);

      // Cannot remove below 1 column
      final clamped = oneCol.removeTableColumn();
      expect(clamped.tableColCount, 1);
    });

    test('serializes to and from JSON preserving all table data', () {
      final original = BoardElement(
        id: 'tbl_json_1',
        type: ShapeType.table,
        start: const Offset(50, 60),
        end: const Offset(350, 260),
        color: Colors.blue,
        fillColor: Colors.grey,
        strokeWidth: 2.0,
        fontSize: 16.0,
        tableData: const [
          ['Feature', 'Basic', 'Pro'],
          ['Users', '5', 'Unlimited'],
          ['Storage', '10GB', '1TB'],
        ],
        tableHasHeader: true,
      );

      final jsonStr = original.toJson();
      final reconstructed = BoardElement.fromJson(jsonStr);

      expect(reconstructed.id, original.id);
      expect(reconstructed.type, ShapeType.table);
      expect(reconstructed.tableRowCount, 3);
      expect(reconstructed.tableColCount, 3);
      expect(reconstructed.tableHasHeader, isTrue);
      expect(reconstructed.safeTableData[1][2], 'Unlimited');
      expect(reconstructed.safeTableData[2][1], '10GB');
    });
  });

  group('SVG Table Export Tests', () {
    test('SvgExportService generates valid SVG with table rects and text nodes', () {
      final table = BoardElement(
        id: 'tbl_svg',
        type: ShapeType.table,
        start: const Offset(10, 10),
        end: const Offset(310, 160),
        color: Colors.black,
        tableData: const [
          ['Product', 'Price'],
          ['Widget', '\$9.99'],
        ],
        tableHasHeader: true,
      );

      final svg = SvgExportService.exportToSvg(
        elements: [table],
        colors: BoardColors.light,
      );

      expect(svg, contains('<svg'));
      expect(svg, contains('Product'));
      expect(svg, contains('Price'));
      expect(svg, contains('Widget'));
      expect(svg, contains('\$9.99'));
      expect(svg, contains('<line'));
    });
  });

  group('PropertiesPanel Table Controls Widget Tests', () {
    testWidgets('renders Table Grid Controls when a table element is selected', (tester) async {
      bool addRowCalled = false;
      bool removeRowCalled = false;
      bool addColCalled = false;
      bool removeColCalled = false;
      bool? headerToggleVal;

      final table = BoardElement(
        id: 'tbl_1',
        type: ShapeType.table,
        start: const Offset(10, 10),
        end: const Offset(300, 200),
        color: Colors.black,
        tableData: const [
          ['Col 1', 'Col 2'],
          ['A', 'B'],
        ],
        tableHasHeader: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertiesPanel(
              selectedElements: [table],
              currentColor: Colors.black,
              currentFillColor: Colors.transparent,
              currentStrokeWidth: 1.5,
              currentStrokeStyle: StrokeStyle.solid,
              currentFillStyle: FillStyle.none,
              currentDrawStyle: DrawStyle.clean,
              currentFontSize: 14.0,
              currentOpacity: 1.0,
              currentRotation: 0.0,
              currentConnectorStyle: ConnectorStyle.straight,
              onColorChanged: (_) {},
              onFillColorChanged: (_) {},
              onStrokeWidthChanged: (_) {},
              onStrokeStyleChanged: (_) {},
              onFillStyleChanged: (_) {},
              onDrawStyleChanged: (_) {},
              onFontSizeChanged: (_) {},
              onOpacityChanged: (_) {},
              onRotationChanged: (_) {},
              onConnectorStyleChanged: (_) {},
              onEditConnectorLabel: () {},
              onAddTableRow: () => addRowCalled = true,
              onRemoveTableRow: () => removeRowCalled = true,
              onAddTableColumn: () => addColCalled = true,
              onRemoveTableColumn: () => removeColCalled = true,
              onToggleTableHeader: (val) => headerToggleVal = val,
              onGroup: () {},
              onUngroup: () {},
              onBringToFront: () {},
              onSendToBack: () {},
              onDuplicate: () {},
              onDelete: () {},
              onAlign: (_) {},
              onDistribute: (_) {},
              onToggleLock: () {},
            ),
          ),
        ),
      );

      expect(find.text('Table Grid Controls'), findsOneWidget);
      expect(find.text('+ Row'), findsOneWidget);
      expect(find.text('- Row'), findsOneWidget);
      expect(find.text('+ Col'), findsOneWidget);
      expect(find.text('- Col'), findsOneWidget);
      expect(find.text('Header Row: ON'), findsOneWidget);

      await tester.tap(find.text('+ Row'));
      expect(addRowCalled, isTrue);

      await tester.tap(find.text('- Row'));
      expect(removeRowCalled, isTrue);

      await tester.tap(find.text('+ Col'));
      expect(addColCalled, isTrue);

      await tester.tap(find.text('- Col'));
      expect(removeColCalled, isTrue);

      await tester.tap(find.text('Header Row: ON'));
      expect(headerToggleVal, isFalse);
    });
  });

  group('InlineTextEditor Table Cell Navigation Tests', () {
    testWidgets('renders table cell inline editor and emits onNavigateCell on Tab / Enter', (tester) async {
      int navDRow = 0;
      int navDCol = 0;
      String submittedText = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                InlineTextEditor(
                  initialText: 'Cell Alpha',
                  fontSize: 14.0,
                  color: Colors.black,
                  screenPosition: const Offset(50, 50),
                  isStickyNote: false,
                  isTableCell: true,
                  customWidth: 140.0,
                  onNavigateCell: (dRow, dCol, text) {
                    navDRow = dRow;
                    navDCol = dCol;
                  },
                  onSubmitted: (t) => submittedText = t,
                  onCanceled: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Cell Alpha'), findsOneWidget);
      expect(find.text('⇥ Tab next cell · ↵ Enter next row'), findsOneWidget);

      // Simulate Tab key down
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(navDRow, 0);
      expect(navDCol, 1);

      // Tap Done button
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(submittedText, 'Cell Alpha');
    });
  });
}
