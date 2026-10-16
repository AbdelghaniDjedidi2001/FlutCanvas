import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/utils/canvas_dialog_coordinator.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/empty_canvas_guide.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';

/// Overlay that presents an onboarding guide when the canvas is empty.
class CanvasEmptyGuideOverlay extends StatelessWidget {
  final CanvasViewportController viewport;
  final Size Function() getViewSize;

  const CanvasEmptyGuideOverlay({
    super.key,
    required this.viewport,
    required this.getViewSize,
  });

  @override
  Widget build(BuildContext context) {
    final isPresenting =
        context.select<PresentationCubit, bool>((c) => c.state.isPresenting);
    if (isPresenting) return const SizedBox.shrink();

    final hasElements = context
        .select<CanvasBloc, bool>((b) => b.state.elements.isNotEmpty);
    if (hasElements) return const SizedBox.shrink();

    return Positioned.fill(
      child: EmptyCanvasGuide(
        onOpenImport: () => CanvasDialogCoordinator.showExportDialog(
          context,
          viewport,
          getViewSize(),
        ),
        onOpenTemplates: () => CanvasDialogCoordinator.showTemplatesDialog(
          context,
          viewport,
          getViewSize(),
        ),
        onOpenMermaid: ([script]) =>
            CanvasDialogCoordinator.showMermaidDialog(
          context,
          viewport,
          getViewSize(),
          script,
        ),
        onOpenHelp: () =>
            CanvasDialogCoordinator.showShortcutsHelpDialog(context),
        onInsertImage: () => CanvasDialogCoordinator.handleInsertImage(
          context,
          viewport,
          getViewSize(),
        ),
        onSelectTool: (tool) => context.read<ToolCubit>().setTool(tool),
      ),
    );
  }
}
