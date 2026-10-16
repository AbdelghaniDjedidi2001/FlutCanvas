import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/utils/canvas_dialog_coordinator.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/minimap_widget.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/theme_toggle.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/zoom_controls.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';

/// Bottom HUD overlay containing ZoomControls (bottom-left) and Minimap/Theme/Help (bottom-right).
class CanvasBottomControls extends StatelessWidget {
  final CanvasViewportController viewport;
  final Size viewSize;
  final void Function(Brightness current, [Offset? origin]) onToggleTheme;

  const CanvasBottomControls({
    super.key,
    required this.viewport,
    required this.viewSize,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isPresenting =
        context.select<PresentationCubit, bool>((c) => c.state.isPresenting);
    if (isPresenting) return const SizedBox.shrink();

    final toolState = context.watch<ToolCubit>().state;
    final canvasState = context.watch<CanvasBloc>().state;
    final colors = BoardColors.of(context);

    return Stack(
      children: [
        // Bottom-Left Zoom Controls
        Positioned(
          left: 16,
          bottom: 16,
          child: ExcludeFocus(
            child: ZoomControls(
              controller: viewport,
              isGridSnap: toolState.gridSnap,
              onToggleGridSnap: () =>
                  context.read<ToolCubit>().toggleGridSnap(),
              isSmartGuides: toolState.smartGuides,
              onToggleSmartGuides: () =>
                  context.read<ToolCubit>().toggleSmartGuides(),
              isShapeSnapping: toolState.autoShapeRecognition,
              onToggleShapeSnapping: () =>
                  context.read<ToolCubit>().toggleAutoShapeRecognition(),
            ),
          ),
        ),

        // Bottom-Right Radar Minimap, Theme Toggle & Help
        Positioned(
          right: 16,
          bottom: 16,
          child: ExcludeFocus(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (canvasState.elements.isNotEmpty &&
                    viewSize.width > 540) ...[
                  ListenableBuilder(
                    listenable: viewport,
                    builder: (context, _) => MinimapWidget(
                      elements: canvasState.elements,
                      pan: viewport.pan,
                      zoom: viewport.zoom,
                      viewSize: viewSize,
                      colors: colors,
                      onJumpTo: (newPan) => viewport.setPan(newPan),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                ThemeToggle(onToggleTheme: onToggleTheme),
                const SizedBox(width: 8),
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  elevation: 3,
                  shadowColor: const Color(0x33000000),
                  borderRadius: BorderRadius.circular(12),
                  child: IconButton(
                    tooltip: 'Shortcuts & Help (?)',
                    onPressed: () =>
                        CanvasDialogCoordinator.showShortcutsHelpDialog(
                      context,
                    ),
                    icon: const Icon(
                      Icons.help_outline_rounded,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
