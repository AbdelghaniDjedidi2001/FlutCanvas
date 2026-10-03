import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/board_comment.dart';
import '../../models/board_element.dart';
import '../../models/shape_type.dart';

class LayersSidebar extends StatefulWidget {
  const LayersSidebar({
    super.key,
    required this.elements,
    required this.selectedIds,
    this.comments = const [],
    this.activeCommentId,
    required this.onSelectElement,
    required this.onToggleVisibility,
    required this.onToggleLock,
    required this.onRenameElement,
    required this.onDeleteElement,
    required this.onReorderElements,
    this.onSelectComment,
    this.onToggleResolveComment,
    this.onDeleteComment,
    this.initialTab = 0,
    required this.onClose,
  });

  final List<BoardElement> elements;
  final Set<String> selectedIds;
  final List<BoardComment> comments;
  final String? activeCommentId;
  final void Function(String id, bool multiSelect) onSelectElement;
  final void Function(String id) onToggleVisibility;
  final void Function(String id) onToggleLock;
  final void Function(String id, String newName) onRenameElement;
  final void Function(String id) onDeleteElement;
  final void Function(int oldIndex, int newIndex) onReorderElements;
  final void Function(String id)? onSelectComment;
  final void Function(String id)? onToggleResolveComment;
  final void Function(String id)? onDeleteComment;
  final int initialTab;
  final VoidCallback onClose;

  @override
  State<LayersSidebar> createState() => _LayersSidebarState();
}

class _LayersSidebarState extends State<LayersSidebar> {
  late int _currentTab; // 0: Layers, 1: Comments
  String _searchQuery = '';
  String? _editingElementId;
  int _commentFilter = 0; // 0: All, 1: Open, 2: Resolved
  final TextEditingController _renameController = TextEditingController();
  final FocusNode _renameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  void dispose() {
    _renameController.dispose();
    _renameFocusNode.dispose();
    super.dispose();
  }

