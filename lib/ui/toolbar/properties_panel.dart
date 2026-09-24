import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../models/board_colors.dart';
import '../../models/board_element.dart';
import '../../models/stroke_fill_style.dart';

class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({
    super.key,
    required this.selectedElements,
    required this.currentColor,
    required this.currentFillColor,
    required this.currentStrokeWidth,
    required this.currentStrokeStyle,
    required this.currentFillStyle,
    required this.currentDrawStyle,
    required this.currentFontSize,
    required this.currentOpacity,
    required this.currentRotation,
    required this.onColorChanged,
    required this.onFillColorChanged,
    required this.onStrokeWidthChanged,
    required this.onStrokeStyleChanged,
    required this.onFillStyleChanged,
    required this.onDrawStyleChanged,
    required this.onFontSizeChanged,
    required this.onOpacityChanged,
    required this.onRotationChanged,
    required this.onGroup,
    required this.onUngroup,
    required this.onBringToFront,
    required this.onSendToBack,
    required this.onDuplicate,
    required this.onDelete,
    required this.onAlign,
    this.onClose,
  });

  final List<BoardElement> selectedElements;
  final Color currentColor;
  final Color currentFillColor;
  final double currentStrokeWidth;
  final StrokeStyle currentStrokeStyle;
  final FillStyle currentFillStyle;
  final DrawStyle currentDrawStyle;
  final double currentFontSize;
  final double currentOpacity;
  final double currentRotation;

  final void Function(Color color) onColorChanged;
  final void Function(Color color) onFillColorChanged;
  final void Function(double width) onStrokeWidthChanged;
  final void Function(StrokeStyle style) onStrokeStyleChanged;
  final void Function(FillStyle style) onFillStyleChanged;
  final void Function(DrawStyle style) onDrawStyleChanged;
  final void Function(double size) onFontSizeChanged;
  final void Function(double opacity) onOpacityChanged;
  final void Function(double radians) onRotationChanged;
  final VoidCallback onGroup;
  final VoidCallback onUngroup;
  final VoidCallback onBringToFront;
  final VoidCallback onSendToBack;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final void Function(String alignment) onAlign;
  final VoidCallback? onClose;

  bool get _hasGroupedElements =>
      selectedElements.any((e) => e.groupId != null);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = BoardColors.of(context);

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 5,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 224,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header / Selected count / Close
              Row(
                children: [
                  Icon(
                    selectedElements.isEmpty ? Icons.tune_rounded : Icons.edit_note_rounded,
                    size: 15,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    selectedElements.isEmpty
                        ? 'Style Settings'
                        : '${selectedElements.length} selected',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (selectedElements.isNotEmpty) ...[
                    IconButton(
                      tooltip: 'Duplicate (Ctrl+D)',
                      visualDensity: VisualDensity.compact,
                      iconSize: 15,
                      onPressed: onDuplicate,
                      icon: const Icon(Icons.copy_rounded),
                    ),
                    IconButton(
                      tooltip: 'Delete (Del)',
                      visualDensity: VisualDensity.compact,
                      iconSize: 15,
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                  ],
                  if (onClose != null)
                    IconButton(
                      tooltip: 'Close panel',
                      visualDensity: VisualDensity.compact,
                      iconSize: 15,
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              const Divider(height: 10),

              // 1. Draw Style (Clean vs Hand-drawn Sketch)
              const Text('Aesthetic Style', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Row(
                children: [
                  _segmentedOption<DrawStyle>(
                    label: 'Clean',
                    value: DrawStyle.clean,
                    groupValue: currentDrawStyle,
                    onSelect: onDrawStyleChanged,
                    scheme: scheme,
                  ),
                  const SizedBox(width: 4),
                  _segmentedOption<DrawStyle>(
                    label: '✏️ Sketchy',
                    value: DrawStyle.sketch,
                    groupValue: currentDrawStyle,
                    onSelect: onDrawStyleChanged,
                    scheme: scheme,
                  ),
                ],
              ),
              const SizedBox(height: 9),

              // 2. Stroke Color
              const Text('Stroke Color', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final c in BoardColors.strokePalette)
                    _colorBubble(
                      color: colors.display(c),
                      isSelected: currentColor == c,
                      onTap: () => onColorChanged(c),
                      selectionColor: scheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 9),

              // 3. Fill Style & Color
              const Text('Fill Style', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Row(
                children: [
                  _segmentedOption<FillStyle>(
                    label: 'None',
                    value: FillStyle.none,
                    groupValue: currentFillStyle,
                    onSelect: onFillStyleChanged,
                    scheme: scheme,
                  ),
                  const SizedBox(width: 3),
                  _segmentedOption<FillStyle>(
                    label: 'Semi',
                    value: FillStyle.semi,
                    groupValue: currentFillStyle,
                    onSelect: onFillStyleChanged,
                    scheme: scheme,
                  ),
                  const SizedBox(width: 3),
                  _segmentedOption<FillStyle>(
                    label: 'Solid',
                    value: FillStyle.solid,
                    groupValue: currentFillStyle,
                    onSelect: onFillStyleChanged,
                    scheme: scheme,
                  ),
                  const SizedBox(width: 3),
                  _segmentedOption<FillStyle>(
                    label: 'Hatch',
                    value: FillStyle.hatch,
                    groupValue: currentFillStyle,
                    onSelect: onFillStyleChanged,
                    scheme: scheme,
                  ),
                ],
              ),
              if (currentFillStyle != FillStyle.none) ...[
                const SizedBox(height: 5),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    for (final c in BoardColors.strokePalette)
                      _colorBubble(
                        color: colors.display(c),
                        isSelected: currentFillColor == c,
                        onTap: () => onFillColorChanged(c),
                        selectionColor: scheme.primary,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 9),

              // 4. Stroke Width & Style
              const Text('Stroke Width & Style', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Row(
                children: [
                  for (final p in StrokeWidthPreset.values) ...[
                    _strokeWidthOption(p, scheme),
                    if (p != StrokeWidthPreset.values.last) const SizedBox(width: 4),
                  ],
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  _strokeStyleOption(StrokeStyle.solid, Icons.remove, scheme),
                  const SizedBox(width: 4),
                  _strokeStyleOption(StrokeStyle.dashed, Icons.more_horiz, scheme),
                  const SizedBox(width: 4),
                  _strokeStyleOption(StrokeStyle.dotted, Icons.grain, scheme),
                ],
              ),
              const SizedBox(height: 9),

              // 5. Text Size
              const Text('Font Size', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Row(
                children: [
                  for (final p in FontSizePreset.values) ...[
                    Expanded(
                      child: InkWell(
                        onTap: () => onFontSizeChanged(p.size),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: (currentFontSize - p.size).abs() < 2
                                ? scheme.primaryContainer
                                : scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: (currentFontSize - p.size).abs() < 2
                                  ? scheme.primary.withValues(alpha: 0.5)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            p.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: (currentFontSize - p.size).abs() < 2
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (p != FontSizePreset.values.last) const SizedBox(width: 4),
                  ],
                ],
              ),
              const SizedBox(height: 9),

              // 6. Rotation Slider
              Row(
                children: [
                  const Text('Rotation', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${((currentRotation * 180 / math.pi).round() % 360)}°', style: const TextStyle(fontSize: 11)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.5,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                ),
                child: Slider(
                  value: (currentRotation % (2 * math.pi)),
                  min: 0.0,
                  max: 2 * math.pi,
                  onChanged: onRotationChanged,
                ),
              ),

              // 7. Opacity Slider
              Row(
                children: [
                  const Text('Opacity', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${(currentOpacity * 100).round()}%', style: const TextStyle(fontSize: 11)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.5,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                ),
                child: Slider(
                  value: currentOpacity,
                  min: 0.1,
                  max: 1.0,
                  onChanged: onOpacityChanged,
                ),
              ),

              // 8. Grouping & Alignment (when selected)
              if (selectedElements.isNotEmpty) ...[
                const Divider(height: 8),
                const Text('Group & Arrange', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onPressed: selectedElements.length > 1 ? onGroup : null,
                        icon: const Icon(Icons.group_work_outlined, size: 13),
                        label: const Text('Group', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    if (_hasGroupedElements) ...[
                      const SizedBox(width: 4),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          onPressed: onUngroup,
                          icon: const Icon(Icons.workspaces_outline, size: 13),
                          label: const Text('Ungroup', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Bring to Front',
                      visualDensity: VisualDensity.compact,
                      iconSize: 16,
                      onPressed: onBringToFront,
                      icon: const Icon(Icons.flip_to_front),
                    ),
                    IconButton(
                      tooltip: 'Send to Back',
                      visualDensity: VisualDensity.compact,
                      iconSize: 16,
                      onPressed: onSendToBack,
                      icon: const Icon(Icons.flip_to_back),
                    ),
                    IconButton(
                      tooltip: 'Align Left',
                      visualDensity: VisualDensity.compact,
                      iconSize: 16,
                      onPressed: () => onAlign('left'),
                      icon: const Icon(Icons.align_horizontal_left),
                    ),
                    IconButton(
                      tooltip: 'Align Center',
                      visualDensity: VisualDensity.compact,
                      iconSize: 16,
                      onPressed: () => onAlign('center'),
                      icon: const Icon(Icons.align_horizontal_center),
                    ),
                    IconButton(
                      tooltip: 'Align Right',
                      visualDensity: VisualDensity.compact,
                      iconSize: 16,
                      onPressed: () => onAlign('right'),
                      icon: const Icon(Icons.align_horizontal_right),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorBubble({
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
              color: isSelected ? selectionColor : Colors.black26,
              width: isSelected ? 2.5 : 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _segmentedOption<T>({
    required String label,
    required T value,
    required T groupValue,
    required void Function(T val) onSelect,
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
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? scheme.onPrimaryContainer : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _strokeWidthOption(StrokeWidthPreset preset, ColorScheme scheme) {
    final isSelected = (currentStrokeWidth - preset.width).abs() < 0.2;
    return Expanded(
      child: InkWell(
        onTap: () => onStrokeWidthChanged(preset.width),
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

  Widget _strokeStyleOption(StrokeStyle style, IconData icon, ColorScheme scheme) {
    final isSelected = currentStrokeStyle == style;
    return Expanded(
      child: InkWell(
        onTap: () => onStrokeStyleChanged(style),
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
          child: Icon(icon, size: 15, color: isSelected ? scheme.primary : Colors.grey),
        ),
      ),
    );
  }
}
