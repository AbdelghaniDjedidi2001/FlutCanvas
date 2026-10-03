import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../models/board_colors.dart';
import '../../models/board_element.dart';
import '../../models/connector_style.dart';
import '../../models/shape_type.dart';
import '../../models/stroke_fill_style.dart';
import '../../services/syntax_highlighter_service.dart';

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
    this.currentConnectorStyle = ConnectorStyle.straight,
    this.currentCodeLanguage,
    this.currentShowLineNumbers = true,
    required this.onColorChanged,
    required this.onFillColorChanged,
    required this.onStrokeWidthChanged,
    required this.onStrokeStyleChanged,
    required this.onFillStyleChanged,
    required this.onDrawStyleChanged,
    required this.onFontSizeChanged,
    required this.onOpacityChanged,
    required this.onRotationChanged,
    required this.onConnectorStyleChanged,
    required this.onEditConnectorLabel,
    this.onCodeLanguageChanged,
    this.onToggleLineNumbers,
    this.onCopyCode,
    this.onAddTableRow,
    this.onRemoveTableRow,
    this.onAddTableColumn,
    this.onRemoveTableColumn,
    this.onToggleTableHeader,
    required this.onGroup,
    required this.onUngroup,
    required this.onBringToFront,
    required this.onSendToBack,
    required this.onDuplicate,
    required this.onDelete,
    required this.onAlign,
    required this.onDistribute,
    required this.onToggleLock,
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
  final ConnectorStyle currentConnectorStyle;
  final String? currentCodeLanguage;
  final bool currentShowLineNumbers;

  final void Function(Color color) onColorChanged;
  final void Function(Color color) onFillColorChanged;
  final void Function(double width) onStrokeWidthChanged;
  final void Function(StrokeStyle style) onStrokeStyleChanged;
  final void Function(FillStyle style) onFillStyleChanged;
  final void Function(DrawStyle style) onDrawStyleChanged;
  final void Function(double size) onFontSizeChanged;
  final void Function(double opacity) onOpacityChanged;
  final void Function(double radians) onRotationChanged;
  final void Function(ConnectorStyle style) onConnectorStyleChanged;
  final VoidCallback onEditConnectorLabel;
  final void Function(String language)? onCodeLanguageChanged;
  final void Function(bool showNumbers)? onToggleLineNumbers;
  final VoidCallback? onCopyCode;
  final VoidCallback? onAddTableRow;
  final VoidCallback? onRemoveTableRow;
  final VoidCallback? onAddTableColumn;
  final VoidCallback? onRemoveTableColumn;
  final void Function(bool hasHeader)? onToggleTableHeader;
  final VoidCallback onGroup;
  final VoidCallback onUngroup;
  final VoidCallback onBringToFront;
  final VoidCallback onSendToBack;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final void Function(String alignment) onAlign;
  final void Function(String direction) onDistribute;
  final VoidCallback onToggleLock;
  final VoidCallback? onClose;

  bool get _hasConnectors => selectedElements.isEmpty ||
      selectedElements.any((e) =>
          e.type == ShapeType.line ||
          e.type == ShapeType.arrow ||
          e.type == ShapeType.doubleArrow);

  bool get _hasCodeBlock =>
      selectedElements.any((e) => e.type == ShapeType.codeBlock);

  bool get _hasTable =>
      selectedElements.any((e) => e.type == ShapeType.table);

  BoardElement? get _firstTable =>
      selectedElements.where((e) => e.type == ShapeType.table).firstOrNull;

  bool get _hasMarkdownText => selectedElements.any(
      (e) => e.type == ShapeType.stickyNote || e.type == ShapeType.text);

  bool get _hasGroupedElements =>
      selectedElements.any((e) => e.groupId != null);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = BoardColors.of(context);
    final mqHeight = MediaQuery.of(context).size.height;

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 5,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 224,
        constraints: BoxConstraints(
          maxHeight: math.max(200.0, mqHeight - 80),
        ),
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
                  Expanded(
                    child: Text(
                      selectedElements.isEmpty
                          ? 'Style Settings'
                          : '${selectedElements.length} selected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selectedElements.isNotEmpty) ...[
                    IconButton(
                      tooltip: 'Duplicate (Ctrl+D)',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      iconSize: 15,
                      onPressed: onDuplicate,
                      icon: const Icon(Icons.copy_rounded),
                    ),
                    const SizedBox(width: 2),
                    IconButton(
                      tooltip: 'Delete (Del)',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      iconSize: 15,
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                  ],
                  if (onClose != null) ...[
                    const SizedBox(width: 2),
                    IconButton(
                      tooltip: 'Close panel',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      iconSize: 15,
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
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

              // 4.5 Connector Routing (when connectors are present/selected)
              if (_hasConnectors) ...[
                const Text('Connector Routing', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _connectorStyleOption(ConnectorStyle.straight, Icons.straighten_rounded, 'Straight', scheme),
                    const SizedBox(width: 4),
                    _connectorStyleOption(ConnectorStyle.orthogonal, Icons.call_split_rounded, 'Elbow', scheme),
                    const SizedBox(width: 4),
                    _connectorStyleOption(ConnectorStyle.curved, Icons.gesture_rounded, 'Curved', scheme),
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
                  label: const Text('Add / Edit Line Label', style: TextStyle(fontSize: 11)),
                ),
                const SizedBox(height: 9),
              ],

              // 4.6 Code Block Settings (when code blocks are present/selected)
              if (_hasCodeBlock) ...[
                const Text('Code Block Settings', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentCodeLanguage ?? 'dart',
                      isDense: true,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      style: TextStyle(fontSize: 12, color: scheme.onSurface, fontWeight: FontWeight.w600),
                      items: [
                        for (final lang in SyntaxHighlighterService.supportedLanguages)
                          DropdownMenuItem(
                            value: lang,
                            child: Text(SyntaxHighlighterService.getDisplayName(lang)),
                          ),
                      ],
                      onChanged: (val) {
                        if (val != null && onCodeLanguageChanged != null) {
                          onCodeLanguageChanged!(val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          backgroundColor: currentShowLineNumbers ? scheme.primaryContainer.withValues(alpha: 0.5) : null,
                        ),
                        onPressed: () {
                          if (onToggleLineNumbers != null) {
                            onToggleLineNumbers!(!currentShowLineNumbers);
                          }
                        },
                        icon: Icon(
                          Icons.format_list_numbered_rounded,
                          size: 13,
                          color: currentShowLineNumbers ? scheme.primary : null,
                        ),
                        label: Text(
                          currentShowLineNumbers ? 'Line # On' : 'Line # Off',
                          style: TextStyle(fontSize: 11, color: currentShowLineNumbers ? scheme.primary : null),
                        ),
                      ),
                    ),
                    if (onCopyCode != null) ...[
                      const SizedBox(width: 4),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          onPressed: onCopyCode,
                          icon: const Icon(Icons.copy_rounded, size: 13),
                          label: const Text('Copy', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 9),
              ],

              // 4.65 Table Controls (when Table elements are selected)
              if (_hasTable) ...[
                const Text('Table Grid Controls', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onPressed: onAddTableRow,
                        icon: const Icon(Icons.add, size: 13),
                        label: const Text('+ Row', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onPressed: onRemoveTableRow,
                        icon: const Icon(Icons.remove, size: 13),
                        label: const Text('- Row', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onPressed: onAddTableColumn,
                        icon: const Icon(Icons.add, size: 13),
                        label: const Text('+ Col', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onPressed: onRemoveTableColumn,
                        icon: const Icon(Icons.remove, size: 13),
                        label: const Text('- Col', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (_firstTable != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        backgroundColor: _firstTable!.tableHasHeader
                            ? scheme.primaryContainer.withValues(alpha: 0.5)
                            : null,
                      ),
                      onPressed: () {
                        if (onToggleTableHeader != null) {
                          onToggleTableHeader!(!_firstTable!.tableHasHeader);
                        }
                      },
                      icon: Icon(
                        Icons.view_headline_rounded,
                        size: 13,
                        color: _firstTable!.tableHasHeader ? scheme.primary : null,
                      ),
                      label: Text(
                        _firstTable!.tableHasHeader ? 'Header Row: ON' : 'Header Row: OFF',
                        style: TextStyle(
                          fontSize: 11,
                          color: _firstTable!.tableHasHeader ? scheme.primary : null,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 9),
              ],

              // 4.7 Markdown Tips (when sticky notes / text elements are selected)
              if (_hasMarkdownText) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.text_fields_rounded, size: 12, color: scheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Markdown Supported',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '**bold** *italic* `code` # H1 - list',
                        style: TextStyle(fontSize: 9.5, color: scheme.onSurfaceVariant.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ],

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
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onPressed: onBringToFront,
                        icon: const Icon(Icons.flip_to_front, size: 13),
                        label: const Text('Front', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onPressed: onSendToBack,
                        icon: const Icon(Icons.flip_to_back, size: 13),
                        label: const Text('Back', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onPressed: onToggleLock,
                        icon: Icon(
                          selectedElements.any((e) => e.isLocked)
                              ? Icons.lock_open_rounded
                              : Icons.lock_outline_rounded,
                          size: 13,
                        ),
                        label: Text(
                          selectedElements.any((e) => e.isLocked)
                              ? 'Unlock (Ctrl+L)'
                              : 'Lock (Ctrl+L)',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
                if (selectedElements.length >= 2) ...[
                  const SizedBox(height: 8),
                  const Text('Align & Distribute', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                      IconButton(
                        tooltip: selectedElements.length >= 3
                            ? 'Distribute Horizontally'
                            : 'Distribute Horizontally (select 3+)',
                        visualDensity: VisualDensity.compact,
                        iconSize: 16,
                        onPressed: selectedElements.length >= 3
                            ? () => onDistribute('horizontal')
                            : null,
                        icon: const Icon(Icons.horizontal_distribute),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        tooltip: 'Align Top',
                        visualDensity: VisualDensity.compact,
                        iconSize: 16,
                        onPressed: () => onAlign('top'),
                        icon: const Icon(Icons.align_vertical_top),
                      ),
                      IconButton(
                        tooltip: 'Align Middle',
                        visualDensity: VisualDensity.compact,
                        iconSize: 16,
                        onPressed: () => onAlign('middle'),
                        icon: const Icon(Icons.align_vertical_center),
                      ),
                      IconButton(
                        tooltip: 'Align Bottom',
                        visualDensity: VisualDensity.compact,
                        iconSize: 16,
                        onPressed: () => onAlign('bottom'),
                        icon: const Icon(Icons.align_vertical_bottom),
                      ),
                      IconButton(
                        tooltip: selectedElements.length >= 3
                            ? 'Distribute Vertically'
                            : 'Distribute Vertically (select 3+)',
                        visualDensity: VisualDensity.compact,
                        iconSize: 16,
                        onPressed: selectedElements.length >= 3
                            ? () => onDistribute('vertical')
                            : null,
                        icon: const Icon(Icons.vertical_distribute),
                      ),
                    ],
                  ),
                ],
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

  Widget _connectorStyleOption(
    ConnectorStyle style,
    IconData icon,
    String label,
    ColorScheme scheme,
  ) {
    final isSelected = currentConnectorStyle == style;
    return Expanded(
      child: InkWell(
        onTap: () => onConnectorStyleChanged(style),
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
}
