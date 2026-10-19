import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/broadcast/presentation/widgets/broadcast_dialog.dart';
import 'package:flutcanvas/features/broadcast/presentation/widgets/broadcast_hud_pill.dart';
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
  final VoidCallback? onOpenCommandPalette;

  const CanvasTopBar({
    super.key,
    required this.viewport,
    required this.getViewSize,
    this.onOpenCommandPalette,
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
            if (onOpenCommandPalette != null) ...[
              const SizedBox(width: 8),
              _CommandPaletteButton(onPressed: onOpenCommandPalette!),
            ],
            const SizedBox(width: 8),
            BroadcastHudPill(
              onTap: () => BroadcastDialog.show(context, viewport: viewport),
            ),
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
                  onToggleIconLibrary: () =>
                      context.read<ToolCubit>().toggleIconLibrary(),
                  onOpenBroadcast: () =>
                      BroadcastDialog.show(context, viewport: viewport),
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

class _CommandPaletteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CommandPaletteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: 'Command Palette (Cmd+K / Ctrl+K)',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E222D).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: scheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '⌘K',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

