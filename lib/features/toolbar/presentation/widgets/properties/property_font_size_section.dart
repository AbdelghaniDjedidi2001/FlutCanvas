import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_shared_widgets.dart';

/// Section for selecting font size presets (S, M, L, XL).
class PropertyFontSizeSection extends StatelessWidget {
  final double activeFontSize;
  final void Function(double size) onSelectFontSize;

  const PropertyFontSizeSection({
    super.key,
    required this.activeFontSize,
    required this.onSelectFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Font Size',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            for (final preset in FontSizePreset.values) ...[
              propertyFontSizeOption(
                preset,
                activeFontSize,
                onSelectFontSize,
                scheme,
              ),
              if (preset != FontSizePreset.values.last)
                const SizedBox(width: 3),
            ],
          ],
        ),
      ],
    );
  }
}
