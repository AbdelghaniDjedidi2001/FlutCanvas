import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/boards_cubit.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_document.dart';

class BoardTabsBar extends StatelessWidget {
  const BoardTabsBar({
    super.key,
    this.boards,
    this.activeIndex,
    this.onSelectBoard,
    this.onCreateBoard,
    this.onRenameBoard,
    this.onDeleteBoard,
    this.onDuplicateBoard,
  });

  final List<BoardDocument>? boards;
  final int? activeIndex;
  final void Function(int index)? onSelectBoard;
  final VoidCallback? onCreateBoard;
  final void Function(int index, String newTitle)? onRenameBoard;
  final void Function(int index)? onDeleteBoard;
  final void Function(int index)? onDuplicateBoard;

  @override
  Widget build(BuildContext context) {
    final boardsCubit = context.watch<BoardsCubit?>();
    final cubitState = boardsCubit?.state;

    final effectiveBoards = boards ??
        cubitState?.boards ??
        [
          BoardDocument(id: 'board_1', title: 'Main Board', elements: const []),
        ];
    final effectiveIndex = (activeIndex ?? cubitState?.activeBoardIndex ?? 0)
        .clamp(0, effectiveBoards.length - 1);
    final effectiveSelectBoard =
        onSelectBoard ?? (i) => boardsCubit?.switchBoard(i);
    final effectiveCreateBoard =
        onCreateBoard ?? () => boardsCubit?.addNewBoard();
    final effectiveRenameBoard =
        onRenameBoard ?? (i, name) => boardsCubit?.renameBoard(i, name);
    final effectiveDeleteBoard =
        onDeleteBoard ?? (i) => boardsCubit?.deleteBoard(i);
    final effectiveDuplicateBoard =
        onDuplicateBoard ?? (i) => boardsCubit?.duplicateBoard(i);

    final scheme = Theme.of(context).colorScheme;
    final currentBoard = effectiveBoards[effectiveIndex];

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
                side: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              color: scheme.surfaceContainerHigh,
              onSelected: effectiveSelectBoard,
              itemBuilder: (ctx) => [
                for (var i = 0; i < effectiveBoards.length; i++)
                  PopupMenuItem<int>(
                    value: i,
                    child: Row(
                      children: [
                        Icon(
                          i == effectiveIndex
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: i == effectiveIndex
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            effectiveBoards[i].title,
                            style: TextStyle(
                              fontWeight: i == effectiveIndex
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color:
                                  i == effectiveIndex ? scheme.primary : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const PopupMenuDivider(),
                PopupMenuItem<int>(
                  value: -1,
                  onTap: effectiveCreateBoard,
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline,
                          size: 16, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Create New Board',
                        style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dashboard_outlined,
                      size: 16,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(
                        currentBoard.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: 1,
              height: 18,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),

            // Context Menu: Rename / Duplicate / Delete
            PopupMenuButton<String>(
              tooltip: 'Board Settings',
              padding: EdgeInsets.zero,
              iconSize: 16,
              icon: Icon(Icons.more_horiz,
                  size: 16, color: scheme.onSurfaceVariant),
              offset: const Offset(0, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              color: scheme.surfaceContainerHigh,
              onSelected: (val) {
                if (val == 'rename') {
                  _promptRename(context, effectiveIndex, currentBoard.title,
                      effectiveRenameBoard);
                } else if (val == 'duplicate') {
                  effectiveDuplicateBoard(effectiveIndex);
                } else if (val == 'delete') {
                  effectiveDeleteBoard(effectiveIndex);
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
                if (effectiveBoards.length > 1)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 16, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Delete Board',
                            style: TextStyle(color: Colors.redAccent)),
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
                onPressed: effectiveCreateBoard,
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _promptRename(BuildContext context, int index, String currentTitle,
      void Function(int, String) onRename) {
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
            if (t.isNotEmpty) onRename(index, t);
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
              if (t.isNotEmpty) onRename(index, t);
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
