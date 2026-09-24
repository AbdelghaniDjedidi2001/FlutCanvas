import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../models/board_colors.dart';
import '../models/board_element.dart';
import '../painters/element_renderer.dart';

class ExportService {
  /// Renders all elements onto a high-resolution PNG image
  static Future<Uint8List?> renderToPng({
    required List<BoardElement> elements,
    required BoardColors colors,
    bool includeBackground = true,
    double scale = 2.0,
    double padding = 40.0,
  }) async {
    if (elements.isEmpty) return null;

    // 1. Calculate entire bounding box
    Rect bounds = elements.first.bounds;
    for (var i = 1; i < elements.length; i++) {
      bounds = bounds.expandToInclude(elements[i].bounds);
    }
    bounds = bounds.inflate(padding);

    final width = (bounds.width * scale).ceil().toDouble();
    final height = (bounds.height * scale).ceil().toDouble();

    if (width <= 0 || height <= 0) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Optional background fill
    if (includeBackground) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width, height),
        Paint()..color = colors.background,
      );
    }

    canvas.scale(scale);
    canvas.translate(-bounds.left, -bounds.top);

    // Draw all elements in order
    for (final el in elements) {
      ElementRenderer.draw(canvas, el, colors);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }

  /// Serializes board elements to formatted JSON string
  static String exportToJson(List<BoardElement> elements) {
    final data = {
      'type': 'mini_whiteboard_export',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'elements': elements.map((e) => e.toMap()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Imports board elements from a JSON string
  static List<BoardElement>? importFromJson(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      List<dynamic> list;
      if (decoded is Map<String, dynamic> && decoded.containsKey('elements')) {
        list = decoded['elements'] as List<dynamic>;
      } else if (decoded is List<dynamic>) {
        list = decoded;
      } else {
        return null;
      }

      return list
          .map((e) => BoardElement.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to import board: $e');
      return null;
    }
  }
}
