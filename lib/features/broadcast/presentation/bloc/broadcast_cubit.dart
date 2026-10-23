import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flutcanvas/features/broadcast/data/services/lan_broadcast_server.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/laser_painter.dart';
import 'broadcast_state.dart';

@injectable
class BroadcastCubit extends Cubit<BroadcastState> {
  final LanBroadcastServer _server;
  StreamSubscription<int>? _viewerCountSubscription;

  // Viewport throttling timer (~30 FPS = 33ms)
  Timer? _viewportThrottleTimer;
  Offset? _pendingPan;
  double? _pendingZoom;

  BroadcastCubit({@factoryParam LanBroadcastServer? server})
      : _server = server ?? LanBroadcastServer(),
        super(const BroadcastState()) {
    _viewerCountSubscription = _server.viewerCountStream.listen((count) {
      if (!isClosed) {
        emit(state.copyWith(viewersCount: count));
      }
    });
  }

  /// Starts the embedded broadcast server and pushes initial board snapshot.
  Future<bool> startBroadcast({
    int port = 4040,
    required List<BoardElement> initialElements,
    required bool isDark,
    String? boardName,
    Offset? pan,
    double? zoom,
  }) async {
    if (state.isBroadcasting) return true;

    if (kIsWeb) {
      emit(state.copyWith(
        isBroadcasting: false,
        isStarting: false,
        errorMessage:
            'Broadcasting is not supported in web browsers. Please run FlutCanvas as a desktop app (macOS, Windows, Linux).',
      ));
      return false;
    }

    emit(state.copyWith(isStarting: true, errorMessage: null));

    final success = await _server.start(initialPort: port);

    if (success) {
      _server.broadcastSnapshot(
        elements: initialElements,
        isDark: isDark,
        boardName: boardName,
        pan: pan,
        zoom: zoom,
      );

      emit(state.copyWith(
        isBroadcasting: true,
        isStarting: false,
        port: _server.port,
        localIp: _server.localIp,
        serverUrl: _server.url,
        viewersCount: _server.connectedViewersCount,
        errorMessage: null,
      ));
      return true;
    } else {
      emit(state.copyWith(
        isBroadcasting: false,
        isStarting: false,
        errorMessage: 'Could not bind to local port. Check network permissions.',
      ));
      return false;
    }
  }

  /// Stops the local broadcast server.
  Future<void> stopBroadcast() async {
    _viewportThrottleTimer?.cancel();
    await _server.stop();
    emit(state.copyWith(
      isBroadcasting: false,
      isStarting: false,
      viewersCount: 0,
      errorMessage: null,
    ));
  }

  /// Throttled viewport broadcasting (prevents Wi-Fi saturation during fast gestures).
  void broadcastViewportThrottled(Offset pan, double zoom) {
    if (!state.isBroadcasting) return;

    _pendingPan = pan;
    _pendingZoom = zoom;

    if (_viewportThrottleTimer == null || !_viewportThrottleTimer!.isActive) {
      _server.broadcastViewport(pan, zoom);
      _viewportThrottleTimer = Timer(const Duration(milliseconds: 33), () {
        if (_pendingPan != null && _pendingZoom != null) {
          _server.broadcastViewport(_pendingPan!, _pendingZoom!);
        }
      });
    }
  }

  /// Real-time glowing laser pointer trail broadcasting.
  void broadcastLaser(List<LaserPoint> trail) {
    if (!state.isBroadcasting) return;
    _server.broadcastLaser(trail);
  }

  /// Slide frame navigation broadcasting.
  void broadcastSlideChange({
    required int slideIndex,
    required int totalSlides,
    String? title,
    Rect? bounds,
  }) {
    if (!state.isBroadcasting) return;
    _server.broadcastSlideChange(
      slideIndex: slideIndex,
      totalSlides: totalSlides,
      title: title,
      bounds: bounds,
    );
  }

  /// Incremental canvas modifications broadcasting.
  void broadcastElementsUpdate(List<BoardElement> elements) {
    if (!state.isBroadcasting) return;
    _server.broadcastElementsUpdate(elements);
  }

  @override
  Future<void> close() {
    _viewportThrottleTimer?.cancel();
    _viewerCountSubscription?.cancel();
    _server.dispose();
    return super.close();
  }
}
