import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShortcutsHelpDialog extends StatelessWidget {
  const ShortcutsHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r.clamp(10.0, 20.0))),
      child: Container(
        width: math.min(680.w.clamp(320.0, 720.0), mq.width - 32),
        constraints: BoxConstraints(
          maxHeight: math.min(640.h.clamp(400.0, 700.0), mq.height - 48),
        ),
        padding: EdgeInsets.all(20.r.clamp(12.0, 24.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r.clamp(6.0, 10.0)),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10.r.clamp(6.0, 12.0)),
                  ),
                  child: Icon(Icons.keyboard_outlined, color: scheme.primary, size: 24.r.clamp(18.0, 28.0)),
                ),
                SizedBox(width: 14.w.clamp(8.0, 16.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keyboard Shortcuts',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp.clamp(15.0, 22.0),
                            ),
                      ),
                      Text(
                        'Quick reference guide for navigating and creating in FlutCanvas',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13.sp.clamp(10.5, 14.5),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ],
            ),
            SizedBox(height: 16.h.clamp(8.0, 20.0)),
            const Divider(height: 1),
            SizedBox(height: 10.h.clamp(6.0, 14.0)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      title: '🖌️ Drawing & Creation Tools',
                      items: [
                        _ShortcutItem('Select / Move Tool', 'V'),
                        _ShortcutItem('Hand / Pan Canvas', 'H / Space + Drag'),
                        _ShortcutItem('Rectangle', 'R'),
                        _ShortcutItem('Rounded Box', 'Shift + R'),
                        _ShortcutItem('Ellipse', 'O'),
                        _ShortcutItem('Diamond', 'D'),
                        _ShortcutItem('Triangle', 'Shift + T'),
                        _ShortcutItem('Line', 'L'),
                        _ShortcutItem('Arrow Connector', 'A'),
                        _ShortcutItem('Pen (Freehand)', 'P'),
                        _ShortcutItem('Highlighter', 'M'),
                        _ShortcutItem('Text Tool', 'T'),
                        _ShortcutItem('Sticky Note', 'N'),
                        _ShortcutItem('Eraser', 'E'),
                        _ShortcutItem('Laser Pointer', 'K'),
                        _ShortcutItem('Slide Frame', 'F'),
                        _ShortcutItem('Insert Image', 'I'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      title: '⚡ Editing & Manipulation',
                      items: [
                        _ShortcutItem('Undo', 'Ctrl / Cmd + Z'),
                        _ShortcutItem('Redo', 'Ctrl / Cmd + Shift + Z / Ctrl+Y'),
                        _ShortcutItem('Copy Selected', 'Ctrl / Cmd + C'),
                        _ShortcutItem('Paste', 'Ctrl / Cmd + V'),
                        _ShortcutItem('Duplicate', 'Ctrl / Cmd + D'),
                        _ShortcutItem('Lock / Unlock Selected', 'Ctrl / Cmd + L'),
                        _ShortcutItem('Group Selected', 'Ctrl / Cmd + G'),
                        _ShortcutItem('Ungroup', 'Ctrl / Cmd + Shift + G'),
                        _ShortcutItem('Bring to Front', 'Ctrl / Cmd + ]'),
                        _ShortcutItem('Send to Back', 'Ctrl / Cmd + ['),
                        _ShortcutItem('Delete Selected', 'Delete / Backspace'),
                        _ShortcutItem('Open / Import Board', 'Ctrl / Cmd + O'),
                        _ShortcutItem('Export Board', 'Ctrl / Cmd + E'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      title: '📐 Viewport & Navigation',
                      items: [
                        _ShortcutItem('Pan Canvas', 'Middle Drag / Space + Drag'),
                        _ShortcutItem('Zoom In / Out', 'Mouse Scroll Wheel'),
                        _ShortcutItem('Toggle Layers / Object Tree', 'Alt + L'),
                        _ShortcutItem('Toggle Smart Snapping Guides', 'S'),
                        _ShortcutItem('Toggle Grid Snapping', 'G'),
                        _ShortcutItem('Toggle Dark/Light Mode', 'Alt + Shift + D'),
                        _ShortcutItem('Start Presentation', 'F5'),
                        _ShortcutItem('Open Help & Shortcuts', '?'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_ShortcutItem> items,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h.clamp(4.0, 10.0), top: 4.h.clamp(2.0, 8.0)),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp.clamp(12.0, 16.0),
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10.r.clamp(6.0, 12.0)),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w.clamp(8.0, 16.0), vertical: 7.h.clamp(4.0, 9.0)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          items[i].action,
                          style: TextStyle(fontSize: 13.sp.clamp(11.0, 14.5)),
                        ),
                      ),
                      _KeyBadge(items[i].keyCombo),
                    ],
                  ),
                ),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: scheme.outlineVariant.withValues(alpha: 0.2),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ShortcutItem {
  final String action;
  final String keyCombo;
  const _ShortcutItem(this.action, this.keyCombo);
}

class _KeyBadge extends StatelessWidget {
  final String keys;
  const _KeyBadge(this.keys);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final parts = keys.split(' / ');

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: parts.map((part) {
        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: 7.w.clamp(5.0, 9.0), vertical: 3.h.clamp(2.0, 5.0)),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6.r.clamp(4.0, 8.0)),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                offset: Offset(0, 1),
                blurRadius: 1,
              ),
            ],
          ),
          child: Text(
            part,
            style: TextStyle(
              fontSize: 11.5.sp.clamp(10.0, 13.0),
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: scheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }
}
