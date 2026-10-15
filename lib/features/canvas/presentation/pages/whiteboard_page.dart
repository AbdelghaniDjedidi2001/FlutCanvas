import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/boards_cubit.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/boards_state.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_state.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_interaction_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/tools/tool_registry.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_background_layer.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_elements_layer.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_gesture_dispatcher.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_overlay_layer.dart';
import 'package:flutcanvas/features/comments/presentation/bloc/comments_cubit.dart';
import 'package:flutcanvas/features/comments/presentation/bloc/comments_state.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';
import 'package:flutcanvas/features/canvas/domain/models/templates.dart';
import 'package:flutcanvas/features/canvas/data/services/connector_routing_service.dart';
import 'package:flutcanvas/core/services/clipboard/clipboard_paste_service.dart';
import 'package:flutcanvas/features/clipboard/data/services/clipboard_service.dart';
import 'package:flutcanvas/core/services/media/image_service.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/inline_text_editor.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/widgets/presentation_overlay.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/board_tabs_bar.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/main_toolbar.dart';
import 'package:flutcanvas/features/toolbar/presentation/widgets/properties_panel.dart';
import 'package:flutcanvas/features/comments/presentation/widgets/comment_card_popover.dart';
import 'package:flutcanvas/features/comments/presentation/widgets/comment_pin_badge.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/empty_canvas_guide.dart';
import 'package:flutcanvas/features/export/presentation/widgets/export_dialog.dart';
import 'package:flutcanvas/features/layers/presentation/widgets/layers_sidebar.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/mermaid_dialog.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/minimap_widget.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/shortcuts_handler.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/shortcuts_help_dialog.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/template_picker_dialog.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/theme_toggle.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/zoom_controls.dart';

class WhiteboardPage extends StatefulWidget {
  const WhiteboardPage({super.key, required this.onToggleTheme});

  final void Function(Brightness current) onToggleTheme;

  @override
  State<WhiteboardPage> createState() => _WhiteboardPageState();
}

class _WhiteboardPageState extends State<WhiteboardPage> {
  // Canvas controllers
  late final CanvasViewportController _viewport;
  late final CanvasInteractionController _interaction;
  late final ToolRegistry _toolRegistry;

  Size _viewSize = Size.zero;
  final FocusNode _focus = FocusNode();

  // Inline Text & Table Editing
  int _idCounter = 0;
  BoardElement? _pendingNewElement;
  String? _editingElementId;
  (int, int)? _editingTableCell;
  Offset? _editingScreenPos;
  bool _isEditingSticky = false;
  bool _isEditingCode = false;

  void _openTextEditor(Offset world, Offset screen, {required bool isSticky}) {
    final toolState = context.read<ToolCubit>().state;
    final colors = BoardColors.of(context);
    final newId =
        'el_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';
    final initialColor = isSticky
        ? const Color(0xFF212529)
        : (colors.isDark ? Colors.white : kInk);
    final strokeColor = (toolState.strokeColor == kInk ||
            toolState.strokeColor == Colors.black ||
            toolState.strokeColor == Colors.white)
        ? initialColor
        : toolState.strokeColor;

    final newElement = BoardElement(
      id: newId,
      type: isSticky ? ShapeType.stickyNote : ShapeType.text,
      start: world,
      end: isSticky
          ? world + const Offset(180, 160)
          : world + const Offset(200, 40),
      color: strokeColor,
      fillColor:
          isSticky ? BoardColors.stickyNoteColors[0] : toolState.fillColor,
      fontSize: isSticky ? 18.0 : toolState.fontSize,
      drawStyle: toolState.drawStyle,
      opacity: 1.0,
      text: '',
    );

    context.read<CanvasBloc>().add(CanvasEvent.addElement(newElement));

    setState(() {
      _pendingNewElement = newElement;
      _editingElementId = newId;
      _editingTableCell = null;
      _editingScreenPos = screen;
      _isEditingSticky = isSticky;
      _isEditingCode = false;
    });
  }

  // Presentation Mode
  bool _isPresentationMode = false;
  int _currentSlideIndex = 0;

