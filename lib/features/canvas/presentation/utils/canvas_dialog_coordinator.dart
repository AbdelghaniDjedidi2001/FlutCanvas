import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/core/services/media/image_service.dart';
import 'package:flutcanvas/features/ai_diagram/presentation/widgets/ai_prompt_bar_dialog.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/templates.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/boards_cubit.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/command_palette/command_palette_dialog.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/mermaid_dialog.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/shortcuts_help_dialog.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/template_picker_dialog.dart';
import 'package:flutcanvas/features/export/presentation/widgets/export_dialog.dart';

/// Helper coordinating standard modal dialogs and media import for the whiteboard.
class CanvasDialogCoordinator {
  const CanvasDialogCoordinator._();

  static void showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showExportDialog(
    BuildContext context,
    CanvasViewportController viewport,
    Size viewSize,
  ) {
    final elements = context.read<CanvasBloc>().state.elements;
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
          viewport.zoomToFit(imported, viewSize);
          showToast(context, 'Imported ${imported.length} element(s) to canvas');
        },
      ),
    );
  }

  static void showTemplatesDialog(
    BuildContext context,
    CanvasViewportController viewport,
    Size viewSize,
  ) {
    showDialog(
      context: context,
      builder: (_) => TemplatePickerDialog(
        onSelectTemplate: (type) {
          final center = viewport.toWorld(
            Offset(viewSize.width / 2, viewSize.height / 2),
          );
          final templateEls = TemplateGenerator.generate(type, center);
          context.read<CanvasBloc>().add(CanvasEvent.addElements(templateEls));
          viewport.zoomToFit(templateEls, viewSize);
          showToast(context, 'Inserted template');
        },
        onOpenMermaid: ([script]) =>
            showMermaidDialog(context, viewport, viewSize, script),
      ),
    );
  }

  static void showMermaidDialog(
    BuildContext context,
    CanvasViewportController viewport,
    Size viewSize, [
    String? initialScript,
  ]) {
    final center = viewport.toWorld(
      Offset(viewSize.width / 2, viewSize.height / 2),
    );

    showDialog(
      context: context,
      builder: (_) => MermaidDialog(
        initialScript: initialScript,
        targetOrigin: center - const Offset(200, 150),
        onInsert: (elements) {
          context.read<CanvasBloc>().add(CanvasEvent.addElements(elements));
          viewport.zoomToFit(elements, viewSize);
          showToast(
            context,
            'Inserted Mermaid diagram (${elements.length} items)',
          );
        },
      ),
    );
  }

  static void showAiPromptBarDialog(
    BuildContext context,
    CanvasViewportController viewport,
    Size viewSize,
  ) {
    final center = viewport.toWorld(
      Offset(viewSize.width / 2, viewSize.height / 2),
    );

    showDialog(
      context: context,
      builder: (_) => AiPromptBarDialog(
        targetOrigin: center - const Offset(200, 150),
        onInsert: (elements) {
          context.read<CanvasBloc>().add(CanvasEvent.addElements(elements));
          final ids = elements.map((e) => e.id).toSet();
          context.read<CanvasBloc>().add(CanvasEvent.selectElements(ids));
          viewport.zoomToFit(elements, viewSize);
          showToast(
            context,
            '✨ Injected ${elements.length} AI diagram elements',
          );
        },
      ),
    );
  }

  static void showShortcutsHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ShortcutsHelpDialog(),
    );
  }

  static Future<void> handleInsertImage(
    BuildContext context,
    CanvasViewportController viewport,
    Size viewSize,
  ) async {
    final picked = await ImageService.pickImage();
    if (picked != null && context.mounted) {
      final center = viewport.toWorld(
        Offset(viewSize.width / 2, viewSize.height / 2),
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
      showToast(context, 'Inserted Image');
    }
  }

  static void showCommandPaletteDialog({
    required BuildContext context,
    required CanvasViewportController viewport,
    required Size viewSize,
    VoidCallback? onToggleTheme,
    VoidCallback? onOpenExport,
    VoidCallback? onOpenTemplates,
    VoidCallback? onStartPresentation,
    VoidCallback? onOpenHelp,
    VoidCallback? onInsertImage,
    VoidCallback? onOpenMermaidImport,
    VoidCallback? onOpenAiPrompt,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => CommandPaletteDialog(
        viewport: viewport,
        viewSize: viewSize,
        onToggleTheme: onToggleTheme,
        onOpenExport: onOpenExport,
        onOpenTemplates: onOpenTemplates,
        onStartPresentation: onStartPresentation,
        onOpenHelp: onOpenHelp,
        onInsertImage: onInsertImage,
        onOpenMermaidImport: onOpenMermaidImport,
        onOpenAiPrompt: onOpenAiPrompt,
      ),
    );
  }
}