  void _startRenaming(BoardElement el) {
    setState(() {
      _editingElementId = el.id;
      _renameController.text = el.displayName;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _renameFocusNode.requestFocus();
      _renameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _renameController.text.length,
      );
    });
  }

  void _commitRename() {
    if (_editingElementId != null) {
      final text = _renameController.text.trim();
      if (text.isNotEmpty) {
        widget.onRenameElement(_editingElementId!, text);
      }
      setState(() {
        _editingElementId = null;
      });
    }
  }

  IconData _getShapeIcon(ShapeType type) {
    return switch (type) {
      ShapeType.rectangle => Icons.crop_square_rounded,
      ShapeType.roundedRectangle => Icons.crop_portrait_rounded,
      ShapeType.ellipse => Icons.circle_outlined,
      ShapeType.diamond => Icons.change_history_outlined,
      ShapeType.triangle => Icons.play_arrow_outlined,
      ShapeType.star => Icons.star_border_rounded,
      ShapeType.line => Icons.horizontal_rule_rounded,
      ShapeType.arrow => Icons.north_east_rounded,
      ShapeType.doubleArrow => Icons.compare_arrows_rounded,
      ShapeType.pen => Icons.gesture_rounded,
      ShapeType.highlighter => Icons.brush_outlined,
      ShapeType.text => Icons.title_rounded,
      ShapeType.stickyNote => Icons.sticky_note_2_outlined,
      ShapeType.frame => Icons.crop_free_rounded,
      ShapeType.image => Icons.image_outlined,
      ShapeType.codeBlock => Icons.code_rounded,
      ShapeType.table => Icons.table_chart_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mqHeight = MediaQuery.of(context).size.height;

    final openCommentsCount = widget.comments.where((c) => !c.isResolved).length;

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 5,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 280,
        constraints: BoxConstraints(
          maxHeight: math.max(240.0, mqHeight - 80),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Tab Header
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tabButton(
                          title: 'Layers',
                          count: widget.elements.length,
                          index: 0,
                          icon: Icons.layers_outlined,
                          scheme: scheme,
                        ),
                        const SizedBox(width: 4),
                        _tabButton(
                          title: 'Comments',
                          count: openCommentsCount,
                          index: 1,
                          icon: Icons.chat_bubble_outline_rounded,
                          scheme: scheme,
                          highlightCount: openCommentsCount > 0,
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: widget.onClose,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Search & Filter Bar
            Container(
              height: 28,
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Icon(Icons.search, size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(fontSize: 11),
                      decoration: InputDecoration(
                        hintText: _currentTab == 0 ? 'Filter layers...' : 'Filter comments...',
                        hintStyle: const TextStyle(fontSize: 11),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() => _searchQuery = ''),
                      child: Icon(Icons.clear, size: 12, color: scheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),

            if (_currentTab == 1) ...[
              const SizedBox(height: 6),
              // Comments Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _commentFilterChip('All', 0, scheme),
                    const SizedBox(width: 4),
                    _commentFilterChip('Open ($openCommentsCount)', 1, scheme),
                    const SizedBox(width: 4),
                    _commentFilterChip(
                      'Resolved (${widget.comments.length - openCommentsCount})',
                      2,
                      scheme,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 6),
            const Divider(height: 1),
            const SizedBox(height: 4),

            // Content List
            _currentTab == 0 ? _buildLayersList(scheme) : _buildCommentsList(scheme),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required int count,
    required int index,
    required IconData icon,
    required ColorScheme scheme,
    bool highlightCount = false,
  }) {
    final isActive = _currentTab == index;
    return InkWell(
      onTap: () => setState(() {
        _currentTab = index;
        _searchQuery = '';
      }),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? scheme.primaryContainer.withValues(alpha: 0.6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: highlightCount
                    ? scheme.primary
                    : (isActive ? scheme.primary.withValues(alpha: 0.2) : scheme.surfaceContainerHighest),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: highlightCount
                      ? Colors.white
                      : (isActive ? scheme.primary : scheme.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentFilterChip(String label, int index, ColorScheme scheme) {
    final isSelected = _commentFilter == index;
    return InkWell(
      onTap: () => setState(() => _commentFilter = index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? scheme.primary.withValues(alpha: 0.5) : scheme.outlineVariant.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildLayersList(ColorScheme scheme) {
    final displayElements = widget.elements.reversed.toList();
    final filtered = _searchQuery.isEmpty
        ? displayElements
        : displayElements
            .where((e) =>
                e.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.type.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (filtered.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            widget.elements.isEmpty ? 'No elements on canvas' : 'No matching layers',
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          itemCount: filtered.length,
          buildDefaultDragHandles: false,
          // ignore: deprecated_member_use
          onReorder: (oldIndex, newIndex) {
            final realOldIndex = widget.elements.length - 1 - oldIndex;
            var realNewIndex = widget.elements.length - 1 - newIndex;
            if (oldIndex < newIndex) {
              realNewIndex += 1;
            }
            widget.onReorderElements(
              realOldIndex.clamp(0, widget.elements.length - 1),
              realNewIndex.clamp(0, widget.elements.length - 1),
            );
          },
          itemBuilder: (context, index) {
            final el = filtered[index];
            final isSelected = widget.selectedIds.contains(el.id);
            final isEditing = _editingElementId == el.id;

            return Material(
              key: ValueKey(el.id),
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 1),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? scheme.primaryContainer.withValues(alpha: 0.5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            size: 13,
                            color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _getShapeIcon(el.type),
                      size: 14,
                      color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: isEditing
                          ? SizedBox(
                              height: 22,
                              child: TextField(
                                controller: _renameController,
                                focusNode: _renameFocusNode,
                                style: const TextStyle(fontSize: 11),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onSubmitted: (_) => _commitRename(),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                final isShift = HardwareKeyboard.instance.isShiftPressed;
                                widget.onSelectElement(el.id, isShift);
                              },
                              onDoubleTap: () => _startRenaming(el),
                              child: Text(
                                el.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: el.isVisible
                                      ? scheme.onSurface
                                      : scheme.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                    ),
                    InkWell(
                      onTap: () => widget.onToggleLock(el.id),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          el.isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
                          size: 13,
                          color: el.isLocked
                              ? scheme.primary
                              : scheme.onSurfaceVariant.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: () => widget.onToggleVisibility(el.id),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          el.isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 13,
                          color: el.isVisible
                              ? scheme.onSurfaceVariant.withValues(alpha: 0.65)
                              : scheme.error.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: () => widget.onDeleteElement(el.id),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCommentsList(ColorScheme scheme) {
    var filtered = widget.comments;
    if (_commentFilter == 1) {
      filtered = filtered.where((c) => !c.isResolved).toList();
    } else if (_commentFilter == 2) {
      filtered = filtered.where((c) => c.isResolved).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((c) =>
              c.text.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              '#${c.pinNumber}'.contains(_searchQuery))
          .toList();
    }

    if (filtered.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            widget.comments.isEmpty
                ? 'No comments yet\n(Use Comment Pin tool to add)'
                : 'No matching comments',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final c = filtered[index];
          final isActive = widget.activeCommentId == c.id;

          return Material(
            key: ValueKey(c.id),
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.onSelectComment?.call(c.id),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive
                      ? scheme.primaryContainer.withValues(alpha: 0.5)
                      : scheme.surfaceContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? scheme.primary.withValues(alpha: 0.6)
                        : scheme.outlineVariant.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: c.isResolved
                                ? const Color(0xFF10B981)
                                : scheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${c.pinNumber}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            c.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          c.timeAgo,
                          style: TextStyle(
                            fontSize: 9,
                            color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Resolve checkbox
                        InkWell(
                          onTap: () => widget.onToggleResolveComment?.call(c.id),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              c.isResolved
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 14,
                              color: c.isResolved
                                  ? const Color(0xFF10B981)
                                  : scheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        // Delete icon
                        InkWell(
                          onTap: () => widget.onDeleteComment?.call(c.id),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.text.isEmpty ? '(Empty comment)' : c.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface,
                        decoration: c.isResolved ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (c.replies.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 10, color: scheme.primary),
                          const SizedBox(width: 3),
                          Text(
                            '${c.replies.length} ${c.replies.length == 1 ? 'reply' : 'replies'}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
