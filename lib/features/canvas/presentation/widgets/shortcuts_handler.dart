import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/tool.dart';
import '../../../toolbar/presentation/bloc/tool_cubit.dart';
import '../bloc/canvas_bloc.dart';
import '../bloc/canvas_event.dart';

class CanvasShortcutsHandler extends StatelessWidget {
  final Widget child;
  final VoidCallback? onCopy;
  final VoidCallback? onPaste;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const CanvasShortcutsHandler({
    super.key,
    required this.child,
    this.onCopy,
    this.onPaste,
    this.onDuplicate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        final isControlOrCmd = HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed;
        final isShift = HardwareKeyboard.instance.isShiftPressed;

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

        // Tool Shortcuts (when not holding Cmd/Ctrl)
        if (!isControlOrCmd) {
          final mappedTool = ToolExtension.shortcuts[event.logicalKey];
          if (mappedTool != null) {
            context.read<ToolCubit>().setTool(mappedTool);
            return KeyEventResult.handled;
          }
        }

        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
