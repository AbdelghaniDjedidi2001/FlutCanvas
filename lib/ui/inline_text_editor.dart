import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class InlineTextEditor extends StatefulWidget {
  const InlineTextEditor({
    super.key,
    required this.initialText,
    required this.fontSize,
    required this.color,
    required this.screenPosition,
    required this.isStickyNote,
    this.isCodeBlock = false,
    required this.onSubmitted,
    required this.onCanceled,
  });

  final String initialText;
  final double fontSize;
  final Color color;
  final Offset screenPosition;
  final bool isStickyNote;
  final bool isCodeBlock;
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
    if (text.isNotEmpty) {
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
        // Normal enter in code block inserts newline
        _insertNewline();
        return KeyEventResult.handled;
      }

      if (key == LogicalKeyboardKey.escape) {
        _finish();
        return KeyEventResult.handled;
      }
    } else {
      // 1. Enter key handling for normal text / sticky notes:
      //    - Shift + Enter: Inserts a newline at current cursor
      //    - Enter (or Numpad Enter): Finishes editing
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

    final containerWidth = widget.isCodeBlock
        ? 380.0
        : (widget.isStickyNote ? 220.0 : 280.0);

    final textStyle = widget.isCodeBlock
        ? GoogleFonts.jetBrainsMono(
            fontSize: widget.fontSize * 0.8,
            color: isDark ? const Color(0xFFCDD6F4) : const Color(0xFF24292F),
            fontWeight: FontWeight.w500,
            height: 1.4,
          )
        : GoogleFonts.caveat(
            fontSize: widget.fontSize,
            color: widget.color,
            fontWeight: FontWeight.w600,
          );

    final editorBg = widget.isCodeBlock
        ? (isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FA))
        : (isDark ? const Color(0xFF212529) : Colors.white);

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  color: scheme.primary,
                  width: 2.0,
                ),
              ),
              child: Focus(
                onKeyEvent: _handleKeyEvent,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: widget.isCodeBlock ? 16 : (widget.isStickyNote ? 8 : null),
                  minLines: widget.isCodeBlock ? 4 : (widget.isStickyNote ? 3 : 1),
                  autofocus: true,
                  style: textStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: widget.isCodeBlock ? '// Enter code here...' : 'Type text here...',
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
                    widget.isCodeBlock
                        ? '⌘↵ or Done to finish · ⇥ Tab indent'
                        : '↵ Enter to finish · ⇧↵ New line',
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
