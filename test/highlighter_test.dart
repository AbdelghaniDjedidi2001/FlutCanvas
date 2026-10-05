import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/element_renderer.dart';
import 'package:flutcanvas/features/canvas/presentation/tools/canvas_tool_context.dart';
import 'package:flutcanvas/features/canvas/presentation/tools/freehand_tool.dart';
import 'package:flutcanvas/features/export/data/services/svg_export_service.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';

class _MockCanvasToolContext implements CanvasToolContext {
  BoardElement? draft;
  BoardElement? committed;
  Color testStrokeColor = kInk;
  double testStrokeWidth = 2.5;

  @override
  String generateElementId() => 'highlighter_1';

  @override
  void setDraft(BoardElement? element) {
    draft = element;
  }

  @override
  void commitElement(BoardElement element) {
    committed = element;
  }

  @override
  Color get strokeColor => testStrokeColor;

  @override
  Color get fillColor => Colors.transparent;

  @override
  double get strokeWidth => testStrokeWidth;

  @override
  StrokeStyle get strokeStyle => StrokeStyle.solid;

  @override
  FillStyle get fillStyle => FillStyle.none;

  @override
  DrawStyle get drawStyle => DrawStyle.clean;

  @override
  double get fontSize => 22.0;

  @override
  double get opacity => 1.0;

  @override
  bool get autoShapeRecognition => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Highlighter BoardColors Display & Vibrance Tests', () {
    test('when selecting white, it is white in both dark and white modes', () {
      const darkColors = BoardColors.dark;
      const lightColors = BoardColors.light;

      final darkResult = darkColors.displayHighlighter(Colors.white);
      final lightResult = lightColors.displayHighlighter(Colors.white);

      expect(darkResult.toARGB32(), equals(Colors.white.toARGB32()));
      expect(lightResult.toARGB32(), equals(Colors.white.toARGB32()));
    });

    test('when selecting black, it is black in both dark and white modes', () {
      const darkColors = BoardColors.dark;
      const lightColors = BoardColors.light;

      final darkResult = darkColors.displayHighlighter(kInk);
      final lightResult = lightColors.displayHighlighter(kInk);
      final darkBlack = darkColors.displayHighlighter(Colors.black);
      final lightBlack = lightColors.displayHighlighter(Colors.black);

      expect(darkResult.toARGB32(), equals(const Color(0xFF1F2430).toARGB32()));
      expect(lightResult.toARGB32(), equals(const Color(0xFF1F2430).toARGB32()));
      expect(darkBlack.toARGB32(), equals(const Color(0xFF1F2430).toARGB32()));
      expect(lightBlack.toARGB32(), equals(const Color(0xFF1F2430).toARGB32()));
    });

