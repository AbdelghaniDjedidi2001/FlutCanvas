import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../models/board_colors.dart';
import '../models/board_document.dart';
import '../models/board_element.dart';
import '../painters/element_renderer.dart';
import 'pdf_export_service.dart';
import 'svg_export_service.dart';

export 'pdf_export_service.dart' show PdfExportMode;
export 'svg_export_service.dart';

class ExportService {
  /// Renders all elements onto a high-resolution PNG image with progress feedback
  static Future<Uint8List?> renderToPng({
    required List<BoardElement> elements,
    required BoardColors colors,
    bool includeBackground = true,
    double scale = 2.0,
    double? maxDimension,
    double padding = 40.0,
    void Function(String status)? onProgress,
  }) async {
    if (elements.isEmpty) return null;

    onProgress?.call('Calculating canvas bounds...');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    // 1. Calculate entire bounding box
    Rect bounds = elements.first.bounds;
    for (var i = 1; i < elements.length; i++) {
      bounds = bounds.expandToInclude(elements[i].bounds);
    }
    bounds = bounds.inflate(padding);

    var effectiveScale = scale;
    if (maxDimension != null && maxDimension > 0) {
      final maxSide = math.max(bounds.width, bounds.height);
      if (maxSide * effectiveScale > maxDimension) {
        effectiveScale = maxDimension / maxSide;
      }
    }

    final width = (bounds.width * effectiveScale).ceil().toDouble();
    final height = (bounds.height * effectiveScale).ceil().toDouble();

    if (width <= 0 || height <= 0) return null;

    onProgress?.call('Rasterizing elements (${width.toInt()}x${height.toInt()})...');
    await Future<void>.delayed(const Duration(milliseconds: 30));

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Optional background fill
    if (includeBackground) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width, height),
        Paint()..color = colors.background,
      );
    }

    canvas.scale(effectiveScale);
    canvas.translate(-bounds.left, -bounds.top);

    // Draw all elements in order
    for (final el in elements) {
      ElementRenderer.draw(canvas, el, colors);
    }

    onProgress?.call('Encoding image data...');
    await Future<void>.delayed(const Duration(milliseconds: 30));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }

  /// Exports elements to vector SVG string
  static String exportToSvg({
    required List<BoardElement> elements,
    required BoardColors colors,
    bool includeBackground = true,
  }) {
    return SvgExportService.exportToSvg(
      elements: elements,
      colors: colors,
      includeBackground: includeBackground,
    );
  }

  /// Exports elements/frames/boards to PDF document bytes with progress feedback
  static Future<Uint8List> exportToPdf({
    required List<BoardElement> elements,
    required BoardColors colors,
    List<BoardDocument>? allBoards,
    PdfExportMode mode = PdfExportMode.currentBoard,
    void Function(String status)? onProgress,
  }) {
    return PdfExportService.exportToPdf(
      elements: elements,
      colors: colors,
      allBoards: allBoards,
      mode: mode,
      onProgress: onProgress,
    );
  }

  /// Serializes board elements to formatted JSON string
  static String exportToJson(List<BoardElement> elements) {
    final data = {
      'type': 'flutcanvas_export',
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
