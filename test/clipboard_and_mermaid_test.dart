import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/services/clipboard_service.dart';
import 'package:flutcanvas/services/excalidraw_import_service.dart';
import 'package:flutcanvas/services/mermaid_parser_service.dart';
import 'package:flutcanvas/ui/widgets/mermaid_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MermaidParserService Tests', () {
    test('detects valid Mermaid syntax patterns correctly', () {
      expect(MermaidParserService.isMermaidSyntax('graph TD\n A-->B'), isTrue);
      expect(MermaidParserService.isMermaidSyntax('flowchart LR\n A[Start] --> B[End]'), isTrue);
      expect(MermaidParserService.isMermaidSyntax('subgraph API\n A-->B\n end'), isTrue);
      expect(MermaidParserService.isMermaidSyntax('A --> B --> C'), isTrue);
      expect(MermaidParserService.isMermaidSyntax('Just plain text'), isFalse);
      expect(MermaidParserService.isMermaidSyntax(''), isFalse);
    });

    test('parses various node shapes: rect, rounded, pill, circle, database, diamond', () {
      const script = '''graph TD
        R[Rectangle Box]
        C((Circle Node))
        D{Diamond Decision}
        DB[(Database Storage)]
        P([Pill Stadium])
        R --> C
        C --> D
        D --> DB
        DB --> P''';

      final elements = MermaidParserService.parseToElements(script: script);
      expect(elements, isNotEmpty);

      final rect = elements.firstWhere((e) => e.text == 'Rectangle Box');
      expect(rect.type, equals(ShapeType.rectangle));

      final circle = elements.firstWhere((e) => e.text == 'Circle Node');
      expect(circle.type, equals(ShapeType.ellipse));

      final diamond = elements.firstWhere((e) => e.text == 'Diamond Decision');
      expect(diamond.type, equals(ShapeType.diamond));

      final db = elements.firstWhere((e) => e.text == 'Database Storage');
      expect(db.type, equals(ShapeType.roundedRectangle));

      final pill = elements.firstWhere((e) => e.text == 'Pill Stadium');
      expect(pill.type, equals(ShapeType.roundedRectangle));
    });

    test('parses connector lines, arrowheads, and labels with connection bindings', () {
      const script = '''graph LR
        Client[Web Client] -->|HTTP POST| API[API Gateway]
        API -.->|Async Event| Worker[Event Worker]
        API ==>|High Priority| DB[(Main DB)]''';

      final elements = MermaidParserService.parseToElements(script: script);

      // Find connector elements
      final connectors = elements.where((e) => e.type == ShapeType.arrow || e.type == ShapeType.line).toList();
      expect(connectors.length, equals(3));

      final httpConnector = connectors.firstWhere((e) => e.label == 'HTTP POST');
      expect(httpConnector.startBinding, isNotNull);
      expect(httpConnector.endBinding, isNotNull);
      expect(httpConnector.strokeStyle, equals(StrokeStyle.solid));

      final asyncConnector = connectors.firstWhere((e) => e.label == 'Async Event');
      expect(asyncConnector.strokeStyle, equals(StrokeStyle.dashed));
      expect(asyncConnector.connectorStyle, equals(ConnectorStyle.curved));
    });

    test('parses subgraphs into Frame elements bounding child nodes', () {
      const script = '''graph TD
        subgraph Cloud Cluster
          ServiceA[Service A]
          ServiceB[Service B]
          ServiceA --> ServiceB
        end''';

      final elements = MermaidParserService.parseToElements(script: script);
      expect(elements, isNotEmpty);

      final frame = elements.firstWhere((e) => e.type == ShapeType.frame);
      expect(frame.frameTitle, equals('Cloud Cluster'));

      final nodeA = elements.firstWhere((e) => e.text == 'Service A');
      final nodeB = elements.firstWhere((e) => e.text == 'Service B');

      // The frame must enclose both nodes
      expect(frame.bounds.contains(nodeA.bounds.center), isTrue);
      expect(frame.bounds.contains(nodeB.bounds.center), isTrue);
    });
  });

  group('ExcalidrawImportService Tests', () {
    test('detects and parses Excalidraw JSON document', () {
      const excalidrawJson = '''{
        "type": "excalidraw",
        "version": 2,
        "elements": [
          {
            "id": "rect_1",
            "type": "rectangle",
            "x": 100,
            "y": 150,
            "width": 200,
            "height": 100,
            "strokeColor": "#1e1e1e",
            "backgroundColor": "#ffd43b",
            "fillStyle": "solid",
            "strokeWidth": 2,
            "strokeStyle": "dashed",
            "roundness": {"type": 3}
          },
          {
            "id": "text_1",
            "type": "text",
            "x": 120,
            "y": 170,
            "width": 160,
            "height": 30,
            "text": "Excalidraw Note",
            "fontSize": 20,
            "strokeColor": "#000000"
          }
        ]
      }''';

      expect(ExcalidrawImportService.isExcalidrawJson(excalidrawJson), isTrue);

      final imported = ExcalidrawImportService.importFromExcalidraw(jsonStr: excalidrawJson);
      expect(imported.length, equals(2));

      final rect = imported[0];
      expect(rect.type, equals(ShapeType.roundedRectangle));
      expect(rect.strokeStyle, equals(StrokeStyle.dashed));
      expect(rect.bounds.width, equals(200));

      final text = imported[1];
      expect(text.type, equals(ShapeType.text));
      expect(text.text, equals('Excalidraw Note'));
    });

    test('parses Excalidraw frames and correctly sorts frames behind shapes', () {
      const excalidrawWithFrame = '''{
        "type": "excalidraw",
        "version": 2,
        "elements": [
          {
            "id": "text_child",
            "type": "text",
            "x": 120,
            "y": 140,
            "width": 100,
            "height": 30,
            "text": "Inside Frame",
            "frameId": "frame_1"
          },
          {
            "id": "frame_1",
            "type": "frame",
            "x": 100,
            "y": 100,
            "width": 500,
            "height": 400,
            "name": "Design Sprint Frame"
          },
          {
            "id": "rect_child",
            "type": "rectangle",
            "x": 110,
            "y": 120,
            "width": 150,
            "height": 80,
            "frameId": "frame_1"
          }
        ]
      }''';

      final imported = ExcalidrawImportService.importFromExcalidraw(jsonStr: excalidrawWithFrame);
      expect(imported.length, equals(3));

      // Frame should be sorted first (lowest Z-index, behind child elements)
      expect(imported[0].type, equals(ShapeType.frame));
      expect(imported[0].frameTitle, equals('Design Sprint Frame'));
      expect(imported[0].bounds.width, equals(500));

      // Rectangle shape should be middle
      expect(imported[1].type, equals(ShapeType.rectangle));

      // Text should be on top
      expect(imported[2].type, equals(ShapeType.text));
      expect(imported[2].text, equals('Inside Frame'));
    });
  });

  group('ClipboardService Tests', () {
    test('duplicates in-memory elements with fresh IDs and offset', () {
      final original = [
        BoardElement(
          id: 'orig_1',
          type: ShapeType.rectangle,
          start: const Offset(50, 50),
          end: const Offset(150, 150),
          color: Colors.blue,
        ),
      ];

      ClipboardService.copy(original);
      expect(ClipboardService.hasInternalData, isTrue);

      final duplicated = ClipboardService.duplicate(offset: const Offset(30, 30));
      expect(duplicated.length, equals(1));
      expect(duplicated[0].id, isNot(equals('orig_1')));
      expect(duplicated[0].start, equals(const Offset(80, 80)));
      expect(duplicated[0].end, equals(const Offset(180, 180)));
    });

    test('creates image element with base64 data and size', () {
      final img = ClipboardService.createImageElement(
        base64Image: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
        position: const Offset(200, 200),
      );

      expect(img.type, equals(ShapeType.image));
      expect(img.imageBase64, isNotNull);
      expect(img.bounds.topLeft, equals(const Offset(200, 200)));
    });
  });

  group('MermaidDialog Widget Test', () {
    testWidgets('renders code editor and inserts parsed diagram', (tester) async {
      List<BoardElement>? insertedElements;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MermaidDialog(
              onInsert: (elements) {
                insertedElements = elements;
              },
            ),
          ),
        ),
      );

      expect(find.text('Mermaid Code to Diagram'), findsOneWidget);
      expect(find.text('Architecture'), findsOneWidget);
      expect(find.text('Flowchart'), findsOneWidget);
      expect(find.text('Subgraphs'), findsOneWidget);

      // Tap Insert Diagram button
      final insertButton = find.byType(FilledButton);
      expect(insertButton, findsOneWidget);
      await tester.tap(insertButton);
      await tester.pumpAndSettle();

      expect(insertedElements, isNotNull);
      expect(insertedElements!.length, greaterThan(3));
    });
  });
}