    test('preserves vibrant highlighter palette colors across modes', () {
      const darkColors = BoardColors.dark;
      const lightColors = BoardColors.light;
      const neonGreen = Color(0xFF69DB7C);
      const neonPink = Color(0xFFFF8787);

      expect(darkColors.displayHighlighter(neonGreen).toARGB32(), equals(neonGreen.toARGB32()));
      expect(lightColors.displayHighlighter(neonGreen).toARGB32(), equals(neonGreen.toARGB32()));
      expect(darkColors.displayHighlighter(neonPink).toARGB32(), equals(neonPink.toARGB32()));
      expect(lightColors.displayHighlighter(neonPink).toARGB32(), equals(neonPink.toARGB32()));
    });
  });

  group('FreehandTool Highlighter Creation Tests', () {
    test('when selecting white, FreehandTool creates white highlighter without turning yellow', () {
      final tool = FreehandTool(toolType: Tool.highlighter, isHighlighter: true);
      final ctx = _MockCanvasToolContext();
      ctx.testStrokeColor = Colors.white;

      tool.onPointerDown(const Offset(50, 50), ctx);

      expect(ctx.draft, isNotNull);
      expect(ctx.draft!.type, equals(ShapeType.highlighter));
      // Must be pure white, NOT yellow!
      expect(ctx.draft!.color.toARGB32(), equals(Colors.white.toARGB32()));
      expect(ctx.draft!.strokeWidth, equals(24.0));
      expect(ctx.draft!.opacity, equals(1.0));
    });

    test('when selecting black, FreehandTool creates black highlighter without turning yellow', () {
      final tool = FreehandTool(toolType: Tool.highlighter, isHighlighter: true);
      final ctx = _MockCanvasToolContext();
      ctx.testStrokeColor = kInk;

      tool.onPointerDown(const Offset(50, 50), ctx);

      expect(ctx.draft, isNotNull);
      expect(ctx.draft!.type, equals(ShapeType.highlighter));
      // Must be black ink, NOT yellow!
      expect(ctx.draft!.color.toARGB32(), equals(kInk.toARGB32()));
      expect(ctx.draft!.strokeWidth, equals(24.0));
      expect(ctx.draft!.opacity, equals(1.0));
    });

    test('retains user-chosen highlighter color on pointer down', () {
      final tool = FreehandTool(toolType: Tool.highlighter, isHighlighter: true);
      final ctx = _MockCanvasToolContext();
      ctx.testStrokeColor = const Color(0xFF4DABF7); // Neon Cyan

      tool.onPointerDown(const Offset(100, 100), ctx);

      expect(ctx.draft, isNotNull);
      expect(ctx.draft!.color.toARGB32(), equals(const Color(0xFF4DABF7).toARGB32()));
    });
  });

  group('ToolCubit Highlighter Switching Tests', () {
    test('switching to highlighter automatically sets vibrant color and chisel width', () {
      final cubit = ToolCubit();
      expect(cubit.state.currentTool, equals(Tool.rectangle));
      expect(cubit.state.strokeColor, equals(kInk));

      cubit.setTool(Tool.highlighter);

      expect(cubit.state.currentTool, equals(Tool.highlighter));
      expect(cubit.state.strokeColor.toARGB32(), equals(const Color(0xFFFFD43B).toARGB32()));
      expect(cubit.state.strokeWidth, equals(24.0));

      // Switching back to pen restores ink and pen stroke width
      cubit.setTool(Tool.pen);
      expect(cubit.state.currentTool, equals(Tool.pen));
      expect(cubit.state.strokeColor, equals(kInk));
      expect(cubit.state.strokeWidth, equals(2.5));
    });
  });

  group('ElementRenderer and SvgExportService Highlighter Tests', () {
    test('ElementRenderer executes draw for highlighter without errors', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      final highlighter = BoardElement(
        id: 'hl_1',
        type: ShapeType.highlighter,
        start: const Offset(20, 20),
        end: const Offset(120, 20),
        points: const [Offset(20, 20), Offset(70, 20), Offset(120, 20)],
        color: const Color(0xFFFFD43B),
        strokeWidth: 24.0,
      );

      // Render in dark mode
      ElementRenderer.draw(canvas, highlighter, BoardColors.dark);
      // Render in light mode
      ElementRenderer.draw(canvas, highlighter, BoardColors.light);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('SvgExportService exports vivid highlighter with high-contrast color and opacity', () {
      final highlighter = BoardElement(
        id: 'hl_svg',
        type: ShapeType.highlighter,
        start: const Offset(10, 10),
        end: const Offset(100, 10),
        points: const [Offset(10, 10), Offset(55, 10), Offset(100, 10)],
        color: const Color(0xFFFFD43B),
        strokeWidth: 24.0,
      );

      final svgLight = SvgExportService.exportToSvg(
        elements: [highlighter],
        colors: BoardColors.light,
      );

      expect(svgLight, contains('stroke-linecap="round"'));
      expect(svgLight, contains('opacity="0.5"'));

      final svgDark = SvgExportService.exportToSvg(
        elements: [highlighter],
        colors: BoardColors.dark,
      );

      expect(svgDark, contains('opacity="0.6"'));
    });
  });
}
