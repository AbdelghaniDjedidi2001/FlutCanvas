import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/board_element.dart';
import '../../models/shape_type.dart';

class LayersSidebar extends StatefulWidget {
  const LayersSidebar({
    super.key,
    required this.elements,
    required this.selectedIds,
    required this.onSelectElement,
    required this.onToggleVisibility,
    required this.onToggleLock,
    required this.onRenameElement,
    required this.onDeleteElement,
    required this.onReorderElements,
    required this.onClose,
  });

  final List<BoardElement> elements;
  final Set<String> selectedIds;
  final void Function(String id, bool multiSelect) onSelectElement;
  final void Function(String id) onToggleVisibility;
  final void Function(String id) onToggleLock;
  final void Function(String id, String newName) onRenameElement;
  final void Function(String id) onDeleteElement;
  final void Function(int oldIndex, int newIndex) onReorderElements;
  final VoidCallback onClose;

  @override
  State<LayersSidebar> createState() => _LayersSidebarState();
}

class _LayersSidebarState extends State<LayersSidebar> {
  String _searchQuery = '';
  String? _editingElementId;
  final TextEditingController _renameController = TextEditingController();
  final FocusNode _renameFocusNode = FocusNode();

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
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mqHeight = MediaQuery.of(context).size.height;

    // Canvas elements are stored bottom-to-top (index 0 = back, last = front).
    // In standard design tools, the layers panel lists top-most Z-index elements at the top of the list.
    final displayElements = widget.elements.reversed.toList();
    final filtered = _searchQuery.isEmpty
        ? displayElements
        : displayElements
            .where((e) =>
                e.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.type.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 5,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 250,
        constraints: BoxConstraints(
          maxHeight: math.max(220.0, mqHeight - 80),
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
            // Header
            Row(
              children: [
                Icon(Icons.layers_outlined, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Layers',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.elements.length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
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

            // Search Bar
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
                      decoration: const InputDecoration(
                        hintText: 'Filter layers...',
                        hintStyle: TextStyle(fontSize: 11),
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
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 4),

            // Layers List
            if (widget.elements.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                child: Center(
                  child: Text(
                    'No layers on this board.\nStart drawing to create elements!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              )
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No matching layers',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Flexible(
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: filtered.length,
                  // ignore: deprecated_member_use
                  onReorder: (oldIndex, newIndex) {
                    // Map displayed top-down index back to bottom-up canvas array index
                    final count = widget.elements.length;
                    final origOldIndex = count - 1 - oldIndex;
                    var origNewIndex = count - 1 - (newIndex > oldIndex ? newIndex - 1 : newIndex);
                    origNewIndex = origNewIndex.clamp(0, count - 1);
                    widget.onReorderElements(origOldIndex, origNewIndex);
                  },
                  itemBuilder: (context, index) {
                    final el = filtered[index];
                    final isSelected = widget.selectedIds.contains(el.id);
                    final isEditingThis = _editingElementId == el.id;

                    return Container(
                      key: ValueKey(el.id),
                      height: 32,
                      margin: const EdgeInsets.symmetric(vertical: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? scheme.primaryContainer.withValues(alpha: 0.75)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? scheme.primary.withValues(alpha: 0.4)
                              : Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Reorder Drag Handle
                          ReorderableDragStartListener(
                            index: index,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.grab,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 3),
                                child: Icon(
                                  Icons.drag_indicator_rounded,
                                  size: 13,
                                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ),

                          // Shape Type Icon
                          Icon(
                            _getShapeIcon(el.type),
                            size: 14,
                            color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),

                            // Layer Title / Inline Rename Editor
                            Expanded(
                              child: isEditingThis
                                  ? Container(
                                      height: 24,
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: scheme.surface,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: scheme.primary,
                                          width: 1.2,
                                        ),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: TextField(
                                        controller: _renameController,
                                        focusNode: _renameFocusNode,
                                        autofocus: true,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                        ),
                                        onSubmitted: (_) => _commitRename(),
                                        onTapOutside: (_) => _commitRename(),
                                      ),
                                    )
                                  : InkWell(
                                      borderRadius: BorderRadius.circular(4),
                                      onTap: () {
                                        final isShift = HardwareKeyboard.instance.isShiftPressed;
                                        widget.onSelectElement(el.id, isShift);
                                      },
                                      onDoubleTap: () => _startRenaming(el),
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        height: 32,
                                        padding: const EdgeInsets.symmetric(horizontal: 2),
                                        child: Text(
                                          el.displayName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            color: !el.isVisible
                                                ? scheme.onSurfaceVariant.withValues(alpha: 0.4)
                                                : (isSelected ? scheme.onPrimaryContainer : scheme.onSurface),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),

                            // Lock Toggle Action
                            InkWell(
                              onTap: () => widget.onToggleLock(el.id),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(
                                  el.isLocked ? Icons.lock_rounded : Icons.lock_open_outlined,
                                  size: 13,
                                  color: el.isLocked
                                      ? Colors.amber.shade800
                                      : scheme.onSurfaceVariant.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),

                            // Visibility Toggle Action
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

                            // Delete Action
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
                      );
                    },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
