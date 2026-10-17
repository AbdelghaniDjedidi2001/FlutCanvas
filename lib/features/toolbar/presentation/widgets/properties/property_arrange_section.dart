import 'package:flutter/material.dart';

import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_shared_widgets.dart';

/// Section for arranging, aligning, grouping, and ordering selected elements.
class PropertyArrangeSection extends StatelessWidget {
  final int selectedCount;
  final bool hasGrouped;
  final void Function(String alignment) onAlign;
  final void Function(String direction) onDistribute;
  final VoidCallback onGroup;
  final VoidCallback onUngroup;
  final VoidCallback onBringToFront;
  final VoidCallback onSendToBack;
  final VoidCallback onToggleLock;
  final VoidCallback onDelete;

  const PropertyArrangeSection({
    super.key,
    required this.selectedCount,
    required this.hasGrouped,
    required this.onAlign,
    required this.onDistribute,
    required this.onGroup,
    required this.onUngroup,
    required this.onBringToFront,
    required this.onSendToBack,
    required this.onToggleLock,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 12),
        const Text(
          'Layout & Arrange',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            if (selectedCount >= 2) ...[
              propertyActionButton(
                icon: Icons.align_horizontal_left,
                tooltip: 'Align Left',
                onTap: () => onAlign('left'),
                scheme: scheme,
              ),
              propertyActionButton(
                icon: Icons.align_horizontal_center,
                tooltip: 'Align Center',
                onTap: () => onAlign('center'),
                scheme: scheme,
              ),
              propertyActionButton(
                icon: Icons.align_horizontal_right,
                tooltip: 'Align Right',
                onTap: () => onAlign('right'),
                scheme: scheme,
              ),
              propertyActionButton(
                icon: Icons.align_vertical_top,
                tooltip: 'Align Top',
                onTap: () => onAlign('top'),
                scheme: scheme,
              ),
            ],
            if (selectedCount >= 3) ...[
              propertyActionButton(
                icon: Icons.horizontal_distribute,
                tooltip: 'Distribute Horizontally',
                onTap: () => onDistribute('horizontal'),
                scheme: scheme,
              ),
            ],
            if (selectedCount >= 2)
              propertyActionButton(
                icon: Icons.group,
                tooltip: 'Group (Ctrl+G)',
                onTap: onGroup,
                scheme: scheme,
              ),
            if (hasGrouped)
              propertyActionButton(
                icon: Icons.group_remove_outlined,
                tooltip: 'Ungroup (Ctrl+Shift+G)',
                onTap: onUngroup,
                scheme: scheme,
              ),
            propertyActionButton(
              icon: Icons.flip_to_front,
              tooltip: 'Bring to Front (])',
              onTap: onBringToFront,
              scheme: scheme,
            ),
            propertyActionButton(
              icon: Icons.flip_to_back,
              tooltip: 'Send to Back ([)',
              onTap: onSendToBack,
              scheme: scheme,
            ),
            propertyActionButton(
              icon: Icons.lock_outline,
              tooltip: 'Toggle Lock',
              onTap: onToggleLock,
              scheme: scheme,
            ),
            propertyActionButton(
              icon: Icons.delete_outline,
              tooltip: 'Delete (Del)',
              color: Colors.redAccent,
              onTap: onDelete,
              scheme: scheme,
            ),
          ],
        ),
      ],
    );
  }
}
