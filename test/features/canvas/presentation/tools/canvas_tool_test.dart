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
  bool gridSnap = false;

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
  BoardElement? hitTestTopmost(Offset worldPos) {
    for (final el in elements.reversed) {
      if (el.hitTest(worldPos, 6.0)) return el;
    }
    return null;
  }
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
      expect(context.committedElements.first.bounds.width, closeTo(100.0, 1.0));
      expect(context.committedElements.first.bounds.height, closeTo(100.0, 1.0));
    });

    test('FreehandTool snaps rectangle on pointer up and aligns to 24.0 grid when gridSnap is true', () {
      final tool = FreehandTool(toolType: Tool.pen);
      final context = MockToolContext()
        ..autoShapeRecognition = true
        ..gridSnap = true;

      // Draw a rectangle from (50, 50) to (150, 150)
      tool.onPointerDown(const Offset(50, 50), context);
      for (double x = 50; x <= 150; x += 10) {
        tool.onPointerMove(Offset(x, 50), context);
      }
      for (double y = 50; y <= 150; y += 10) {
        tool.onPointerMove(Offset(150, y), context);
      }
      for (double x = 150; x >= 50; x -= 10) {
        tool.onPointerMove(Offset(x, 150), context);
      }
      for (double y = 150; y >= 50; y -= 10) {
        tool.onPointerMove(Offset(50, y), context);
      }
      tool.onPointerUp(const Offset(50, 50), context);

      expect(context.committedElements.length, equals(1));
      final shape = context.committedElements.first;
      expect(shape.type, equals(ShapeType.rectangle));
      // 50 snapped to 24 is 48.0, 150 snapped to 24 is 144.0
      expect(shape.start.dx, equals(48.0));
      expect(shape.start.dy, equals(48.0));
      expect(shape.end.dx, equals(144.0));
      expect(shape.end.dy, equals(144.0));
    });

    test('SelectTool snaps element top-left to 24.0 grid multiples when moving with gridSnap = true', () {
      final tool = SelectTool();
      // Element starts at non-grid coordinates (50, 50)
      final element = const BoardElement(
        id: 'box_grid',
        type: ShapeType.rectangle,
        start: Offset(50, 50),
        end: Offset(150, 150),
      );
      final context = MockToolContext()
        ..elements = [element]
        ..selectedIds = {'box_grid'}
        ..gridSnap = true;

      // Click at (60, 60) and drag by (25, 25)
      tool.onPointerDown(const Offset(60, 60), context);
      tool.onPointerMove(const Offset(85, 85), context);
      tool.onPointerUp(const Offset(85, 85), context);

      // (50 + 25, 50 + 25) = (75, 75). Nearest 24.0 multiple is 72.0!
      final moved = context.elements.firstWhere((e) => e.id == 'box_grid');
      expect(moved.bounds.left, equals(72.0));
      expect(moved.bounds.top, equals(72.0));
    });

    test('SelectTool snaps element top-left to 24.0 grid multiples on FIRST CLICK drag when initially unselected', () {
      final tool = SelectTool();
      final element = const BoardElement(
        id: 'unselected_box',
        type: ShapeType.rectangle,
        start: Offset(50, 50),
        end: Offset(150, 150),
      );
      // Notice: selectedIds starts EMPTY!
      final context = MockToolContext()
        ..elements = [element]
        ..selectedIds = {}
        ..gridSnap = true;

      // Click at (60, 60) and drag by (25, 25)
      tool.onPointerDown(const Offset(60, 60), context);
      tool.onPointerMove(const Offset(85, 85), context);
      tool.onPointerUp(const Offset(85, 85), context);

      final moved = context.elements.firstWhere((e) => e.id == 'unselected_box');
      // Element must have moved on the first click and snapped to 72.0!
      expect(moved.bounds.left, equals(72.0));
      expect(moved.bounds.top, equals(72.0));
      expect(context.selectedIds, contains('unselected_box'));
    });

    test('SelectTool snaps resize handles to 24.0 grid multiples when resizing with gridSnap = true', () {
      final tool = SelectTool();
      final element = const BoardElement(
        id: 'resizable_box',
        type: ShapeType.rectangle,
        start: Offset(48, 48),
        end: Offset(144, 144),
      );
      final context = MockToolContext()
        ..elements = [element]
        ..selectedIds = {'resizable_box'}
        ..gridSnap = true;

      // Bottom-right handle is at (144, 144)
      tool.onPointerDown(const Offset(144, 144), context);
      // Drag down-right by 30px to (174, 174)
      tool.onPointerMove(const Offset(174, 174), context);
      tool.onPointerUp(const Offset(174, 174), context);

      final resized = context.elements.firstWhere((e) => e.id == 'resizable_box');
      // 174 snapped to 24 is 168.0!
      expect(resized.bounds.right, equals(168.0));
      expect(resized.bounds.bottom, equals(168.0));
    });

    test('SelectTool displays smart guides and snaps position when moving with smartGuides = true', () {
      final tool = SelectTool();
      final stationary = const BoardElement(
        id: 'box1',
        type: ShapeType.rectangle,
        start: Offset(100, 100),
        end: Offset(200, 200),
      );
      final moving = const BoardElement(
        id: 'box2',
        type: ShapeType.rectangle,
        start: Offset(100, 300),
        end: Offset(200, 400),
      );
      final context = MockToolContext()
        ..elements = [stationary, moving]
        ..selectedIds = {'box2'}
        ..gridSnap = false
        ..smartGuides = true;

      // Start drag at (150, 350)
      tool.onPointerDown(const Offset(150, 350), context);
      // Move slightly to the right by 2px (to 152, 350) - should snap back to 100 (diff=2 < 10)
      tool.onPointerMove(const Offset(152, 350), context);

      expect(context.snapGuides.isNotEmpty, true);
      final moved = context.elements.firstWhere((e) => e.id == 'box2');
      expect(moved.bounds.left, equals(100.0));

      // Pointer up clears snap guides
      tool.onPointerUp(const Offset(152, 350), context);
      expect(context.snapGuides.isEmpty, true);
    });

    test('SelectTool displays smart guides and snaps handle when resizing with smartGuides = true', () {
      final tool = SelectTool();
      final stationary = const BoardElement(
        id: 'box1',
        type: ShapeType.rectangle,
        start: Offset(200, 100),
        end: Offset(300, 200),
      );
      final resizable = const BoardElement(
        id: 'box2',
        type: ShapeType.rectangle,
        start: Offset(50, 100),
        end: Offset(150, 200), // right is at 150
      );
      final context = MockToolContext()
        ..elements = [stationary, resizable]
        ..selectedIds = {'box2'}
        ..gridSnap = false
        ..smartGuides = true;

      // Center-right handle is at (150, 150)
      tool.onPointerDown(const Offset(150, 150), context);
      // Drag right handle towards 200 (drag by 48px to 198) - within 10px of 200
      tool.onPointerMove(const Offset(198, 150), context);

      expect(context.snapGuides.isNotEmpty, true);
      final resized = context.elements.firstWhere((e) => e.id == 'box2');
      expect(resized.bounds.right, equals(200.0));

      // Pointer up clears snap guides
      tool.onPointerUp(const Offset(198, 150), context);
      expect(context.snapGuides.isEmpty, true);
    });

    test('ShapeTool creates rectangle with coordinates aligned to 24.0 grid when gridSnap = true', () {
      final tool = ShapeTool(toolType: Tool.rectangle, shapeType: ShapeType.rectangle);
      final context = MockToolContext()..gridSnap = true;

      // Draw from (50, 50) to (150, 150)
      tool.onPointerDown(const Offset(50, 50), context);
      tool.onPointerMove(const Offset(150, 150), context);
      tool.onPointerUp(const Offset(150, 150), context);

      expect(context.committedElements.length, equals(1));
      final shape = context.committedElements.first;
      // 50 snapped is 48.0, 150 snapped is 144.0
      expect(shape.start, equals(const Offset(48.0, 48.0)));
      expect(shape.end, equals(const Offset(144.0, 144.0)));
    });

    test('FreehandTool snaps every stroke point to 24.0 grid multiples when gridSnap is true', () {
      final tool = FreehandTool(toolType: Tool.pen);
      final context = MockToolContext()
        ..gridSnap = true
        ..autoShapeRecognition = false; // test pure freehand snapping

      // Start at (26, 25) -> snapped to (24, 24)
      tool.onPointerDown(const Offset(26, 25), context);
      expect(context.draft?.start, equals(const Offset(24.0, 24.0)));

      // Move across grid cells
      tool.onPointerMove(const Offset(50, 25), context); // -> (48, 24)
      tool.onPointerMove(const Offset(75, 49), context); // -> (72, 48)
      tool.onPointerUp(const Offset(75, 49), context);

      expect(context.committedElements.length, equals(1));
      final stroke = context.committedElements.first;
      expect(stroke.type, equals(ShapeType.pen));
      for (final p in stroke.points) {
        expect(p.dx % 24.0, equals(0.0), reason: 'Point $p dx should be multiple of 24');
        expect(p.dy % 24.0, equals(0.0), reason: 'Point $p dy should be multiple of 24');
      }
    });

    test('FreehandTool recognizes fast straight line stroke on pointer up', () {
      final tool = FreehandTool(toolType: Tool.pen);
      final context = MockToolContext()
        ..gridSnap = false
        ..autoShapeRecognition = true;

      // Draw a straight horizontal line
      tool.onPointerDown(const Offset(10, 50), context);
      tool.onPointerMove(const Offset(60, 50), context);
      tool.onPointerMove(const Offset(120, 50), context);
      tool.onPointerUp(const Offset(180, 50), context);

      expect(context.committedElements.length, equals(1));
      final element = context.committedElements.first;
      expect(element.type, equals(ShapeType.line));
      expect(element.start, equals(const Offset(10, 50)));
      expect(element.end.dy, equals(50.0));
    });
  });
}
