import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/snap_guide.dart';
import 'package:flutcanvas/services/alignment_service.dart';

void main() {
  group('AlignmentService tests', () {
    final el1 = BoardElement(
      id: '1',
      type: ShapeType.rectangle,
      start: const Offset(10, 20),
      end: const Offset(50, 60), // w=40, h=40, center=(30, 40)
      color: Colors.black,
    );

    final el2 = BoardElement(
      id: '2',
      type: ShapeType.rectangle,
      start: const Offset(100, 120),
      end: const Offset(160, 180), // w=60, h=60, center=(130, 150)
      color: Colors.black,
    );

    final el3 = BoardElement(
      id: '3',
      type: ShapeType.rectangle,
      start: const Offset(200, 300),
      end: const Offset(240, 340), // w=40, h=40, center=(220, 320)
      color: Colors.black,
    );

    test('align left aligns all selected elements to leftmost bound', () {
      final elements = [el1, el2];
      final aligned = AlignmentService.alignElements(
        allElements: elements,
        selectedIds: {'1', '2'},
        alignment: 'left',
      );

      final alignedEl1 = aligned.firstWhere((e) => e.id == '1');
      final alignedEl2 = aligned.firstWhere((e) => e.id == '2');

      expect(alignedEl1.bounds.left, 10.0);
      expect(alignedEl2.bounds.left, 10.0);
    });

    test('align center aligns elements to horizontal center of bounding box', () {
      final elements = [el1, el2]; // combined left=10, right=160 -> center.dx = 85
      final aligned = AlignmentService.alignElements(
        allElements: elements,
        selectedIds: {'1', '2'},
        alignment: 'center',
      );

      final alignedEl1 = aligned.firstWhere((e) => e.id == '1');
      final alignedEl2 = aligned.firstWhere((e) => e.id == '2');

      expect(alignedEl1.bounds.center.dx, 85.0);
      expect(alignedEl2.bounds.center.dx, 85.0);
    });

    test('align top and bottom aligns correctly', () {
      final elements = [el1, el2]; // combined top=20, bottom=180
      final topAligned = AlignmentService.alignElements(
        allElements: elements,
        selectedIds: {'1', '2'},
        alignment: 'top',
      );

      expect(topAligned.firstWhere((e) => e.id == '1').bounds.top, 20.0);
      expect(topAligned.firstWhere((e) => e.id == '2').bounds.top, 20.0);

      final bottomAligned = AlignmentService.alignElements(
        allElements: elements,
        selectedIds: {'1', '2'},
        alignment: 'bottom',
      );

      expect(bottomAligned.firstWhere((e) => e.id == '1').bounds.bottom, 180.0);
      expect(bottomAligned.firstWhere((e) => e.id == '2').bounds.bottom, 180.0);
    });

    test('distribute horizontally spaces items evenly', () {
      final elements = [el1, el2, el3];
      final distributed = AlignmentService.distributeElements(
        allElements: elements,
        selectedIds: {'1', '2', '3'},
        direction: 'horizontal',
      );

      final d1 = distributed.firstWhere((e) => e.id == '1');
      final d2 = distributed.firstWhere((e) => e.id == '2');
      final d3 = distributed.firstWhere((e) => e.id == '3');

      // Leftmost should stay at 10, rightmost right should stay at 240
      expect(d1.bounds.left, 10.0);
      expect(d3.bounds.right, 240.0);

      // Gap 1 should equal Gap 2
      final gap1 = d2.bounds.left - d1.bounds.right;
      final gap2 = d3.bounds.left - d2.bounds.right;
      expect((gap1 - gap2).abs(), lessThan(0.001));
    });

    test('distribute vertically spaces items evenly', () {
      final elements = [el1, el2, el3];
      final distributed = AlignmentService.distributeElements(
        allElements: elements,
        selectedIds: {'1', '2', '3'},
        direction: 'vertical',
      );

      final d1 = distributed.firstWhere((e) => e.id == '1');
      final d2 = distributed.firstWhere((e) => e.id == '2');
      final d3 = distributed.firstWhere((e) => e.id == '3');

      expect(d1.bounds.top, 20.0);
      expect(d3.bounds.bottom, 340.0);

      final gap1 = d2.bounds.top - d1.bounds.bottom;
      final gap2 = d3.bounds.top - d2.bounds.bottom;
      expect((gap1 - gap2).abs(), lessThan(0.001));
    });
  });

  group('SnapService tests', () {
    final stationary = BoardElement(
      id: 'target',
      type: ShapeType.rectangle,
      start: const Offset(100, 100),
      end: const Offset(200, 200),
      color: Colors.black,
    );

    test('snaps horizontally when close to reference center', () {
      // Moving object center moving towards x=150 (approx x=152)
      final moving = const Rect.fromLTWH(130, 300, 40, 40); // center = 150
      final snapResult = SnapService.calculateSnap(
        initialBounds: moving,
        rawDisplacement: const Offset(2.0, 0.0), // center becomes 152, stationary center is 150
        otherElements: [stationary],
        zoom: 1.0,
        snapThresholdPx: 8.0,
      );

      // Raw displacement was +2.0, but snap should adjust by -2.0 to hit 150.0 center
      expect(snapResult.snappedDisplacement.dx, 0.0);
      expect(snapResult.guides.isNotEmpty, true);
      expect(snapResult.guides.first.type, SnapGuideType.vertical);
      expect(snapResult.guides.first.position, 150.0);
    });

    test('does not snap when distance exceeds threshold', () {
      final moving = const Rect.fromLTWH(130, 300, 40, 40);
      final snapResult = SnapService.calculateSnap(
        initialBounds: moving,
        rawDisplacement: const Offset(100.0, 0.0), // clearly outside 8px threshold
        otherElements: [stationary],
        zoom: 1.0,
        snapThresholdPx: 8.0,
      );

      expect(snapResult.snappedDisplacement.dx, 100.0);
      expect(snapResult.guides.isEmpty, true);
    });
  });
}
