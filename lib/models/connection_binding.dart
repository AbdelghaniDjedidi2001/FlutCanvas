import 'package:flutter/material.dart';
import 'board_element.dart';

enum AnchorPoint {
  top,
  right,
  bottom,
  left,
  center,
}

@immutable
class ConnectionBinding {
  const ConnectionBinding({
    required this.elementId,
    required this.anchor,
  });

  final String elementId;
  final AnchorPoint anchor;

  Map<String, dynamic> toMap() => {
        'elementId': elementId,
        'anchor': anchor.name,
      };

  factory ConnectionBinding.fromMap(Map<String, dynamic> map) {
    return ConnectionBinding(
      elementId: map['elementId'] as String? ?? '',
      anchor: AnchorPoint.values.firstWhere(
        (a) => a.name == map['anchor'],
        orElse: () => AnchorPoint.center,
      ),
    );
  }

  static Offset getAnchorPosition(BoardElement element, AnchorPoint anchor) {
    final bounds = element.bounds;
    return switch (anchor) {
      AnchorPoint.top => Offset(bounds.center.dx, bounds.top),
      AnchorPoint.right => Offset(bounds.right, bounds.center.dy),
      AnchorPoint.bottom => Offset(bounds.center.dx, bounds.bottom),
      AnchorPoint.left => Offset(bounds.left, bounds.center.dy),
      AnchorPoint.center => bounds.center,
    };
  }

  static (AnchorPoint, Offset)? findNearestAnchor(
    BoardElement element,
    Offset worldPoint, {
    double maxDistance = 24.0,
  }) {
    AnchorPoint? closest;
    var minDist = double.infinity;
    Offset? closestPos;

    for (final anchor in [
      AnchorPoint.top,
      AnchorPoint.right,
      AnchorPoint.bottom,
      AnchorPoint.left
    ]) {
      final pos = getAnchorPosition(element, anchor);
      final dist = (pos - worldPoint).distance;
      if (dist < minDist && dist <= maxDistance) {
        minDist = dist;
        closest = anchor;
        closestPos = pos;
      }
    }

    if (closest != null && closestPos != null) {
      return (closest, closestPos);
    }
    return null;
  }
}
