import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutcanvas/core/constants/board_colors.dart';

class InlineTextEditor extends StatefulWidget {
  const InlineTextEditor({
    super.key,
    required this.initialText,
    required this.fontSize,
    required this.color,
    required this.screenPosition,
    required this.isStickyNote,
    this.isCodeBlock = false,
    this.isTableCell = false,
    this.customWidth,
    this.onNavigateCell,
    required this.onSubmitted,
    required this.onCanceled,
  });

  final String initialText;
  final double fontSize;
  final Color color;
  final Offset screenPosition;
  final bool isStickyNote;
  final bool isCodeBlock;
  final bool isTableCell;
  final double? customWidth;
  final void Function(int dRow, int dCol, String currentText)? onNavigateCell;
  final void Function(String text) onSubmitted;
  final VoidCallback onCanceled;

  @override
  State<InlineTextEditor> createState() => _InlineTextEditorState();
}

class _InlineTextEditorState extends State<InlineTextEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _finish() {
    final text = _controller.text.trim();
    if (widget.isTableCell || text.isNotEmpty) {
      widget.onSubmitted(text);
    } else {
      widget.onCanceled();
    }
  }

  void _insertNewline() {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, '\n');
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + 1),
    );
  }

  void _insertTab() {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, '  ');
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + 2),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    final kb = HardwareKeyboard.instance;

    // Table cell navigation (Tab next cell, Enter next row)
    if (widget.isTableCell) {
      if (key == LogicalKeyboardKey.tab) {
        if (kb.isShiftPressed) {
          widget.onNavigateCell?.call(0, -1, _controller.text);
        } else {
          widget.onNavigateCell?.call(0, 1, _controller.text);
        }
        return KeyEventResult.handled;
      }

      if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
        widget.onNavigateCell?.call(1, 0, _controller.text);
        return KeyEventResult.handled;
      }

      if (key == LogicalKeyboardKey.escape) {
        _finish();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // Tab key handling for code indentation
    if (key == LogicalKeyboardKey.tab) {
      _insertTab();
      return KeyEventResult.handled;
    }

    if (widget.isCodeBlock) {
      // For Code Blocks:
      // - Enter: Inserts a newline (natural coding)
      // - Ctrl/Cmd + Enter: Finishes editing
      // - Escape: Finishes editing
      if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
        if (kb.isControlPressed || kb.isMetaPressed) {
          _finish();
          return KeyEventResult.handled;
        }
        _insertNewline();
        return KeyEventResult.handled;
      }

      if (key == LogicalKeyboardKey.escape) {
        _finish();
        return KeyEventResult.handled;
      }
    } else {
      // 1. Enter key handling for normal text / sticky notes:
      if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.numpadEnter) {
        if (kb.isShiftPressed) {
          _insertNewline();
          return KeyEventResult.handled;
        } else {
          _finish();
          return KeyEventResult.handled;
        }
      }

      // 2. Ctrl/Cmd + Enter: Always finishes editing
      if ((kb.isControlPressed || kb.isMetaPressed) &&
          (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.numpadEnter)) {
        _finish();
        return KeyEventResult.handled;
      }

      // 3. Escape key: Finishes editing
      if (key == LogicalKeyboardKey.escape) {
        _finish();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor;
    if (widget.isTableCell) {
      textColor = isDark ? Colors.white : const Color(0xFF212529);
    } else if (widget.isStickyNote) {
      textColor = const Color(0xFF212529);
    } else if (widget.isCodeBlock) {
      textColor = isDark ? const Color(0xFFCDD6F4) : const Color(0xFF24292F);
    } else {
      // Normal text or connector label:
      final raw = widget.color;
      final isMonoOrInk = raw == Colors.transparent ||
          raw == kInk ||
          raw == Colors.black ||
          raw == Colors.white ||
          raw.toARGB32() == 0xFF1F2430 ||
          raw.toARGB32() == 0xFF000000 ||
          raw.toARGB32() == 0xFFFFFFFF ||
          (isDark && raw.computeLuminance() < 0.25) ||
          (!isDark && raw.computeLuminance() > 0.75);

      if (isMonoOrInk) {
        textColor = isDark ? Colors.white : const Color(0xFF212529);
      } else {
        textColor = raw;
      }
    }

    final Color editorBg;
    if (widget.isCodeBlock) {
      editorBg = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FA);
    } else if (widget.isStickyNote) {
      editorBg = const Color(0xFFFFF9C4);
    } else if (widget.isTableCell) {
      editorBg = isDark ? const Color(0xFF1E222B) : Colors.white;
    } else {
      // Normal text or connector label:
      // White text on dark box in dark mode, Black text on white box in light mode
      if (textColor.computeLuminance() > 0.5) {
        editorBg = const Color(0xFF1E222B);
      } else {
        editorBg = Colors.white;
      }
    }

    final isEditorBgDark = editorBg.computeLuminance() < 0.5;
    final cursorColor = isEditorBgDark ? Colors.white : scheme.primary;
    final hintColor = textColor.withValues(alpha: 0.45);

    final containerWidth = widget.customWidth ??
        (widget.isCodeBlock
            ? 380.0
            : (widget.isStickyNote ? 220.0 : (widget.isTableCell ? 160.0 : 280.0)));

    final textStyle = widget.isTableCell
        ? GoogleFonts.inter(
            fontSize: widget.fontSize,
            color: textColor,
            fontWeight: FontWeight.w600,
          )
        : (widget.isCodeBlock
            ? GoogleFonts.jetBrainsMono(
                fontSize: widget.fontSize * 0.8,
                color: textColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              )
            : GoogleFonts.caveat(
                fontSize: widget.fontSize,
                color: textColor,
                fontWeight: FontWeight.w600,
              ));

    return Positioned(
      left: widget.screenPosition.dx,
      top: widget.screenPosition.dy,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Input Box
            Container(
              width: containerWidth,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: editorBg,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x28000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isEditorBgDark
                      ? const Color(0xFF5C7CFA)
                      : scheme.primary,
                  width: 2.0,
                ),
              ),
              child: Focus(
                onKeyEvent: _handleKeyEvent,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  cursorColor: cursorColor,
                  maxLines: widget.isCodeBlock
                      ? 16
                      : (widget.isStickyNote ? 8 : (widget.isTableCell ? 2 : null)),
                  minLines: widget.isCodeBlock ? 4 : (widget.isStickyNote ? 3 : 1),
                  autofocus: true,
                  style: textStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: widget.isCodeBlock
                        ? '// Enter code here...'
                        : (widget.isTableCell ? 'Cell value...' : 'Type text here...'),
                    hintStyle: textStyle.copyWith(color: hintColor),
                  ),
                  onTapOutside: (_) => _finish(),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Helper hint & Quick Finish Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xEE212529),
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(color: Color(0x18000000), blurRadius: 4),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isTableCell
                        ? '⇥ Tab next cell · ↵ Enter next row'
                        : (widget.isCodeBlock
                            ? '⌘↵ or Done to finish · ⇥ Tab indent'
                            : '↵ Enter to finish · ⇧↵ New line'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _finish,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 12, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
