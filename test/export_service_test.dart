import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_document.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/services/export_service.dart';
import 'package:flutcanvas/services/pdf_export_service.dart';
import 'package:flutcanvas/ui/widgets/export_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const colors = BoardColors.dark;

  group('SvgExportService', () {
    test('exports empty canvas with minimal svg tag', () {
      final svg = SvgExportService.exportToSvg(
        elements: [],
        colors: colors,
      );
      expect(svg, contains('<svg'));
      expect(svg, contains('</svg>'));
    });

    test('exports various shapes, connectors with labels, and sticky notes', () {
      final elements = [
        BoardElement(
          id: 'rect1',
          type: ShapeType.rectangle,
          start: const Offset(10, 10),
          end: const Offset(110, 110),
          color: Colors.blue,
          fillStyle: FillStyle.solid,
        ),
        BoardElement(
          id: 'elbow1',
          type: ShapeType.arrow,
          start: const Offset(110, 60),
          end: const Offset(200, 150),
          connectorStyle: ConnectorStyle.orthogonal,
          label: 'Data Pipeline',
          color: Colors.green,
        ),
        BoardElement(
          id: 'bezier1',
          type: ShapeType.doubleArrow,
          start: const Offset(200, 150),
          end: const Offset(300, 60),
          connectorStyle: ConnectorStyle.curved,
          color: Colors.purple,
        ),
        BoardElement(
          id: 'sticky1',
          type: ShapeType.stickyNote,
          start: const Offset(320, 20),
          end: const Offset(470, 170),
          text: 'Sprint 4 Vector & PDF Export',
          color: Colors.black,
        ),
        BoardElement(
          id: 'frame1',
          type: ShapeType.frame,
          start: const Offset(0, 0),
          end: const Offset(600, 400),
          color: Colors.indigo,
          frameTitle: 'Slide 1: Intro',
          frameIndex: 1,
        ),
      ];

      final svg = SvgExportService.exportToSvg(
        elements: elements,
        colors: colors,
        includeBackground: true,
      );

      // SVG definitions & structure
      expect(svg, contains('<svg'));
      expect(svg, contains('filter id="stickyShadow"'));
      expect(svg, contains('<rect')); // background & rects
      expect(svg, contains('Data Pipeline')); // connector label
      expect(svg, contains('Sprint 4 Vector &amp; PDF Export')); // sticky note text
      expect(svg, contains('Slide 1: Intro')); // frame title
      expect(svg, contains('</svg>'));
    });

    test('omits background when includeBackground is false', () {
      final elements = [
        BoardElement(
          id: 'el1',
          type: ShapeType.ellipse,
          start: const Offset(50, 50),
          end: const Offset(150, 150),
          color: Colors.red,
        ),
      ];

      final svgWithBg = SvgExportService.exportToSvg(
        elements: elements,
        colors: colors,
        includeBackground: true,
      );
      final svgWithoutBg = SvgExportService.exportToSvg(
        elements: elements,
        colors: colors,
        includeBackground: false,
      );

      expect(svgWithBg.length, greaterThan(svgWithoutBg.length));
    });
  });

  group('PdfExportService', () {
    test('generates valid PDF bytes for current board', () async {
      final elements = [
        BoardElement(
          id: 'rect1',
          type: ShapeType.rectangle,
          start: const Offset(50, 50),
          end: const Offset(200, 150),
          color: Colors.blue,
        ),
      ];

      final pdfBytes = await PdfExportService.exportToPdf(
        elements: elements,
        colors: colors,
        mode: PdfExportMode.currentBoard,
      );

      expect(pdfBytes, isNotEmpty);
      // PDF standard file header starts with %PDF-
      expect(String.fromCharCodes(pdfBytes.take(5)), equals('%PDF-'));
    });

    test('generates multi-page presentation PDF from frame elements', () async {
      final elements = [
        BoardElement(
          id: 'frame1',
          type: ShapeType.frame,
          start: const Offset(0, 0),
          end: const Offset(400, 300),
          color: Colors.blue,
          frameTitle: 'Slide 1',
          frameIndex: 1,
        ),
        BoardElement(
          id: 'note1',
          type: ShapeType.stickyNote,
          start: const Offset(50, 50),
          end: const Offset(180, 180),
          color: Colors.black,
          text: 'Slide 1 Content',
        ),
        BoardElement(
          id: 'frame2',
          type: ShapeType.frame,
          start: const Offset(500, 0),
          end: const Offset(900, 300),
          color: Colors.blue,
          frameTitle: 'Slide 2',
          frameIndex: 2,
        ),
        BoardElement(
          id: 'note2',
          type: ShapeType.stickyNote,
          start: const Offset(550, 50),
          end: const Offset(680, 180),
          color: Colors.black,
          text: 'Slide 2 Content',
        ),
      ];

      final pdfBytes = await PdfExportService.exportToPdf(
        elements: elements,
        colors: colors,
        mode: PdfExportMode.presentationSlides,
      );

      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.take(5)), equals('%PDF-'));
    });

    test('generates multi-page PDF from all workspace boards', () async {
      final boards = [
        BoardDocument(
          id: 'b1',
          title: 'Architecture',
          elements: [
            BoardElement(
              id: 'e1',
              type: ShapeType.rectangle,
              start: const Offset(10, 10),
              end: const Offset(100, 100),
              color: Colors.blue,
            ),
          ],
        ),
        BoardDocument(
          id: 'b2',
          title: 'Flowchart',
          elements: [
            BoardElement(
              id: 'e2',
              type: ShapeType.ellipse,
              start: const Offset(20, 20),
              end: const Offset(120, 120),
              color: Colors.green,
            ),
          ],
        ),
      ];

      final pdfBytes = await PdfExportService.exportToPdf(
        elements: boards[0].elements,
        colors: colors,
        allBoards: boards,
        mode: PdfExportMode.allBoards,
      );

      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.take(5)), equals('%PDF-'));
    });
  });

  group('ExportService JSON round-trip', () {
    test('serializes and deserializes all properties intact', () {
      final original = [
        BoardElement(
          id: 'el1',
          type: ShapeType.arrow,
          start: const Offset(10, 20),
          end: const Offset(150, 180),
          color: Colors.cyan,
          fillColor: Colors.amber,
          strokeWidth: 4.0,
          strokeStyle: StrokeStyle.dashed,
          fillStyle: FillStyle.semi,
          connectorStyle: ConnectorStyle.orthogonal,
          label: 'API Request',
          isLocked: true,
          isVisible: true,
          customName: 'Custom Arrow',
        ),
      ];

      final jsonStr = ExportService.exportToJson(original);
      final deserialized = ExportService.importFromJson(jsonStr);

      expect(deserialized, isNotNull);
      expect(deserialized!.length, equals(1));
      final el = deserialized.first;
      expect(el.id, equals('el1'));
      expect(el.type, equals(ShapeType.arrow));
      expect(el.start, equals(const Offset(10, 20)));
      expect(el.end, equals(const Offset(150, 180)));
      expect(el.connectorStyle, equals(ConnectorStyle.orthogonal));
      expect(el.label, equals('API Request'));
      expect(el.isLocked, isTrue);
      expect(el.customName, equals('Custom Arrow'));
    });
  });

  group('ExportDialog widget test', () {
    testWidgets('renders format tabs and switches between them', (tester) async {
      final elements = [
        BoardElement(
          id: '1',
          type: ShapeType.rectangle,
          start: const Offset(10, 10),
          end: const Offset(100, 100),
          color: Colors.blue,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(
              elements: elements,
              colors: colors,
              boardName: 'Sprint4 Test Board',
              onImport: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Export & Share'), findsOneWidget);
      expect(find.text('PNG'), findsOneWidget);
      expect(find.text('SVG'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('Data'), findsOneWidget);

      // PNG tab is active by default
      expect(find.text('Download PNG Image (.png)'), findsOneWidget);

      // Switch to SVG tab
      await tester.tap(find.text('SVG'));
      await tester.pumpAndSettle();
      expect(find.text('Download SVG'), findsOneWidget);
      expect(find.text('Copy SVG XML'), findsOneWidget);

      // Switch to PDF tab
      await tester.tap(find.text('PDF'));
      await tester.pumpAndSettle();
      expect(find.text('Current Board (Single Page)'), findsOneWidget);
      expect(find.text('Download PDF Document (.pdf)'), findsOneWidget);

      // Switch to Data tab
      await tester.tap(find.text('Data'));
      await tester.pumpAndSettle();
      expect(find.text('Save File'), findsOneWidget);
      expect(find.text('Copy JSON'), findsOneWidget);
      expect(find.text('Open / Import File...'), findsOneWidget);
    });
  });
}
