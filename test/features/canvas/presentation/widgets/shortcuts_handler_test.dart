import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/shortcuts_handler.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';
import 'package:flutcanvas/models/tool.dart';

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
    });
  });
}
