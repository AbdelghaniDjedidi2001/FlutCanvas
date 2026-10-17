import 'package:flutter/material.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_shared_widgets.dart';

/// Section for selecting stroke / pencil / highlighter colors.
class PropertyStrokeColorSection extends StatelessWidget {
  final Color activeColor;
  final bool isHighlighterTarget;
  final List<Color> strokeColorPalette;
  final BoardColors colors;
  final void Function(Color color) onSelectColor;

  const PropertyStrokeColorSection({
    super.key,
    required this.activeColor,
    required this.isHighlighterTarget,
    required this.strokeColorPalette,
    required this.colors,
    required this.onSelectColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHighlighterTarget ? 'Highlighter Color' : 'Stroke Color',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            for (final c in strokeColorPalette)
              propertyColorBubble(
                color: isHighlighterTarget
                    ? colors.displayHighlighter(c)
                    : colors.display(c),
                isSelected: activeColor == c,
                onTap: () => onSelectColor(c),
                selectionColor: scheme.primary,
              ),
          ],
        ),
      ],
    );
  }
}
