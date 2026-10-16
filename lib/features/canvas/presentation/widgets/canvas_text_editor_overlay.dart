import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_text_editing_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/inline_text_editor.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';

/// Floating in-canvas text, sticky note, code block, and table cell editor overlay.
class CanvasTextEditorOverlay extends StatelessWidget {
  final CanvasTextEditingController controller;
  final CanvasViewportController viewport;
  final FocusNode focusNode;

  const CanvasTextEditorOverlay({
    super.key,
    required this.controller,
    required this.viewport,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isEditing || controller.editingScreenPos == null) {
          return const SizedBox.shrink();
        }

        final canvasState = context.watch<CanvasBloc>().state;
        final toolState = context.watch<ToolCubit>().state;
        final colors = BoardColors.of(context);

        final editingId = controller.editingElementId;
        final editingEl = canvasState.elements
                .where((e) => e.id == editingId)
                .firstOrNull ??
            (controller.pendingNewElement?.id == editingId
                ? controller.pendingNewElement
                : null);

        if (editingEl == null) {
          return const SizedBox.shrink();
        }

        final isConnector = editingEl.type == ShapeType.line ||
            editingEl.type == ShapeType.arrow ||
            editingEl.type == ShapeType.doubleArrow;
        final editingCell = controller.editingTableCell;
        final isTableCell =
            editingCell != null && editingEl.type == ShapeType.table;

        final initialText = isTableCell
            ? (editingCell.$1 < editingEl.tableRowCount &&
                    editingCell.$2 < editingEl.tableColCount
                ? editingEl.safeTableData[editingCell.$1][editingCell.$2]
                : '')
            : (isConnector ? (editingEl.label ?? '') : editingEl.text);

        final cellWidth = isTableCell
            ? editingEl.getCellRect(editingCell.$1, editingCell.$2).width *
                viewport.zoom
            : null;

        final isMonoOrDefault = editingEl.color == kInk ||
            editingEl.color == Colors.black ||
            editingEl.color == Colors.white ||
            editingEl.color.toARGB32() == 0xFF1F2430 ||
            editingEl.color.toARGB32() == 0xFF000000 ||
            editingEl.color.toARGB32() == 0xFFFFFFFF;
        final textNoteColor = isMonoOrDefault
            ? (colors.isDark ? Colors.white : const Color(0xFF212529))
            : editingEl.color;

        return InlineTextEditor(
          initialText: initialText,
          fontSize: isConnector
              ? 16.0
              : (isTableCell ? editingEl.fontSize : toolState.fontSize),
          color: isConnector
              ? editingEl.color
              : (isTableCell
                  ? (colors.isDark ? Colors.white : const Color(0xFF212529))
                  : (controller.isEditingSticky
                      ? const Color(0xFF212529)
                      : (controller.isEditingCode
                          ? (colors.isDark
                              ? const Color(0xFFCDD6F4)
                              : const Color(0xFF24292F))
                          : textNoteColor))),
          screenPosition: controller.editingScreenPos!,
          isStickyNote: controller.isEditingSticky,
          isCodeBlock: controller.isEditingCode,
          isTableCell: isTableCell,
          customWidth: isTableCell
              ? cellWidth
              : (controller.isEditingCode
                  ? math.max(
                      340.0,
                      editingEl.bounds.width * viewport.zoom,
                    )
                  : null),
          onNavigateCell: (dRow, dCol, currentText) {
            final updatedEl = controller.navigateTableCell(
              dRow: dRow,
              dCol: dCol,
              currentText: currentText,
              elements: canvasState.elements,
              viewport: viewport,
            );
            if (updatedEl != null) {
              context
                  .read<CanvasBloc>()
                  .add(CanvasEvent.updateElement(updatedEl));
            }
          },
          onSubmitted: (newText) {
            if (isTableCell) {
              final updated = editingEl.updateTableCell(
                editingCell.$1,
                editingCell.$2,
                newText,
              );
              context
                  .read<CanvasBloc>()
                  .add(CanvasEvent.updateElement(updated));
            } else if (isConnector) {
              final updated = editingEl.copyWith(
                label: newText.trim().isEmpty ? null : newText.trim(),
              );
              context
                  .read<CanvasBloc>()
                  .add(CanvasEvent.updateElement(updated));
            } else {
              final updated = editingEl.copyWith(
                text: newText,
                color: isMonoOrDefault
                    ? (colors.isDark ? Colors.white : kInk)
                    : editingEl.color,
              );
              context
                  .read<CanvasBloc>()
                  .add(CanvasEvent.updateElement(updated));
            }

            controller.clearEditing();
            focusNode.requestFocus();
          },
          onCanceled: () {
            if (!isConnector &&
                !isTableCell &&
                editingEl.text.trim().isEmpty) {
              context.read<CanvasBloc>().add(
                    CanvasEvent.deleteElements({editingEl.id}),
                  );
            }
            controller.clearEditing();
            focusNode.requestFocus();
          },
        );
      },
    );
  }
}
