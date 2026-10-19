import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_state.dart';
import 'package:flutcanvas/features/comments/presentation/bloc/comments_cubit.dart';
import 'package:flutcanvas/features/comments/presentation/bloc/comments_state.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_state.dart';
import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';

class MainToolbar extends StatelessWidget {
  final Tool? currentTool;
  final Color? currentColor;
  final bool? canUndo;
  final bool? canRedo;
  final bool? hasElements;
  final bool? hasFrames;
  final int? openCommentsCount;
  final void Function(Tool tool)? onSelectTool;
  final void Function(Color color)? onSelectColor;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onClear;
  final VoidCallback? onOpenExport;
  final VoidCallback? onOpenTemplates;
  final VoidCallback? onStartPresentation;
  final VoidCallback? onToggleProperties;
  final bool? isPropertiesOpen;
  final VoidCallback? onToggleLayers;
  final bool? isLayersOpen;
  final VoidCallback? onToggleIconLibrary;
  final bool? isIconLibraryOpen;
  final VoidCallback? onOpenBroadcast;
  final VoidCallback? onInsertImage;

  const MainToolbar({
    super.key,
    this.currentTool,
    this.currentColor,
    this.canUndo,
    this.canRedo,
    this.hasElements,
    this.hasFrames,
    this.onSelectTool,
    this.onSelectColor,
    this.onUndo,
    this.onRedo,
    this.onClear,
    this.onOpenExport,
    this.onOpenTemplates,
    this.onStartPresentation,
    this.onToggleProperties,
    this.isPropertiesOpen,
    this.onToggleLayers,
    this.isLayersOpen,
    this.onToggleIconLibrary,
    this.isIconLibraryOpen,
    this.onOpenBroadcast,
    this.openCommentsCount,
    this.onInsertImage,
  });

