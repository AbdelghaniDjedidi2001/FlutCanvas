import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/features/broadcast/domain/models/broadcast_message.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/laser_painter.dart';

void main() {
  group('BroadcastMessage', () {
    test('serializes and deserializes snapshot message', () {
      final element = BoardElement(
        id: 'el_1',
        type: ShapeType.rectangle,
        start: const Offset(10, 20),
        end: const Offset(100, 80),
        text: 'Architecture Node',
      );

      final msg = BroadcastMessage.snapshot(
        elements: [element],
        isDark: true,
        boardName: 'System Design',
        pan: const Offset(100, -50),
        zoom: 1.5,
      );

      final jsonStr = msg.toJsonString();
      final parsed = BroadcastMessage.fromJsonString(jsonStr);

      expect(parsed.type, BroadcastMessageType.snapshot);
      expect(parsed.data['boardName'], 'System Design');
      expect(parsed.data['isDark'], isTrue);
      expect(parsed.data['panX'], 100.0);
      expect(parsed.data['panY'], -50.0);
      expect(parsed.data['zoom'], 1.5);
      expect(parsed.data['elements'], isList);
      expect((parsed.data['elements'] as List).length, 1);
    });

    test('serializes and deserializes viewport message', () {
      final msg = BroadcastMessage.viewport(
        pan: const Offset(250.5, 420.0),
        zoom: 2.0,
      );

      final jsonStr = msg.toJsonString();
      final parsed = BroadcastMessage.fromJsonString(jsonStr);

      expect(parsed.type, BroadcastMessageType.viewport);
      expect(parsed.data['panX'], 250.5);
      expect(parsed.data['panY'], 420.0);
      expect(parsed.data['zoom'], 2.0);
    });

    test('serializes and deserializes laser message', () {
      final now = DateTime.now();
      final points = [
        LaserPoint(point: const Offset(100, 200), time: now),
        LaserPoint(point: const Offset(105, 208), time: now),
      ];

      final msg = BroadcastMessage.laser(trail: points);
      final jsonStr = msg.toJsonString();
      final parsed = BroadcastMessage.fromJsonString(jsonStr);

      expect(parsed.type, BroadcastMessageType.laser);
      final rawPoints = parsed.data['points'] as List;
      expect(rawPoints.length, 2);
      expect(rawPoints[0]['x'], 100.0);
      expect(rawPoints[0]['y'], 200.0);
    });

    test('serializes and deserializes slideChange message', () {
      final msg = BroadcastMessage.slideChange(
        slideIndex: 3,
        totalSlides: 8,
        title: 'Microservices Overview',
        bounds: const Rect.fromLTWH(50, 60, 800, 600),
      );

      final jsonStr = msg.toJsonString();
      final parsed = BroadcastMessage.fromJsonString(jsonStr);

      expect(parsed.type, BroadcastMessageType.slideChange);
      expect(parsed.data['slideIndex'], 3);
      expect(parsed.data['totalSlides'], 8);
      expect(parsed.data['title'], 'Microservices Overview');
      expect(parsed.data['left'], 50.0);
      expect(parsed.data['width'], 800.0);
    });

    test('serializes and deserializes viewerCount message', () {
      final msg = BroadcastMessage.viewerCount(count: 7);
      final jsonStr = msg.toJsonString();
      final parsed = BroadcastMessage.fromJsonString(jsonStr);

      expect(parsed.type, BroadcastMessageType.viewerCount);
      expect(parsed.data['count'], 7);
    });
  });
}
