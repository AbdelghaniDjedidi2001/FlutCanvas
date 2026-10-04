import 'dart:typed_data';
import 'package:injectable/injectable.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_document.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/export/data/services/export_service.dart';
import '../../domain/repositories/export_repository.dart';

@LazySingleton(as: ExportRepository)
class DefaultExportRepository implements ExportRepository {
  @override
  Future<Uint8List?> renderToPng({
    required List<BoardElement> elements,
    required BoardColors colors,
    bool includeBackground = true,
    double scale = 2.0,
    double? maxDimension,
    double padding = 40.0,
    void Function(String status)? onProgress,
  }) {
    return ExportService.renderToPng(
      elements: elements,
      colors: colors,
      includeBackground: includeBackground,
      scale: scale,
      maxDimension: maxDimension,
      padding: padding,
      onProgress: onProgress,
    );
  }

  @override
  String exportToSvg({
    required List<BoardElement> elements,
    required BoardColors colors,
    bool includeBackground = true,
  }) {
    return ExportService.exportToSvg(
      elements: elements,
      colors: colors,
      includeBackground: includeBackground,
    );
  }

  @override
  Future<Uint8List> exportToPdf({
    required List<BoardElement> elements,
    required BoardColors colors,
    List<BoardDocument>? allBoards,
    PdfExportMode mode = PdfExportMode.currentBoard,
    void Function(String status)? onProgress,
  }) {
    return ExportService.exportToPdf(
      elements: elements,
      colors: colors,
      allBoards: allBoards,
      mode: mode,
      onProgress: onProgress,
    );
  }

  @override
  String exportToJson(List<BoardElement> elements) {
    return ExportService.exportToJson(elements);
  }

  @override
  List<BoardElement>? importFromJson(String rawJson) {
    return ExportService.importFromJson(rawJson);
  }
}
