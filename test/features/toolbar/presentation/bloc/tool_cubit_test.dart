import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_state.dart';

void main() {
  group('ToolCubit Tests', () {
    late ToolCubit cubit;

    setUp(() {
      cubit = ToolCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state defaults to rectangle and clean stroke', () {
      expect(cubit.state.currentTool, equals(Tool.rectangle));
      expect(cubit.state.strokeWidth, equals(2.5));
      expect(cubit.state.drawStyle, equals(DrawStyle.clean));
      expect(cubit.state.isPropertiesOpen, isFalse);
    });

    blocTest<ToolCubit, ToolState>(
      'setTool updates active tool',
      build: () => cubit,
      act: (c) => c.setTool(Tool.pen),
      expect: () => [
        const ToolState(currentTool: Tool.pen),
      ],
    );

    blocTest<ToolCubit, ToolState>(
      'setStrokeColor and setFillColor update colors',
      build: () => cubit,
      act: (c) {
        c.setStrokeColor(Colors.red);
        c.setFillColor(Colors.blue);
      },
      expect: () => [
        const ToolState(strokeColor: Colors.red),
        const ToolState(strokeColor: Colors.red, fillColor: Colors.blue),
      ],
    );

    blocTest<ToolCubit, ToolState>(
      'togglePropertiesPanel toggles panel visibility',
      build: () => cubit,
      act: (c) => c.togglePropertiesPanel(),
      expect: () => [
        const ToolState(isPropertiesOpen: true),
      ],
    );
  });
}
