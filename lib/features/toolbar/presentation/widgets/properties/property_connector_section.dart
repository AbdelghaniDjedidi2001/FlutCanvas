import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_shared_widgets.dart';

/// Section for configuring connector routes and labels.
class PropertyConnectorSection extends StatelessWidget {
  final ConnectorStyle activeConnectorStyle;
  final void Function(ConnectorStyle style) onSelectConnectorStyle;
  final VoidCallback? onEditConnectorLabel;

  const PropertyConnectorSection({
    super.key,
    required this.activeConnectorStyle,
    required this.onSelectConnectorStyle,
    this.onEditConnectorLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connector Route',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            propertyConnectorStyleOption(
              ConnectorStyle.straight,
              Icons.linear_scale,
              'Line',
              activeConnectorStyle,
              onSelectConnectorStyle,
              scheme,
            ),
            const SizedBox(width: 3),
            propertyConnectorStyleOption(
              ConnectorStyle.orthogonal,
              Icons.timeline,
              'Elbow',
              activeConnectorStyle,
              onSelectConnectorStyle,
              scheme,
            ),
            const SizedBox(width: 3),
            propertyConnectorStyleOption(
              ConnectorStyle.curved,
              Icons.show_chart,
              'Curve',
              activeConnectorStyle,
              onSelectConnectorStyle,
              scheme,
            ),
          ],
        ),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            minimumSize: const Size.fromHeight(26),
          ),
          onPressed: onEditConnectorLabel,
          icon: const Icon(Icons.label_outline_rounded, size: 13),
          label: const Text(
            'Add / Edit Line Label',
            style: TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}
