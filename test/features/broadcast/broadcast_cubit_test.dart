import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/features/broadcast/data/services/lan_broadcast_server.dart';
import 'package:flutcanvas/features/broadcast/presentation/bloc/broadcast_cubit.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/laser_painter.dart';

void main() {
  group('BroadcastCubit', () {
    late LanBroadcastServer server;
    late BroadcastCubit cubit;

    setUp(() {
      server = LanBroadcastServer();
      cubit = BroadcastCubit(server: server);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state has default values and is not broadcasting', () {
      expect(cubit.state.isBroadcasting, isFalse);
      expect(cubit.state.isStarting, isFalse);
      expect(cubit.state.viewersCount, 0);
      expect(cubit.state.port, 4040);
      expect(cubit.state.serverUrl, isNull);
    });

    test('starts broadcast successfully and updates state', () async {
      final initialElements = [
        BoardElement(
          id: '1',
          type: ShapeType.rectangle,
          start: const Offset(0, 0),
          end: const Offset(100, 100),
        ),
      ];

      final success = await cubit.startBroadcast(
        port: 4990,
        initialElements: initialElements,
        isDark: false,
        boardName: 'Test Board',
        pan: const Offset(10, 10),
        zoom: 1.0,
      );

      expect(success, isTrue);
      expect(cubit.state.isBroadcasting, isTrue);
      expect(cubit.state.isStarting, isFalse);
      expect(cubit.state.serverUrl, isNotNull);
      expect(cubit.state.port, greaterThanOrEqualTo(4990));

      // Stopping broadcast resets state
      await cubit.stopBroadcast();
      expect(cubit.state.isBroadcasting, isFalse);
      expect(cubit.state.viewersCount, 0);
    });

    test('throttles viewport updates during active broadcast', () async {
      await cubit.startBroadcast(
        port: 4995,
        initialElements: const [],
        isDark: true,
      );

      // Rapidly call viewport updates
      cubit.broadcastViewportThrottled(const Offset(10, 10), 1.1);
      cubit.broadcastViewportThrottled(const Offset(20, 20), 1.2);
      cubit.broadcastViewportThrottled(const Offset(30, 30), 1.3);

      // Verify that calling when broadcasting does not throw
      cubit.broadcastLaser([
        LaserPoint(point: const Offset(50, 50), time: DateTime.now()),
      ]);

      cubit.broadcastSlideChange(
        slideIndex: 0,
        totalSlides: 3,
        title: 'Title Slide',
      );

      cubit.broadcastElementsUpdate([]);

      await Future<void>.delayed(const Duration(milliseconds: 60));
      await cubit.stopBroadcast();
    });

    test('ignores broadcasts when not broadcasting', () {
      expect(cubit.state.isBroadcasting, isFalse);

      // None of these should throw or fail
      cubit.broadcastViewportThrottled(const Offset(10, 10), 1.1);
      cubit.broadcastLaser([]);
      cubit.broadcastSlideChange(slideIndex: 0, totalSlides: 1);
      cubit.broadcastElementsUpdate([]);
    });
  });
}
