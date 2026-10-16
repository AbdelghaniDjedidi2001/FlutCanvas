import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/core/services/clipboard/clipboard_paste_service.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/utils/canvas_dialog_coordinator.dart';
import 'package:flutcanvas/features/clipboard/data/services/clipboard_service.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';

/// Coordinates copy, paste, duplicate, and clipboard listeners for the whiteboard canvas.
class CanvasClipboardCoordinator {
  int _counter = 0;

  void copySelected(BuildContext context) {
    final elements = context.read<CanvasBloc>().state.elements;
    final selectedIds = context.read<CanvasBloc>().state.selectedIds;
    final selected = elements.where((e) => selectedIds.contains(e.id)).toList();
    if (selected.isEmpty) return;

    ClipboardService.copy(selected);
    CanvasDialogCoordinator.showToast(
      context,
      'Copied ${selected.length} element(s)',
    );
  }

  void duplicateSelected(BuildContext context) {
    final elements = context.read<CanvasBloc>().state.elements;
    final selectedIds = context.read<CanvasBloc>().state.selectedIds;
    final selected = elements.where((e) => selectedIds.contains(e.id)).toList();
    if (selected.isEmpty) return;

    final duplicated = selected.map((el) {
      final newId =
          'el_${DateTime.now().millisecondsSinceEpoch}_${_counter++}';
      return el.translated(const Offset(24, 24)).copyWith(id: newId);
    }).toList();

    context.read<CanvasBloc>().add(CanvasEvent.addElements(duplicated));
    context.read<CanvasBloc>().add(
          CanvasEvent.selectElements(duplicated.map((e) => e.id).toSet()),
        );
    CanvasDialogCoordinator.showToast(
      context,
      'Duplicated ${duplicated.length} element(s)',
    );
  }

  Future<void> paste(
    BuildContext context,
    CanvasViewportController viewport,
    Size viewSize,
  ) async {
    final center = viewport.toWorld(
      Offset(viewSize.width / 2, viewSize.height / 2),
    );
    final pasteResult = await ClipboardService.pasteFromSystem(
      targetCanvasPosition: center,
      defaultColor: context.read<ToolCubit>().state.strokeColor,
    );
    if (!context.mounted) return;

    if (pasteResult != null && pasteResult.elements.isNotEmpty) {
      context
          .read<CanvasBloc>()
          .add(CanvasEvent.addElements(pasteResult.elements));
      context.read<CanvasBloc>().add(
            CanvasEvent.selectElements(
              pasteResult.elements.map((e) => e.id).toSet(),
            ),
          );
      CanvasDialogCoordinator.showToast(
        context,
        'Pasted ${pasteResult.sourceDescription}',
      );
      return;
    }

    if (ClipboardService.hasInternalData) {
      final duplicated = ClipboardService.duplicate();
      if (duplicated.isNotEmpty) {
        context.read<CanvasBloc>().add(CanvasEvent.addElements(duplicated));
        context.read<CanvasBloc>().add(
              CanvasEvent.selectElements(
                duplicated.map((e) => e.id).toSet(),
              ),
            );
        CanvasDialogCoordinator.showToast(
          context,
          'Pasted ${duplicated.length} element(s)',
        );
      }
    }
  }

  void initWebPasteListener({
    required BuildContext Function() getContext,
    required CanvasViewportController Function() getViewport,
    required Size Function() getViewSize,
  }) {
    ClipboardPasteService.initWebPasteListener((base64Image) {
      final context = getContext();
      if (!context.mounted) return;

      final viewport = getViewport();
      final viewSize = getViewSize();
      final center = viewport.toWorld(
        Offset(viewSize.width / 2, viewSize.height / 2),
      );
      final imgEl = ClipboardService.createImageElement(
        base64Image: base64Image,
        position: center - const Offset(160, 110),
      );

      context.read<CanvasBloc>().add(CanvasEvent.addElement(imgEl));
      context.read<CanvasBloc>().add(CanvasEvent.selectElements({imgEl.id}));
      CanvasDialogCoordinator.showToast(context, 'Pasted image from clipboard');
    });
  }

  void dispose() {
    ClipboardPasteService.dispose();
  }
}
