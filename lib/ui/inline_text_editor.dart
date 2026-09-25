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
    required this.onSubmitted,
    required this.onCanceled,
  });

  final String initialText;
  final double fontSize;
  final Color color;
  final Offset screenPosition;
  final bool isStickyNote;
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

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    final kb = HardwareKeyboard.instance;

    // 1. Enter key handling:
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

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
              width: widget.isStickyNote ? 200 : 280,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isStickyNote
                    ? Colors.white.withValues(alpha: 0.96)
                    : Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x28000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
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
                  maxLines: widget.isStickyNote ? 8 : null,
                  minLines: widget.isStickyNote ? 3 : 1,
                  autofocus: true,
                  style: GoogleFonts.caveat(
                    fontSize: widget.fontSize,
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'Type text here...',
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
                  const Text(
                    '↵ Enter to finish  ·  ⇧↵ New line',
                    style: TextStyle(
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