  @override
  void initState() {
    super.initState();
    _viewport = CanvasViewportController();
    _interaction = CanvasInteractionController();
    _toolRegistry = ToolRegistry();

    // Initialize workspace
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BoardsCubit>().loadWorkspace();
    });

    // Web Clipboard image paste listener
    ClipboardPasteService.initWebPasteListener((base64Image) {
      if (!mounted) return;
      final center = _viewport.toWorld(
        Offset(_viewSize.width / 2, _viewSize.height / 2),
      );
      final imgEl = ClipboardService.createImageElement(
        base64Image: base64Image,
        position: center - const Offset(160, 110),
      );
      context.read<CanvasBloc>().add(CanvasEvent.addElement(imgEl));
      context.read<CanvasBloc>().add(CanvasEvent.selectElements({imgEl.id}));
      _showToast('Pasted image from clipboard');
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _viewport.dispose();
    _interaction.dispose();
    ClipboardPasteService.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Double Tap for In-Canvas Editing ───────────────────────
  void _onDoubleTap(Offset localPos) {
    final world = _viewport.toWorld(localPos);
    final elements = context.read<CanvasBloc>().state.elements;
    final tol = 6.0 / _viewport.zoom;

    BoardElement? hit;
    for (final el in elements.reversed) {
      if (el.isVisible && el.hitTest(world, tol)) {
        hit = el;
        break;
      }
    }

    if (hit != null && !hit.isLocked) {
      if (hit.type == ShapeType.table) {
        final cell = hit.hitTestCell(world);
        if (cell != null) {
          final cellRect = hit.getCellRect(cell.$1, cell.$2);
          setState(() {
            _editingElementId = hit!.id;
            _editingTableCell = (cell.$1, cell.$2);
            _editingScreenPos = _viewport.toScreen(cellRect.topLeft);
            _isEditingSticky = false;
            _isEditingCode = false;
          });
        }
        return;
      }

      if (hit.type == ShapeType.line ||
          hit.type == ShapeType.arrow ||
          hit.type == ShapeType.doubleArrow) {
        final route = ConnectorRoutingService.computeRoute(hit);
        setState(() {
          _editingElementId = hit!.id;
          _editingTableCell = null;
          _editingScreenPos = _viewport.toScreen(route.midpoint);
          _isEditingSticky = false;
          _isEditingCode = false;
        });
        return;
      }

      if (hit.type == ShapeType.text ||
          hit.type == ShapeType.stickyNote ||
          hit.type == ShapeType.codeBlock) {
        setState(() {
          _editingElementId = hit!.id;
          _editingTableCell = null;
          _editingScreenPos = _viewport.toScreen(
            hit.type == ShapeType.codeBlock
                ? hit.bounds.topLeft + const Offset(0, 32)
                : hit.bounds.topLeft,
          );
          _isEditingSticky = hit.type == ShapeType.stickyNote;
          _isEditingCode = hit.type == ShapeType.codeBlock;
        });
      }
    }
  }

  void _navigateTableCell(int dRow, int dCol, String currentText) {
    if (_editingElementId == null || _editingTableCell == null) return;
    final elementId = _editingElementId!;
    final currentCell = _editingTableCell!;
    final elements = context.read<CanvasBloc>().state.elements;
    final el = elements.where((e) => e.id == elementId).firstOrNull;
    if (el == null || el.type != ShapeType.table) return;

    final updatedEl =
        el.updateTableCell(currentCell.$1, currentCell.$2, currentText);
    final rows = updatedEl.tableRowCount;
    final cols = updatedEl.tableColCount;

    var nextRow = currentCell.$1 + dRow;
    var nextCol = currentCell.$2 + dCol;

    if (nextCol >= cols) {
      nextCol = 0;
      nextRow++;
    } else if (nextCol < 0) {
      nextCol = cols - 1;
      nextRow--;
    }

    if (nextRow < 0) nextRow = 0;
    if (nextRow >= rows) {
      context.read<CanvasBloc>().add(CanvasEvent.updateElement(updatedEl));
      setState(() {
        _pendingNewElement = null;
        _editingElementId = null;
        _editingTableCell = null;
        _editingScreenPos = null;
      });
      return;
    }

    context.read<CanvasBloc>().add(CanvasEvent.updateElement(updatedEl));
    final nextCellRect = updatedEl.getCellRect(nextRow, nextCol);
    setState(() {
      _editingTableCell = (nextRow, nextCol);
      _editingScreenPos = _viewport.toScreen(nextCellRect.topLeft);
    });
  }

  // ── Clipboard & Duplicate ───────────────────────────────────
  void _duplicateSelected() {
    final elements = context.read<CanvasBloc>().state.elements;
    final selectedIds = context.read<CanvasBloc>().state.selectedIds;
    final selected = elements.where((e) => selectedIds.contains(e.id)).toList();
    if (selected.isEmpty) return;

    final duplicated = selected.map((el) {
      final newId = 'el_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';
      return el.translated(const Offset(24, 24)).copyWith(id: newId);
    }).toList();

    context.read<CanvasBloc>().add(CanvasEvent.addElements(duplicated));
    context.read<CanvasBloc>().add(
          CanvasEvent.selectElements(duplicated.map((e) => e.id).toSet()),
        );
    _showToast('Duplicated ${duplicated.length} element(s)');
  }

  void _copySelected() {
    final elements = context.read<CanvasBloc>().state.elements;
    final selectedIds = context.read<CanvasBloc>().state.selectedIds;
    final selected = elements.where((e) => selectedIds.contains(e.id)).toList();
    if (selected.isEmpty) return;
    ClipboardService.copy(selected);
    _showToast('Copied ${selected.length} element(s)');
  }

  Future<void> _paste() async {
    final center = _viewport.toWorld(
      Offset(_viewSize.width / 2, _viewSize.height / 2),
    );
    final pasteResult = await ClipboardService.pasteFromSystem(
      targetCanvasPosition: center,
      defaultColor: context.read<ToolCubit>().state.strokeColor,
    );
    if (!mounted) return;

    if (pasteResult != null && pasteResult.elements.isNotEmpty) {
      context.read<CanvasBloc>().add(CanvasEvent.addElements(pasteResult.elements));
      context.read<CanvasBloc>().add(
            CanvasEvent.selectElements(
                pasteResult.elements.map((e) => e.id).toSet()),
          );
      _showToast('Pasted ${pasteResult.sourceDescription}');
      return;
    }

    if (ClipboardService.hasInternalData) {
      final duplicated = ClipboardService.duplicate();
      if (duplicated.isNotEmpty) {
        context.read<CanvasBloc>().add(CanvasEvent.addElements(duplicated));
        context.read<CanvasBloc>().add(
              CanvasEvent.selectElements(
                  duplicated.map((e) => e.id).toSet()),
            );
        _showToast('Pasted ${duplicated.length} element(s)');
      }
    }
  }

  // ── Presentation Mode ──────────────────────────────────────
  void _startPresentation(List<BoardElement> frames) {
    if (frames.isEmpty) return;
    setState(() {
      _isPresentationMode = true;
      _currentSlideIndex = 0;
    });
    _navigateToSlide(0, frames);
  }

  void _navigateToSlide(int index, List<BoardElement> frames) {
    if (index < 0 || index >= frames.length) return;
    final frame = frames[index];
    setState(() => _currentSlideIndex = index);
    _viewport.zoomToFit([frame], _viewSize, padding: 40.0);
  }

  // ── Dialog Helpers ─────────────────────────────────────────
  void _showExportDialog(List<BoardElement> elements) {
    final boardsState = context.read<BoardsCubit>().state;
    showDialog(
      context: context,
      builder: (_) => ExportDialog(
        elements: elements,
        colors: BoardColors.of(context),
        allBoards: boardsState.boards,
        boardName: boardsState.currentBoard.title,
        onImport: (imported) {
          context.read<CanvasBloc>().add(CanvasEvent.addElements(imported));
          _viewport.zoomToFit(imported, _viewSize);
          _showToast('Imported ${imported.length} element(s) to canvas');
        },
      ),
    );
  }

  void _showTemplatesDialog() {
    showDialog(
      context: context,
      builder: (_) => TemplatePickerDialog(
        onSelectTemplate: (type) {
          final center = _viewport.toWorld(
            Offset(_viewSize.width / 2, _viewSize.height / 2),
          );
          final templateEls = TemplateGenerator.generate(type, center);
          context.read<CanvasBloc>().add(CanvasEvent.addElements(templateEls));
          _viewport.zoomToFit(templateEls, _viewSize);
          _showToast('Inserted template');
        },
        onOpenMermaid: _showMermaidDialog,
      ),
    );
  }

  void _showMermaidDialog([String? initialScript]) {
    final center = _viewport.toWorld(
      Offset(_viewSize.width / 2, _viewSize.height / 2),
    );
    showDialog(
      context: context,
      builder: (_) => MermaidDialog(
        initialScript: initialScript,
        targetOrigin: center - const Offset(200, 150),
        onInsert: (elements) {
          context.read<CanvasBloc>().add(CanvasEvent.addElements(elements));
          _viewport.zoomToFit(elements, _viewSize);
          _showToast('Inserted Mermaid diagram (${elements.length} items)');
        },
      ),
    );
  }

  void _showShortcutsHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => const ShortcutsHelpDialog(),
    );
  }

  Future<void> _handleInsertImage() async {
    final picked = await ImageService.pickImage();
    if (picked != null && mounted) {
      final center = _viewport.toWorld(
        Offset(_viewSize.width / 2, _viewSize.height / 2),
      );
      const targetWidth = 240.0;
      final targetHeight = (targetWidth / picked.width) * picked.height;

      final newElement = BoardElement(
        id: 'img_${DateTime.now().millisecondsSinceEpoch}',
        type: ShapeType.image,
        start: center - Offset(targetWidth / 2, targetHeight / 2),
        end: center + Offset(targetWidth / 2, targetHeight / 2),
        color: Colors.transparent,
        imageBase64: picked.base64,
      );

      context.read<CanvasBloc>().add(CanvasEvent.addElement(newElement));
      _showToast('Inserted Image');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    final toolState = context.watch<ToolCubit>().state;
    final canvasState = context.watch<CanvasBloc>().state;
    final commentsState = context.watch<CommentsCubit>().state;

    final frames = canvasState.elements
        .where((e) => e.type == ShapeType.frame)
        .toList()
      ..sort((a, b) {
        if (a.frameIndex != null && b.frameIndex != null) {
          return a.frameIndex!.compareTo(b.frameIndex!);
        }
        return a.start.dy.compareTo(b.start.dy);
      });

    return MultiBlocListener(
      listeners: [
        // 1. Sync board switch to CanvasBloc and CommentsCubit
        BlocListener<BoardsCubit, BoardsState>(
          listenWhen: (prev, curr) =>
              prev.activeBoardIndex != curr.activeBoardIndex ||
              (prev.boards.isEmpty && curr.boards.isNotEmpty),
          listener: (context, bState) {
            final active = bState.currentBoard;
            context
                .read<CanvasBloc>()
                .add(CanvasEvent.loadElements(active.elements));
            context.read<CommentsCubit>().setComments(active.comments);
            _viewport.setPan(active.pan);
            _viewport.setZoom(active.zoom);
          },
        ),
        // 2. Persist canvas updates to active board
        BlocListener<CanvasBloc, CanvasState>(
          listenWhen: (prev, curr) => prev.elements != curr.elements,
          listener: (context, cState) {
            context.read<BoardsCubit>().updateCurrentBoard(
                  elements: cState.elements,
                  pan: _viewport.pan,
                  zoom: _viewport.zoom,
                );
          },
        ),
        // 3. Persist comments updates to active board
        BlocListener<CommentsCubit, CommentsState>(
          listenWhen: (prev, curr) => prev.comments != curr.comments,
          listener: (context, commState) {
            context.read<BoardsCubit>().updateCurrentBoard(
                  comments: commState.comments,
                );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: colors.background,
        body: CanvasShortcutsHandler(
          focusNode: _focus,
          isEditingText: _editingElementId != null,
          isPresentationMode: _isPresentationMode,
          onCopy: _copySelected,
          onPaste: _paste,
          onDuplicate: _duplicateSelected,
          onDelete: () => context
              .read<CanvasBloc>()
              .add(const CanvasEvent.deleteSelected()),
          onStartPresentation: () => _startPresentation(frames),
          onOpenTemplates: _showTemplatesDialog,
          onOpenExport: () => _showExportDialog(canvasState.elements),
          onOpenHelp: _showShortcutsHelpDialog,
          onToggleTheme: () =>
              widget.onToggleTheme(Theme.of(context).brightness),
          onEscape: () {
            if (_editingElementId != null) {
              setState(() {
                final editingEl = canvasState.elements
                    .where((e) => e.id == _editingElementId)
                    .firstOrNull;
                if (editingEl != null &&
                    editingEl.type != ShapeType.line &&
                    editingEl.type != ShapeType.arrow &&
                    _editingTableCell == null &&
                    editingEl.text.trim().isEmpty) {
                  context.read<CanvasBloc>().add(
                        CanvasEvent.deleteElements({editingEl.id}),
                      );
                }
                _pendingNewElement = null;
                _editingElementId = null;
                _editingTableCell = null;
                _editingScreenPos = null;
              });
              _focus.requestFocus();
              return;
            }
            if (_isPresentationMode) {
              setState(() => _isPresentationMode = false);
            } else {
              context
                  .read<CanvasBloc>()
                  .add(const CanvasEvent.clearSelection());
            }
          },
          onNextSlide: () =>
              _navigateToSlide(_currentSlideIndex + 1, frames),
          onPreviousSlide: () =>
              _navigateToSlide(_currentSlideIndex - 1, frames),
          child: LayoutBuilder(
            builder: (context, constraints) {
              _viewSize = constraints.biggest;

              return Stack(
                children: [
                  // 1. Interactive Multi-Layer Canvas Surface
                  Positioned.fill(
                    child: CanvasGestureDispatcher(
                      viewport: _viewport,
                      interaction: _interaction,
                      toolRegistry: _toolRegistry,
                      focusNode: _focus,
                      onOpenTextEditor: (world, screen, {required isSticky}) =>
                          _openTextEditor(world, screen, isSticky: isSticky),
                      onInsertImage: _handleInsertImage,
                      child: GestureDetector(
                        onDoubleTapDown: (details) =>
                            _onDoubleTap(details.localPosition),
                        child: Stack(
                          children: [
                            // 1a. Background Grid
                            CanvasBackgroundLayer(viewport: _viewport),
                            // 1b. Committed Elements
                            CanvasElementsLayer(viewport: _viewport),
                            // 1c. Live Transient Overlays (Draft, Marquee, Laser)
                            CanvasOverlayLayer(
                              viewport: _viewport,
                              interaction: _interaction,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 1.5 Empty Canvas Onboarding Guide
                  if (canvasState.elements.isEmpty && !_isPresentationMode)
                    Positioned.fill(
                      child: EmptyCanvasGuide(
                        onOpenImport: () =>
                            _showExportDialog(canvasState.elements),
                        onOpenTemplates: _showTemplatesDialog,
                        onOpenMermaid: _showMermaidDialog,
                        onOpenHelp: _showShortcutsHelpDialog,
                        onInsertImage: _handleInsertImage,
                        onSelectTool: (t) =>
                            context.read<ToolCubit>().setTool(t),
                      ),
                    ),

                  // 2. Unified Top Bar
                  if (!_isPresentationMode)
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: ExcludeFocus(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BoardTabsBar(),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Center(
                                child: MainToolbar(
                                  onClear: () => context
                                      .read<CanvasBloc>()
                                      .add(const CanvasEvent.loadElements([])),
                                  onOpenExport: () =>
                                      _showExportDialog(canvasState.elements),
                                  onOpenTemplates: _showTemplatesDialog,
                                  onStartPresentation: () =>
                                      _startPresentation(frames),
                                  onToggleProperties: () => context
                                      .read<ToolCubit>()
                                      .togglePropertiesPanel(),
                                  onToggleLayers: () => context
                                      .read<ToolCubit>()
                                      .toggleLayersSidebar(),
                                  onInsertImage: _handleInsertImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 3. Floating Properties Panel
                  if (!_isPresentationMode &&
                      (toolState.isPropertiesOpen ||
                          canvasState.selectedIds.isNotEmpty))
                    Positioned(
                      top: 64,
                      left: 12,
                      child: ExcludeFocus(
                        child: PropertiesPanel(
                          currentCodeLanguage: toolState.codeLanguage,
                          onCodeLanguageChanged: (newLang) {
                            context.read<ToolCubit>().setCodeLanguage(newLang);
                            final codeElements = canvasState.selectedElements
                                .where((e) => e.type == ShapeType.codeBlock)
                                .toList();
                            if (codeElements.isNotEmpty) {
                              final updated = codeElements
                                  .map((e) => e.copyWith(codeLanguage: newLang))
                                  .toList();
                              context
                                  .read<CanvasBloc>()
                                  .add(CanvasEvent.updateElements(updated));
                            }
                          },
                          onToggleLineNumbers: (show) {
                            final codeElements = canvasState.selectedElements
                                .where((e) => e.type == ShapeType.codeBlock)
                                .toList();
                            if (codeElements.isNotEmpty) {
                              final updated = codeElements
                                  .map((e) => e.copyWith(showLineNumbers: show))
                                  .toList();
                              context
                                  .read<CanvasBloc>()
                                  .add(CanvasEvent.updateElements(updated));
                            }
                          },
                          onCopyCode: () {
                            final codeEl = canvasState.selectedElements
                                .where((e) => e.type == ShapeType.codeBlock)
                                .firstOrNull;
                            if (codeEl != null) {
                              Clipboard.setData(ClipboardData(text: codeEl.text));
                              _showToast('Code copied to clipboard');
                            }
                          },
                          onEditConnectorLabel: () {
                            final connector = canvasState.selectedElements
                                .where((e) =>
                                    e.type == ShapeType.line ||
                                    e.type == ShapeType.arrow ||
                                    e.type == ShapeType.doubleArrow)
                                .firstOrNull;
                            if (connector != null) {
                              final route =
                                  ConnectorRoutingService.computeRoute(connector);
                              setState(() {
                                _editingElementId = connector.id;
                                _editingTableCell = null;
                                _editingScreenPos =
                                    _viewport.toScreen(route.midpoint);
                                _isEditingSticky = false;
                                _isEditingCode = false;
                              });
                            }
                          },
                          onClose: () => context
                              .read<ToolCubit>()
                              .setPropertiesOpen(false),
                        ),
                      ),
                    ),

                  // 4. Floating Layers / Object Tree Sidebar
                  if (!_isPresentationMode && toolState.isLayersOpen)
                    Positioned(
                      top: 64,
                      right: 12,
                      child: LayersSidebar(
                        onSelectComment: (commentId) {
                          context
                              .read<CommentsCubit>()
                              .setActiveCommentId(commentId);
                          final comment = commentsState.comments
                              .where((c) => c.id == commentId)
                              .firstOrNull;
                          if (comment != null) {
                            _viewport.panToCenter(
                              comment.worldPosition,
                              _viewSize,
                            );
                          }
                        },
                        onClose: () =>
                            context.read<ToolCubit>().setLayersOpen(false),
                      ),
                    ),

                  // 5. Bottom-Left Zoom Controls
                  if (!_isPresentationMode)
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: ExcludeFocus(
                        child: ZoomControls(
                          controller: _viewport,
                          isGridSnap: toolState.gridSnap,
                          onToggleGridSnap: () =>
                              context.read<ToolCubit>().toggleGridSnap(),
                          isSmartGuides: toolState.smartGuides,
                          onToggleSmartGuides: () =>
                              context.read<ToolCubit>().toggleSmartGuides(),
                          isShapeSnapping: toolState.autoShapeRecognition,
                          onToggleShapeSnapping: () =>
                              context.read<ToolCubit>().toggleAutoShapeRecognition(),
                        ),
                      ),
                    ),

                  // 6. Bottom-Right Radar Minimap, Theme Toggle & Help
                  if (!_isPresentationMode)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: ExcludeFocus(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (canvasState.elements.isNotEmpty &&
                                _viewSize.width > 540) ...[
                              ListenableBuilder(
                                listenable: _viewport,
                                builder: (context, _) => MinimapWidget(
                                  elements: canvasState.elements,
                                  pan: _viewport.pan,
                                  zoom: _viewport.zoom,
                                  viewSize: _viewSize,
                                  colors: colors,
                                  onJumpTo: (newPan) =>
                                      _viewport.setPan(newPan),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            ThemeToggle(onToggleTheme: widget.onToggleTheme),
                            const SizedBox(width: 8),
                            Material(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                              elevation: 3,
                              shadowColor: const Color(0x33000000),
                              borderRadius: BorderRadius.circular(12),
                              child: IconButton(
                                tooltip: 'Shortcuts & Help (?)',
                                onPressed: _showShortcutsHelpDialog,
                                icon: const Icon(
                                  Icons.help_outline_rounded,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 7. Floating In-Canvas Text & Table Editor Overlay
                  if (_editingElementId != null && _editingScreenPos != null)
                    Builder(builder: (context) {
                      final editingEl = canvasState.elements
                              .where((e) => e.id == _editingElementId)
                              .firstOrNull ??
                          (_pendingNewElement?.id == _editingElementId
                              ? _pendingNewElement
                              : null);

                      if (editingEl == null) {
                        return const SizedBox.shrink();
                      }

                      final isConnector = editingEl.type == ShapeType.line ||
                          editingEl.type == ShapeType.arrow ||
                          editingEl.type == ShapeType.doubleArrow;
                      final isTableCell = _editingTableCell != null &&
                          editingEl.type == ShapeType.table;

                      final initialText = isTableCell
                          ? (_editingTableCell!.$1 < editingEl.tableRowCount &&
                                  _editingTableCell!.$2 <
                                      editingEl.tableColCount
                              ? editingEl.safeTableData[_editingTableCell!.$1]
                                  [_editingTableCell!.$2]
                              : '')
                          : (isConnector
                              ? (editingEl.label ?? '')
                              : editingEl.text);

                      final cellWidth = isTableCell
                          ? editingEl
                                  .getCellRect(
                                    _editingTableCell!.$1,
                                    _editingTableCell!.$2,
                                  )
                                  .width *
                              _viewport.zoom
                          : null;

                      final isMonoOrDefault = editingEl.color == kInk ||
                          editingEl.color == Colors.black ||
                          editingEl.color == Colors.white ||
                          editingEl.color.toARGB32() == 0xFF1F2430 ||
                          editingEl.color.toARGB32() == 0xFF000000 ||
                          editingEl.color.toARGB32() == 0xFFFFFFFF;
                      final textNoteColor = isMonoOrDefault
                          ? (colors.isDark ? Colors.white : const Color(0xFF212529))
                          : editingEl.color;

                      return InlineTextEditor(
                        initialText: initialText,
                        fontSize: isConnector
                            ? 16.0
                            : (isTableCell
                                ? editingEl.fontSize
                                : toolState.fontSize),
                        color: isConnector
                            ? editingEl.color
                            : (isTableCell
                                ? (colors.isDark
                                    ? Colors.white
                                    : const Color(0xFF212529))
                                : (_isEditingSticky
                                    ? const Color(0xFF212529)
                                    : (_isEditingCode
                                        ? (colors.isDark
                                            ? const Color(0xFFCDD6F4)
                                            : const Color(0xFF24292F))
                                        : textNoteColor))),
                        screenPosition: _editingScreenPos!,
                        isStickyNote: _isEditingSticky,
                        isCodeBlock: _isEditingCode,
                        isTableCell: isTableCell,
                        customWidth: isTableCell
                            ? cellWidth
                            : (_isEditingCode
                                ? math.max(
                                    340.0,
                                    editingEl.bounds.width * _viewport.zoom)
                                : null),
                        onNavigateCell: _navigateTableCell,
                        onSubmitted: (newText) {
                          if (isTableCell) {
                            final updated = editingEl.updateTableCell(
                              _editingTableCell!.$1,
                              _editingTableCell!.$2,
                              newText,
                            );
                            context
                                .read<CanvasBloc>()
                                .add(CanvasEvent.updateElement(updated));
                          } else if (isConnector) {
                            final updated = editingEl.copyWith(
                              label:
                                  newText.trim().isEmpty ? null : newText.trim(),
                            );
                            context
                                .read<CanvasBloc>()
                                .add(CanvasEvent.updateElement(updated));
                          } else {
                            final updated = editingEl.copyWith(
                              text: newText,
                              color: isMonoOrDefault
                                  ? (colors.isDark ? Colors.white : kInk)
                                  : editingEl.color,
                            );
                            context
                                .read<CanvasBloc>()
                                .add(CanvasEvent.updateElement(updated));
                          }

                          setState(() {
                            _pendingNewElement = null;
                            _editingElementId = null;
                            _editingTableCell = null;
                            _editingScreenPos = null;
                          });
                          _focus.requestFocus();
                        },
                        onCanceled: () {
                          if (!isConnector &&
                              !isTableCell &&
                              editingEl.text.trim().isEmpty) {
                            context.read<CanvasBloc>().add(
                                  CanvasEvent.deleteElements({editingEl.id}),
                                );
                          }
                          setState(() {
                            _pendingNewElement = null;
                            _editingElementId = null;
                            _editingTableCell = null;
                            _editingScreenPos = null;
                          });
                          _focus.requestFocus();
                        },
                      );
                    }),

                  // 8. Interactive Canvas Comment Pins
                  if (!_isPresentationMode)
                    for (final comment in commentsState.comments)
                      Builder(builder: (context) {
                        final screenPos =
                            _viewport.toScreen(comment.worldPosition);
                        if (screenPos.dx < -60 ||
                            screenPos.dx > _viewSize.width + 60 ||
                            screenPos.dy < -60 ||
                            screenPos.dy > _viewSize.height + 60) {
                          return const SizedBox.shrink();
                        }
                        final isSelected =
                            commentsState.activeCommentId == comment.id;
                        return Positioned(
                          left: screenPos.dx - (isSelected ? 17 : 14),
                          top: screenPos.dy - (isSelected ? 17 : 14),
                          child: CommentPinBadge(
                            comment: comment,
                            isSelected: isSelected,
                            onTap: () {
                              context
                                  .read<CommentsCubit>()
                                  .setActiveCommentId(
                                    isSelected ? null : comment.id,
                                  );
                            },
                          ),
                        );
                      }),

                  // 8.5 Active Comment Popover Card
                  if (!_isPresentationMode &&
                      commentsState.activeCommentId != null)
                    Builder(builder: (context) {
                      final activeComment = commentsState.comments
                          .where((c) => c.id == commentsState.activeCommentId)
                          .firstOrNull;
                      if (activeComment == null) {
                        return const SizedBox.shrink();
                      }
                      final screenPos =
                          _viewport.toScreen(activeComment.worldPosition);
                      return CommentCardPopover(
                        comment: activeComment,
                        screenPosition: screenPos,
                        viewSize: _viewSize,
                        onAddReply: (text) => context
                            .read<CommentsCubit>()
                            .addReply(
                              commentId: activeComment.id,
                              author: 'User',
                              text: text,
                            ),
                        onToggleResolved: () => context
                            .read<CommentsCubit>()
                            .toggleResolved(activeComment.id),
                        onDeleteComment: () => context
                            .read<CommentsCubit>()
                            .deleteComment(activeComment.id),
                        onSaveInitialText: (text) {
                          final updated = activeComment.copyWith(text: text);
                          context.read<CommentsCubit>().setComments([
                            for (final c in commentsState.comments)
                              if (c.id == activeComment.id) updated else c,
                          ]);
                        },
                        onClose: () => context
                            .read<CommentsCubit>()
                            .setActiveCommentId(null),
                      );
                    }),

                  // 9. Full-screen Presentation Slides Overlay
                  if (_isPresentationMode)
                    PresentationOverlay(
                      frames: frames,
                      currentSlideIndex: _currentSlideIndex,
                      onNextSlide: () =>
                          _navigateToSlide(_currentSlideIndex + 1, frames),
                      onPrevSlide: () =>
                          _navigateToSlide(_currentSlideIndex - 1, frames),
                      onExit: () =>
                          setState(() => _isPresentationMode = false),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
