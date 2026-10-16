import 'package:flutter/material.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/data/services/connector_routing_service.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_state.dart';

/// Manages active in-canvas text, code block, sticky note, and table cell editing.
class CanvasTextEditingController extends ChangeNotifier {
  int _idCounter = 0;

  BoardElement? _pendingNewElement;
  String? _editingElementId;
  (int, int)? _editingTableCell;
  Offset? _editingScreenPos;
  bool _isEditingSticky = false;
  bool _isEditingCode = false;

  bool get isEditing => _editingElementId != null;
  String? get editingElementId => _editingElementId;
  (int, int)? get editingTableCell => _editingTableCell;
  Offset? get editingScreenPos => _editingScreenPos;
  bool get isEditingSticky => _isEditingSticky;
  bool get isEditingCode => _isEditingCode;
  BoardElement? get pendingNewElement => _pendingNewElement;

  /// Starts editing a newly placed text or sticky note element.
  BoardElement createAndStartTextEditing({
    required Offset worldPos,
    required Offset screenPos,
    required bool isSticky,
    required ToolState toolState,
    required BoardColors colors,
  }) {
    final newId =
        'el_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';
    final initialColor = isSticky
        ? const Color(0xFF212529)
        : (colors.isDark ? Colors.white : kInk);
    final strokeColor = (toolState.strokeColor == kInk ||
            toolState.strokeColor == Colors.black ||
            toolState.strokeColor == Colors.white)
        ? initialColor
        : toolState.strokeColor;

    final newElement = BoardElement(
      id: newId,
      type: isSticky ? ShapeType.stickyNote : ShapeType.text,
      start: worldPos,
      end: isSticky
          ? worldPos + const Offset(180, 160)
          : worldPos + const Offset(200, 40),
      color: strokeColor,
      fillColor:
          isSticky ? BoardColors.stickyNoteColors[0] : toolState.fillColor,
      fontSize: isSticky ? 18.0 : toolState.fontSize,
      drawStyle: toolState.drawStyle,
      opacity: 1.0,
      text: '',
    );

    _pendingNewElement = newElement;
    _editingElementId = newId;
    _editingTableCell = null;
    _editingScreenPos = screenPos;
    _isEditingSticky = isSticky;
    _isEditingCode = false;
    notifyListeners();

    return newElement;
  }

  /// Handles double tap to enter edit mode for text, tables, connectors, sticky notes, or code blocks.
  bool handleDoubleTap({
    required Offset localPos,
    required List<BoardElement> elements,
    required CanvasViewportController viewport,
  }) {
    final world = viewport.toWorld(localPos);
    final tol = 6.0 / viewport.zoom;

    BoardElement? hit;
    for (final el in elements.reversed) {
      if (el.isVisible && el.hitTest(world, tol)) {
        hit = el;
        break;
      }
    }

    if (hit != null && !hit.isLocked) {
      if (hit.type == ShapeType.table) {
        final cell = hit.hitTestCell(world);
        if (cell != null) {
          final cellRect = hit.getCellRect(cell.$1, cell.$2);
          _editingElementId = hit.id;
          _editingTableCell = (cell.$1, cell.$2);
          _editingScreenPos = viewport.toScreen(cellRect.topLeft);
          _isEditingSticky = false;
          _isEditingCode = false;
          _pendingNewElement = null;
          notifyListeners();
          return true;
        }
        return false;
      }

      if (hit.type == ShapeType.line ||
          hit.type == ShapeType.arrow ||
          hit.type == ShapeType.doubleArrow) {
        final route = ConnectorRoutingService.computeRoute(hit);
        _editingElementId = hit.id;
        _editingTableCell = null;
        _editingScreenPos = viewport.toScreen(route.midpoint);
        _isEditingSticky = false;
        _isEditingCode = false;
        _pendingNewElement = null;
        notifyListeners();
        return true;
      }

      if (hit.type == ShapeType.text ||
          hit.type == ShapeType.stickyNote ||
          hit.type == ShapeType.codeBlock) {
        _editingElementId = hit.id;
        _editingTableCell = null;
        _editingScreenPos = viewport.toScreen(
          hit.type == ShapeType.codeBlock
              ? hit.bounds.topLeft + const Offset(0, 32)
              : hit.bounds.topLeft,
        );
        _isEditingSticky = hit.type == ShapeType.stickyNote;
        _isEditingCode = hit.type == ShapeType.codeBlock;
        _pendingNewElement = null;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Opens inline editor for connector label from properties panel.
  void editConnectorLabel(
    BoardElement connector,
    CanvasViewportController viewport,
  ) {
    final route = ConnectorRoutingService.computeRoute(connector);
    _editingElementId = connector.id;
    _editingTableCell = null;
    _editingScreenPos = viewport.toScreen(route.midpoint);
    _isEditingSticky = false;
    _isEditingCode = false;
    _pendingNewElement = null;
    notifyListeners();
  }

  /// Navigates across table cells (Tab / Shift-Tab / Enter).
  BoardElement? navigateTableCell({
    required int dRow,
    required int dCol,
    required String currentText,
    required List<BoardElement> elements,
    required CanvasViewportController viewport,
  }) {
    if (_editingElementId == null || _editingTableCell == null) return null;
    final elementId = _editingElementId!;
    final currentCell = _editingTableCell!;
    final el = elements.where((e) => e.id == elementId).firstOrNull;
    if (el == null || el.type != ShapeType.table) return null;

    final updatedEl =
        el.updateTableCell(currentCell.$1, currentCell.$2, currentText);
    final rows = updatedEl.tableRowCount;
    final cols = updatedEl.tableColCount;

    var nextRow = currentCell.$1 + dRow;
    var nextCol = currentCell.$2 + dCol;

    if (nextCol >= cols) {
      nextCol = 0;
      nextRow++;
    } else if (nextCol < 0) {
      nextCol = cols - 1;
      nextRow--;
    }

    if (nextRow < 0) nextRow = 0;
    if (nextRow >= rows) {
      clearEditing();
      return updatedEl;
    }

    final nextCellRect = updatedEl.getCellRect(nextRow, nextCol);
    _editingTableCell = (nextRow, nextCol);
    _editingScreenPos = viewport.toScreen(nextCellRect.topLeft);
    notifyListeners();
    return updatedEl;
  }

  /// Clears active editing session.
  void clearEditing() {
    _pendingNewElement = null;
    _editingElementId = null;
    _editingTableCell = null;
    _editingScreenPos = null;
    _isEditingSticky = false;
    _isEditingCode = false;
    notifyListeners();
  }
}
