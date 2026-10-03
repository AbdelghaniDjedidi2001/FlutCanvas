import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_binding.freezed.dart';
part 'connection_binding.g.dart';

enum AnchorPoint {
  top,
  right,
  bottom,
  left,
  center,
}

@freezed
abstract class ConnectionBinding with _$ConnectionBinding {
  const factory ConnectionBinding({
    required String elementId,
    required AnchorPoint anchor,
  }) = _ConnectionBinding;

  const ConnectionBinding._();

  factory ConnectionBinding.fromJson(Map<String, dynamic> json) =>
      _$ConnectionBindingFromJson(json);

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

  String toJsonString() => jsonEncode(toMap());
  static ConnectionBinding fromJsonString(String source) =>
      ConnectionBinding.fromMap(jsonDecode(source) as Map<String, dynamic>);

  static Offset getAnchorPosition(dynamic elementOrBounds, AnchorPoint anchor) {
    final Rect bounds = elementOrBounds is Rect
        ? elementOrBounds
        : (elementOrBounds.bounds as Rect);
    return switch (anchor) {
      AnchorPoint.top => Offset(bounds.center.dx, bounds.top),
      AnchorPoint.right => Offset(bounds.right, bounds.center.dy),
      AnchorPoint.bottom => Offset(bounds.center.dx, bounds.bottom),
      AnchorPoint.left => Offset(bounds.left, bounds.center.dy),
      AnchorPoint.center => bounds.center,
    };
  }

  static (AnchorPoint, Offset)? findNearestAnchor(
    dynamic elementOrBounds,
    Offset worldPoint, {
    double maxDistance = 24.0,
  }) {
    final Rect bounds = elementOrBounds is Rect
        ? elementOrBounds
        : (elementOrBounds.bounds as Rect);

    AnchorPoint? closest;
    var minDist = double.infinity;
    Offset? closestPos;

    for (final anchor in [
      AnchorPoint.top,
      AnchorPoint.right,
      AnchorPoint.bottom,
      AnchorPoint.left
    ]) {
      final pos = getAnchorPosition(bounds, anchor);
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
