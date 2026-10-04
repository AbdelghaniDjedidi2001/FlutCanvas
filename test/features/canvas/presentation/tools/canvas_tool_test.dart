import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/snap_guide.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'package:flutcanvas/features/canvas/presentation/tools/canvas_tool_context.dart';
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

  @override
  void commitElement(BoardElement element) => committedElements.add(element);

  @override
  void commitElements(List<BoardElement> els) => committedElements.addAll(els);

  @override
  void updateElement(BoardElement element) {}

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
  });
}
