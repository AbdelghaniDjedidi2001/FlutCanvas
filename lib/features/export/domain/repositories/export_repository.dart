import 'dart:typed_data';
import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_document.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/export/data/services/pdf_export_service.dart';

abstract class ExportRepository {
  Future<Uint8List?> renderToPng({
    required List<BoardElement> elements,
    required BoardColors colors,
    bool includeBackground = true,
    double scale = 2.0,
    double? maxDimension,
    double padding = 40.0,
    void Function(String status)? onProgress,
  });

  String exportToSvg({
    required List<BoardElement> elements,
    required BoardColors colors,
    bool includeBackground = true,
  });

  Future<Uint8List> exportToPdf({
    required List<BoardElement> elements,
    required BoardColors colors,
    List<BoardDocument>? allBoards,
    PdfExportMode mode = PdfExportMode.currentBoard,
    void Function(String status)? onProgress,
  });

  String exportToJson(List<BoardElement> elements);

  List<BoardElement>? importFromJson(String rawJson);
}
