import 'package:flutter/material.dart';

/// Header for the floating properties panel displaying selection count and close button.
class PropertyPanelHeader extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onClose;

  const PropertyPanelHeader({
    super.key,
    required this.selectedCount,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          selectedCount == 0
              ? Icons.tune_rounded
              : Icons.edit_note_rounded,
          size: 15,
          color: scheme.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            selectedCount == 0
                ? 'Default Style'
                : '$selectedCount selected',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
        if (onClose != null)
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.close,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
