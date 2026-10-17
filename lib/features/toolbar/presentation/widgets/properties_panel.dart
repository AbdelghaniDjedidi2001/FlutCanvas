import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/data/services/alignment_service.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_state.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_state.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_arrange_section.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_code_snippet_section.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_connector_section.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_draw_style_section.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_fill_section.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_font_size_section.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_opacity_section.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_panel_header.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_stroke_color_section.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_stroke_style_section.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_stroke_width_section.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties/property_table_section.dart';

/// Floating Properties Panel allowing users to edit styles, stroke, fill,
/// font size, opacity, and layout of active tools or selected canvas elements.
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

  bool _hasCodeBlock(List<BoardElement> list) =>
      list.any((e) => e.type == ShapeType.codeBlock);

  BoardElement? _firstCodeBlock(List<BoardElement> list) =>
      list.where((e) => e.type == ShapeType.codeBlock).firstOrNull;

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
            activeSelectedElements
                .every((e) => e.type == ShapeType.highlighter)) ||
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

    void applyFillStyle(FillStyle s) {
      if (onFillStyleChanged != null) {
        onFillStyleChanged!(s);
      } else {
        toolCubit?.setFillStyle(s);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements) el.copyWith(fillStyle: s)
          ];
          canvasBloc.add(CanvasEvent.updateElements(updated));
        }
      }
    }

    void applyDrawStyle(DrawStyle s) {
      if (onDrawStyleChanged != null) {
        onDrawStyleChanged!(s);
      } else {
        toolCubit?.setDrawStyle(s);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements) el.copyWith(drawStyle: s)
          ];
          canvasBloc.add(CanvasEvent.updateElements(updated));
        }
      }
    }

    void applyFontSize(double sz) {
      if (onFontSizeChanged != null) {
        onFontSizeChanged!(sz);
      } else {
        toolCubit?.setFontSize(sz);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements) el.copyWith(fontSize: sz)
          ];
          canvasBloc.add(CanvasEvent.updateElements(updated));
        }
      }
    }

    void applyOpacity(double op) {
      if (onOpacityChanged != null) {
        onOpacityChanged!(op);
      } else {
        toolCubit?.setOpacity(op);
        if (activeSelectedElements.isNotEmpty && canvasBloc != null) {
          final updated = [
            for (final el in activeSelectedElements) el.copyWith(opacity: op)
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
              // Header
              PropertyPanelHeader(
                selectedCount: activeSelectedElements.length,
                onClose: onClose ??
                    (toolCubit != null
                        ? () => toolCubit.setPropertiesOpen(false)
                        : null),
              ),
              const Divider(height: 10),

              // 1. Draw Style
              PropertyDrawStyleSection(
                activeDrawStyle: activeDrawStyle,
                onSelectDrawStyle: applyDrawStyle,
              ),
              const SizedBox(height: 9),

              // 2. Stroke Color
              PropertyStrokeColorSection(
                activeColor: activeColor,
                isHighlighterTarget: isHighlighterTarget,
                strokeColorPalette: strokeColorPalette,
                colors: colors,
                onSelectColor: applyColor,
              ),
              const SizedBox(height: 9),

              // 3. Fill Style & Color
              PropertyFillSection(
                activeFillStyle: activeFillStyle,
                activeFillColor: activeFillColor,
                colors: colors,
                onSelectFillStyle: applyFillStyle,
                onSelectFillColor: applyFillColor,
              ),
              const SizedBox(height: 9),

              // 4. Stroke Width
              PropertyStrokeWidthSection(
                activeStrokeWidth: activeStrokeWidth,
                onSelectStrokeWidth: applyStrokeWidth,
              ),
              const SizedBox(height: 9),

              // 5. Stroke Style
              PropertyStrokeStyleSection(
                activeStrokeStyle: activeStrokeStyle,
                onSelectStrokeStyle: applyStrokeStyle,
              ),
              const SizedBox(height: 9),

              // 6. Connector Route
              if (hasConn) ...[
                PropertyConnectorSection(
                  activeConnectorStyle: activeConnectorStyle,
                  onSelectConnectorStyle: applyConnectorStyle,
                  onEditConnectorLabel: onEditConnectorLabel,
                ),
                const SizedBox(height: 9),
              ],

              // 7. Table Controls
              if (hasTbl && tblEl != null) ...[
                PropertyTableSection(
                  tableElement: tblEl,
                  onAddRow: onAddTableRow ??
                      () {
                        if (canvasBloc != null) {
                          canvasBloc.add(
                            CanvasEvent.updateElement(tblEl.addTableRow()),
                          );
                        }
                      },
                  onRemoveRow: onRemoveTableRow ??
                      () {
                        if (canvasBloc != null) {
                          canvasBloc.add(
                            CanvasEvent.updateElement(tblEl.removeTableRow()),
                          );
                        }
                      },
                  onAddColumn: onAddTableColumn ??
                      () {
                        if (canvasBloc != null) {
                          canvasBloc.add(
                            CanvasEvent.updateElement(tblEl.addTableColumn()),
                          );
                        }
                      },
                  onRemoveColumn: onRemoveTableColumn ??
                      () {
                        if (canvasBloc != null) {
                          canvasBloc.add(
                            CanvasEvent.updateElement(
                                tblEl.removeTableColumn()),
                          );
                        }
                      },
                  onToggleHeader: (hasHeader) {
                    if (onToggleTableHeader != null) {
                      onToggleTableHeader!(hasHeader);
                    } else if (canvasBloc != null) {
                      canvasBloc.add(
                        CanvasEvent.updateElement(
                          tblEl.copyWith(tableHasHeader: hasHeader),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 9),
              ],

              // 7b. Code Snippet Section
              if (_hasCodeBlock(activeSelectedElements) ||
                  toolState.currentTool == Tool.codeBlock) ...[
                Builder(builder: (context) {
                  final codeEl = _firstCodeBlock(activeSelectedElements);
                  final activeLang = currentCodeLanguage ??
                      codeEl?.codeLanguage ??
                      toolState.codeLanguage;
                  final activeShowLines = currentShowLineNumbers ??
                      codeEl?.showLineNumbers ??
                      true;

                  return PropertyCodeSnippetSection(
                    codeElement: codeEl,
                    activeLanguage: activeLang,
                    activeShowLineNumbers: activeShowLines,
                    onSelectLanguage: (newLang) {
                      if (onCodeLanguageChanged != null) {
                        onCodeLanguageChanged!(newLang);
                      } else {
                        toolCubit?.setCodeLanguage(newLang);
                        if (codeEl != null && canvasBloc != null) {
                          canvasBloc.add(
                            CanvasEvent.updateElement(
                              codeEl.copyWith(codeLanguage: newLang),
                            ),
                          );
                        }
                      }
                    },
                    onToggleLineNumbers: (show) {
                      if (onToggleLineNumbers != null) {
                        onToggleLineNumbers!(show);
                      } else if (codeEl != null && canvasBloc != null) {
                        canvasBloc.add(
                          CanvasEvent.updateElement(
                            codeEl.copyWith(showLineNumbers: show),
                          ),
                        );
                      }
                    },
                    onCopyCode: onCopyCode ??
                        () {
                          if (codeEl != null) {
                            Clipboard.setData(
                              ClipboardData(text: codeEl.text),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Code copied to clipboard'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                  );
                }),
                const SizedBox(height: 9),
              ],

              // 8. Typography
              PropertyFontSizeSection(
                activeFontSize: activeFontSize,
                onSelectFontSize: applyFontSize,
              ),
              const SizedBox(height: 9),

              // 9. Opacity Slider
              PropertyOpacitySection(
                activeOpacity: activeOpacity,
                onChangeOpacity: applyOpacity,
              ),

              // 10. Layout & Arrange Actions
              if (activeSelectedElements.isNotEmpty)
                PropertyArrangeSection(
                  selectedCount: activeSelectedElements.length,
                  hasGrouped: hasGrouped,
                  onAlign: (alignment) {
                    if (onAlign != null) {
                      onAlign!(alignment);
                    } else {
                      final dir = switch (alignment) {
                        'left' => AlignDirection.left,
                        'center' => AlignDirection.center,
                        'right' => AlignDirection.right,
                        'top' => AlignDirection.top,
                        _ => AlignDirection.left,
                      };
                      canvasBloc?.add(CanvasEvent.alignSelected(dir));
                    }
                  },
                  onDistribute: (direction) {
                    if (onDistribute != null) {
                      onDistribute!(direction);
                    } else {
                      canvasBloc?.add(
                        const CanvasEvent.distributeSelected(
                          DistributeDirection.horizontal,
                        ),
                      );
                    }
                  },
                  onGroup: onGroup ??
                      () => canvasBloc?.add(const CanvasEvent.groupSelected()),
                  onUngroup: onUngroup ??
                      () => canvasBloc
                          ?.add(const CanvasEvent.ungroupSelected()),
                  onBringToFront: onBringToFront ??
                      () => canvasBloc
                          ?.add(const CanvasEvent.bringSelectedToFront()),
                  onSendToBack: onSendToBack ??
                      () => canvasBloc
                          ?.add(const CanvasEvent.sendSelectedToBack()),
                  onToggleLock: onToggleLock ??
                      () => canvasBloc
                          ?.add(const CanvasEvent.toggleLockSelected()),
                  onDelete: onDelete ??
                      () => canvasBloc
                          ?.add(const CanvasEvent.deleteSelected()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
