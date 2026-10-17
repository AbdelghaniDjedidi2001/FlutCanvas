import 'package:flutter/material.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_shared_widgets.dart';

/// Section for selecting shape fill style and fill colors.
class PropertyFillSection extends StatelessWidget {
  final FillStyle activeFillStyle;
  final Color activeFillColor;
  final BoardColors colors;
  final void Function(FillStyle style) onSelectFillStyle;
  final void Function(Color color) onSelectFillColor;

  const PropertyFillSection({
    super.key,
    required this.activeFillStyle,
    required this.activeFillColor,
    required this.colors,
    required this.onSelectFillStyle,
    required this.onSelectFillColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fill Style',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            propertySegmentedOption<FillStyle>(
              label: 'None',
              value: FillStyle.none,
              groupValue: activeFillStyle,
              onSelect: onSelectFillStyle,
              scheme: scheme,
            ),
            const SizedBox(width: 3),
            propertySegmentedOption<FillStyle>(
              label: 'Semi',
              value: FillStyle.semi,
              groupValue: activeFillStyle,
              onSelect: onSelectFillStyle,
              scheme: scheme,
            ),
            const SizedBox(width: 3),
            propertySegmentedOption<FillStyle>(
              label: 'Solid',
              value: FillStyle.solid,
              groupValue: activeFillStyle,
              onSelect: onSelectFillStyle,
              scheme: scheme,
            ),
            const SizedBox(width: 3),
            propertySegmentedOption<FillStyle>(
              label: 'Hatch',
              value: FillStyle.hatch,
              groupValue: activeFillStyle,
              onSelect: onSelectFillStyle,
              scheme: scheme,
            ),
          ],
        ),
        if (activeFillStyle != FillStyle.none) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final c in BoardColors.stickyNoteColors)
                propertyColorBubble(
                  color: colors.display(c),
                  isSelected: activeFillColor == c,
                  onTap: () => onSelectFillColor(c),
                  selectionColor: scheme.primary,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
