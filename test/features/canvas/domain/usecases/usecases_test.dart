import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/data/services/alignment_service.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/usecases/align_elements_usecase.dart';
import 'package:flutcanvas/features/canvas/domain/usecases/distribute_elements_usecase.dart';
import 'package:flutcanvas/features/canvas/domain/usecases/group_elements_usecase.dart';
import 'package:flutcanvas/features/canvas/domain/usecases/ungroup_elements_usecase.dart';

void main() {
  group('Domain Use Cases Tests', () {
    final el1 = BoardElement(
      id: 'el_1',
      type: ShapeType.rectangle,
      start: const Offset(10, 20),
      end: const Offset(50, 60),
    );

    final el2 = BoardElement(
      id: 'el_2',
      type: ShapeType.rectangle,
      start: const Offset(100, 80),
      end: const Offset(160, 120),
    );

    test('AlignElementsUseCase aligns selected elements to left', () {
      const alignUseCase = AlignElementsUseCase();
      final result = alignUseCase(
        allElements: [el1, el2],
        selectedIds: {'el_1', 'el_2'},
        direction: AlignDirection.left,
      );

      final alignedEl1 = result.firstWhere((e) => e.id == 'el_1');
      final alignedEl2 = result.firstWhere((e) => e.id == 'el_2');

      expect(alignedEl1.bounds.left, equals(10.0));
      expect(alignedEl2.bounds.left, equals(10.0));
    });

    test('GroupElementsUseCase assigns groupId to selected elements', () {
      const groupUseCase = GroupElementsUseCase();
      final result = groupUseCase(
        allElements: [el1, el2],
        selectedIds: {'el_1', 'el_2'},
        groupId: 'group_abc',
      );

      expect(result.every((e) => e.groupId == 'group_abc'), isTrue);
    });

    test('UngroupElementsUseCase clears matching groupId', () {
      final grouped1 = el1.copyWith(groupId: 'group_abc');
      final grouped2 = el2.copyWith(groupId: 'group_abc');

      const ungroupUseCase = UngroupElementsUseCase();
      final result = ungroupUseCase(
        allElements: [grouped1, grouped2],
        selectedIds: {'el_1'},
      );

      expect(result.every((e) => e.groupId == null), isTrue);
    });
  });
}
