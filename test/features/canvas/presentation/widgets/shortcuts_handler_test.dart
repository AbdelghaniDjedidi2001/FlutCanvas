import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/shortcuts_handler.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';

void main() {
  group('CanvasShortcutsHandler Widget Tests', () {
    testWidgets('press V changes active tool to Select', (tester) async {
      final canvasBloc = CanvasBloc();
      final toolCubit = ToolCubit();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: canvasBloc),
            BlocProvider.value(value: toolCubit),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CanvasShortcutsHandler(
                child: SizedBox(key: Key('canvas_body')),
              ),
            ),
          ),
        ),
      );

      // Initially rectangle
      expect(toolCubit.state.currentTool, equals(Tool.rectangle));

      // Press 'V'
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.pump();

      expect(toolCubit.state.currentTool, equals(Tool.select));

      // Press 'P' for Pen
      await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
      await tester.pump();

      expect(toolCubit.state.currentTool, equals(Tool.pen));

      // Press 'G' for Grid Snap
      expect(toolCubit.state.gridSnap, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.pump();
      expect(toolCubit.state.gridSnap, isTrue);

      // Press 'S' for Smart Guides
      expect(toolCubit.state.smartGuides, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.pump();
      expect(toolCubit.state.smartGuides, isFalse);
    });

    testWidgets('press Shift+R and Shift+T selects roundedRectangle and triangle', (tester) async {
      final canvasBloc = CanvasBloc();
      final toolCubit = ToolCubit();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: canvasBloc),
            BlocProvider.value(value: toolCubit),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CanvasShortcutsHandler(
                child: SizedBox(key: Key('canvas_body')),
              ),
            ),
          ),
        ),
      );

      // Hold Shift and press R
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(toolCubit.state.currentTool, equals(Tool.roundedRectangle));

      // Hold Shift and press T
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(toolCubit.state.currentTool, equals(Tool.triangle));
    });
  });
}
