import 'package:flutter/material.dart';
import '../models/board_element.dart';

class AlignmentService {
  /// Aligns the elements according to the given [alignment] mode.
  /// Options: 'left', 'center', 'right', 'top', 'middle', 'bottom'
  static List<BoardElement> alignElements({
    required List<BoardElement> allElements,
    required Set<String> selectedIds,
    required String alignment,
  }) {
    if (selectedIds.length < 2) return allElements;

    final selected = allElements.where((e) => selectedIds.contains(e.id)).toList();
    if (selected.isEmpty) return allElements;

    Rect combined = selected.first.bounds;
    for (var i = 1; i < selected.length; i++) {
      combined = combined.expandToInclude(selected[i].bounds);
    }

    return [
      for (final el in allElements)
        if (!selectedIds.contains(el.id))
          el
        else
          switch (alignment) {
            'left' => el.translated(Offset(combined.left - el.bounds.left, 0)),
            'right' => el.translated(Offset(combined.right - el.bounds.right, 0)),
            'center' => el.translated(
                Offset(combined.center.dx - el.bounds.center.dx, 0)),
            'top' => el.translated(Offset(0, combined.top - el.bounds.top)),
            'bottom' => el.translated(Offset(0, combined.bottom - el.bounds.bottom)),
            'middle' => el.translated(
                Offset(0, combined.center.dy - el.bounds.center.dy)),
            _ => el,
          },
    ];
  }

  /// Distributes elements evenly either horizontally or vertically.
  /// Options: 'horizontal', 'vertical'
  static List<BoardElement> distributeElements({
    required List<BoardElement> allElements,
    required Set<String> selectedIds,
    required String direction,
  }) {
    if (selectedIds.length < 3) return allElements;

    final selected = allElements.where((e) => selectedIds.contains(e.id)).toList();
    if (selected.length < 3) return allElements;

    final updatedMap = <String, BoardElement>{};

    if (direction == 'horizontal') {
      selected.sort((a, b) => a.bounds.left.compareTo(b.bounds.left));
      final first = selected.first;
      final last = selected.last;

      final totalSpan = last.bounds.right - first.bounds.left;
      final totalItemsWidth =
          selected.fold<double>(0.0, (sum, el) => sum + el.bounds.width);
      final totalGap = totalSpan - totalItemsWidth;

      if (totalGap >= 0) {
        final gap = totalGap / (selected.length - 1);
        double currentLeft = first.bounds.left;

        for (var i = 0; i < selected.length; i++) {
          final el = selected[i];
          final dx = currentLeft - el.bounds.left;
          updatedMap[el.id] = el.translated(Offset(dx, 0));
          currentLeft += el.bounds.width + gap;
        }
      } else {
        // Fallback: distribute centers equally
        final startCenter = first.bounds.center.dx;
        final endCenter = last.bounds.center.dx;
        final step = (endCenter - startCenter) / (selected.length - 1);

        for (var i = 0; i < selected.length; i++) {
          final el = selected[i];
          final targetCenter = startCenter + i * step;
          final dx = targetCenter - el.bounds.center.dx;
          updatedMap[el.id] = el.translated(Offset(dx, 0));
        }
      }
    } else if (direction == 'vertical') {
      selected.sort((a, b) => a.bounds.top.compareTo(b.bounds.top));
      final first = selected.first;
      final last = selected.last;

      final totalSpan = last.bounds.bottom - first.bounds.top;
      final totalItemsHeight =
          selected.fold<double>(0.0, (sum, el) => sum + el.bounds.height);
      final totalGap = totalSpan - totalItemsHeight;

      if (totalGap >= 0) {
        final gap = totalGap / (selected.length - 1);
        double currentTop = first.bounds.top;

        for (var i = 0; i < selected.length; i++) {
          final el = selected[i];
          final dy = currentTop - el.bounds.top;
          updatedMap[el.id] = el.translated(Offset(0, dy));
          currentTop += el.bounds.height + gap;
        }
      } else {
        // Fallback: distribute centers equally
        final startCenter = first.bounds.center.dy;
        final endCenter = last.bounds.center.dy;
        final step = (endCenter - startCenter) / (selected.length - 1);

        for (var i = 0; i < selected.length; i++) {
          final el = selected[i];
          final targetCenter = startCenter + i * step;
          final dy = targetCenter - el.bounds.center.dy;
          updatedMap[el.id] = el.translated(Offset(0, dy));
        }
      }
    }

    return [
      for (final el in allElements)
        updatedMap.containsKey(el.id) ? updatedMap[el.id]! : el,
    ];
  }
}
