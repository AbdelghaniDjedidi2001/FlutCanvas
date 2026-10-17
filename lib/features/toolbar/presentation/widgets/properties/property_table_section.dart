import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';

/// Section for managing table dimensions and header row.
class PropertyTableSection extends StatelessWidget {
  final BoardElement tableElement;
  final VoidCallback onAddRow;
  final VoidCallback onRemoveRow;
  final VoidCallback onAddColumn;
  final VoidCallback onRemoveColumn;
  final void Function(bool hasHeader) onToggleHeader;

  const PropertyTableSection({
    super.key,
    required this.tableElement,
    required this.onAddRow,
    required this.onRemoveRow,
    required this.onAddColumn,
    required this.onRemoveColumn,
    required this.onToggleHeader,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Table Grid Controls',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onAddRow,
                      icon: const Icon(Icons.add, size: 13),
                      label: const Text('+ Row', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onRemoveRow,
                      icon: const Icon(Icons.remove, size: 13),
                      label: const Text('- Row', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onAddColumn,
                      icon: const Icon(Icons.add, size: 13),
                      label: const Text('+ Col', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onRemoveColumn,
                      icon: const Icon(Icons.remove, size: 13),
                      label: const Text('- Col', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => onToggleHeader(!tableElement.tableHasHeader),
                  icon: Icon(
                    tableElement.tableHasHeader
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 13,
                  ),
                  label: Text(
                    tableElement.tableHasHeader
                        ? 'Header Row: ON'
                        : 'Header Row: OFF',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
