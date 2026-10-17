import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_shared_widgets.dart';

/// Section for selecting stroke patterns (solid, dashed, dotted).
class PropertyStrokeStyleSection extends StatelessWidget {
  final StrokeStyle activeStrokeStyle;
  final void Function(StrokeStyle style) onSelectStrokeStyle;

  const PropertyStrokeStyleSection({
    super.key,
    required this.activeStrokeStyle,
    required this.onSelectStrokeStyle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stroke Pattern',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            propertyStrokeStyleOption(
              StrokeStyle.solid,
              Icons.horizontal_rule,
              activeStrokeStyle,
              onSelectStrokeStyle,
              scheme,
            ),
            const SizedBox(width: 3),
            propertyStrokeStyleOption(
              StrokeStyle.dashed,
              Icons.more_horiz,
              activeStrokeStyle,
              onSelectStrokeStyle,
              scheme,
            ),
            const SizedBox(width: 3),
            propertyStrokeStyleOption(
              StrokeStyle.dotted,
              Icons.grain,
              activeStrokeStyle,
              onSelectStrokeStyle,
              scheme,
            ),
          ],
        ),
      ],
    );
  }
}
