import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/boards_cubit.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_interaction_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_text_editing_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/tools/tool_registry.dart';
import 'package:flutcanvas/features/canvas/presentation/utils/canvas_clipboard_coordinator.dart';
import 'package:flutcanvas/features/canvas/presentation/utils/canvas_dialog_coordinator.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/board_workspace_sync.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_bottom_controls.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_empty_guide_overlay.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_icon_library_overlay.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_interactive_surface.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_layers_overlay.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_properties_overlay.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_text_editor_overlay.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_top_bar.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/shortcuts_handler.dart';
import 'package:flutcanvas/features/comments/presentation/widgets/canvas_comments_layer.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/widgets/presentation_layer.dart';

/// Primary Whiteboard Page.
///
/// Functions as a clean composition root orchestrating the canvas surface,
/// floating toolbars, overlays, and shortcut handlers.
class WhiteboardPage extends StatefulWidget {
  const WhiteboardPage({super.key, required this.onToggleTheme});

  final void Function(Brightness current, [Offset? origin]) onToggleTheme;

  @override
  State<WhiteboardPage> createState() => _WhiteboardPageState();
}

class _WhiteboardPageState extends State<WhiteboardPage> {
  // Canvas controllers
  late final CanvasViewportController _viewport;
  late final CanvasInteractionController _interaction;
  late final ToolRegistry _toolRegistry;
  late final CanvasTextEditingController _textEditingController;
  late final CanvasClipboardCoordinator _clipboard;

  final FocusNode _focus = FocusNode();
  Size _viewSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _viewport = CanvasViewportController();
    _interaction = CanvasInteractionController();
    _toolRegistry = ToolRegistry();
    _textEditingController = CanvasTextEditingController();
    _clipboard = CanvasClipboardCoordinator();

