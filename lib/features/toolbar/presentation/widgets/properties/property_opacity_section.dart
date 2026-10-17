import 'package:flutter/material.dart';

/// Section for adjusting element opacity via a slider.
class PropertyOpacitySection extends StatelessWidget {
  final double activeOpacity;
  final void Function(double opacity) onChangeOpacity;

  const PropertyOpacitySection({
    super.key,
    required this.activeOpacity,
    required this.onChangeOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Opacity',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '${(activeOpacity * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
          ),
          child: Slider(
            value: activeOpacity,
            min: 0.1,
            max: 1.0,
            onChanged: onChangeOpacity,
          ),
        ),
      ],
    );
  }
}
