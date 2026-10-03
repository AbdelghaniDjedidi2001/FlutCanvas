import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../models/board_element.dart';
import '../../../../services/clipboard_service.dart';
import '../../domain/repositories/clipboard_repository.dart';

@LazySingleton(as: ClipboardRepository)
class DefaultClipboardRepository implements ClipboardRepository {
  List<BoardElement> _inMemoryClipboard = [];

  @override
  bool get hasInternalData => _inMemoryClipboard.isNotEmpty;

  @override
  void copy(List<BoardElement> elements) {
    if (elements.isEmpty) return;
    _inMemoryClipboard = elements.map((e) => e.copyWith()).toList();
    ClipboardService.copy(elements);
  }

  @override
  List<BoardElement> duplicate({Offset offset = const Offset(24, 24)}) {
    if (_inMemoryClipboard.isEmpty) return ClipboardService.duplicate(offset: offset);
    final now = DateTime.now().millisecondsSinceEpoch;
    var counter = 0;
    final pasted = <BoardElement>[];

    for (final el in _inMemoryClipboard) {
      final newId = 'el_${now}_${counter++}';
      final translated = el.translated(offset).copyWith(id: newId);
      pasted.add(translated);
    }
    return pasted;
  }

  @override
  Future<PasteResult?> pasteFromSystem({
    required Offset targetCanvasPosition,
    Color defaultColor = const Color(0xFF1971C2),
  }) {
    return ClipboardService.pasteFromSystem(
      targetCanvasPosition: targetCanvasPosition,
      defaultColor: defaultColor,
    );
  }

  @override
  BoardElement createImageElement({
    required String base64Image,
    required Offset position,
    double width = 320.0,
    double height = 220.0,
  }) {
    return ClipboardService.createImageElement(
      base64Image: base64Image,
      position: position,
      width: width,
      height: height,
    );
  }
}
