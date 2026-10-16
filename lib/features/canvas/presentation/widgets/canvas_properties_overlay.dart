import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_text_editing_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/utils/canvas_dialog_coordinator.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties_panel.dart';

/// Floating Properties Panel overlay with handlers for code blocks and connectors.
class CanvasPropertiesOverlay extends StatelessWidget {
  final CanvasViewportController viewport;
  final CanvasTextEditingController textEditingController;

  const CanvasPropertiesOverlay({
    super.key,
    required this.viewport,
    required this.textEditingController,
  });

  @override
  Widget build(BuildContext context) {
    final isPresenting =
        context.select<PresentationCubit, bool>((c) => c.state.isPresenting);
    if (isPresenting) return const SizedBox.shrink();

    final toolState = context.watch<ToolCubit>().state;
    final canvasState = context.watch<CanvasBloc>().state;

    final shouldShow =
        toolState.isPropertiesOpen || canvasState.selectedIds.isNotEmpty;
    if (!shouldShow) return const SizedBox.shrink();

    return Positioned(
      top: 64,
      left: 12,
      child: ExcludeFocus(
        child: PropertiesPanel(
          currentCodeLanguage: toolState.codeLanguage,
          onCodeLanguageChanged: (newLang) {
            context.read<ToolCubit>().setCodeLanguage(newLang);
            final codeElements = canvasState.selectedElements
                .where((e) => e.type == ShapeType.codeBlock)
                .toList();
            if (codeElements.isNotEmpty) {
              final updated = codeElements
                  .map((e) => e.copyWith(codeLanguage: newLang))
                  .toList();
              context
                  .read<CanvasBloc>()
                  .add(CanvasEvent.updateElements(updated));
            }
          },
          onToggleLineNumbers: (show) {
            final codeElements = canvasState.selectedElements
                .where((e) => e.type == ShapeType.codeBlock)
                .toList();
            if (codeElements.isNotEmpty) {
              final updated = codeElements
                  .map((e) => e.copyWith(showLineNumbers: show))
                  .toList();
              context
                  .read<CanvasBloc>()
                  .add(CanvasEvent.updateElements(updated));
            }
          },
          onCopyCode: () {
            final codeEl = canvasState.selectedElements
                .where((e) => e.type == ShapeType.codeBlock)
                .firstOrNull;
            if (codeEl != null) {
              Clipboard.setData(ClipboardData(text: codeEl.text));
              CanvasDialogCoordinator.showToast(
                context,
                'Code copied to clipboard',
              );
            }
          },
          onEditConnectorLabel: () {
            final connector = canvasState.selectedElements
                .where((e) =>
                    e.type == ShapeType.line ||
                    e.type == ShapeType.arrow ||
                    e.type == ShapeType.doubleArrow)
                .firstOrNull;
            if (connector != null) {
              textEditingController.editConnectorLabel(connector, viewport);
            }
          },
          onClose: () => context.read<ToolCubit>().setPropertiesOpen(false),
        ),
      ),
    );
  }
}
