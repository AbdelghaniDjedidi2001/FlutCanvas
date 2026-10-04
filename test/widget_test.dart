import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/main.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_document.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connection_binding.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/templates.dart';
import 'package:flutcanvas/services/export_service.dart';
import 'package:flutcanvas/services/history_manager.dart';

void main() {
  testWidgets('WhiteboardApp renders canvas, multi-board tabs, and toolbar smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const WhiteboardApp());
    await tester.pumpAndSettle();

    // Verify main toolbar icons exist
    expect(find.byIcon(Icons.near_me_outlined), findsOneWidget); // Select tool
    expect(find.byIcon(Icons.pan_tool_outlined), findsOneWidget); // Hand tool
    expect(find.byIcon(Icons.crop_square), findsOneWidget); // Rectangle tool
    expect(find.byIcon(Icons.auto_awesome_mosaic_outlined), findsWidgets); // Template buttons
    expect(find.byIcon(Icons.image_outlined), findsWidgets); // Image tools
    expect(find.byIcon(Icons.crop_free_rounded), findsOneWidget); // Frame tool
    expect(find.text('Main Board'), findsOneWidget); // Board tab title

    // Verify Empty Canvas Onboarding Guide renders when board has no elements
    expect(find.text('FLUTCANVAS'), findsOneWidget);
    expect(find.text('Pick a tool &\nStart drawing!'), findsOneWidget);
    expect(find.text('Open / Import file'), findsOneWidget);
    expect(find.text('Keyboard shortcuts & Help'), findsOneWidget);

    // Tap shortcuts & help button to verify ShortcutsHelpDialog opens
    await tester.ensureVisible(find.text('Keyboard shortcuts & Help'));
    await tester.tap(find.text('Keyboard shortcuts & Help'));
    await tester.pumpAndSettle();
    expect(find.text('Keyboard Shortcuts'), findsOneWidget);
    expect(find.text('🖌️ Drawing & Creation Tools'), findsOneWidget);

    // Close help dialog
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    // Select text tool and tap canvas to type
    await tester.tap(find.byIcon(Icons.title_rounded));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(150, 250));
    await tester.pumpAndSettle();

    // Verify TextField appears and enter text
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'This is a test note');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    // Verify text is committed, editor closed, and welcome guide is replaced by drawn elements
    expect(find.byType(TextField), findsNothing);
    expect(find.text('FLUTCANVAS'), findsNothing);
  });

  test('ConnectionBinding anchor positions and hit-testing', () {
    const rect = BoardElement(
      id: 'box1',
      type: ShapeType.rectangle,
      start: Offset(100, 100),
      end: Offset(200, 200),
      color: Colors.black,
    );

    final topAnchor = ConnectionBinding.getAnchorPosition(rect, AnchorPoint.top);
    expect(topAnchor, const Offset(150, 100));

    final rightAnchor = ConnectionBinding.getAnchorPosition(rect, AnchorPoint.right);
    expect(rightAnchor, const Offset(200, 150));

    final bottomAnchor = ConnectionBinding.getAnchorPosition(rect, AnchorPoint.bottom);
    expect(bottomAnchor, const Offset(150, 200));

    final leftAnchor = ConnectionBinding.getAnchorPosition(rect, AnchorPoint.left);
    expect(leftAnchor, const Offset(100, 150));

    // Nearest anchor hit testing
    final match = ConnectionBinding.findNearestAnchor(rect, const Offset(152, 98));
    expect(match, isNotNull);
    expect(match!.$1, AnchorPoint.top);
    expect(match.$2, const Offset(150, 100));
  });

  test('Diagram Template Generators produce valid elements', () {
    const center = Offset(500, 500);

    for (final type in DiagramTemplateType.values) {
      final elements = TemplateGenerator.generate(type, center);
      expect(elements.isNotEmpty, isTrue);
      expect(elements.first.id.isNotEmpty, isTrue);
    }
  });

  test('BoardDocument serialization and multi-board tabs', () {
    final doc = BoardDocument(
      id: 'doc_1',
      title: 'Sprint Planning',
      elements: [
        const BoardElement(
          id: 'el_test',
          type: ShapeType.diamond,
          start: Offset(50, 50),
          end: Offset(150, 150),
          color: Colors.red,
          rotation: 0.5,
          drawStyle: DrawStyle.sketch,
        ),
      ],
      pan: const Offset(100, 50),
      zoom: 1.5,
    );

    final jsonStr = doc.toJson();
    final restored = BoardDocument.fromJson(jsonStr);

    expect(restored.id, 'doc_1');
    expect(restored.title, 'Sprint Planning');
    expect(restored.pan, const Offset(100, 50));
    expect(restored.zoom, 1.5);
    expect(restored.elements.length, 1);
    expect(restored.elements.first.rotation, 0.5);
    expect(restored.elements.first.drawStyle, DrawStyle.sketch);
  });

  test('HistoryManager push, undo, and redo', () {
    final history = HistoryManager();
    const el1 = BoardElement(
      id: 'el1',
      type: ShapeType.rectangle,
      start: Offset.zero,
      end: Offset(100, 100),
      color: Colors.black,
    );

    final state0 = <BoardElement>[];
    final state1 = [el1];

    expect(history.canUndo, isFalse);
    expect(history.canRedo, isFalse);

    history.push(state0);
    expect(history.canUndo, isTrue);

    final undone = history.undo(state1);
    expect(undone, equals(state0));
    expect(history.canRedo, isTrue);

    final redone = history.redo(undone!);
    expect(redone, equals(state1));
  });

  test('ExportService JSON import and export', () {
    const el = BoardElement(
      id: 'export_test',
      type: ShapeType.star,
      start: Offset(10, 20),
      end: Offset(80, 90),
      color: Colors.blue,
    );

    final jsonString = ExportService.exportToJson([el]);
    expect(jsonString.contains('flutcanvas_export'), isTrue);

    final imported = ExportService.importFromJson(jsonString);
    expect(imported, isNotNull);
    expect(imported!.length, 1);
    expect(imported.first.id, 'export_test');
    expect(imported.first.type, ShapeType.star);
  });
}
