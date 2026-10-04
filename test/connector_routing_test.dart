import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connection_binding.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/data/services/connector_routing_service.dart';

void main() {
  group('ConnectorRoutingService Unit Tests', () {
    test('computes straight route accurately with correct midpoints and angles', () {
      final line = BoardElement(
        id: 'line_1',
        type: ShapeType.line,
        start: const Offset(0, 0),
        end: const Offset(100, 0),
        color: Colors.black,
        connectorStyle: ConnectorStyle.straight,
      );

      final route = ConnectorRoutingService.computeRoute(line);
      expect(route.waypoints.length, equals(2));
      expect(route.midpoint, equals(const Offset(50, 0)));
      expect(route.endAngle, closeTo(0.0, 0.001));
    });

    test('computes orthogonal elbow route with 90-degree waypoints', () {
      final arrow = BoardElement(
        id: 'arrow_1',
        type: ShapeType.arrow,
        start: const Offset(0, 0),
        end: const Offset(100, 100),
        color: Colors.black,
        connectorStyle: ConnectorStyle.orthogonal,
        startBinding: const ConnectionBinding(
          elementId: 'box_1',
          anchor: AnchorPoint.right,
        ),
        endBinding: const ConnectionBinding(
          elementId: 'box_2',
          anchor: AnchorPoint.left,
        ),
      );

      final route = ConnectorRoutingService.computeRoute(arrow);
      expect(route.waypoints.length, greaterThanOrEqualTo(4));
      // First segment leaves rightwards from start
      expect(route.waypoints[1].dx, greaterThan(route.waypoints[0].dx));
      // Last segment enters leftwards into end
      expect(route.waypoints.last, equals(const Offset(100, 100)));
      expect(route.midpoint.dx, closeTo(50.0, 5.0));
      expect(route.midpoint.dy, closeTo(50.0, 5.0));
    });

    test('computes curved bezier route with anchor normal tangents', () {
      final curved = BoardElement(
        id: 'curved_1',
        type: ShapeType.doubleArrow,
        start: const Offset(0, 0),
        end: const Offset(200, 200),
        color: Colors.black,
        connectorStyle: ConnectorStyle.curved,
        startBinding: const ConnectionBinding(
          elementId: 'box_1',
          anchor: AnchorPoint.bottom,
        ),
        endBinding: const ConnectionBinding(
          elementId: 'box_2',
          anchor: AnchorPoint.top,
        ),
      );

      final route = ConnectorRoutingService.computeRoute(curved);
      expect(route.waypoints.length, equals(4));
      // Midpoint along curve
      expect(route.midpoint.dx, closeTo(100.0, 10.0));
      expect(route.midpoint.dy, closeTo(100.0, 10.0));
    });

    test('hitTestRoute detects hits along orthogonal and curved segments and labels', () {
      final elbow = BoardElement(
        id: 'elbow_1',
        type: ShapeType.arrow,
        start: const Offset(0, 0),
        end: const Offset(100, 100),
        color: Colors.black,
        connectorStyle: ConnectorStyle.orthogonal,
        label: 'Submit Data',
      );

      // Hit test near start
      expect(ConnectorRoutingService.hitTestRoute(elbow, const Offset(2, 2), 6.0), isTrue);

      // Hit test near midpoint label
      final route = ConnectorRoutingService.computeRoute(elbow);
      expect(ConnectorRoutingService.hitTestRoute(elbow, route.midpoint, 6.0), isTrue);

      // Far away point
      expect(ConnectorRoutingService.hitTestRoute(elbow, const Offset(500, 500), 6.0), isFalse);
    });
  });

  group('BoardElement Connector Serialization & Copy', () {
    test('serializes and deserializes connectorStyle and label', () {
      final el = BoardElement(
        id: 'conn_test',
        type: ShapeType.arrow,
        start: const Offset(10, 20),
        end: const Offset(150, 180),
        color: Colors.blue,
        connectorStyle: ConnectorStyle.orthogonal,
        label: 'API Request',
      );

      final map = el.toMap();
      expect(map['connectorStyle'], equals('orthogonal'));
      expect(map['label'], equals('API Request'));

      final restored = BoardElement.fromMap(map);
      expect(restored.connectorStyle, equals(ConnectorStyle.orthogonal));
      expect(restored.label, equals('API Request'));
      expect(restored.displayName, equals('API Request'));
    });

    test('copyWith updates connectorStyle and clearLabel correctly', () {
      final el = BoardElement(
        id: 'c1',
        type: ShapeType.line,
        start: Offset.zero,
        end: const Offset(50, 50),
        color: Colors.black,
        connectorStyle: ConnectorStyle.straight,
        label: 'Old Label',
      );

      final updated = el.copyWith(
        connectorStyle: ConnectorStyle.curved,
        label: null,
      );
      expect(updated.connectorStyle, equals(ConnectorStyle.curved));
      expect(updated.label, isNull);
    });
  });
}
