import 'package:flutter/services.dart';

enum HandleType {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
  rotation,
}

class TransformHandle {
  const TransformHandle({
    required this.type,
    required this.position,
  });

  final HandleType type;
  final Offset position;

  static const double hitRadius = 8.0;

  static List<TransformHandle> getHandlesForRect(Rect rect, double zoom) {
    return [
      TransformHandle(type: HandleType.topLeft, position: rect.topLeft),
      TransformHandle(
          type: HandleType.topCenter, position: Offset(rect.center.dx, rect.top)),
      TransformHandle(type: HandleType.topRight, position: rect.topRight),
      TransformHandle(
          type: HandleType.centerLeft,
          position: Offset(rect.left, rect.center.dy)),
      TransformHandle(
          type: HandleType.centerRight,
          position: Offset(rect.right, rect.center.dy)),
      TransformHandle(type: HandleType.bottomLeft, position: rect.bottomLeft),
      TransformHandle(
          type: HandleType.bottomCenter,
          position: Offset(rect.center.dx, rect.bottom)),
      TransformHandle(type: HandleType.bottomRight, position: rect.bottomRight),
      TransformHandle(
        type: HandleType.rotation,
        position: Offset(rect.center.dx, rect.top - 20.0 / zoom),
      ),
    ];
  }

  static HandleType? hitTest(
      Rect rect, Offset worldPoint, double zoomThreshold) {
    final radius = hitRadius / zoomThreshold;
    for (final handle in getHandlesForRect(rect, zoomThreshold)) {
      if ((handle.position - worldPoint).distance <= radius) {
        return handle.type;
      }
    }
    return null;
  }

  static SystemMouseCursor cursorForHandle(HandleType type) {
    switch (type) {
      case HandleType.topLeft:
      case HandleType.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case HandleType.topRight:
      case HandleType.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case HandleType.topCenter:
      case HandleType.bottomCenter:
        return SystemMouseCursors.resizeUpDown;
      case HandleType.centerLeft:
      case HandleType.centerRight:
        return SystemMouseCursors.resizeLeftRight;
      case HandleType.rotation:
        return SystemMouseCursors.grab;
    }
  }

  /// Calculates the new Start/End (or Rect) when dragging a handle with a given [delta].
  static Rect resizeRect(Rect original, HandleType handle, Offset delta) {
    double left = original.left;
    double top = original.top;
    double right = original.right;
    double bottom = original.bottom;

    switch (handle) {
      case HandleType.topLeft:
        left += delta.dx;
        top += delta.dy;
        break;
      case HandleType.topCenter:
        top += delta.dy;
        break;
      case HandleType.topRight:
        right += delta.dx;
        top += delta.dy;
        break;
      case HandleType.centerLeft:
        left += delta.dx;
        break;
      case HandleType.centerRight:
        right += delta.dx;
        break;
      case HandleType.bottomLeft:
        left += delta.dx;
        bottom += delta.dy;
        break;
      case HandleType.bottomCenter:
        bottom += delta.dy;
        break;
      case HandleType.bottomRight:
        right += delta.dx;
        bottom += delta.dy;
        break;
      case HandleType.rotation:
        break;
    }

    return Rect.fromLTRB(
      left > right ? right : left,
      top > bottom ? bottom : top,
      left > right ? left : right,
      top > bottom ? top : bottom,
    );
  }
}
