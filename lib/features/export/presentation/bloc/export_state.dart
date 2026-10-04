import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutcanvas/features/export/data/services/pdf_export_service.dart';

part 'export_state.freezed.dart';

enum ExportFormat {
  png('PNG Image', 'High-resolution raster graphic'),
  svg('SVG Vector', 'Scalable vector format for web and print'),
  pdf('PDF Document', 'Multi-page document or presentation slides'),
  json('FlutCanvas JSON', 'Full editable project backup');

  const ExportFormat(this.label, this.description);
  final String label;
  final String description;
}

@Freezed(fromJson: false, toJson: false)
abstract class ExportState with _$ExportState {
  const factory ExportState({
    @Default(ExportFormat.png) ExportFormat format,
    @Default(PdfExportMode.currentBoard) PdfExportMode pdfMode,
    @Default(true) bool includeBackground,
    @Default(2.0) double scale,
    @Default(40.0) double padding,
    @Default(false) bool isExporting,
    @Default('') String statusMessage,
    String? errorMessage,
  }) = _ExportState;
}
