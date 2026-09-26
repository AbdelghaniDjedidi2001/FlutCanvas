import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/board_colors.dart';
import '../models/board_document.dart';
import '../models/board_element.dart';
import '../models/shape_type.dart';
import '../painters/element_renderer.dart';

enum PdfExportMode {
  currentBoard,
  presentationSlides,
  allBoards,
}

class _RawPageRender {
  final Uint8List rawBytes;
  final int width;
  final int height;

  _RawPageRender(this.rawBytes, this.width, this.height);
}

class PdfExportService {
  static Future<Uint8List> exportToPdf({
    required List<BoardElement> elements,
    required BoardColors colors,
    List<BoardDocument>? allBoards,
    PdfExportMode mode = PdfExportMode.currentBoard,
    void Function(String status)? onProgress,
  }) async {
    final pdf = pw.Document();

    switch (mode) {
      case PdfExportMode.presentationSlides:
        final frames = elements
            .where((e) => e.type == ShapeType.frame && e.isVisible)
            .toList()
          ..sort((a, b) => (a.frameIndex ?? 0).compareTo(b.frameIndex ?? 0));

        if (frames.isNotEmpty) {
          for (var i = 0; i < frames.length; i++) {
            final frame = frames[i];
            final title = frame.frameTitle?.trim().isNotEmpty == true
                ? frame.frameTitle!
                : 'Slide ${i + 1}';
            onProgress?.call('Rendering $title (${i + 1}/${frames.length})...');
            await Future<void>.delayed(const Duration(milliseconds: 20));

            final pageRender = await _renderPagePixels(
              elements: elements,
              colors: colors,
              boundingBox: frame.bounds,
            );
            if (pageRender != null) {
              final pdfImage = PdfImage(
                pdf.document,
                image: pageRender.rawBytes,
                width: pageRender.width,
                height: pageRender.height,
                alpha: false,
              );
              final imageProvider = pw.ImageProxy(pdfImage);
              pdf.addPage(
                pw.Page(
                  pageFormat: PdfPageFormat.a4.landscape,
                  margin: pw.EdgeInsets.zero,
                  build: (pw.Context context) {
                    return pw.FullPage(
                      ignoreMargins: true,
                      child: pw.Center(
                        child: pw.Image(imageProvider, fit: pw.BoxFit.contain),
                      ),
                    );
                  },
                ),
              );
            }
          }
          break;
        }
        // Fallback to currentBoard if no frames
        continue currentBoardCase;

      currentBoardCase:
      case PdfExportMode.currentBoard:
        onProgress?.call('Rendering canvas elements to high-resolution page...');
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final pageRender = await _renderPagePixels(
          elements: elements,
          colors: colors,
        );
        if (pageRender != null) {
          onProgress?.call('Constructing landscape PDF page...');
          await Future<void>.delayed(const Duration(milliseconds: 20));

          final pdfImage = PdfImage(
            pdf.document,
            image: pageRender.rawBytes,
            width: pageRender.width,
            height: pageRender.height,
            alpha: false,
          );
          final imageProvider = pw.ImageProxy(pdfImage);
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4.landscape,
              margin: pw.EdgeInsets.zero,
              build: (pw.Context context) {
                return pw.FullPage(
                  ignoreMargins: true,
                  child: pw.Center(
                    child: pw.Image(imageProvider, fit: pw.BoxFit.contain),
                  ),
                );
              },
            ),
          );
        }
        break;

      case PdfExportMode.allBoards:
        final boards = allBoards ?? [];
        if (boards.isNotEmpty) {
          for (var i = 0; i < boards.length; i++) {
            final board = boards[i];
            if (board.elements.isEmpty) continue;

            onProgress?.call('Rendering "${board.title}" (${i + 1}/${boards.length})...');
            await Future<void>.delayed(const Duration(milliseconds: 20));

            final pageRender = await _renderPagePixels(
              elements: board.elements,
              colors: colors,
            );
            if (pageRender != null) {
              final pdfImage = PdfImage(
                pdf.document,
                image: pageRender.rawBytes,
                width: pageRender.width,
                height: pageRender.height,
                alpha: false,
              );
              final imageProvider = pw.ImageProxy(pdfImage);
              pdf.addPage(
                pw.Page(
                  pageFormat: PdfPageFormat.a4.landscape,
                  margin: pw.EdgeInsets.zero,
                  build: (pw.Context context) {
                    return pw.FullPage(
                      ignoreMargins: true,
                      child: pw.Center(
                        child: pw.Image(imageProvider, fit: pw.BoxFit.contain),
                      ),
                    );
                  },
                ),
              );
            }
          }
        }
        break;
    }

    onProgress?.call('Finalizing PDF document...');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return pdf.save();
  }

  static Future<_RawPageRender?> _renderPagePixels({
    required List<BoardElement> elements,
    required BoardColors colors,
    Rect? boundingBox,
    double maxDimension = 1800.0,
  }) async {
    final visibleElements = elements.where((e) => e.isVisible).toList();
    if (visibleElements.isEmpty) return null;

    Rect bounds;
    if (boundingBox != null) {
      bounds = boundingBox.inflate(16.0);
    } else {
      bounds = visibleElements.first.bounds;
      for (var i = 1; i < visibleElements.length; i++) {
        bounds = bounds.expandToInclude(visibleElements[i].bounds);
      }
      bounds = bounds.inflate(40.0);
    }

    var scale = 2.0;
    final maxSide = math.max(bounds.width, bounds.height);
    if (maxSide * scale > maxDimension) {
      scale = maxDimension / maxSide;
    }

    final width = (bounds.width * scale).ceil().toDouble();
    final height = (bounds.height * scale).ceil().toDouble();

    if (width <= 0 || height <= 0) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Background fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = colors.background,
    );

    canvas.scale(scale);
    canvas.translate(-bounds.left, -bounds.top);

    // Draw elements
    for (final el in visibleElements) {
      if (boundingBox != null) {
        if (el.type == ShapeType.frame && el.bounds == boundingBox) continue;
        if (!el.bounds.overlaps(boundingBox) && !boundingBox.contains(el.start)) continue;
      }
      ElementRenderer.draw(canvas, el, colors);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (byteData == null) return null;
    return _RawPageRender(byteData.buffer.asUint8List(), width.toInt(), height.toInt());
  }
}
