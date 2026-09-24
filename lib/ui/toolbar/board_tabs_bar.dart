import 'package:flutter/material.dart';
import '../../models/board_document.dart';

class BoardTabsBar extends StatelessWidget {
  const BoardTabsBar({
    super.key,
    required this.boards,
    required this.activeIndex,
    required this.onSelectBoard,
    required this.onCreateBoard,
    required this.onRenameBoard,
    required this.onDeleteBoard,
    required this.onDuplicateBoard,
  });

  final List<BoardDocument> boards;
  final int activeIndex;
  final void Function(int index) onSelectBoard;
  final VoidCallback onCreateBoard;
  final void Function(int index, String newTitle) onRenameBoard;
  final void Function(int index) onDeleteBoard;
  final void Function(int index) onDuplicateBoard;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currentBoard = boards[activeIndex.clamp(0, boards.length - 1)];

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 3,
      shadowColor: const Color(0x22000000),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Board Switcher Popup Menu
            PopupMenuButton<int>(
              tooltip: 'Switch Board',
              padding: EdgeInsets.zero,
              offset: const Offset(0, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              color: scheme.surfaceContainerHigh,
              onSelected: onSelectBoard,
              itemBuilder: (ctx) => [
                for (var i = 0; i < boards.length; i++)
                  PopupMenuItem<int>(
                    value: i,
                    child: Row(
                      children: [
                        Icon(
                          i == activeIndex
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: i == activeIndex ? scheme.primary : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            boards[i].title,
                            style: TextStyle(
                              fontWeight: i == activeIndex ? FontWeight.bold : FontWeight.normal,
                              color: i == activeIndex ? scheme.primary : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const PopupMenuDivider(),
                PopupMenuItem<int>(
                  value: -1,
                  onTap: onCreateBoard,
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, size: 16, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Create New Board',
                        style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dashboard_rounded, size: 15, color: scheme.primary),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: Text(
                        currentBoard.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 16, color: scheme.onPrimaryContainer),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Quick Options for Active Board
            PopupMenuButton<String>(
              tooltip: 'Board Settings',
              padding: EdgeInsets.zero,
              iconSize: 16,
              icon: Icon(Icons.more_horiz, size: 16, color: scheme.onSurfaceVariant),
              offset: const Offset(0, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              color: scheme.surfaceContainerHigh,
              onSelected: (val) {
                if (val == 'rename') {
                  _promptRename(context, activeIndex, currentBoard.title);
                } else if (val == 'duplicate') {
                  onDuplicateBoard(activeIndex);
                } else if (val == 'delete') {
                  onDeleteBoard(activeIndex);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Rename Board'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Duplicate Board'),
                    ],
                  ),
                ),
                if (boards.length > 1)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Delete Board', style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
              ],
            ),

            // Quick Add Board
            Tooltip(
              message: 'New Board',
              child: IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                onPressed: onCreateBoard,
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _promptRename(BuildContext context, int index, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Board'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Board Title'),
          onSubmitted: (val) {
            final t = val.trim();
            if (t.isNotEmpty) onRenameBoard(index, t);
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final t = controller.text.trim();
              if (t.isNotEmpty) onRenameBoard(index, t);
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
