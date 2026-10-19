import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/features/broadcast/data/services/lan_broadcast_server.dart';
import 'package:flutcanvas/features/broadcast/domain/models/broadcast_message.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/laser_painter.dart';

void main() {
  group('LanBroadcastServer', () {
    late LanBroadcastServer server;

    setUp(() {
      server = LanBroadcastServer();
    });

    tearDown(() async {
      await server.stop();
      server.dispose();
    });

    test('starts and binds to an available port', () async {
      final success = await server.start(initialPort: 4950);
      expect(success, isTrue);
      expect(server.isRunning, isTrue);
      expect(server.port, greaterThanOrEqualTo(4950));
      expect(server.url, isNotNull);
      expect(server.connectedViewersCount, 0);
    });

    test('serves health check and HTML web viewer over HTTP', () async {
      await server.start(initialPort: 4960);
      final client = HttpClient();

      // 1. Test /health
      final healthReq = await client.getUrl(Uri.parse('http://127.0.0.1:${server.port}/health'));
      final healthRes = await healthReq.close();
      expect(healthRes.statusCode, HttpStatus.ok);
      expect(healthRes.headers.contentType?.mimeType, ContentType.json.mimeType);
      final healthBody = await healthRes.transform(utf8.decoder).join();
      final healthJson = jsonDecode(healthBody) as Map<String, dynamic>;
      expect(healthJson['status'], 'ok');
      expect(healthJson['viewers'], 0);

      // 2. Test / (HTML viewer)
      final rootReq = await client.getUrl(Uri.parse('http://127.0.0.1:${server.port}/'));
      final rootRes = await rootReq.close();
      expect(rootRes.statusCode, HttpStatus.ok);
      expect(rootRes.headers.contentType?.mimeType, ContentType.html.mimeType);
      final rootBody = await rootRes.transform(utf8.decoder).join();
      expect(rootBody.contains('FlutCanvas • Live Presentation'), isTrue);
      expect(rootBody.contains('<canvas id="board">'), isTrue);

      client.close();
    });

    test('handles WebSocket connections, snapshot caching, and message broadcasts', () async {
      await server.start(initialPort: 4970);

      // Cache an initial snapshot before client connects
      server.broadcastSnapshot(
        elements: [
          BoardElement(
            id: 'node_1',
            type: ShapeType.rectangle,
            start: const Offset(10, 20),
            end: const Offset(110, 120),
            text: 'Database',
          ),
        ],
        isDark: true,
        boardName: 'Infra Architecture',
        pan: const Offset(50, 50),
        zoom: 1.25,
      );

      final wsUri = Uri.parse('ws://127.0.0.1:${server.port}/ws');
      final ws = await WebSocket.connect(wsUri.toString());

      final receivedMessages = <BroadcastMessage>[];
      final completer = Completer<void>();

      final sub = ws.listen((data) {
        if (data is String) {
          final msg = BroadcastMessage.fromJsonString(data);
          receivedMessages.add(msg);
          if (!completer.isCompleted && msg.type == BroadcastMessageType.elementsUpdate) {
            completer.complete();
          }
        }
      });

      // 1. First message should be the cached snapshot upon connect
      // Wait shortly for initial snapshot arrival
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(receivedMessages.isNotEmpty, isTrue);
      expect(receivedMessages.first.type, BroadcastMessageType.snapshot);
      expect(receivedMessages.first.data['boardName'], 'Infra Architecture');

      // 2. Broadcast Viewport
      server.broadcastViewport(const Offset(120, -80), 1.75);

      // 3. Broadcast Laser
      final now = DateTime.now();
      server.broadcastLaser([
        LaserPoint(point: const Offset(30, 40), time: now),
      ]);

      // 4. Broadcast Slide Change
      server.broadcastSlideChange(
        slideIndex: 1,
        totalSlides: 5,
        title: 'Backend Design',
        bounds: const Rect.fromLTWH(0, 0, 1920, 1080),
      );

      // 5. Broadcast Elements Update
      server.broadcastElementsUpdate([
        BoardElement(
          id: 'node_2',
          type: ShapeType.ellipse,
          start: const Offset(200, 200),
          end: const Offset(300, 300),
          text: 'Redis Cache',
        ),
      ]);

      await completer.future.timeout(const Duration(seconds: 3));

      expect(receivedMessages.any((m) => m.type == BroadcastMessageType.viewport), isTrue);
      expect(receivedMessages.any((m) => m.type == BroadcastMessageType.laser), isTrue);
      expect(receivedMessages.any((m) => m.type == BroadcastMessageType.slideChange), isTrue);
      expect(receivedMessages.any((m) => m.type == BroadcastMessageType.elementsUpdate), isTrue);

      await sub.cancel();
      await ws.close();
    });

    test('tracks viewer count accurately across connections and disconnections', () async {
      await server.start(initialPort: 4980);

      final counts = <int>[];
      final countSub = server.viewerCountStream.listen(counts.add);

      final wsUri = 'ws://127.0.0.1:${server.port}/ws';
      final ws1 = await WebSocket.connect(wsUri);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(server.connectedViewersCount, 1);

      final ws2 = await WebSocket.connect(wsUri);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(server.connectedViewersCount, 2);

      await ws1.close();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(server.connectedViewersCount, 1);

      await ws2.close();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(server.connectedViewersCount, 0);

      await countSub.cancel();
    });
  });
}
