import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/board_element.dart';

class CanvasViewportController extends ChangeNotifier {
  Offset _pan;
  double _zoom;
  final double minZoom;
  final double maxZoom;

  CanvasViewportController({
    Offset initialPan = Offset.zero,
    double initialZoom = 1.0,
    this.minZoom = 0.1,
    this.maxZoom = 5.0,
  })  : _pan = initialPan,
        _zoom = initialZoom;

  Offset get pan => _pan;
  double get zoom => _zoom;

  Offset toWorld(Offset screen) => (screen - _pan) / _zoom;
  Offset toScreen(Offset world) => world * _zoom + _pan;

  void panBy(Offset delta) {
    _pan += delta;
    notifyListeners();
  }

  void setPan(Offset newPan) {
    if (_pan != newPan) {
      _pan = newPan;
      notifyListeners();
    }
  }

  void setZoom(double newZoom) {
    final clamped = newZoom.clamp(minZoom, maxZoom);
    if (_zoom != clamped) {
      _zoom = clamped;
      notifyListeners();
    }
  }

  void zoomAt(Offset focalPoint, double targetZoom) {
    final clamped = targetZoom.clamp(minZoom, maxZoom);
    if ((_zoom - clamped).abs() < 0.001) return;

    final world = toWorld(focalPoint);
    _zoom = clamped;
    _pan = focalPoint - world * _zoom;
    notifyListeners();
  }

  void reset() {
    _pan = Offset.zero;
    _zoom = 1.0;
    notifyListeners();
  }

  void zoomToFit(List<BoardElement> items, Size viewSize, {double padding = 60.0}) {
    if (items.isEmpty || viewSize.isEmpty) return;

    var bounds = items.first.bounds;
    for (var i = 1; i < items.length; i++) {
      bounds = bounds.expandToInclude(items[i].bounds);
    }

    final availableW = viewSize.width - padding * 2;
    final availableH = viewSize.height - padding * 2;
    if (availableW <= 0 || availableH <= 0) return;

    final scaleX = availableW / bounds.width;
    final scaleY = availableH / bounds.height;
    final targetZoom = math.min(scaleX, scaleY).clamp(minZoom, maxZoom);

    final targetPan = Offset(
      viewSize.width / 2 - bounds.center.dx * targetZoom,
      viewSize.height / 2 - bounds.center.dy * targetZoom,
    );

    _zoom = targetZoom;
    _pan = targetPan;
    notifyListeners();
  }
}
