import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/clipboard/data/services/clipboard_service.dart';

abstract class ClipboardRepository {
  bool get hasInternalData;

  void copy(List<BoardElement> elements);

  List<BoardElement> duplicate({Offset offset = const Offset(24, 24)});

  Future<PasteResult?> pasteFromSystem({
    required Offset targetCanvasPosition,
    Color defaultColor = const Color(0xFF1971C2),
  });

  BoardElement createImageElement({
    required String base64Image,
    required Offset position,
    double width = 320.0,
    double height = 220.0,
  });
}
