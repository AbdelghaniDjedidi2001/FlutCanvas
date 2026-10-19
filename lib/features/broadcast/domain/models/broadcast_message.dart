import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/laser_painter.dart';

/// Types of real-time broadcast messages.
enum BroadcastMessageType {
  snapshot,
  viewport,
  laser,
  slideChange,
  elementsUpdate,
  viewerCount,
  ping,
  pong;

  static BroadcastMessageType fromString(String val) {
    return switch (val) {
      'snapshot' => BroadcastMessageType.snapshot,
      'viewport' => BroadcastMessageType.viewport,
      'laser' => BroadcastMessageType.laser,
      'slide_change' || 'slideChange' => BroadcastMessageType.slideChange,
      'elements_update' || 'elementsUpdate' => BroadcastMessageType.elementsUpdate,
      'viewer_count' || 'viewerCount' => BroadcastMessageType.viewerCount,
      'ping' => BroadcastMessageType.ping,
      'pong' => BroadcastMessageType.pong,
      _ => BroadcastMessageType.ping,
    };
  }

  String get wireName => switch (this) {
    BroadcastMessageType.snapshot => 'snapshot',
    BroadcastMessageType.viewport => 'viewport',
    BroadcastMessageType.laser => 'laser',
    BroadcastMessageType.slideChange => 'slide_change',
    BroadcastMessageType.elementsUpdate => 'elements_update',
    BroadcastMessageType.viewerCount => 'viewer_count',
    BroadcastMessageType.ping => 'ping',
    BroadcastMessageType.pong => 'pong',
  };
}

/// Unified message container for LAN broadcast payloads.
class BroadcastMessage {
  final BroadcastMessageType type;
  final Map<String, dynamic> data;

  const BroadcastMessage({
    required this.type,
    required this.data,
  });

  /// Factory for full board snapshot when viewers connect.
  factory BroadcastMessage.snapshot({
    required List<BoardElement> elements,
    required bool isDark,
    String? boardName,
    Offset? pan,
    double? zoom,
  }) {
    return BroadcastMessage(
      type: BroadcastMessageType.snapshot,
      data: {
        'boardName': boardName ?? 'Untitled Board',
        'isDark': isDark,
        if (pan != null) ...{
          'panX': pan.dx,
          'panY': pan.dy,
        },
        'zoom': ?zoom,
        'elements': elements.map((e) => e.toJson()).toList(),
      },
    );
  }

  /// Factory for camera pan & zoom viewport sync.
  factory BroadcastMessage.viewport({
    required Offset pan,
    required double zoom,
  }) {
    return BroadcastMessage(
      type: BroadcastMessageType.viewport,
      data: {
        'panX': pan.dx,
        'panY': pan.dy,
        'zoom': zoom,
      },
    );
  }

  /// Factory for glowing laser pointer trail sync.
  factory BroadcastMessage.laser({
    required List<LaserPoint> trail,
  }) {
    return BroadcastMessage(
      type: BroadcastMessageType.laser,
      data: {
        'points': trail
            .map((p) => {
                  'x': p.point.dx,
                  'y': p.point.dy,
                  'time': p.time.millisecondsSinceEpoch,
                })
            .toList(),
      },
    );
  }

  /// Factory for slide frame navigation transitions.
  factory BroadcastMessage.slideChange({
    required int slideIndex,
    required int totalSlides,
    String? title,
    Rect? bounds,
  }) {
    return BroadcastMessage(
      type: BroadcastMessageType.slideChange,
      data: {
        'slideIndex': slideIndex,
        'totalSlides': totalSlides,
        'title': ?title,
        if (bounds != null) ...{
          'left': bounds.left,
          'top': bounds.top,
          'width': bounds.width,
          'height': bounds.height,
        },
      },
    );
  }

  /// Factory for incremental elements update.
  factory BroadcastMessage.elementsUpdate({
    required List<BoardElement> elements,
  }) {
    return BroadcastMessage(
      type: BroadcastMessageType.elementsUpdate,
      data: {
        'elements': elements.map((e) => e.toJson()).toList(),
      },
    );
  }

  /// Factory for connected viewer count update.
  factory BroadcastMessage.viewerCount({
    required int count,
  }) {
    return BroadcastMessage(
      type: BroadcastMessageType.viewerCount,
      data: {
        'count': count,
      },
    );
  }

  /// Serialization to JSON string for WebSocket wire transfer.
  String toJsonString() {
    return jsonEncode({
      'type': type.wireName,
      ...data,
    });
  }

  /// Deserialization from JSON string.
  factory BroadcastMessage.fromJsonString(String rawJson) {
    final map = jsonDecode(rawJson) as Map<String, dynamic>;
    final typeStr = map['type'] as String? ?? 'ping';
    final type = BroadcastMessageType.fromString(typeStr);

    final payload = Map<String, dynamic>.from(map)..remove('type');
    return BroadcastMessage(type: type, data: payload);
  }
}
