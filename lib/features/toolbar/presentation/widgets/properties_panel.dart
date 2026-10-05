import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/canvas/data/services/alignment_service.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_state.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_state.dart';
import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';

class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({
    super.key,
    this.selectedElements,
    this.currentColor,
    this.currentFillColor,
    this.currentStrokeWidth,
    this.currentStrokeStyle,
    this.currentFillStyle,
    this.currentDrawStyle,
    this.currentFontSize,
    this.currentOpacity,
    this.currentRotation,
    this.currentConnectorStyle,
    this.currentCodeLanguage,
    this.currentShowLineNumbers,
    this.onColorChanged,
    this.onFillColorChanged,
    this.onStrokeWidthChanged,
    this.onStrokeStyleChanged,
    this.onFillStyleChanged,
    this.onDrawStyleChanged,
    this.onFontSizeChanged,
    this.onOpacityChanged,
    this.onRotationChanged,
    this.onConnectorStyleChanged,
    this.onEditConnectorLabel,
    this.onCodeLanguageChanged,
    this.onToggleLineNumbers,
    this.onCopyCode,
    this.onAddTableRow,
    this.onRemoveTableRow,
    this.onAddTableColumn,
    this.onRemoveTableColumn,
    this.onToggleTableHeader,
    this.onGroup,
    this.onUngroup,
    this.onBringToFront,
    this.onSendToBack,
    this.onDuplicate,
    this.onDelete,
    this.onAlign,
    this.onDistribute,
    this.onToggleLock,
    this.onClose,
  });

  final List<BoardElement>? selectedElements;
  final Color? currentColor;
  final Color? currentFillColor;
  final double? currentStrokeWidth;
  final StrokeStyle? currentStrokeStyle;
  final FillStyle? currentFillStyle;
  final DrawStyle? currentDrawStyle;
  final double? currentFontSize;
  final double? currentOpacity;
  final double? currentRotation;
  final ConnectorStyle? currentConnectorStyle;
  final String? currentCodeLanguage;
  final bool? currentShowLineNumbers;

  final void Function(Color color)? onColorChanged;
  final void Function(Color color)? onFillColorChanged;
  final void Function(double width)? onStrokeWidthChanged;
  final void Function(StrokeStyle style)? onStrokeStyleChanged;
  final void Function(FillStyle style)? onFillStyleChanged;
  final void Function(DrawStyle style)? onDrawStyleChanged;
  final void Function(double size)? onFontSizeChanged;
  final void Function(double opacity)? onOpacityChanged;
  final void Function(double radians)? onRotationChanged;
  final void Function(ConnectorStyle style)? onConnectorStyleChanged;
  final VoidCallback? onEditConnectorLabel;
  final void Function(String language)? onCodeLanguageChanged;
  final void Function(bool showNumbers)? onToggleLineNumbers;
  final VoidCallback? onCopyCode;
  final VoidCallback? onAddTableRow;
  final VoidCallback? onRemoveTableRow;
  final VoidCallback? onAddTableColumn;
  final VoidCallback? onRemoveTableColumn;
  final void Function(bool hasHeader)? onToggleTableHeader;
  final VoidCallback? onGroup;
  final VoidCallback? onUngroup;
  final VoidCallback? onBringToFront;
  final VoidCallback? onSendToBack;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final void Function(String alignment)? onAlign;
  final void Function(String direction)? onDistribute;
  final VoidCallback? onToggleLock;
  final VoidCallback? onClose;

  bool _hasConnectors(List<BoardElement> list) =>
      list.isEmpty ||
      list.any((e) =>
          e.type == ShapeType.line ||
          e.type == ShapeType.arrow ||
          e.type == ShapeType.doubleArrow);

  bool _hasTable(List<BoardElement> list) =>
      list.any((e) => e.type == ShapeType.table);

  BoardElement? _firstTable(List<BoardElement> list) =>
      list.where((e) => e.type == ShapeType.table).firstOrNull;

  bool _hasGroupedElements(List<BoardElement> list) =>
      list.any((e) => e.groupId != null);

  @override
  Widget build(BuildContext context) {
    final toolCubit = context.watch<ToolCubit?>();
    final canvasBloc = context.watch<CanvasBloc?>();

    final toolState = toolCubit?.state ?? const ToolState();
    final canvasState = canvasBloc?.state ?? const CanvasState();

    final activeSelectedElements =
        selectedElements ?? canvasState.selectedElements;
    final activeColor = currentColor ?? toolState.strokeColor;
    final activeFillColor = currentFillColor ?? toolState.fillColor;
    final activeStrokeWidth = currentStrokeWidth ?? toolState.strokeWidth;
    final activeStrokeStyle = currentStrokeStyle ?? toolState.strokeStyle;
    final activeFillStyle = currentFillStyle ?? toolState.fillStyle;
    final activeDrawStyle = currentDrawStyle ?? toolState.drawStyle;
    final activeFontSize = currentFontSize ?? toolState.fontSize;
    final activeOpacity = currentOpacity ?? toolState.opacity;
    final activeConnectorStyle =
        currentConnectorStyle ?? toolState.connectorStyle;

    final scheme = Theme.of(context).colorScheme;
    final colors = BoardColors.of(context);
    final mqHeight = MediaQuery.of(context).size.height;

    final hasConn = _hasConnectors(activeSelectedElements);
    final hasTbl = _hasTable(activeSelectedElements);
    final tblEl = _firstTable(activeSelectedElements);
    final hasGrouped = _hasGroupedElements(activeSelectedElements);

    final isHighlighterTarget = (activeSelectedElements.isNotEmpty &&
            activeSelectedElements.every((e) => e.type == ShapeType.highlighter)) ||
        (activeSelectedElements.isEmpty &&
            toolState.currentTool == Tool.highlighter);
    final strokeColorPalette = isHighlighterTarget
        ? BoardColors.highlighterPalette
        : BoardColors.strokePalette;

    void applyColor(Color c) {
      if (onColorChanged != null) {
        onColorChanged!(c);
      } else {
        toolCubit?.setStrokeColor(c);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements) el.copyWith(color: c)
          ];
          canvasBloc.add(CanvasEvent.updateElements(updated));
        }
      }
    }

    void applyFillColor(Color c) {
      if (onFillColorChanged != null) {
        onFillColorChanged!(c);
      } else {
        toolCubit?.setFillColor(c);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements) el.copyWith(fillColor: c)
          ];
          canvasBloc.add(CanvasEvent.updateElements(updated));
        }
      }
    }

    void applyStrokeWidth(double w) {
      if (onStrokeWidthChanged != null) {
        onStrokeWidthChanged!(w);
      } else {
        toolCubit?.setStrokeWidth(w);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements)
              el.copyWith(strokeWidth: w)
          ];
          canvasBloc.add(CanvasEvent.updateElements(updated));
        }
      }
    }

    void applyStrokeStyle(StrokeStyle s) {
      if (onStrokeStyleChanged != null) {
        onStrokeStyleChanged!(s);
      } else {
        toolCubit?.setStrokeStyle(s);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements)
              el.copyWith(strokeStyle: s)
          ];
          canvasBloc.add(CanvasEvent.updateElements(updated));
        }
      }
    }

    void applyFillStyle(FillStyle f) {
      if (onFillStyleChanged != null) {
        onFillStyleChanged!(f);
      } else {
        toolCubit?.setFillStyle(f);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements) el.copyWith(fillStyle: f)
          ];
          canvasBloc.add(CanvasEvent.updateElements(updated));
        }
      }
    }

    void applyDrawStyle(DrawStyle d) {
      if (onDrawStyleChanged != null) {
        onDrawStyleChanged!(d);
      } else {
        toolCubit?.setDrawStyle(d);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements) el.copyWith(drawStyle: d)
          ];
          canvasBloc.add(CanvasEvent.updateElements(updated));
        }
      }
    }

    void applyFontSize(double s) {
      if (onFontSizeChanged != null) {
        onFontSizeChanged!(s);
      } else {
        toolCubit?.setFontSize(s);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements) el.copyWith(fontSize: s)
          ];
          canvasBloc.add(CanvasEvent.updateElements(updated));
        }
      }
    }

    void applyOpacity(double o) {
      if (onOpacityChanged != null) {
        onOpacityChanged!(o);
      } else {
        toolCubit?.setOpacity(o);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements) el.copyWith(opacity: o)
          ];
          canvasBloc.add(CanvasEvent.updateElements(updated));
        }
      }
    }


    void applyConnectorStyle(ConnectorStyle s) {
      if (onConnectorStyleChanged != null) {
        onConnectorStyleChanged!(s);
      } else {
        toolCubit?.setConnectorStyle(s);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements)
              el.copyWith(connectorStyle: s)
          ];
          canvasBloc.add(CanvasEvent.updateElements(updated));
        }
      }
    }

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
                    activeSelectedElements.isEmpty
                        ? Icons.tune_rounded
                        : Icons.edit_note_rounded,
                    size: 15,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      activeSelectedElements.isEmpty
                          ? 'Default Style'
                          : '${activeSelectedElements.length} selected',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  if (onClose != null || toolCubit != null)
                    InkWell(
                      onTap: onClose ??
                          () => toolCubit?.setPropertiesOpen(false),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
              const Divider(height: 10),

              // 1. Draw Style (Clean vs Hand-drawn Sketch)
              const Text('Aesthetic Style',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Row(
                children: [
                  _segmentedOption<DrawStyle>(
                    label: 'Clean',
                    value: DrawStyle.clean,
                    groupValue: activeDrawStyle,
                    onSelect: applyDrawStyle,
                    scheme: scheme,
                  ),
                  const SizedBox(width: 4),
                  _segmentedOption<DrawStyle>(
                    label: '✏️ Sketchy',
                    value: DrawStyle.sketch,
                    groupValue: activeDrawStyle,
                    onSelect: applyDrawStyle,
                    scheme: scheme,
                  ),
                ],
              ),
              const SizedBox(height: 9),

              // 2. Stroke Color
              Text(isHighlighterTarget ? 'Highlighter Color' : 'Stroke Color',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final c in strokeColorPalette)
                    _colorBubble(
                      color: isHighlighterTarget
                          ? colors.displayHighlighter(c)
                          : colors.display(c),
                      isSelected: activeColor == c,
                      onTap: () => applyColor(c),
                      selectionColor: scheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 9),

              // 3. Fill Style & Color
              const Text('Fill Style',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Row(
                children: [
                  _segmentedOption<FillStyle>(
                    label: 'None',
                    value: FillStyle.none,
                    groupValue: activeFillStyle,
                    onSelect: applyFillStyle,
                    scheme: scheme,
                  ),
                  const SizedBox(width: 3),
                  _segmentedOption<FillStyle>(
                    label: 'Semi',
                    value: FillStyle.semi,
                    groupValue: activeFillStyle,
                    onSelect: applyFillStyle,
                    scheme: scheme,
                  ),
                  const SizedBox(width: 3),
                  _segmentedOption<FillStyle>(
                    label: 'Solid',
                    value: FillStyle.solid,
                    groupValue: activeFillStyle,
                    onSelect: applyFillStyle,
                    scheme: scheme,
                  ),
                  const SizedBox(width: 3),
                  _segmentedOption<FillStyle>(
                    label: 'Hatch',
                    value: FillStyle.hatch,
                    groupValue: activeFillStyle,
                    onSelect: applyFillStyle,
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
                      _colorBubble(
                        color: colors.display(c),
                        isSelected: activeFillColor == c,
                        onTap: () => applyFillColor(c),
                        selectionColor: scheme.primary,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 9),

              // 4. Stroke Width
              const Text('Stroke Thickness',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Row(
                children: [
                  for (final preset in StrokeWidthPreset.values) ...[
                    _strokeWidthOption(
                        preset, activeStrokeWidth, applyStrokeWidth, scheme),
                    if (preset != StrokeWidthPreset.values.last)
                      const SizedBox(width: 3),
                  ],
                ],
              ),
              const SizedBox(height: 9),

              // 5. Stroke Style
              const Text('Stroke Pattern',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Row(
                children: [
                  _strokeStyleOption(StrokeStyle.solid, Icons.horizontal_rule,
                      activeStrokeStyle, applyStrokeStyle, scheme),
                  const SizedBox(width: 3),
                  _strokeStyleOption(StrokeStyle.dashed, Icons.more_horiz,
                      activeStrokeStyle, applyStrokeStyle, scheme),
                  const SizedBox(width: 3),
                  _strokeStyleOption(StrokeStyle.dotted, Icons.grain,
                      activeStrokeStyle, applyStrokeStyle, scheme),
                ],
              ),
              const SizedBox(height: 9),

              // 6. Connectors section
              if (hasConn) ...[
                const Text('Connector Route',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _connectorStyleOption(
                      ConnectorStyle.straight,
                      Icons.linear_scale,
                      'Line',
                      activeConnectorStyle,
                      applyConnectorStyle,
                      scheme,
                    ),
                    const SizedBox(width: 3),
                    _connectorStyleOption(
                      ConnectorStyle.orthogonal,
                      Icons.timeline,
                      'Elbow',
                      activeConnectorStyle,
                      applyConnectorStyle,
                      scheme,
                    ),
                    const SizedBox(width: 3),
                    _connectorStyleOption(
                      ConnectorStyle.curved,
                      Icons.show_chart,
                      'Curve',
                      activeConnectorStyle,
                      applyConnectorStyle,
                      scheme,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    minimumSize: const Size.fromHeight(26),
                  ),
                  onPressed: onEditConnectorLabel,
                  icon: const Icon(Icons.label_outline_rounded, size: 13),
                  label: const Text('Add / Edit Line Label',
                      style: TextStyle(fontSize: 11)),
                ),
                const SizedBox(height: 9),
              ],

              // 7. Table Controls
              if (hasTbl && tblEl != null) ...[
                const Text('Table Grid Controls',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: onAddTableRow ??
                                  () {
                                    if (canvasBloc != null) {
                                      final updated = tblEl.addTableRow();
                                      canvasBloc.add(
                                          CanvasEvent.updateElement(updated));
                                    }
                                  },
                              icon: const Icon(Icons.add, size: 13),
                              label: const Text('+ Row',
                                  style: TextStyle(fontSize: 10)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: onRemoveTableRow ??
                                  () {
                                    if (canvasBloc != null) {
                                      final updated = tblEl.removeTableRow();
                                      canvasBloc.add(
                                          CanvasEvent.updateElement(updated));
                                    }
                                  },
                              icon: const Icon(Icons.remove, size: 13),
                              label: const Text('- Row',
                                  style: TextStyle(fontSize: 10)),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: onAddTableColumn ??
                                  () {
                                    if (canvasBloc != null) {
                                      final updated = tblEl.addTableColumn();
                                      canvasBloc.add(
                                          CanvasEvent.updateElement(updated));
                                    }
                                  },
                              icon: const Icon(Icons.add, size: 13),
                              label: const Text('+ Col',
                                  style: TextStyle(fontSize: 10)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: onRemoveTableColumn ??
                                  () {
                                    if (canvasBloc != null) {
                                      final updated =
                                          tblEl.removeTableColumn();
                                      canvasBloc.add(
                                          CanvasEvent.updateElement(updated));
                                    }
                                  },
                              icon: const Icon(Icons.remove, size: 13),
                              label: const Text('- Col',
                                  style: TextStyle(fontSize: 10)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () {
                            if (onToggleTableHeader != null) {
                              onToggleTableHeader!(!tblEl.tableHasHeader);
                            } else if (canvasBloc != null) {
                              final updated = tblEl.copyWith(
                                tableHasHeader: !tblEl.tableHasHeader,
                              );
                              canvasBloc
                                  .add(CanvasEvent.updateElement(updated));
                            }
                          },
                          icon: Icon(
                            tblEl.tableHasHeader
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 13,
                          ),
                          label: Text(
                            tblEl.tableHasHeader
                                ? 'Header Row: ON'
                                : 'Header Row: OFF',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
              ],

              // 8. Typography
              const Text('Font Size',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Row(
                children: [
                  for (final preset in FontSizePreset.values) ...[
                    _fontSizeOption(
                        preset, activeFontSize, applyFontSize, scheme),
                    if (preset != FontSizePreset.values.last)
                      const SizedBox(width: 3),
                  ],
                ],
              ),
              const SizedBox(height: 9),

              // 9. Opacity Slider
              Row(
                children: [
                  const Text('Opacity',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(
                    '${(activeOpacity * 100).toInt()}%',
                    style: TextStyle(
                        fontSize: 10, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.5,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 10),
                ),
                child: Slider(
                  value: activeOpacity,
                  min: 0.1,
                  max: 1.0,
                  onChanged: applyOpacity,
                ),
              ),

              // 10. Actions (Align, Distribute, Group, Front, Back, Delete)
              if (activeSelectedElements.isNotEmpty) ...[
                const Divider(height: 12),
                const Text('Layout & Arrange',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (activeSelectedElements.length >= 2) ...[
                      _actionButton(
                        icon: Icons.align_horizontal_left,
                        tooltip: 'Align Left',
                        onTap: () {
                          if (onAlign != null) {
                            onAlign!('left');
                          } else {
                            canvasBloc?.add(const CanvasEvent.alignSelected(
                                AlignDirection.left));
                          }
                        },
                        scheme: scheme,
                      ),
                      _actionButton(
                        icon: Icons.align_horizontal_center,
                        tooltip: 'Align Center',
                        onTap: () {
                          if (onAlign != null) {
                            onAlign!('center');
                          } else {
                            canvasBloc?.add(const CanvasEvent.alignSelected(
                                AlignDirection.center));
                          }
                        },
                        scheme: scheme,
                      ),
                      _actionButton(
                        icon: Icons.align_horizontal_right,
                        tooltip: 'Align Right',
                        onTap: () {
                          if (onAlign != null) {
                            onAlign!('right');
                          } else {
                            canvasBloc?.add(const CanvasEvent.alignSelected(
                                AlignDirection.right));
                          }
                        },
                        scheme: scheme,
                      ),
                      _actionButton(
                        icon: Icons.align_vertical_top,
                        tooltip: 'Align Top',
                        onTap: () {
                          if (onAlign != null) {
                            onAlign!('top');
                          } else {
                            canvasBloc?.add(const CanvasEvent.alignSelected(
                                AlignDirection.top));
                          }
                        },
                        scheme: scheme,
                      ),
                    ],
                    if (activeSelectedElements.length >= 3) ...[
                      _actionButton(
                        icon: Icons.horizontal_distribute,
                        tooltip: 'Distribute Horizontally',
                        onTap: () {
                          if (onDistribute != null) {
                            onDistribute!('horizontal');
                          } else {
                            canvasBloc?.add(
                                const CanvasEvent.distributeSelected(
                                    DistributeDirection.horizontal));
                          }
                        },
                        scheme: scheme,
                      ),
                    ],
                    if (activeSelectedElements.length >= 2)
                      _actionButton(
                        icon: Icons.group,
                        tooltip: 'Group (Ctrl+G)',
                        onTap: onGroup ??
                            () => canvasBloc
                                ?.add(const CanvasEvent.groupSelected()),
                        scheme: scheme,
                      ),
                    if (hasGrouped)
                      _actionButton(
                        icon: Icons.group_remove_outlined,
                        tooltip: 'Ungroup (Ctrl+Shift+G)',
                        onTap: onUngroup ??
                            () => canvasBloc
                                ?.add(const CanvasEvent.ungroupSelected()),
                        scheme: scheme,
                      ),
                    _actionButton(
                      icon: Icons.flip_to_front,
                      tooltip: 'Bring to Front (])',
                      onTap: onBringToFront ??
                          () => canvasBloc
                              ?.add(const CanvasEvent.bringSelectedToFront()),
                      scheme: scheme,
                    ),
                    _actionButton(
                      icon: Icons.flip_to_back,
                      tooltip: 'Send to Back ([)',
                      onTap: onSendToBack ??
                          () => canvasBloc
                              ?.add(const CanvasEvent.sendSelectedToBack()),
                      scheme: scheme,
                    ),
                    _actionButton(
                      icon: Icons.lock_outline,
                      tooltip: 'Toggle Lock',
                      onTap: onToggleLock ??
                          () => canvasBloc
                              ?.add(const CanvasEvent.toggleLockSelected()),
                      scheme: scheme,
                    ),
                    _actionButton(
                      icon: Icons.delete_outline,
                      tooltip: 'Delete (Del)',
                      color: Colors.redAccent,
                      onTap: onDelete ??
                          () => canvasBloc
                              ?.add(const CanvasEvent.deleteSelected()),
                      scheme: scheme,
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

  Widget _actionButton({
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
              color: isSelected ? selectionColor : Colors.grey.shade400,
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

  Widget _strokeWidthOption(
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

  Widget _strokeStyleOption(
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

  Widget _connectorStyleOption(
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
                  color:
                      isSelected ? scheme.onPrimaryContainer : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fontSizeOption(
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
}