    // Initialize workspace
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BoardsCubit>().loadWorkspace();
    });

    // Web Clipboard image paste listener
    _clipboard.initWebPasteListener(
      getContext: () => context,
      getViewport: () => _viewport,
      getViewSize: () => _viewSize,
    );
  }

  @override
  void dispose() {
    _focus.dispose();
    _viewport.dispose();
    _interaction.dispose();
    _textEditingController.dispose();
    _clipboard.dispose();
    super.dispose();
  }

  void _onEscape(BuildContext context, bool isPresenting) {
    if (_textEditingController.isEditing) {
      final editingId = _textEditingController.editingElementId;
      final canvasState = context.read<CanvasBloc>().state;
      final editingEl = canvasState.elements
          .where((e) => e.id == editingId)
          .firstOrNull;
      if (editingEl != null &&
          editingEl.type != ShapeType.line &&
          editingEl.type != ShapeType.arrow &&
          _textEditingController.editingTableCell == null &&
          editingEl.text.trim().isEmpty) {
        context.read<CanvasBloc>().add(
              CanvasEvent.deleteElements({editingEl.id}),
            );
      }
      _textEditingController.clearEditing();
      _focus.requestFocus();
      return;
    }

    if (isPresenting) {
      context.read<PresentationCubit>().stopPresentation();
    } else {
      context.read<CanvasBloc>().add(const CanvasEvent.clearSelection());
    }
  }

  void _openCommandPalette(BuildContext context) {
    CanvasDialogCoordinator.showCommandPaletteDialog(
      context: context,
      viewport: _viewport,
      viewSize: _viewSize,
      onToggleTheme: () => widget.onToggleTheme(Theme.of(context).brightness),
      onOpenExport: () => CanvasDialogCoordinator.showExportDialog(
        context,
        _viewport,
        _viewSize,
      ),
      onOpenTemplates: () => CanvasDialogCoordinator.showTemplatesDialog(
        context,
        _viewport,
        _viewSize,
      ),
      onStartPresentation: () {
        final elements = context.read<CanvasBloc>().state.elements;
        context.read<PresentationCubit>().startPresentation(elements);
      },
      onOpenHelp: () =>
          CanvasDialogCoordinator.showShortcutsHelpDialog(context),
      onInsertImage: () => CanvasDialogCoordinator.handleInsertImage(
        context,
        _viewport,
        _viewSize,
      ),
      onOpenMermaidImport: () => CanvasDialogCoordinator.showMermaidDialog(
        context,
        _viewport,
        _viewSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    final isPresenting =
        context.select<PresentationCubit, bool>((c) => c.state.isPresenting);

    return BoardWorkspaceSync(
      viewport: _viewport,
      child: Scaffold(
        backgroundColor: colors.background,
        body: ListenableBuilder(
          listenable: _textEditingController,
          builder: (context, _) => CanvasShortcutsHandler(
            focusNode: _focus,
            isEditingText: _textEditingController.isEditing,
            isPresentationMode: isPresenting,
            onCopy: () => _clipboard.copySelected(context),
            onPaste: () => _clipboard.paste(context, _viewport, _viewSize),
            onDuplicate: () => _clipboard.duplicateSelected(context),
            onDelete: () => context
                .read<CanvasBloc>()
                .add(const CanvasEvent.deleteSelected()),
            onStartPresentation: () {
              final elements = context.read<CanvasBloc>().state.elements;
              context.read<PresentationCubit>().startPresentation(elements);
            },
            onOpenTemplates: () => CanvasDialogCoordinator.showTemplatesDialog(
              context,
              _viewport,
              _viewSize,
            ),
            onOpenExport: () => CanvasDialogCoordinator.showExportDialog(
              context,
              _viewport,
              _viewSize,
            ),
            onOpenHelp: () =>
                CanvasDialogCoordinator.showShortcutsHelpDialog(context),
            onToggleTheme: () =>
                widget.onToggleTheme(Theme.of(context).brightness),
            onOpenCommandPalette: () => _openCommandPalette(context),
            onEscape: () => _onEscape(context, isPresenting),
            onNextSlide: () => context.read<PresentationCubit>().nextSlide(),
            onPreviousSlide: () =>
                context.read<PresentationCubit>().previousSlide(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                _viewSize = constraints.biggest;

                return Stack(
                  children: [
                    // 1. Interactive Multi-Layer Canvas Surface
                    CanvasInteractiveSurface(
                      viewport: _viewport,
                      interaction: _interaction,
                      toolRegistry: _toolRegistry,
                      textEditingController: _textEditingController,
                      focusNode: _focus,
                      onInsertImage: () =>
                          CanvasDialogCoordinator.handleInsertImage(
                        context,
                        _viewport,
                        _viewSize,
                      ),
                    ),

                    // 1.5 Empty Canvas Onboarding Guide
                    CanvasEmptyGuideOverlay(
                      viewport: _viewport,
                      getViewSize: () => _viewSize,
                    ),

                    // 2. Unified Top Bar
                    CanvasTopBar(
                      viewport: _viewport,
                      getViewSize: () => _viewSize,
                      onOpenCommandPalette: () => _openCommandPalette(context),
                    ),

                    // 3. Floating Properties Panel Overlay
                    CanvasPropertiesOverlay(
                      viewport: _viewport,
                      textEditingController: _textEditingController,
                    ),

                    // 3.5 Floating Cloud & Tech Icon Library Overlay
                    CanvasIconLibraryOverlay(
                      viewport: _viewport,
                      getViewSize: () => _viewSize,
                    ),

                    // 4. Floating Layers / Object Tree Sidebar
                    CanvasLayersOverlay(
                      viewport: _viewport,
                      getViewSize: () => _viewSize,
                    ),

                    // 5 & 6. Bottom HUD (ZoomControls, Minimap, Theme, Help)
                    CanvasBottomControls(
                      viewport: _viewport,
                      viewSize: _viewSize,
                      onToggleTheme: widget.onToggleTheme,
                    ),

                    // 7. Floating In-Canvas Text & Table Editor Overlay
                    CanvasTextEditorOverlay(
                      controller: _textEditingController,
                      viewport: _viewport,
                      focusNode: _focus,
                    ),

                    // 8 & 8.5 Interactive Comments & Active Popover Card
                    CanvasCommentsLayer(
                      viewport: _viewport,
                      viewSize: _viewSize,
                    ),

                    // 9. Full-screen Presentation Slides Overlay
                    PresentationLayer(
                      viewport: _viewport,
                      getViewSize: () => _viewSize,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
