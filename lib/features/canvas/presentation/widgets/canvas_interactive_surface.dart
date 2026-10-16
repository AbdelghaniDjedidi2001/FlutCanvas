import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_interaction_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_text_editing_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/tools/tool_registry.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_background_layer.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_elements_layer.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_gesture_dispatcher.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/canvas_overlay_layer.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';

/// Interactive multi-layer canvas surface containing gestures, background grid,
/// elements layer, and transient tool overlays.
class CanvasInteractiveSurface extends StatelessWidget {
  final CanvasViewportController viewport;
  final CanvasInteractionController interaction;
  final ToolRegistry toolRegistry;
  final CanvasTextEditingController textEditingController;
  final FocusNode focusNode;
  final VoidCallback onInsertImage;

  const CanvasInteractiveSurface({
    super.key,
    required this.viewport,
    required this.interaction,
    required this.toolRegistry,
    required this.textEditingController,
    required this.focusNode,
    required this.onInsertImage,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CanvasGestureDispatcher(
        viewport: viewport,
        interaction: interaction,
        toolRegistry: toolRegistry,
        focusNode: focusNode,
        onOpenTextEditor: (world, screen, {required isSticky}) {
          final toolState = context.read<ToolCubit>().state;
          final colors = BoardColors.of(context);
          final newElement = textEditingController.createAndStartTextEditing(
            worldPos: world,
            screenPos: screen,
            isSticky: isSticky,
            toolState: toolState,
            colors: colors,
          );
          context.read<CanvasBloc>().add(CanvasEvent.addElement(newElement));
        },
        onInsertImage: onInsertImage,
        child: GestureDetector(
          onDoubleTapDown: (details) {
            final elements = context.read<CanvasBloc>().state.elements;
            textEditingController.handleDoubleTap(
              localPos: details.localPosition,
              elements: elements,
              viewport: viewport,
            );
          },
          child: Stack(
            children: [
              // Background Grid
              CanvasBackgroundLayer(viewport: viewport),
              // Committed Elements
              CanvasElementsLayer(viewport: viewport),
              // Live Transient Overlays (Draft, Marquee, Laser)
              CanvasOverlayLayer(
                viewport: viewport,
                interaction: interaction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
