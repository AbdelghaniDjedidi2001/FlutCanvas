import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:injectable/injectable.dart';

import 'package:flutcanvas/features/broadcast/data/services/embedded_web_viewer_html.dart';
import 'package:flutcanvas/features/broadcast/data/services/lan_ip_resolver.dart';
import 'package:flutcanvas/features/broadcast/domain/models/broadcast_message.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/laser_painter.dart';

/// Embedded HTTP and WebSocket server for Local Network Live Presentation Broadcasting.
@lazySingleton
class LanBroadcastServer {
  HttpServer? _server;
  final Set<WebSocket> _clients = {};
  final StreamController<int> _viewerCountController =
      StreamController<int>.broadcast();

  String? _localIp;
  int _port = 4040;
  BroadcastMessage? _cachedSnapshot;

  bool get isRunning => _server != null;
  int get port => _port;
  String? get localIp => _localIp;
  String? get url =>
      _localIp != null ? LanIpResolver.formatBroadcastUrl(_localIp!, _port) : null;
  int get connectedViewersCount => _clients.length;
  Stream<int> get viewerCountStream => _viewerCountController.stream;

  /// Starts the embedded HTTP and WebSocket server.
  /// 
  /// Automatically tries subsequent ports if the default port is already in use.
  Future<bool> start({
    int initialPort = 4040,
    int maxPortAttempts = 10,
  }) async {
    if (isRunning) return true;

    _localIp = await LanIpResolver.getLocalIpAddress();

    for (int offset = 0; offset < maxPortAttempts; offset++) {
      final candidatePort = initialPort + offset;
      try {
        _server = await HttpServer.bind(
          InternetAddress.anyIPv4,
          candidatePort,
          shared: true,
        );
        _port = candidatePort;
        break;
      } catch (e) {
        debugPrint('Port $candidatePort in use, trying next...');
      }
    }

    if (_server == null) {
      debugPrint('Failed to bind LanBroadcastServer to any available port.');
      return false;
    }

    debugPrint('📡 LanBroadcastServer running at $url');

    _server!.listen(
      _handleRequest,
      onError: (e) => debugPrint('LanBroadcastServer HTTP error: $e'),
    );

    return true;
  }

  /// Stops the broadcast server and disconnects clients gracefully.
  Future<void> stop() async {
    for (final client in _clients) {
      try {
        await client.close(WebSocketStatus.normalClosure, 'Broadcast stopped');
      } catch (_) {}
    }
    _clients.clear();
    _cachedSnapshot = null;

    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
    }

    if (!_viewerCountController.isClosed) {
      _viewerCountController.add(0);
    }

    debugPrint('📡 LanBroadcastServer stopped.');
  }

  void _handleRequest(HttpRequest request) {
    // 1. WebSocket upgrade endpoint
    if (request.uri.path == '/ws' &&
        WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocketTransformer.upgrade(request).then(_handleWebSocketClient).catchError((e) {
        debugPrint('WS upgrade error: $e');
      });
      return;
    }

    // 2. Health check endpoint
    if (request.uri.path == '/health') {
      request.response
        ..headers.contentType = ContentType.json
        ..write('{"status":"ok","viewers":${_clients.length}}')
        ..close();
      return;
    }

    // 3. Web Viewer single-page HTML client (default)
    request.response
      ..headers.contentType = ContentType.html
      ..headers.add('Cache-Control', 'no-cache, no-store, must-revalidate')
      ..write(EmbeddedWebViewerHtml.html)
      ..close();
  }

  void _handleWebSocketClient(WebSocket client) {
    _clients.add(client);

    // Immediately send the latest board snapshot upon client connection
    if (_cachedSnapshot != null) {
      try {
        client.add(_cachedSnapshot!.toJsonString());
      } catch (_) {}
    }

    _notifyViewerCount();

    client.listen(
      (data) {
        // Handle incoming ping / pong if sent by client
        if (data is String && data.contains('ping')) {
          client.add(const BroadcastMessage(
            type: BroadcastMessageType.pong,
            data: {},
          ).toJsonString());
        }
      },
      onDone: () {
        _clients.remove(client);
        _notifyViewerCount();
      },
      onError: (_) {
        _clients.remove(client);
        _notifyViewerCount();
      },
      cancelOnError: true,
    );
  }

  void _notifyViewerCount() {
    final count = _clients.length;
    if (!_viewerCountController.isClosed) {
      _viewerCountController.add(count);
    }
    // Broadcast count to all web clients for live HUD
    _broadcastRaw(BroadcastMessage.viewerCount(count: count).toJsonString());
  }

  /// Sends full board snapshot and caches it for newly joining viewers.
  void broadcastSnapshot({
    required List<BoardElement> elements,
    required bool isDark,
    String? boardName,
    Offset? pan,
    double? zoom,
  }) {
    final msg = BroadcastMessage.snapshot(
      elements: elements,
      isDark: isDark,
      boardName: boardName,
      pan: pan,
      zoom: zoom,
    );
    _cachedSnapshot = msg;
    _broadcastRaw(msg.toJsonString());
  }

  /// Broadcasts camera pan and zoom position to all following audience viewers.
  void broadcastViewport(Offset pan, double zoom) {
    final msg = BroadcastMessage.viewport(pan: pan, zoom: zoom);
    _broadcastRaw(msg.toJsonString());
  }

  /// Broadcasts active glowing laser pointer trail coordinates.
  void broadcastLaser(List<LaserPoint> trail) {
    final msg = BroadcastMessage.laser(trail: trail);
    _broadcastRaw(msg.toJsonString());
  }

  /// Broadcasts presentation slide frame transition.
  void broadcastSlideChange({
    required int slideIndex,
    required int totalSlides,
    String? title,
    Rect? bounds,
  }) {
    final msg = BroadcastMessage.slideChange(
      slideIndex: slideIndex,
      totalSlides: totalSlides,
      title: title,
      bounds: bounds,
    );
    _broadcastRaw(msg.toJsonString());
  }

  /// Broadcasts incremental updates when canvas elements are edited.
  void broadcastElementsUpdate(List<BoardElement> elements) {
    final msg = BroadcastMessage.elementsUpdate(elements: elements);
    // Also update cached snapshot elements so newcomers get the updated version
    if (_cachedSnapshot != null) {
      final updatedData = Map<String, dynamic>.from(_cachedSnapshot!.data);
      updatedData['elements'] = elements.map((e) => e.toJson()).toList();
      _cachedSnapshot = BroadcastMessage(
        type: BroadcastMessageType.snapshot,
        data: updatedData,
      );
    }
    _broadcastRaw(msg.toJsonString());
  }

  void _broadcastRaw(String jsonString) {
    if (_clients.isEmpty) return;

    final deadClients = <WebSocket>[];
    for (final client in _clients) {
      try {
        client.add(jsonString);
      } catch (e) {
        deadClients.add(client);
      }
    }

    if (deadClients.isNotEmpty) {
      _clients.removeAll(deadClients);
      _notifyViewerCount();
    }
  }

  void dispose() {
    stop();
    _viewerCountController.close();
  }
}
