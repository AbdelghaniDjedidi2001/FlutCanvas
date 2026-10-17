import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_shared_widgets.dart';

/// Section for switching between clean and hand-drawn sketch styles.
class PropertyDrawStyleSection extends StatelessWidget {
  final DrawStyle activeDrawStyle;
  final void Function(DrawStyle style) onSelectDrawStyle;

  const PropertyDrawStyleSection({
    super.key,
    required this.activeDrawStyle,
    required this.onSelectDrawStyle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aesthetic Style',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            propertySegmentedOption<DrawStyle>(
              label: 'Clean',
              value: DrawStyle.clean,
              groupValue: activeDrawStyle,
              onSelect: onSelectDrawStyle,
              scheme: scheme,
            ),
            const SizedBox(width: 4),
            propertySegmentedOption<DrawStyle>(
              label: '✏️ Sketchy',
              value: DrawStyle.sketch,
              groupValue: activeDrawStyle,
              onSelect: onSelectDrawStyle,
              scheme: scheme,
            ),
          ],
        ),
      ],
    );
  }
}
