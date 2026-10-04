import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/snap_guide.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'package:flutcanvas/features/canvas/presentation/tools/canvas_tool_context.dart';
import 'package:flutcanvas/features/canvas/presentation/tools/connector_tool.dart';
import 'package:flutcanvas/features/canvas/presentation/tools/freehand_tool.dart';
import 'package:flutcanvas/features/canvas/presentation/tools/select_tool.dart';
import 'package:flutcanvas/features/canvas/presentation/tools/shape_tool.dart';
import 'package:flutcanvas/features/canvas/presentation/tools/tool_registry.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/laser_painter.dart';

class MockToolContext implements CanvasToolContext {
  @override
  List<BoardElement> elements = [];

  @override
  Set<String> selectedIds = {};

  @override
  double zoom = 1.0;

  @override
  Offset pan = Offset.zero;

  @override
  Color strokeColor = Colors.black;

  @override
  Color fillColor = Colors.transparent;

  @override
  double strokeWidth = 2.0;

  @override
  StrokeStyle strokeStyle = StrokeStyle.solid;

  @override
  FillStyle fillStyle = FillStyle.none;

  @override
  DrawStyle drawStyle = DrawStyle.clean;

  @override
  double fontSize = 16.0;

  @override
  double opacity = 1.0;

  @override
  ConnectorStyle connectorStyle = ConnectorStyle.straight;

  @override
  bool smartGuides = true;

  @override
  bool autoShapeRecognition = true;

  @override
  bool isShiftDown = false;

  @override
  String codeLanguage = 'dart';

  BoardElement? draft;
  Rect? marquee;
  List<LaserPoint> laserTrail = [];
  List<SnapGuide> snapGuides = [];
  final List<BoardElement> committedElements = [];

  @override
  void setDraft(BoardElement? d) => draft = d;

  @override
  void setMarquee(Rect? m) => marquee = m;

  @override
  void setLaserTrail(List<LaserPoint> t) => laserTrail = t;

  @override
  void setSnapGuides(List<SnapGuide> g) => snapGuides = g;

  BoardElement? hoveredAnchorElement;
  Offset? activeAnchorPoint;

  @override
  void setConnectionAnchor({BoardElement? element, Offset? point}) {
    hoveredAnchorElement = element;
    activeAnchorPoint = point;
  }

  @override
  void commitElement(BoardElement element) => committedElements.add(element);

  @override
  void commitElements(List<BoardElement> els) => committedElements.addAll(els);

  @override
  void updateElement(BoardElement element) {
    final idx = elements.indexWhere((e) => e.id == element.id);
    if (idx != -1) elements[idx] = element;
  }

  @override
  void updateElements(List<BoardElement> els) {
    elements = List.from(els);
  }

  @override
  void deleteElements(Set<String> ids) {
    elements.removeWhere((e) => ids.contains(e.id));
  }

  @override
  void selectElements(Set<String> ids) => selectedIds = ids;

  @override
  void clearSelection() => selectedIds.clear();

  @override
  String generateElementId() => 'mock_el_${committedElements.length + 1}';

  @override
  BoardElement? hitTestTopmost(Offset worldPos) => null;
}

