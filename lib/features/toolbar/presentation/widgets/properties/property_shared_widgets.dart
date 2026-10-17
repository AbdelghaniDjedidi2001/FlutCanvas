import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';

/// Reusable action icon button for arrangement & quick actions.
Widget propertyActionButton({
  required IconData icon,
  required String tooltip,
  required VoidCallback onTap,
  required ColorScheme scheme,
  Color? color,
}) {
  return Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: color ?? scheme.onSurfaceVariant),
      ),
    ),
  );
}

/// Circular color selector bubble.
Widget propertyColorBubble({
  required Color color,
  required bool isSelected,
  required VoidCallback onTap,
  required Color selectionColor,
}) {
  return GestureDetector(
    onTap: onTap,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: 17,
        height: 17,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? selectionColor : Colors.grey.shade400,
            width: isSelected ? 2.5 : 1.0,
          ),
        ),
      ),
    ),
  );
}

/// Segmented option pill.
Widget propertySegmentedOption<T>({
  required String label,
  required T value,
  required T groupValue,
  required void Function(T value) onSelect,
  required ColorScheme scheme,
}) {
  final isSelected = value == groupValue;
  return Expanded(
    child: InkWell(
      onTap: () => onSelect(value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.6)
                : scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
        ),
      ),
    ),
  );
}

/// Preset option for stroke width.
Widget propertyStrokeWidthOption(
  StrokeWidthPreset preset,
  double currentWidth,
  void Function(double w) onSelect,
  ColorScheme scheme,
) {
  final isSelected = (currentWidth - preset.width).abs() < 0.2;
  return Expanded(
    child: InkWell(
      onTap: () => onSelect(preset.width),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.6)
                : scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Container(
          width: 14,
          height: preset.width,
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary : Colors.grey,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    ),
  );
}

/// Option for stroke pattern (solid, dashed, dotted).
Widget propertyStrokeStyleOption(
  StrokeStyle style,
  IconData icon,
  StrokeStyle currentStyle,
  void Function(StrokeStyle s) onSelect,
  ColorScheme scheme,
) {
  final isSelected = currentStyle == style;
  return Expanded(
    child: InkWell(
      onTap: () => onSelect(style),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.6)
                : scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Icon(icon,
            size: 15, color: isSelected ? scheme.primary : Colors.grey),
      ),
    ),
  );
}

/// Option for connector routing (straight, orthogonal, curved).
Widget propertyConnectorStyleOption(
  ConnectorStyle style,
  IconData icon,
  String label,
  ConnectorStyle currentStyle,
  void Function(ConnectorStyle s) onSelect,
  ColorScheme scheme,
) {
  final isSelected = currentStyle == style;
  return Expanded(
    child: InkWell(
      onTap: () => onSelect(style),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.6)
                : scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 11,
              color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? scheme.onPrimaryContainer : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Preset option for font size.
Widget propertyFontSizeOption(
  FontSizePreset preset,
  double currentSize,
  void Function(double s) onSelect,
  ColorScheme scheme,
) {
  final isSelected = (currentSize - preset.size).abs() < 1.0;
  return Expanded(
    child: InkWell(
      onTap: () => onSelect(preset.size),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.6)
                : scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          preset.label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
        ),
      ),
    ),
  );
}