  @override
  Widget build(BuildContext context) {
    final toolCubit = context.watch<ToolCubit?>();
    final canvasBloc = context.watch<CanvasBloc?>();
    final commentsCubit = context.watch<CommentsCubit?>();

    final toolState = toolCubit?.state ?? const ToolState();
    final canvasState = canvasBloc?.state ?? const CanvasState();
    final commentsState = commentsCubit?.state ?? const CommentsState();

    final activeTool = currentTool ?? toolState.currentTool;
    final activeColor = currentColor ?? toolState.strokeColor;
    final activeCanUndo = canUndo ?? canvasState.canUndo;
    final activeCanRedo = canRedo ?? canvasState.canRedo;
    final activeHasElements = hasElements ?? canvasState.elements.isNotEmpty;
    final activeHasFrames = hasFrames ??
        canvasState.elements.any((e) => e.type == ShapeType.frame);
    final activeIsPropertiesOpen =
        isPropertiesOpen ?? toolState.isPropertiesOpen;
    final activeIsLayersOpen = isLayersOpen ?? toolState.isLayersOpen;
    final activeIsIconLibraryOpen =
        isIconLibraryOpen ?? toolState.isIconLibraryOpen;
    final activeCommentsCount = openCommentsCount ??
        commentsState.comments.where((c) => !c.isResolved).length;

    final scheme = Theme.of(context).colorScheme;
    final colors = BoardColors.of(context);
    final isHighlighterActive = activeTool == Tool.highlighter;
    final swatches = isHighlighterActive
        ? BoardColors.highlighterPalette
        : BoardColors.strokePalette.take(5);

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 4,
      shadowColor: const Color(0x22000000),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Navigation & Selection
              _toolButton(context, Tool.select, activeTool, scheme),
              _toolButton(context, Tool.hand, activeTool, scheme),
              _divider(scheme),

              // 2. Geometric Shapes
              _toolButton(context, Tool.rectangle, activeTool, scheme),
              _toolButton(context, Tool.roundedRectangle, activeTool, scheme),
              _toolButton(context, Tool.ellipse, activeTool, scheme),
              _toolButton(context, Tool.diamond, activeTool, scheme),
              _toolButton(context, Tool.triangle, activeTool, scheme),
              _toolButton(context, Tool.star, activeTool, scheme),
              _divider(scheme),

              // 3. Connectors
              _toolButton(context, Tool.line, activeTool, scheme),
              _toolButton(context, Tool.arrow, activeTool, scheme),
              _divider(scheme),

              // 4. Drawing, Text & Cards
              _toolButton(context, Tool.pen, activeTool, scheme),
              _toolButton(context, Tool.highlighter, activeTool, scheme),
              _toolButton(context, Tool.text, activeTool, scheme),
              _toolButton(context, Tool.stickyNote, activeTool, scheme),
              _toolButton(context, Tool.codeBlock, activeTool, scheme),
              _toolButton(context, Tool.table, activeTool, scheme),
              _toolButton(context, Tool.comment, activeTool, scheme),
              _toolButton(context, Tool.image, activeTool, scheme),
              _toolButton(context, Tool.frame, activeTool, scheme),
              _divider(scheme),

              // 5. Utility
              _toolButton(context, Tool.eraser, activeTool, scheme),
              _toolButton(context, Tool.laser, activeTool, scheme),
              _divider(scheme),

              // 6. Quick Palette Swatches
              for (final c in swatches)
                _swatch(context, c, activeColor, colors, scheme,
                    isHighlighter: isHighlighterActive),
              _divider(scheme),

              // 7. Templates & Slides
              Tooltip(
                message: 'Diagram Templates',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: onOpenTemplates,
                  icon: const Icon(Icons.auto_awesome_mosaic_outlined),
                ),
              ),
              Tooltip(
                message: 'Cloud & Architecture Icons (Alt+I)',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  style: activeIsIconLibraryOpen
                      ? IconButton.styleFrom(
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                        )
                      : null,
                  onPressed: onToggleIconLibrary ??
                      () => toolCubit?.toggleIconLibrary(),
                  icon: Icon(
                    Icons.category_outlined,
                    color: activeIsIconLibraryOpen ? scheme.primary : null,
                  ),
                ),
              ),
              Tooltip(
                message: activeHasFrames
                    ? 'Start Presentation (F5)'
                    : 'Add a Frame to Present',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: activeHasFrames ? onStartPresentation : null,
                  icon: Icon(
                    Icons.slideshow_rounded,
                    color: activeHasFrames ? scheme.primary : null,
                  ),
                ),
              ),
              Tooltip(
                message: 'LAN Live Broadcast (Alt+B)',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: onOpenBroadcast,
                  icon: const Icon(Icons.wifi_tethering_rounded),
                ),
              ),
              _divider(scheme),

              // 8. History
              Tooltip(
                message: 'Undo (Ctrl+Z)',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: activeCanUndo
                      ? () {
                          if (onUndo != null) {
                            onUndo!();
                          } else {
                            canvasBloc?.add(const CanvasEvent.undo());
                          }
                        }
                      : null,
                  icon: const Icon(Icons.undo),
                ),
              ),
              Tooltip(
                message: 'Redo (Ctrl+Shift+Z / Ctrl+Y)',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: activeCanRedo
                      ? () {
                          if (onRedo != null) {
                            onRedo!();
                          } else {
                            canvasBloc?.add(const CanvasEvent.redo());
                          }
                        }
                      : null,
                  icon: const Icon(Icons.redo),
                ),
              ),
              _divider(scheme),

              // 9. Layers & Comments Sidebar Toggle
              Tooltip(
                message: activeCommentsCount > 0
                    ? 'Layers & Comments ($activeCommentsCount unread) (Alt+L)'
                    : 'Layers & Comments (Alt+L)',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  style: activeIsLayersOpen
                      ? IconButton.styleFrom(
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                        )
                      : null,
                  onPressed: onToggleLayers ??
                      () => toolCubit?.toggleLayersSidebar(),
                  icon: Badge(
                    isLabelVisible: activeCommentsCount > 0,
                    label: Text(
                      '$activeCommentsCount',
                      style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                    child: Icon(
                      Icons.layers_outlined,
                      color: activeIsLayersOpen ? scheme.primary : null,
                    ),
                  ),
                ),
              ),

              // 10. Properties Panel Toggle
              Tooltip(
                message: 'Styling & Properties',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  style: activeIsPropertiesOpen
                      ? IconButton.styleFrom(
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                        )
                      : null,
                  onPressed: onToggleProperties ??
                      () => toolCubit?.togglePropertiesPanel(),
                  icon: Icon(
                    Icons.palette_outlined,
                    color: activeIsPropertiesOpen ? scheme.primary : null,
                  ),
                ),
              ),

              // 11. Export & Clear
              Tooltip(
                message: 'Export / Save / Load',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: onOpenExport,
                  icon: const Icon(Icons.ios_share_outlined),
                ),
              ),
              Tooltip(
                message: 'Clear Canvas',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: activeHasElements
                      ? () => _confirmClear(context, canvasBloc)
                      : null,
                  icon: const Icon(Icons.layers_clear_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolButton(
      BuildContext context, Tool t, Tool currentTool, ColorScheme scheme) {
    final selected = currentTool == t;
    return Tooltip(
      message: t.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: InkWell(
          onTap: () {
            if (t == Tool.image && onInsertImage != null) {
              onInsertImage!();
              return;
            }
            if (onSelectTool != null) {
              onSelectTool!(t);
            } else {
              context.read<ToolCubit?>()?.setTool(t);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? scheme.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? scheme.primary.withValues(alpha: 0.6)
                    : Colors.transparent,
                width: 1.0,
              ),
            ),
            child: Icon(
              t.icon,
              size: 17,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(ColorScheme scheme) => Container(
        width: 1,
        height: 18,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: scheme.outlineVariant.withValues(alpha: 0.4),
      );

  Widget _swatch(BuildContext context, Color c, Color currentColor,
      BoardColors colors, ColorScheme scheme,
      {bool isHighlighter = false}) {
    final selected = currentColor == c;
    final displayColor =
        isHighlighter ? colors.displayHighlighter(c) : colors.display(c);
    final isWhiteish = displayColor == Colors.white ||
        displayColor.computeLuminance() > 0.85;

    return GestureDetector(
      onTap: () {
        if (onSelectColor != null) {
          onSelectColor!(c);
        } else {
          context.read<ToolCubit?>()?.setStrokeColor(c);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          decoration: BoxDecoration(
            color: displayColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? colors.selection
                  : (isWhiteish
                      ? Colors.grey.shade400
                      : scheme.surfaceContainerHighest),
              width: selected ? 2.5 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x18000000), blurRadius: 1),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, CanvasBloc? canvasBloc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear whiteboard?'),
        content: const Text(
          'This will remove all shapes and drawings from the board. You can still Undo this action.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (onClear != null) {
                onClear!();
              } else {
                final allIds =
                    canvasBloc?.state.elements.map((e) => e.id).toSet() ?? {};
                canvasBloc?.add(CanvasEvent.deleteElements(allIds));
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