void main() {
  group('CanvasTool Strategy & Registry Tests', () {
    test('ToolRegistry resolves default tools correctly', () {
      final registry = ToolRegistry();

      final selectTool = registry.get(Tool.select);
      expect(selectTool.toolType, equals(Tool.select));

      final rectTool = registry.get(Tool.rectangle);
      expect(rectTool.toolType, equals(Tool.rectangle));

      final penTool = registry.get(Tool.pen);
      expect(penTool.toolType, equals(Tool.pen));
    });

    test('ShapeTool creates draft on pointerDown/move and commits on pointerUp', () {
      final tool = ShapeTool(
        toolType: Tool.rectangle,
        shapeType: ShapeType.rectangle,
      );
      final context = MockToolContext();

      // 1. Pointer Down
      tool.onPointerDown(const Offset(10, 10), context);
      expect(context.draft, isNotNull);
      expect(context.draft!.type, equals(ShapeType.rectangle));
      expect(context.draft!.start, equals(const Offset(10, 10)));

      // 2. Pointer Move
      tool.onPointerMove(const Offset(100, 100), context);
      expect(context.draft!.end, equals(const Offset(100, 100)));

      // 3. Pointer Up
      tool.onPointerUp(const Offset(100, 100), context);
      expect(context.draft, isNull);
      expect(context.committedElements.length, equals(1));
      expect(context.committedElements.first.end, equals(const Offset(100, 100)));
    });

    test('FreehandTool snaps rough circle to ShapeType.ellipse when autoShapeRecognition is true', () {
      final tool = FreehandTool(toolType: Tool.pen);
      final context = MockToolContext()..autoShapeRecognition = true;

      tool.onPointerDown(const Offset(100, 50), context);
      // Generate rough circle points (radius 50 around (100, 100))
      for (var deg = 0; deg <= 360; deg += 15) {
        final rad = deg * 3.14159 / 180;
        tool.onPointerMove(Offset(100 + 50 * math.cos(rad), 100 + 50 * math.sin(rad)), context);
      }
      tool.onPointerUp(const Offset(150, 100), context);

      expect(context.committedElements.length, equals(1));
      expect(context.committedElements.first.type, equals(ShapeType.ellipse));
    });

    test('ConnectorTool snaps to nearby shape anchor points', () {
      final tool = ConnectorTool(toolType: Tool.arrow, shapeType: ShapeType.arrow);
      final shape = const BoardElement(
        id: 'box_1',
        type: ShapeType.rectangle,
        start: Offset(50, 50),
        end: Offset(150, 150),
      );
      final context = MockToolContext()..elements = [shape];

      // Top anchor of shape is (100, 50). Click near it at (102, 52).
      tool.onPointerDown(const Offset(102, 52), context);
      expect(context.draft!.start, equals(const Offset(100, 50)));
      expect(context.draft!.startBinding, isNotNull);
      expect(context.draft!.startBinding!.elementId, equals('box_1'));

      tool.onPointerMove(const Offset(300, 300), context);
      tool.onPointerUp(const Offset(300, 300), context);

      expect(context.committedElements.length, equals(1));
      expect(context.committedElements.first.startBinding, isNotNull);
    });

    test('SelectTool resizes element when dragging transform handle', () {
      final tool = SelectTool();
      final element = const BoardElement(
        id: 'el_1',
        type: ShapeType.rectangle,
        start: Offset(100, 100),
        end: Offset(200, 200),
      );
      final context = MockToolContext()
        ..elements = [element]
        ..selectedIds = {'el_1'};

      // Bottom-right handle is at (200, 200)
      tool.onPointerDown(const Offset(200, 200), context);
      expect(tool.cursor, equals(SystemMouseCursors.resizeUpLeftDownRight));

      // Drag to (250, 250)
      tool.onPointerMove(const Offset(250, 250), context);
      expect(context.elements.first.bounds.width, closeTo(150, 1.0));
      expect(context.elements.first.bounds.height, closeTo(150, 1.0));

      tool.onPointerUp(const Offset(250, 250), context);
    });

    test('ConnectorTool onPointerHover sets connection anchor', () {
      final tool = ConnectorTool(toolType: Tool.arrow, shapeType: ShapeType.arrow);
      final shape = const BoardElement(
        id: 'box_1',
        type: ShapeType.rectangle,
        start: Offset(50, 50),
        end: Offset(150, 150),
      );
      final context = MockToolContext()..elements = [shape];

      // Top anchor is (100, 50). Hover near it at (102, 51).
      tool.onPointerHover(const Offset(102, 51), context);
      expect(context.hoveredAnchorElement, equals(shape));
      expect(context.activeAnchorPoint, equals(const Offset(100, 50)));

      // Hover far away
      tool.onPointerHover(const Offset(500, 500), context);
      expect(context.hoveredAnchorElement, isNull);
      expect(context.activeAnchorPoint, isNull);
    });

    test('FreehandTool snaps live draft to shape during pause (380ms)', () async {
      final tool = FreehandTool(toolType: Tool.pen);
      final context = MockToolContext()..autoShapeRecognition = true;

      tool.onPointerDown(const Offset(100, 50), context);
      for (var deg = 0; deg <= 360; deg += 15) {
        final rad = deg * 3.14159 / 180;
        tool.onPointerMove(Offset(100 + 50 * math.cos(rad), 100 + 50 * math.sin(rad)), context);
      }

      // Before pause, draft is still pen
      expect(context.draft!.type, equals(ShapeType.pen));

      // Wait 400ms for pause timer to fire
      await Future<void>.delayed(const Duration(milliseconds: 400));

      // Draft snapped to ellipse in real-time before pointer up!
      expect(context.draft!.type, equals(ShapeType.ellipse));

      tool.onPointerUp(const Offset(150, 100), context);
      expect(context.committedElements.first.type, equals(ShapeType.ellipse));
    });
  });
}
