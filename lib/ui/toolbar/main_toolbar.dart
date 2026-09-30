import 'package:flutter/material.dart';

import '../../models/board_colors.dart';
import '../../models/tool.dart';

class MainToolbar extends StatelessWidget {
  const MainToolbar({
    super.key,
    required this.currentTool,
    required this.currentColor,
    required this.canUndo,
    required this.canRedo,
    required this.hasElements,
    required this.hasFrames,
    required this.onSelectTool,
    required this.onSelectColor,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    required this.onOpenExport,
    required this.onOpenTemplates,
    required this.onStartPresentation,
    required this.onToggleProperties,
    required this.isPropertiesOpen,
    required this.onToggleLayers,
    required this.isLayersOpen,
  });

  final Tool currentTool;
  final Color currentColor;
  final bool canUndo;
  final bool canRedo;
  final bool hasElements;
  final bool hasFrames;
  final void Function(Tool tool) onSelectTool;
  final void Function(Color color) onSelectColor;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final VoidCallback onOpenExport;
  final VoidCallback onOpenTemplates;
  final VoidCallback onStartPresentation;
  final VoidCallback onToggleProperties;
  final bool isPropertiesOpen;
  final VoidCallback onToggleLayers;
  final bool isLayersOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = BoardColors.of(context);

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
              _toolButton(Tool.select, scheme),
              _toolButton(Tool.hand, scheme),
              _divider(scheme),

              // 2. Geometric Shapes
              _toolButton(Tool.rectangle, scheme),
              _toolButton(Tool.roundedRectangle, scheme),
              _toolButton(Tool.ellipse, scheme),
              _toolButton(Tool.diamond, scheme),
              _toolButton(Tool.triangle, scheme),
              _toolButton(Tool.star, scheme),
              _divider(scheme),

              // 3. Connectors
              _toolButton(Tool.line, scheme),
              _toolButton(Tool.arrow, scheme),
              _divider(scheme),

              // 4. Drawing, Text & Cards
              _toolButton(Tool.pen, scheme),
              _toolButton(Tool.highlighter, scheme),
              _toolButton(Tool.text, scheme),
              _toolButton(Tool.stickyNote, scheme),
              _toolButton(Tool.codeBlock, scheme),
              _toolButton(Tool.image, scheme),
              _toolButton(Tool.frame, scheme),
              _divider(scheme),

              // 5. Utility
              _toolButton(Tool.eraser, scheme),
              _toolButton(Tool.laser, scheme),
              _divider(scheme),

              // 6. Quick Palette Swatches
              for (final c in BoardColors.strokePalette.take(5))
                _swatch(c, colors, scheme),
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
                message: hasFrames ? 'Start Presentation (F5)' : 'Add a Frame to Present',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: hasFrames ? onStartPresentation : null,
                  icon: Icon(
                    Icons.slideshow_rounded,
                    color: hasFrames ? scheme.primary : null,
                  ),
                ),
              ),
              _divider(scheme),

              // 8. History
              Tooltip(
                message: 'Undo (Ctrl+Z)',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: canUndo ? onUndo : null,
                  icon: const Icon(Icons.undo),
                ),
              ),
              Tooltip(
                message: 'Redo (Ctrl+Shift+Z / Ctrl+Y)',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: canRedo ? onRedo : null,
                  icon: const Icon(Icons.redo),
                ),
              ),
              _divider(scheme),

              // 9. Layers Sidebar Toggle
              Tooltip(
                message: 'Layers & Objects (Alt+L)',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  style: isLayersOpen
                      ? IconButton.styleFrom(
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                        )
                      : null,
                  onPressed: onToggleLayers,
                  icon: Icon(
                    Icons.layers_outlined,
                    color: isLayersOpen ? scheme.primary : null,
                  ),
                ),
              ),

              // 10. Properties Panel Toggle
              Tooltip(
                message: 'Styling & Properties',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  style: isPropertiesOpen
                      ? IconButton.styleFrom(
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                        )
                      : null,
                  onPressed: onToggleProperties,
                  icon: Icon(
                    Icons.palette_outlined,
                    color: isPropertiesOpen ? scheme.primary : null,
                  ),
                ),
              ),

              // 10. Export & Clear
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
                  onPressed: hasElements ? () => _confirmClear(context) : null,
                  icon: const Icon(Icons.layers_clear_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolButton(Tool t, ColorScheme scheme) {
    final selected = currentTool == t;
    return Tooltip(
      message: t.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: InkWell(
          onTap: () => onSelectTool(t),
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

  Widget _swatch(Color c, BoardColors colors, ColorScheme scheme) {
    final selected = currentColor == c;
    return GestureDetector(
      onTap: () => onSelectColor(c),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          decoration: BoxDecoration(
            color: colors.display(c),
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? colors.selection : scheme.surfaceContainerHighest,
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

  void _confirmClear(BuildContext context) {
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
              onClear();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
