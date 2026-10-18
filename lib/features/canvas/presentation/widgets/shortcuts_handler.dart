import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import '../../../toolbar/presentation/bloc/tool_cubit.dart';
import '../bloc/canvas_bloc.dart';
import '../bloc/canvas_event.dart';

class CanvasShortcutsHandler extends StatelessWidget {
  final Widget child;
  final FocusNode? focusNode;
  final bool isEditingText;
  final VoidCallback? onCopy;
  final VoidCallback? onPaste;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final VoidCallback? onStartPresentation;
  final VoidCallback? onOpenTemplates;
  final VoidCallback? onOpenExport;
  final VoidCallback? onOpenHelp;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onEscape;
  final VoidCallback? onOpenCommandPalette;
  final VoidCallback? onNextSlide;
  final VoidCallback? onPreviousSlide;
  final bool isPresentationMode;

  const CanvasShortcutsHandler({
    super.key,
    required this.child,
    this.focusNode,
    this.isEditingText = false,
    this.onCopy,
    this.onPaste,
    this.onDuplicate,
    this.onDelete,
    this.onStartPresentation,
    this.onOpenTemplates,
    this.onOpenExport,
    this.onOpenHelp,
    this.onToggleTheme,
    this.onEscape,
    this.onOpenCommandPalette,
    this.onNextSlide,
    this.onPreviousSlide,
    this.isPresentationMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        // 1. If currently editing text (inline text editor, sticky note, code block, table cell, etc.)
        // let the text input handle all typing and navigation instead of triggering canvas tool shortcuts.
        if (isEditingText) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            onEscape?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        }

        // 2. If an inner widget (e.g. TextField in LayersSidebar, search bar, comment card popover, or dialog)
        // has focus, ignore canvas shortcuts so all characters type normally into the input.
        if (!node.hasPrimaryFocus) {
          return KeyEventResult.ignored;
        }

        final primaryFocus = FocusManager.instance.primaryFocus;
        if (primaryFocus != null && primaryFocus != node) {
          return KeyEventResult.ignored;
        }

        final isControlOrCmd = HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed;
        final isShift = HardwareKeyboard.instance.isShiftPressed;
        final isAlt = HardwareKeyboard.instance.isAltPressed;

        // Presentation Mode Navigation
        if (isPresentationMode) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            onEscape?.call();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
              event.logicalKey == LogicalKeyboardKey.space) {
            onNextSlide?.call();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            onPreviousSlide?.call();
            return KeyEventResult.handled;
          }
        }

        // F5: Start Presentation
        if (event.logicalKey == LogicalKeyboardKey.f5) {
          onStartPresentation?.call();
          return KeyEventResult.handled;
        }

        // Escape: Exit presentation or clear selection
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          if (onEscape != null) {
            onEscape!();
          } else {
            context.read<CanvasBloc>().add(const CanvasEvent.clearSelection());
          }
          return KeyEventResult.handled;
        }

        // Command Palette: Cmd+K / Ctrl+K
        if (isControlOrCmd && event.logicalKey == LogicalKeyboardKey.keyK) {
          onOpenCommandPalette?.call();
          return KeyEventResult.handled;
        }

        // Undo: Cmd+Z
        if (isControlOrCmd &&
            !isShift &&
            event.logicalKey == LogicalKeyboardKey.keyZ) {
          context.read<CanvasBloc>().add(const CanvasEvent.undo());
          return KeyEventResult.handled;
        }

        // Redo: Cmd+Shift+Z or Cmd+Y
        if ((isControlOrCmd &&
                isShift &&
                event.logicalKey == LogicalKeyboardKey.keyZ) ||
            (isControlOrCmd && event.logicalKey == LogicalKeyboardKey.keyY)) {
          context.read<CanvasBloc>().add(const CanvasEvent.redo());
          return KeyEventResult.handled;
        }

        // Copy: Cmd+C
        if (isControlOrCmd && event.logicalKey == LogicalKeyboardKey.keyC) {
          onCopy?.call();
          return KeyEventResult.handled;
        }

        // Paste: Cmd+V
        if (isControlOrCmd && event.logicalKey == LogicalKeyboardKey.keyV) {
          onPaste?.call();
          return KeyEventResult.handled;
        }

        // Duplicate: Cmd+D
        if (isControlOrCmd && event.logicalKey == LogicalKeyboardKey.keyD) {
          onDuplicate?.call();
          return KeyEventResult.handled;
        }

        // Select All: Cmd+A
        if (isControlOrCmd && event.logicalKey == LogicalKeyboardKey.keyA) {
          final allIds = context
              .read<CanvasBloc>()
              .state
              .elements
              .map((e) => e.id)
              .toSet();
          context
              .read<CanvasBloc>()
              .add(CanvasEvent.selectElements(allIds));
          return KeyEventResult.handled;
        }

        // Group: Cmd+G
        if (isControlOrCmd &&
            !isShift &&
            event.logicalKey == LogicalKeyboardKey.keyG) {
          context.read<CanvasBloc>().add(const CanvasEvent.groupSelected());
          return KeyEventResult.handled;
        }

        // Ungroup: Cmd+Shift+G
        if (isControlOrCmd &&
            isShift &&
            event.logicalKey == LogicalKeyboardKey.keyG) {
          context.read<CanvasBloc>().add(const CanvasEvent.ungroupSelected());
          return KeyEventResult.handled;
        }

        // Toggle Lock: Cmd+L
        if (isControlOrCmd && event.logicalKey == LogicalKeyboardKey.keyL) {
          context
              .read<CanvasBloc>()
              .add(const CanvasEvent.toggleLockSelected());
          return KeyEventResult.handled;
        }

        // Toggle Layers Sidebar: Alt+L
        if (isAlt && !isShift && event.logicalKey == LogicalKeyboardKey.keyL) {
          context.read<ToolCubit>().toggleLayersSidebar();
          return KeyEventResult.handled;
        }

        // Toggle Dark/Light Mode: Alt+Shift+D
        if (isAlt && isShift && event.logicalKey == LogicalKeyboardKey.keyD) {
          onToggleTheme?.call();
          return KeyEventResult.handled;
        }

        // Diagram Templates: Cmd+O
        if (isControlOrCmd && event.logicalKey == LogicalKeyboardKey.keyO) {
          onOpenTemplates?.call();
          return KeyEventResult.handled;
        }

        // Export Dialog: Cmd+E
        if (isControlOrCmd && event.logicalKey == LogicalKeyboardKey.keyE) {
          onOpenExport?.call();
          return KeyEventResult.handled;
        }

        // Help / Shortcuts: ? or Shift+/
        if ((event.logicalKey == LogicalKeyboardKey.slash && isShift) ||
            event.logicalKey == LogicalKeyboardKey.question) {
          onOpenHelp?.call();
          return KeyEventResult.handled;
        }

        // Bring to front: ]
        if (event.logicalKey == LogicalKeyboardKey.bracketRight) {
          context
              .read<CanvasBloc>()
              .add(const CanvasEvent.bringSelectedToFront());
          return KeyEventResult.handled;
        }

        // Send to back: [
        if (event.logicalKey == LogicalKeyboardKey.bracketLeft) {
          context
              .read<CanvasBloc>()
              .add(const CanvasEvent.sendSelectedToBack());
          return KeyEventResult.handled;
        }

        // Delete / Backspace
        if (event.logicalKey == LogicalKeyboardKey.delete ||
            event.logicalKey == LogicalKeyboardKey.backspace) {
          if (onDelete != null) {
            onDelete!();
          } else {
            context.read<CanvasBloc>().add(const CanvasEvent.deleteSelected());
          }
          return KeyEventResult.handled;
        }

        // Grid Snap toggle: G
        if (!isControlOrCmd &&
            !isAlt &&
            event.logicalKey == LogicalKeyboardKey.keyG) {
          context.read<ToolCubit>().toggleGridSnap();
          return KeyEventResult.handled;
        }

        // Smart Alignment Guides toggle: S
        if (!isControlOrCmd &&
            !isAlt &&
            event.logicalKey == LogicalKeyboardKey.keyS) {
          context.read<ToolCubit>().toggleSmartGuides();
          return KeyEventResult.handled;
        }

        // Tool Shortcuts (when not holding Cmd/Ctrl)
        if (!isControlOrCmd && !isAlt) {
          if (isShift && event.logicalKey == LogicalKeyboardKey.keyR) {
            context.read<ToolCubit>().setTool(Tool.roundedRectangle);
            return KeyEventResult.handled;
          }
          if (isShift && event.logicalKey == LogicalKeyboardKey.keyT) {
            context.read<ToolCubit>().setTool(Tool.triangle);
            return KeyEventResult.handled;
          }
          if (!isShift) {
            final mappedTool = ToolExtension.shortcuts[event.logicalKey];
            if (mappedTool != null) {
              context.read<ToolCubit>().setTool(mappedTool);
              return KeyEventResult.handled;
            }
          }
        }

        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
