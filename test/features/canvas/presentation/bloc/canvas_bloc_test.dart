import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/data/services/alignment_service.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connection_binding.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_state.dart';

void main() {
  group('CanvasBloc Tests', () {
    late CanvasBloc bloc;

    final rect1 = BoardElement(
      id: 'r1',
      type: ShapeType.rectangle,
      start: const Offset(10, 10),
      end: const Offset(100, 100),
      color: Colors.black,
    );

    final rect2 = BoardElement(
      id: 'r2',
      type: ShapeType.rectangle,
      start: const Offset(150, 150),
      end: const Offset(250, 250),
      color: Colors.blue,
    );

    setUp(() {
      bloc = CanvasBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has empty elements and no selection', () {
      expect(bloc.state.elements, isEmpty);
      expect(bloc.state.selectedIds, isEmpty);
      expect(bloc.state.canUndo, isFalse);
      expect(bloc.state.canRedo, isFalse);
    });

    blocTest<CanvasBloc, CanvasState>(
      'loads elements into state',
      build: () => bloc,
      act: (b) => b.add(CanvasEvent.loadElements([rect1, rect2])),
      expect: () => [
        CanvasState(
          elements: [rect1, rect2],
          selectedIds: {},
          canUndo: false,
          canRedo: false,
        ),
      ],
    );

    blocTest<CanvasBloc, CanvasState>(
      'adds element and updates undo capability',
      build: () => bloc,
      act: (b) => b.add(CanvasEvent.addElement(rect1)),
      expect: () => [
        CanvasState(
          elements: [rect1],
          canUndo: true,
          canRedo: false,
        ),
      ],
    );

    blocTest<CanvasBloc, CanvasState>(
      'selects an element and singleSelectedElement getter works',
      build: () => bloc,
      seed: () => CanvasState(elements: [rect1, rect2]),
      act: (b) => b.add(const CanvasEvent.selectElement('r1')),
      expect: () => [
        CanvasState(
          elements: [rect1, rect2],
          selectedIds: {'r1'},
        ),
      ],
      verify: (b) {
        expect(b.state.isSingleSelection, isTrue);
        expect(b.state.singleSelectedElement?.id, equals('r1'));
      },
    );

    blocTest<CanvasBloc, CanvasState>(
      'moves selected element by delta',
      build: () => bloc,
      seed: () => CanvasState(
        elements: [rect1, rect2],
        selectedIds: {'r1'},
      ),
      act: (b) => b.add(const CanvasEvent.moveSelected(Offset(20, 30))),
      expect: () => [
        CanvasState(
          elements: [rect1.translated(const Offset(20, 30)), rect2],
          selectedIds: {'r1'},
        ),
      ],
    );

    blocTest<CanvasBloc, CanvasState>(
      'undoes and redoes element addition',
      build: () => bloc,
      act: (b) {
        b.add(CanvasEvent.addElement(rect1));
        b.add(const CanvasEvent.undo());
        b.add(const CanvasEvent.redo());
      },
      expect: () => [
        CanvasState(elements: [rect1], canUndo: true, canRedo: false),
        const CanvasState(elements: [], selectedIds: {}, canUndo: false, canRedo: true),
        CanvasState(elements: [rect1], selectedIds: {}, canUndo: true, canRedo: false),
      ],
    );

    blocTest<CanvasBloc, CanvasState>(
      'groups selected elements with same groupId',
      build: () => bloc,
      seed: () => CanvasState(
        elements: [rect1, rect2],
        selectedIds: {'r1', 'r2'},
      ),
      act: (b) => b.add(const CanvasEvent.groupSelected()),
      verify: (b) {
        final g1 = b.state.elements.first.groupId;
        final g2 = b.state.elements.last.groupId;
        expect(g1, isNotNull);
        expect(g1, equals(g2));
      },
    );

    blocTest<CanvasBloc, CanvasState>(
      'aligns elements horizontally',
      build: () => bloc,
      seed: () => CanvasState(
        elements: [rect1, rect2],
        selectedIds: {'r1', 'r2'},
      ),
      act: (b) => b.add(const CanvasEvent.alignSelected(AlignDirection.left)),
      verify: (b) {
        expect(b.state.elements[0].bounds.left, equals(10.0));
        expect(b.state.elements[1].bounds.left, equals(10.0));
      },
    );

    blocTest<CanvasBloc, CanvasState>(
      'recalculates connected arrows on element translation',
      build: () => bloc,
      seed: () {
        final arrow = BoardElement(
          id: 'arr1',
          type: ShapeType.arrow,
          start: const Offset(100, 55),
          end: const Offset(150, 200),
          color: Colors.black,
          startBinding: const ConnectionBinding(
            elementId: 'r1',
            anchor: AnchorPoint.right,
          ),
        );
        return CanvasState(
          elements: [rect1, arrow],
          selectedIds: {'r1'},
        );
      },
      act: (b) => b.add(const CanvasEvent.moveSelected(Offset(50, 0))),
      verify: (b) {
        final updatedArrow =
            b.state.elements.firstWhere((e) => e.id == 'arr1');
        expect(updatedArrow.start.dx, equals(150.0));
      },
    );
  });
}
