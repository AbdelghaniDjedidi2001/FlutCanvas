import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/utils/canvas_dialog_coordinator.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/board_tabs_bar.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/main_toolbar.dart';

/// Top bar container holding BoardTabsBar and MainToolbar.
class CanvasTopBar extends StatelessWidget {
  final CanvasViewportController viewport;
  final Size Function() getViewSize;

  const CanvasTopBar({
    super.key,
    required this.viewport,
    required this.getViewSize,
  });

  @override
  Widget build(BuildContext context) {
    final isPresenting =
        context.select<PresentationCubit, bool>((c) => c.state.isPresenting);
    if (isPresenting) return const SizedBox.shrink();

    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: ExcludeFocus(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BoardTabsBar(),
            const SizedBox(width: 8),
            Expanded(
              child: Center(
                child: MainToolbar(
                  onClear: () => context
                      .read<CanvasBloc>()
                      .add(const CanvasEvent.loadElements([])),
                  onOpenExport: () => CanvasDialogCoordinator.showExportDialog(
                    context,
                    viewport,
                    getViewSize(),
                  ),
                  onOpenTemplates: () =>
                      CanvasDialogCoordinator.showTemplatesDialog(
                    context,
                    viewport,
                    getViewSize(),
                  ),
                  onStartPresentation: () {
                    final elements = context.read<CanvasBloc>().state.elements;
                    context
                        .read<PresentationCubit>()
                        .startPresentation(elements);
                  },
                  onToggleProperties: () =>
                      context.read<ToolCubit>().togglePropertiesPanel(),
                  onToggleLayers: () =>
                      context.read<ToolCubit>().toggleLayersSidebar(),
                  onInsertImage: () =>
                      CanvasDialogCoordinator.handleInsertImage(
                    context,
                    viewport,
                    getViewSize(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
