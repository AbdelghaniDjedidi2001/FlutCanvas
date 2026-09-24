import 'package:flutter/material.dart';
import '../models/board_element.dart';

class ClipboardService {
  static List<BoardElement> _clipboard = [];

  static bool get hasData => _clipboard.isNotEmpty;

  static void copy(List<BoardElement> elements) {
    _clipboard = elements.map((e) => e.copyWith()).toList();
  }

  static List<BoardElement> paste({Offset offset = const Offset(24, 24)}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    var counter = 0;
    final pasted = <BoardElement>[];

    for (final el in _clipboard) {
      final newId = 'el_${now}_${counter++}';
      final translated = el.translated(offset).copyWith(id: newId);
      pasted.add(translated);
    }

    return pasted;
  }
}
