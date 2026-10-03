import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../models/board_colors.dart';
import '../../../../models/board_document.dart';
import '../../../../models/board_element.dart';
import '../../../../services/pdf_export_service.dart';
import '../../domain/repositories/export_repository.dart';
import 'export_state.dart';

@injectable
class ExportCubit extends Cubit<ExportState> {
  final ExportRepository _repository;

  ExportCubit(this._repository) : super(const ExportState());

  void setFormat(ExportFormat format) => emit(state.copyWith(format: format));

  void setPdfMode(PdfExportMode mode) => emit(state.copyWith(pdfMode: mode));

  void setIncludeBackground(bool include) =>
      emit(state.copyWith(includeBackground: include));

  void setScale(double scale) => emit(state.copyWith(scale: scale));

  void setPadding(double padding) => emit(state.copyWith(padding: padding));

  Future<Uint8List?> exportPng({
    required List<BoardElement> elements,
    required BoardColors colors,
  }) async {
    emit(state.copyWith(
        isExporting: true, statusMessage: 'Starting PNG export...'));
    try {
      final bytes = await _repository.renderToPng(
        elements: elements,
        colors: colors,
        includeBackground: state.includeBackground,
        scale: state.scale,
        padding: state.padding,
        onProgress: (status) => emit(state.copyWith(statusMessage: status)),
      );
      emit(state.copyWith(isExporting: false, statusMessage: 'Export complete'));
      return bytes;
    } catch (e) {
      emit(state.copyWith(
          isExporting: false, errorMessage: 'Export failed: $e'));
      return null;
    }
  }

  String exportSvg({
    required List<BoardElement> elements,
    required BoardColors colors,
  }) {
    return _repository.exportToSvg(
      elements: elements,
      colors: colors,
      includeBackground: state.includeBackground,
    );
  }

  Future<Uint8List?> exportPdf({
    required List<BoardElement> elements,
    required BoardColors colors,
    List<BoardDocument>? allBoards,
  }) async {
    emit(state.copyWith(
        isExporting: true, statusMessage: 'Starting PDF export...'));
    try {
      final bytes = await _repository.exportToPdf(
        elements: elements,
        colors: colors,
        allBoards: allBoards,
        mode: state.pdfMode,
        onProgress: (status) => emit(state.copyWith(statusMessage: status)),
      );
      emit(state.copyWith(isExporting: false, statusMessage: 'Export complete'));
      return bytes;
    } catch (e) {
      emit(state.copyWith(
          isExporting: false, errorMessage: 'Export failed: $e'));
      return null;
    }
  }

  String exportJson(List<BoardElement> elements) {
    return _repository.exportToJson(elements);
  }
}
