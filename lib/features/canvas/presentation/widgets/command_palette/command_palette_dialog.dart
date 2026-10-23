import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/broadcast/presentation/widgets/broadcast_dialog.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/tech_icons.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/export/data/services/export_service.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';
import 'command_palette_item.dart';

/// Spotlight-style interactive Command Palette dialog (`Cmd + K` / `Ctrl + K`).
class CommandPaletteDialog extends StatefulWidget {
  final CanvasViewportController viewport;
  final Size viewSize;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onOpenExport;
  final VoidCallback? onOpenTemplates;
  final VoidCallback? onStartPresentation;
  final VoidCallback? onOpenHelp;
  final VoidCallback? onInsertImage;
  final VoidCallback? onOpenMermaidImport;
  final VoidCallback? onOpenAiPrompt;

  const CommandPaletteDialog({
    super.key,
    required this.viewport,
    required this.viewSize,
    this.onToggleTheme,
    this.onOpenExport,
    this.onOpenTemplates,
    this.onStartPresentation,
    this.onOpenHelp,
    this.onInsertImage,
    this.onOpenMermaidImport,
    this.onOpenAiPrompt,
  });

  @override
  State<CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<CommandPaletteDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String _query = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
        _selectedIndex = 0;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<CommandPaletteItem> _buildAllCommands(BuildContext context) {
    final canvasBloc = context.read<CanvasBloc>();
    final toolCubit = context.read<ToolCubit>();
    final presentationCubit = context.read<PresentationCubit>();
    final canvasState = canvasBloc.state;
    final selectedCount = canvasState.selectedIds.length;
    final hasSelection = selectedCount > 0;
    final hasElements = canvasState.elements.isNotEmpty;

    final items = <CommandPaletteItem>[];

    // ── 1. Tools ──────────────────────────────────────────────────────────
    void addTool(String id, String title, Tool tool, IconData icon, String? shortcut, [List<String> kw = const []]) {
      items.add(CommandPaletteItem(
        id: id,
        title: title,
        category: CommandCategory.tools,
        icon: icon,
        shortcut: shortcut,
        keywords: ['tool', ...kw],
        onExecute: () {
          Navigator.of(context).pop();
          toolCubit.setTool(tool);
        },
      ));
    }

    addTool('tool_select', 'Select & Transform', Tool.select, Icons.near_me_outlined, 'V', ['pointer', 'cursor', 'drag']);
    addTool('tool_hand', 'Hand / Pan Canvas', Tool.hand, Icons.pan_tool_outlined, 'H', ['move', 'pan']);
    addTool('tool_rect', 'Rectangle', Tool.rectangle, Icons.crop_square_rounded, 'R', ['box', 'square']);
    addTool('tool_rounded', 'Rounded Box', Tool.roundedRectangle, Icons.crop_portrait_rounded, 'Shift+R', ['card', 'container']);
    addTool('tool_ellipse', 'Ellipse / Circle', Tool.ellipse, Icons.circle_outlined, 'O', ['round', 'oval']);
    addTool('tool_diamond', 'Diamond / Decision', Tool.diamond, Icons.change_history_outlined, 'D', ['flowchart', 'decision', 'rhombus']);
    addTool('tool_triangle', 'Triangle', Tool.triangle, Icons.play_arrow_outlined, 'Shift+T', ['delta', 'pyramid']);
    addTool('tool_star', 'Star', Tool.star, Icons.star_border_rounded, null, ['badge', 'favorite']);
    addTool('tool_arrow', 'Arrow Connector', Tool.arrow, Icons.arrow_forward_rounded, 'A', ['connector', 'edge', 'flow']);
    addTool('tool_line', 'Straight Line', Tool.line, Icons.horizontal_rule_rounded, 'L', ['connector', 'divider']);
    addTool('tool_pen', 'Pen / Sketch', Tool.pen, Icons.edit_outlined, 'P', ['draw', 'freehand', 'pencil']);
    addTool('tool_highlighter', 'Highlighter', Tool.highlighter, Icons.border_color_outlined, 'M', ['mark', 'transparent']);
    addTool('tool_text', 'Text Box', Tool.text, Icons.text_fields_rounded, 'T', ['label', 'type', 'typography']);
    addTool('tool_sticky', 'Sticky Note', Tool.stickyNote, Icons.note_outlined, 'N', ['post-it', 'memo', 'card']);
    addTool('tool_code', 'Code Snippet Block', Tool.codeBlock, Icons.code_rounded, null, ['programming', 'syntax', 'script']);
    addTool('tool_table', 'Data Table / Grid', Tool.table, Icons.table_chart_outlined, null, ['spreadsheet', 'matrix', 'rows', 'columns']);
    addTool('tool_frame', 'Slide Frame', Tool.frame, Icons.filter_frames_outlined, 'F', ['presentation', 'slide', 'subgraph', 'boundary']);
    addTool('tool_eraser', 'Eraser', Tool.eraser, Icons.auto_fix_normal_outlined, 'E', ['delete', 'remove', 'scratch']);
    addTool('tool_laser', 'Laser Pointer', Tool.laser, Icons.adjust_rounded, 'K', ['presentation', 'demo', 'trail']);

    // ── 1.5 Architecture Icons ────────────────────────────────────────────
    for (final def in TechIconRegistry.icons) {
      items.add(CommandPaletteItem(
        id: 'insert_tech_icon_${def.id}',
        title: 'Insert ${def.name} Icon',
        subtitle: '${def.category.label} • Architecture Component',
        category: CommandCategory.tools,
        icon: def.icon,
        iconColor: def.brandColor,
        keywords: ['insert', 'icon', 'cloud', 'architecture', ...def.keywords, def.category.name],
        onExecute: () {
          Navigator.of(context).pop();
          final center = widget.viewSize == Size.zero
              ? const Offset(300, 300)
              : widget.viewport.toWorld(
                  Offset(widget.viewSize.width / 2, widget.viewSize.height / 2),
                );
          const width = 120.0;
          const height = 90.0;
          final colors = BoardColors.of(context);
          final element = BoardElement(
            id: 'icon_${DateTime.now().millisecondsSinceEpoch}',
            type: ShapeType.icon,
            start: center - const Offset(width / 2, height / 2),
            end: center + const Offset(width / 2, height / 2),
            iconName: def.id,
            iconCategory: def.category.name,
            text: def.defaultLabel,
            color: def.brandColor,
            fillColor: colors.isDark ? const Color(0xFF1E222D) : Colors.white,
            strokeWidth: 1.5,
          );
          canvasBloc.add(CanvasEvent.addElement(element));
          canvasBloc.add(CanvasEvent.selectElements({element.id}));
        },
      ));
    }

    // ── 2. Actions ────────────────────────────────────────────────────────
    items.add(CommandPaletteItem(
      id: 'action_undo',
      title: 'Undo',
      category: CommandCategory.actions,
      icon: Icons.undo_rounded,
      shortcut: 'Cmd+Z',
      keywords: ['revert', 'back'],
      onExecute: () {
        Navigator.of(context).pop();
        canvasBloc.add(const CanvasEvent.undo());
      },
    ));

    items.add(CommandPaletteItem(
      id: 'action_redo',
      title: 'Redo',
      category: CommandCategory.actions,
      icon: Icons.redo_rounded,
      shortcut: 'Cmd+Shift+Z',
      keywords: ['repeat', 'forward'],
      onExecute: () {
        Navigator.of(context).pop();
        canvasBloc.add(const CanvasEvent.redo());
      },
    ));

    items.add(CommandPaletteItem(
      id: 'ai_text_to_diagram',
      title: 'AI Text-to-Diagram (Prompt to Canvas)...',
      subtitle: 'Generate architecture or mindmap from prompt',
      category: CommandCategory.actions,
      icon: Icons.auto_awesome,
      shortcut: 'Cmd+Shift+A',
      keywords: [
        'ai',
        'gemini',
        'prompt',
        'generate',
        'architecture',
        'mindmap',
        'flowchart',
        'diagram',
        'text'
      ],
      onExecute: () {
        Navigator.of(context).pop();
        widget.onOpenAiPrompt?.call();
      },
    ));

    if (hasSelection) {
      items.add(CommandPaletteItem(
        id: 'action_group',
        title: 'Group Selected ($selectedCount)',
        category: CommandCategory.actions,
        icon: Icons.group_work_outlined,
        shortcut: 'Cmd+G',
        keywords: ['combine', 'bundle'],
        onExecute: () {
          Navigator.of(context).pop();
          canvasBloc.add(const CanvasEvent.groupSelected());
        },
      ));

      items.add(CommandPaletteItem(
        id: 'action_ungroup',
        title: 'Ungroup Selected',
        category: CommandCategory.actions,
        icon: Icons.grid_view_rounded,
        shortcut: 'Cmd+Shift+G',
        keywords: ['break', 'separate'],
        onExecute: () {
          Navigator.of(context).pop();
          canvasBloc.add(const CanvasEvent.ungroupSelected());
        },
      ));

      items.add(CommandPaletteItem(
        id: 'action_lock',
        title: 'Toggle Lock on Selected',
        category: CommandCategory.actions,
        icon: Icons.lock_outline_rounded,
        shortcut: 'Cmd+L',
        keywords: ['freeze', 'protect', 'unlock'],
        onExecute: () {
          Navigator.of(context).pop();
          canvasBloc.add(const CanvasEvent.toggleLockSelected());
        },
      ));

      items.add(CommandPaletteItem(
        id: 'action_front',
        title: 'Bring to Front',
        category: CommandCategory.actions,
        icon: Icons.flip_to_front_rounded,
        shortcut: ']',
        keywords: ['layer', 'top', 'z-index'],
        onExecute: () {
          Navigator.of(context).pop();
          canvasBloc.add(const CanvasEvent.bringSelectedToFront());
        },
      ));

      items.add(CommandPaletteItem(
        id: 'action_back',
        title: 'Send to Back',
        category: CommandCategory.actions,
        icon: Icons.flip_to_back_rounded,
        shortcut: '[',
        keywords: ['layer', 'bottom', 'z-index'],
        onExecute: () {
          Navigator.of(context).pop();
          canvasBloc.add(const CanvasEvent.sendSelectedToBack());
        },
      ));

      items.add(CommandPaletteItem(
        id: 'action_delete_selected',
        title: 'Delete Selected ($selectedCount item${selectedCount > 1 ? 's' : ''})',
        category: CommandCategory.actions,
        icon: Icons.delete_outline_rounded,
        shortcut: 'Del / Backspace',
        keywords: ['remove', 'trash'],
        onExecute: () {
          Navigator.of(context).pop();
          canvasBloc.add(const CanvasEvent.deleteSelected());
        },
      ));

      items.add(CommandPaletteItem(
        id: 'action_clear_selection',
        title: 'Clear Selection',
        category: CommandCategory.actions,
        icon: Icons.deselect_rounded,
        shortcut: 'Esc',
        keywords: ['unselect', 'deselect'],
        onExecute: () {
          Navigator.of(context).pop();
          canvasBloc.add(const CanvasEvent.clearSelection());
        },
      ));
    }

    items.add(CommandPaletteItem(
      id: 'action_select_all',
      title: 'Select All Elements',
      category: CommandCategory.actions,
      icon: Icons.select_all_rounded,
      shortcut: 'Cmd+A',
      keywords: ['everything', 'all'],
      onExecute: () {
        Navigator.of(context).pop();
        final allIds = canvasState.elements.map((e) => e.id).toSet();
        canvasBloc.add(CanvasEvent.selectElements(allIds));
      },
    ));

    if (hasElements) {
      items.add(CommandPaletteItem(
        id: 'action_clear_canvas',
        title: 'Clear Entire Whiteboard',
        category: CommandCategory.actions,
        icon: Icons.delete_sweep_outlined,
        keywords: ['reset', 'erase all', 'empty'],
        onExecute: () {
          Navigator.of(context).pop();
          final allIds = canvasState.elements.map((e) => e.id).toSet();
          canvasBloc.add(CanvasEvent.deleteElements(allIds));
        },
      ));
    }

    // ── 3. View & Navigation ──────────────────────────────────────────────
    if (hasElements) {
      items.add(CommandPaletteItem(
        id: 'view_zoom_fit',
        title: 'Zoom to Fit Elements',
        category: CommandCategory.view,
        icon: Icons.aspect_ratio_rounded,
        shortcut: 'Shift+1',
        keywords: ['fit', 'center', 'overview', 'all'],
        onExecute: () {
          Navigator.of(context).pop();
          widget.viewport.zoomToFit(canvasState.elements, widget.viewSize);
        },
      ));
    }

    items.add(CommandPaletteItem(
      id: 'view_reset_zoom',
      title: 'Reset Zoom to 100%',
      category: CommandCategory.view,
      icon: Icons.restart_alt_rounded,
      shortcut: 'Cmd+0',
      keywords: ['100%', 'actual size', 'normal'],
      onExecute: () {
        Navigator.of(context).pop();
        widget.viewport.setZoom(1.0);
      },
    ));

    items.add(CommandPaletteItem(
      id: 'view_zoom_in',
      title: 'Zoom In (+25%)',
      category: CommandCategory.view,
      icon: Icons.zoom_in_rounded,
      shortcut: '+',
      keywords: ['magnify', 'closer', 'enlarge'],
      onExecute: () {
        Navigator.of(context).pop();
        widget.viewport.setZoom(widget.viewport.zoom * 1.25);
      },
    ));

    items.add(CommandPaletteItem(
      id: 'view_zoom_out',
      title: 'Zoom Out (-20%)',
      category: CommandCategory.view,
      icon: Icons.zoom_out_rounded,
      shortcut: '-',
      keywords: ['shrink', 'smaller', 'out'],
      onExecute: () {
        Navigator.of(context).pop();
        widget.viewport.setZoom(widget.viewport.zoom / 1.25);
      },
    ));

    items.add(CommandPaletteItem(
      id: 'view_toggle_grid',
      title: 'Toggle Grid Snapping',
      category: CommandCategory.view,
      icon: Icons.grid_on_rounded,
      shortcut: 'G',
      keywords: ['snap', 'coordinates', 'alignment'],
      onExecute: () {
        Navigator.of(context).pop();
        toolCubit.toggleGridSnap();
      },
    ));

    items.add(CommandPaletteItem(
      id: 'view_toggle_theme',
      title: 'Toggle Dark / Light Theme',
      category: CommandCategory.view,
      icon: Icons.brightness_medium_rounded,
      shortcut: 'Alt+Shift+D',
      keywords: ['dark mode', 'light mode', 'night', 'day', 'appearance'],
      onExecute: () {
        Navigator.of(context).pop();
        widget.onToggleTheme?.call();
      },
    ));

    items.add(CommandPaletteItem(
      id: 'view_toggle_layers',
      title: 'Toggle Layers & Comments Sidebar',
      category: CommandCategory.view,
      icon: Icons.layers_outlined,
      shortcut: 'Alt+L',
      keywords: ['objects', 'tree', 'hierarchy', 'comments'],
      onExecute: () {
        Navigator.of(context).pop();
        toolCubit.toggleLayersSidebar();
      },
    ));

    items.add(CommandPaletteItem(
      id: 'view_toggle_properties',
      title: 'Toggle Styling & Properties Panel',
      category: CommandCategory.view,
      icon: Icons.palette_outlined,
      keywords: ['colors', 'stroke', 'fill', 'opacity', 'typography'],
      onExecute: () {
        Navigator.of(context).pop();
        toolCubit.togglePropertiesPanel();
      },
    ));

    items.add(CommandPaletteItem(
      id: 'view_toggle_icon_library',
      title: 'Toggle Cloud & Architecture Icons',
      category: CommandCategory.view,
      icon: Icons.category_outlined,
      shortcut: 'Alt+I',
      keywords: ['cloud', 'aws', 'gcp', 'azure', 'docker', 'k8s', 'tech', 'icons', 'library'],
      onExecute: () {
        Navigator.of(context).pop();
        toolCubit.toggleIconLibrary();
      },
    ));

    // ── 4. Import & Export ────────────────────────────────────────────────
    items.add(CommandPaletteItem(
      id: 'export_dialog',
      title: 'Export & Share...',
      category: CommandCategory.export,
      icon: Icons.ios_share_rounded,
      shortcut: 'Cmd+E',
      keywords: ['save', 'png', 'svg', 'pdf', 'json', 'mermaid', 'share'],
      onExecute: () {
        Navigator.of(context).pop();
        widget.onOpenExport?.call();
      },
    ));

    items.add(CommandPaletteItem(
      id: 'export_mermaid_copy',
      title: 'Copy Diagram as Mermaid Flowchart',
      category: CommandCategory.export,
      icon: Icons.account_tree_outlined,
      keywords: ['mermaid', 'markdown', 'graph', 'flowchart', 'code', 'copy'],
      onExecute: () {
        Navigator.of(context).pop();
        final selectedEls = hasSelection
            ? canvasState.elements.where((e) => canvasState.selectedIds.contains(e.id)).toList()
            : canvasState.elements;
        final mermaid = ExportService.exportToMermaid(elements: selectedEls);
        Clipboard.setData(ClipboardData(text: '```mermaid\n$mermaid```'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mermaid markdown copied to clipboard!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    ));

    items.add(CommandPaletteItem(
      id: 'templates_open',
      title: 'Browse Diagram Templates...',
      category: CommandCategory.export,
      icon: Icons.dashboard_customize_outlined,
      shortcut: 'Cmd+O',
      keywords: ['flowchart', 'mindmap', 'kanban', 'architecture', 'starter'],
      onExecute: () {
        Navigator.of(context).pop();
        widget.onOpenTemplates?.call();
      },
    ));

    items.add(CommandPaletteItem(
      id: 'insert_image',
      title: 'Insert Image...',
      category: CommandCategory.export,
      icon: Icons.image_outlined,
      shortcut: 'I',
      keywords: ['picture', 'photo', 'upload', 'asset'],
      onExecute: () {
        Navigator.of(context).pop();
        widget.onInsertImage?.call();
      },
    ));

    items.add(CommandPaletteItem(
      id: 'help_shortcuts',
      title: 'Keyboard Shortcuts Reference',
      category: CommandCategory.export,
      icon: Icons.keyboard_outlined,
      shortcut: '?',
      keywords: ['shortcuts', 'hotkeys', 'cheat sheet', 'help'],
      onExecute: () {
        Navigator.of(context).pop();
        widget.onOpenHelp?.call();
      },
    ));

    // ── 5. Presentation ───────────────────────────────────────────────────
    items.add(CommandPaletteItem(
      id: 'pres_start',
      title: 'Start Presentation Mode',
      category: CommandCategory.presentation,
      icon: Icons.slideshow_rounded,
      shortcut: 'F5',
      keywords: ['present', 'slides', 'slideshow', 'fullscreen', 'demo'],
      onExecute: () {
        Navigator.of(context).pop();
        if (widget.onStartPresentation != null) {
          widget.onStartPresentation!();
        } else {
          presentationCubit.startPresentation(canvasState.elements);
        }
      },
    ));

    items.add(CommandPaletteItem(
      id: 'pres_lan_broadcast',
      title: 'LAN Live Broadcast & Viewer Sync...',
      category: CommandCategory.presentation,
      icon: Icons.wifi_tethering_rounded,
      shortcut: 'Alt+B',
      keywords: ['broadcast', 'lan', 'wifi', 'share', 'stream', 'live', 'sync', 'qr'],
      onExecute: () {
        Navigator.of(context).pop();
        BroadcastDialog.show(context, viewport: widget.viewport);
      },
    ));

    // ── 6. Canvas Elements (On-Canvas Text Search) ─────────────────────────
    for (final el in canvasState.elements) {
      if (!el.isVisible) continue;

      final text = el.text.trim();
      final label = el.label?.trim() ?? '';
      final title = el.frameTitle?.trim() ?? '';
      final customName = el.customName?.trim() ?? '';
      final iconName = el.iconName != null
          ? (TechIconRegistry.findById(el.iconName!)?.name ?? el.iconName!)
          : '';

      final displayText = text.isNotEmpty
          ? text
          : (title.isNotEmpty
              ? title
              : (label.isNotEmpty
                  ? label
                  : (iconName.isNotEmpty
                      ? iconName
                      : (customName.isNotEmpty ? customName : ''))));

      if (displayText.isEmpty) continue;

      final typeName = switch (el.type) {
        ShapeType.stickyNote => 'Sticky Note',
        ShapeType.frame => 'Slide Frame',
        ShapeType.codeBlock => 'Code Snippet',
        ShapeType.table => 'Data Table',
        ShapeType.diamond => 'Decision Diamond',
        ShapeType.arrow => 'Connector Arrow',
        ShapeType.icon => 'Architecture Icon',
        _ => _capitalize(el.type.name),
      };

      final icon = switch (el.type) {
        ShapeType.stickyNote => Icons.note_outlined,
        ShapeType.frame => Icons.filter_frames_outlined,
        ShapeType.codeBlock => Icons.code_rounded,
        ShapeType.table => Icons.table_chart_outlined,
        ShapeType.diamond => Icons.change_history_outlined,
        ShapeType.arrow => Icons.arrow_forward_rounded,
        ShapeType.ellipse => Icons.circle_outlined,
        ShapeType.icon => Icons.category_outlined,
        _ => Icons.crop_square_rounded,
      };

      items.add(CommandPaletteItem(
        id: 'element_${el.id}',
        title: displayText.length > 55 ? '${displayText.substring(0, 52)}...' : displayText,
        subtitle: '$typeName • at (${el.bounds.left.round()}, ${el.bounds.top.round()})',
        category: CommandCategory.elements,
        icon: icon,
        keywords: [
          typeName,
          displayText,
          el.type.name,
          if (el.iconCategory != null) el.iconCategory!,
        ],
        onExecute: () {
          Navigator.of(context).pop();
          // 1. Select the matching element
          canvasBloc.add(CanvasEvent.selectElements({el.id}));
          // 2. Pan & center camera on element
          widget.viewport.panToCenter(el.bounds.center, widget.viewSize);
          // 3. Feedback toast
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Focused on: $displayText'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 1500),
            ),
          );
        },
      ));
    }

    return items;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  void _handleKey(KeyEvent event, List<CommandPaletteItem> filtered) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (filtered.isNotEmpty) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % filtered.length;
        });
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (filtered.isNotEmpty) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1 + filtered.length) % filtered.length;
        });
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (filtered.isNotEmpty && _selectedIndex < filtered.length) {
        filtered[_selectedIndex].onExecute();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mq = MediaQuery.of(context).size;

    final allCommands = _buildAllCommands(context);
    final filteredCommands = allCommands.where((cmd) => cmd.matches(_query)).toList();

    // Clamp selectedIndex in case filter shrunk
    if (_selectedIndex >= filteredCommands.length) {
      _selectedIndex = math.max(0, filteredCommands.length - 1);
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      elevation: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: math.min(620.0, mq.width - 32),
              constraints: BoxConstraints(
                maxHeight: math.min(520.0, mq.height - 96),
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161922).withValues(alpha: 0.88)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.22),
                    blurRadius: 36,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) => _handleKey(event, filteredCommands),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Search Bar Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: scheme.outlineVariant.withValues(alpha: 0.2),
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 22,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              autofocus: true,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search actions, tools, templates, or canvas elements...',
                                hintStyle: TextStyle(
                                  fontSize: 13.5,
                                  color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              iconSize: 18,
                              icon: const Icon(Icons.clear_rounded),
                              tooltip: 'Clear query',
                              onPressed: () => _searchController.clear(),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ESC',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Filtered Command List
                    Flexible(
                      child: filteredCommands.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(40),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 38,
                                    color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No results found for "$_query"',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Try searching for tools like "Rectangle", actions like "Export", or text on your board.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              itemCount: filteredCommands.length,
                              itemBuilder: (context, index) {
                                final item = filteredCommands[index];
                                final isSelected = index == _selectedIndex;

                                // Show category header when category changes
                                final showHeader = index == 0 ||
                                    filteredCommands[index - 1].category != item.category;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showHeader)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                                        child: Row(
                                          children: [
                                            Icon(
                                              item.category.icon,
                                              size: 13,
                                              color: scheme.primary.withValues(alpha: 0.8),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              item.category.label.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.6,
                                                color: scheme.primary.withValues(alpha: 0.85),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    InkWell(
                                      onTap: item.onExecute,
                                      hoverColor: scheme.primary.withValues(alpha: 0.08),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? scheme.primary.withValues(alpha: isDark ? 0.22 : 0.12)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                          border: isSelected
                                              ? Border.all(
                                                  color: scheme.primary.withValues(alpha: 0.4),
                                                  width: 1,
                                                )
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? scheme.primary.withValues(alpha: 0.2)
                                                    : (isDark
                                                        ? Colors.white.withValues(alpha: 0.05)
                                                        : Colors.black.withValues(alpha: 0.04)),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                item.icon,
                                                size: 17,
                                                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.title,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                      color: isSelected ? scheme.primary : scheme.onSurface,
                                                    ),
                                                  ),
                                                  if (item.subtitle != null) ...[
                                                    const SizedBox(height: 1),
                                                    Text(
                                                      item.subtitle!,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            if (item.shortcut != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? Colors.white.withValues(alpha: 0.06)
                                                      : Colors.black.withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: scheme.outlineVariant.withValues(alpha: 0.2),
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Text(
                                                  item.shortcut!,
                                                  style: TextStyle(
                                                    fontSize: 10.5,
                                                    fontFamily: 'monospace',
                                                    fontWeight: FontWeight.w600,
                                                    color: scheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),

                    // 3. Footer Navigation Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.grey.withValues(alpha: 0.08),
                        border: Border(
                          top: BorderSide(
                            color: scheme.outlineVariant.withValues(alpha: 0.2),
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _footerHint(Icons.arrow_upward_rounded, 'Navigate', scheme),
                          const SizedBox(width: 4),
                          _footerHint(Icons.arrow_downward_rounded, '', scheme),
                          const SizedBox(width: 14),
                          _footerHint(Icons.keyboard_return_rounded, 'Select', scheme),
                          const SizedBox(width: 14),
                          _footerHint(null, 'ESC to Dismiss', scheme),
                          const Spacer(),
                          Text(
                            '${filteredCommands.length} item${filteredCommands.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _footerHint(IconData? icon, String text, ColorScheme scheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: scheme.onSurfaceVariant.withValues(alpha: 0.8)),
          const SizedBox(width: 3),
        ],
        if (text.isNotEmpty)
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
      ],
    );
  }
}
