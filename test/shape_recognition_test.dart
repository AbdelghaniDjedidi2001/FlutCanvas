import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/data/services/shape_recognition_service.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/zoom_controls.dart';

void main() {
  group('ShapeRecognitionService Tests', () {
    List<Offset> generateCirclePoints(Offset center, double radius, {int numPoints = 60, double noise = 2.0}) {
      final rng = math.Random(42);
      final points = <Offset>[];
      for (int i = 0; i <= numPoints; i++) {
        final angle = (i / numPoints) * 2 * math.pi;
        final r = radius + (rng.nextDouble() - 0.5) * noise;
        points.add(Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle)));
      }
      return points;
    }

    List<Offset> generateRectPoints(Rect rect, {int pointsPerSide = 15, double noise = 1.5}) {
      final rng = math.Random(42);
      final points = <Offset>[];

      // Top edge: TL -> TR
      for (int i = 0; i <= pointsPerSide; i++) {
        final t = i / pointsPerSide;
        final x = rect.left + t * rect.width;
        final y = rect.top + (rng.nextDouble() - 0.5) * noise;
        points.add(Offset(x, y));
      }
      // Right edge: TR -> BR
      for (int i = 1; i <= pointsPerSide; i++) {
        final t = i / pointsPerSide;
        final x = rect.right + (rng.nextDouble() - 0.5) * noise;
        final y = rect.top + t * rect.height;
        points.add(Offset(x, y));
      }
      // Bottom edge: BR -> BL
      for (int i = 1; i <= pointsPerSide; i++) {
        final t = i / pointsPerSide;
        final x = rect.right - t * rect.width;
        final y = rect.bottom + (rng.nextDouble() - 0.5) * noise;
        points.add(Offset(x, y));
      }
      // Left edge: BL -> TL
      for (int i = 1; i <= pointsPerSide; i++) {
        final t = i / pointsPerSide;
        final x = rect.left + (rng.nextDouble() - 0.5) * noise;
        final y = rect.bottom - t * rect.height;
        points.add(Offset(x, y));
      }
      return points;
    }

    List<Offset> generateTrianglePoints(Offset p1, Offset p2, Offset p3, {int pointsPerSide = 15}) {
      final points = <Offset>[];
      for (int i = 0; i <= pointsPerSide; i++) {
        points.add(Offset.lerp(p1, p2, i / pointsPerSide)!);
      }
      for (int i = 1; i <= pointsPerSide; i++) {
        points.add(Offset.lerp(p2, p3, i / pointsPerSide)!);
      }
      for (int i = 1; i <= pointsPerSide; i++) {
        points.add(Offset.lerp(p3, p1, i / pointsPerSide)!);
      }
      return points;
    }

    List<Offset> generateDiamondPoints(Rect rect, {int pointsPerSide = 15}) {
      final top = Offset(rect.center.dx, rect.top);
      final right = Offset(rect.right, rect.center.dy);
      final bottom = Offset(rect.center.dx, rect.bottom);
      final left = Offset(rect.left, rect.center.dy);

      final points = <Offset>[];
      for (int i = 0; i <= pointsPerSide; i++) {
        points.add(Offset.lerp(top, right, i / pointsPerSide)!);
      }
      for (int i = 1; i <= pointsPerSide; i++) {
        points.add(Offset.lerp(right, bottom, i / pointsPerSide)!);
      }
      for (int i = 1; i <= pointsPerSide; i++) {
        points.add(Offset.lerp(bottom, left, i / pointsPerSide)!);
      }
      for (int i = 1; i <= pointsPerSide; i++) {
        points.add(Offset.lerp(left, top, i / pointsPerSide)!);
      }
      return points;
    }

    List<Offset> generateStarPoints(Offset center, double outerR, double innerR) {
      final points = <Offset>[];
      const int numTips = 5;
      const int totalPoints = numTips * 2;
      for (int i = 0; i <= totalPoints; i++) {
        final angle = (i / totalPoints) * 2 * math.pi - math.pi / 2;
        final r = (i % 2 == 0) ? outerR : innerR;
        points.add(Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle)));
      }
      return points;
    }

    test('recognizes rough circle as ShapeType.ellipse', () {
      final circlePoints = generateCirclePoints(const Offset(100, 100), 50.0);
      final result = ShapeRecognitionService.recognizeShape(circlePoints);

      expect(result, isNotNull);
      expect(result!.shapeType, ShapeType.ellipse);
      expect(result.confidence, greaterThanOrEqualTo(0.6));
    });

    test('recognizes rough rectangle as ShapeType.rectangle', () {
      final rectPoints = generateRectPoints(const Rect.fromLTWH(50, 50, 140, 90));
      final result = ShapeRecognitionService.recognizeShape(rectPoints);

      expect(result, isNotNull);
      expect(result!.shapeType, ShapeType.rectangle);
      expect(result.confidence, greaterThanOrEqualTo(0.6));
    });

    test('recognizes rough triangle as ShapeType.triangle', () {
      final triPoints = generateTrianglePoints(
        const Offset(100, 20),
        const Offset(180, 140),
        const Offset(20, 140),
      );
      final result = ShapeRecognitionService.recognizeShape(triPoints);

      expect(result, isNotNull);
      expect(result!.shapeType, ShapeType.triangle);
      expect(result.confidence, greaterThanOrEqualTo(0.55));
    });

    test('recognizes diamond as ShapeType.diamond', () {
      final diamondPoints = generateDiamondPoints(const Rect.fromLTWH(40, 40, 120, 120));
      final result = ShapeRecognitionService.recognizeShape(diamondPoints);

      expect(result, isNotNull);
      expect(result!.shapeType, ShapeType.diamond);
      expect(result.confidence, greaterThanOrEqualTo(0.55));
    });

    test('recognizes 5-pointed star as ShapeType.star', () {
      final starPoints = generateStarPoints(const Offset(100, 100), 60.0, 25.0);
      final result = ShapeRecognitionService.recognizeShape(starPoints);

      expect(result, isNotNull);
      expect(result!.shapeType, ShapeType.star);
    });

    test('recognizes straight line as ShapeType.line', () {
      final linePoints = <Offset>[];
      for (int i = 0; i <= 30; i++) {
        final t = i / 30;
        linePoints.add(Offset(20 + t * 200, 30 + t * 100));
      }
      final result = ShapeRecognitionService.recognizeShape(linePoints);

      expect(result, isNotNull);
      expect(result!.shapeType, ShapeType.line);
    });

    test('recognizes perfectly horizontal straight line as ShapeType.line', () {
      final linePoints = <Offset>[];
      for (int i = 0; i <= 30; i++) {
        final t = i / 30;
        linePoints.add(Offset(20 + t * 200, 50));
      }
      final result = ShapeRecognitionService.recognizeShape(linePoints);

      expect(result, isNotNull);
      expect(result!.shapeType, ShapeType.line);
    });

    test('recognizes perfectly vertical straight line as ShapeType.line', () {
      final linePoints = <Offset>[];
      for (int i = 0; i <= 30; i++) {
        final t = i / 30;
        linePoints.add(Offset(50, 20 + t * 200));
      }
      final result = ShapeRecognitionService.recognizeShape(linePoints);

      expect(result, isNotNull);
      expect(result!.shapeType, ShapeType.line);
    });

    test('recognizes arrow stroke with arrowhead as ShapeType.arrow', () {
      final arrowPoints = <Offset>[];
      // Main shaft
      for (int i = 0; i <= 25; i++) {
        final t = i / 25;
        arrowPoints.add(Offset(20 + t * 150, 80));
      }
      // Arrowhead barb
      arrowPoints.add(const Offset(145, 65));
      arrowPoints.add(const Offset(170, 80));
      arrowPoints.add(const Offset(145, 95));

      final result = ShapeRecognitionService.recognizeShape(arrowPoints);

      expect(result, isNotNull);
      expect(result!.shapeType, ShapeType.arrow);
    });

    test('rejects small dots and random squiggles', () {
      final dotPoints = [
        const Offset(10, 10),
        const Offset(11, 11),
        const Offset(10, 12),
      ];
      expect(ShapeRecognitionService.recognizeShape(dotPoints), isNull);

      final tinyPoints = [
        const Offset(10, 10),
        const Offset(12, 11),
        const Offset(13, 14),
        const Offset(11, 15),
        const Offset(10, 10),
        const Offset(10, 11),
      ];
      expect(ShapeRecognitionService.recognizeShape(tinyPoints), isNull);
    });

    test('morphToRecognizedShape converts freehand BoardElement to clean vector', () {
      final circlePoints = generateCirclePoints(const Offset(120, 120), 40.0);
      final freehandElement = BoardElement(
        id: 'el_1',
        type: ShapeType.pen,
        start: circlePoints.first,
        end: circlePoints.last,
        points: circlePoints,
        color: Colors.deepPurple,
        strokeWidth: 3.0,
      );

      final morphed = ShapeRecognitionService.morphToRecognizedShape(
        freehandElement: freehandElement,
      );

      expect(morphed, isNotNull);
      expect(morphed!.type, ShapeType.ellipse);
      expect(morphed.points, isEmpty);
      expect(morphed.color, Colors.deepPurple);
      expect(morphed.strokeWidth, 3.0);
    });

    test('recognizes hand-drawn square with rounded corners as rectangle / rounded box, NOT ellipse', () {
      final square = <Offset>[];
      final rng = math.Random(42);
      // Square with slight corner rounding (r = 10 on 100x100)
      for (double x = 60; x <= 140; x += 5) {
        square.add(Offset(x + (rng.nextDouble() - 0.5) * 3, 50));
      }
      for (double y = 60; y <= 140; y += 5) {
        square.add(Offset(150, y + (rng.nextDouble() - 0.5) * 3));
      }
      for (double x = 140; x >= 60; x -= 5) {
        square.add(Offset(x + (rng.nextDouble() - 0.5) * 3, 150));
      }
      for (double y = 140; y >= 60; y -= 5) {
        square.add(Offset(50, y + (rng.nextDouble() - 0.5) * 3));
      }
      square.add(square.first);

      final result = ShapeRecognitionService.recognizeShape(square);
      expect(result, isNotNull);
      expect(
        result!.shapeType == ShapeType.rectangle || result.shapeType == ShapeType.roundedRectangle,
        isTrue,
        reason: 'Square should be recognized as rectangle or roundedRectangle, but got ${result.shapeType}',
      );
    });

    test('recognizes tall/vertical rectangle as rectangle, NOT ellipse', () {
      final tallRect = generateRectPoints(const Rect.fromLTWH(50, 50, 80, 160));
      final result = ShapeRecognitionService.recognizeShape(tallRect);
      expect(result, isNotNull);
      expect(result!.shapeType, ShapeType.rectangle);
    });

    test('recognizes triangle drawn starting from base as triangle, NOT diamond or circle', () {
      final tri = <Offset>[];
      final rng = math.Random(42);
      for (double t = 0; t <= 1; t += 0.05) {
        tri.add(Offset(50 + t * 100 + (rng.nextDouble() - 0.5) * 3, 150));
      }
      for (double t = 0; t <= 1; t += 0.05) {
        tri.add(Offset(150 - t * 50 + (rng.nextDouble() - 0.5) * 3, 150 - t * 100));
      }
      for (double t = 0; t <= 1; t += 0.05) {
        tri.add(Offset(100 - t * 50 + (rng.nextDouble() - 0.5) * 3, 50 + t * 100));
      }

      final result = ShapeRecognitionService.recognizeShape(tri);
      expect(result, isNotNull);
      expect(result!.shapeType, ShapeType.triangle);
    });

    test('rejects open curved arc / semicircle so it is NOT converted to circle/ellipse', () {
      final arc = <Offset>[];
      for (double a = 0; a <= math.pi; a += 0.1) {
        arc.add(Offset(100 + 40 * math.cos(a), 100 + 40 * math.sin(a)));
      }
      final result = ShapeRecognitionService.recognizeShape(arc);
      expect(result, isNull, reason: 'Open arc must not be converted to circle/ellipse');
    });
  });

  group('ZoomControls Shape Snapping Toggle Tests', () {
    testWidgets('renders shape snapping toggle button and reacts to tap', (tester) async {
      bool shapeSnapping = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ZoomControls(
                  zoom: 1.0,
                  onZoomIn: () {},
                  onZoomOut: () {},
                  onResetZoom: () {},
                  isGridSnap: false,
                  onToggleGridSnap: () {},
                  isShapeSnapping: shapeSnapping,
                  onToggleShapeSnapping: () {
                    setState(() {
                      shapeSnapping = !shapeSnapping;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.polyline_rounded), findsOneWidget);
      expect(shapeSnapping, isTrue);

      await tester.tap(find.byIcon(Icons.polyline_rounded));
      await tester.pumpAndSettle();

      expect(shapeSnapping, isFalse);
    });
  });
}
