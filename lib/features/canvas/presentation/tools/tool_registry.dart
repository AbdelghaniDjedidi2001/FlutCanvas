import 'package:injectable/injectable.dart';
import '../../domain/models/shape_type.dart';
import '../../domain/models/tool.dart';
import 'canvas_tool.dart';
import 'connector_tool.dart';
import 'eraser_tool.dart';
import 'freehand_tool.dart';
import 'laser_tool.dart';
import 'select_tool.dart';
import 'shape_tool.dart';

@lazySingleton
class ToolRegistry {
  final Map<Tool, CanvasTool> _tools = {};

  ToolRegistry() {
    _registerDefaults();
  }

  void register(CanvasTool tool) {
    _tools[tool.toolType] = tool;
  }

  CanvasTool get(Tool type) {
    return _tools[type] ?? _tools[Tool.select]!;
  }

  void _registerDefaults() {
    // Selection
    register(SelectTool());

    // Shapes
    register(ShapeTool(toolType: Tool.rectangle, shapeType: ShapeType.rectangle));
    register(ShapeTool(
        toolType: Tool.roundedRectangle, shapeType: ShapeType.roundedRectangle));
    register(ShapeTool(toolType: Tool.ellipse, shapeType: ShapeType.ellipse));
    register(ShapeTool(toolType: Tool.diamond, shapeType: ShapeType.diamond));
    register(ShapeTool(toolType: Tool.triangle, shapeType: ShapeType.triangle));
    register(ShapeTool(toolType: Tool.star, shapeType: ShapeType.star));
    register(ShapeTool(toolType: Tool.frame, shapeType: ShapeType.frame));

    // Connectors
    register(ConnectorTool(toolType: Tool.line, shapeType: ShapeType.line));
    register(ConnectorTool(toolType: Tool.arrow, shapeType: ShapeType.arrow));

    // Freehand
    register(FreehandTool(toolType: Tool.pen, isHighlighter: false));
    register(FreehandTool(toolType: Tool.highlighter, isHighlighter: true));

    // Utilities
    register(EraserTool());
    register(LaserTool());
  }
}
