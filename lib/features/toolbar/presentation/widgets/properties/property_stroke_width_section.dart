import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_shared_widgets.dart';

/// Section for selecting stroke thickness presets.
class PropertyStrokeWidthSection extends StatelessWidget {
  final double activeStrokeWidth;
  final void Function(double width) onSelectStrokeWidth;

  const PropertyStrokeWidthSection({
    super.key,
    required this.activeStrokeWidth,
    required this.onSelectStrokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stroke Thickness',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            for (final preset in StrokeWidthPreset.values) ...[
              propertyStrokeWidthOption(
                preset,
                activeStrokeWidth,
                onSelectStrokeWidth,
                scheme,
              ),
              if (preset != StrokeWidthPreset.values.last)
                const SizedBox(width: 3),
            ],
          ],
        ),
      ],
    );
  }
}
