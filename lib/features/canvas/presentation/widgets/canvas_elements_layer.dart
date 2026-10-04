import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/element_renderer.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/selection_painter.dart';
import '../bloc/canvas_bloc.dart';
import '../bloc/canvas_state.dart';
import '../controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';

class CanvasElementsLayer extends StatelessWidget {
  final CanvasViewportController viewport;

  const CanvasElementsLayer({super.key, required this.viewport});

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);

    return ListenableBuilder(
      listenable: viewport,
      builder: (context, _) {
        return BlocBuilder<CanvasBloc, CanvasState>(
          builder: (context, canvasState) {
            return CustomPaint(
              painter: _ElementsCustomPainter(
                elements: canvasState.elements,
                selectedIds: canvasState.selectedIds,
                pan: viewport.pan,
                zoom: viewport.zoom,
                colors: colors,
              ),
              size: Size.infinite,
            );
          },
        );
      },
    );
  }
}

class _ElementsCustomPainter extends CustomPainter {
  final List<BoardElement> elements;
  final Set<String> selectedIds;
  final Offset pan;
  final double zoom;
  final BoardColors colors;

  const _ElementsCustomPainter({
    required this.elements,
    required this.selectedIds,
    required this.pan,
    required this.zoom,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(zoom);

    // 1. Visible bounds culling for high-performance rendering
    final visible = Rect.fromPoints(
      (Offset.zero - pan) / zoom,
      (Offset(size.width, size.height) - pan) / zoom,
    ).inflate(80 / zoom);

    for (final el in elements) {
      if (!el.isVisible) continue;
      if (el.bounds.overlaps(visible) || el.bounds.isEmpty) {
        ElementRenderer.draw(canvas, el, colors);
      }
    }

    // 2. Selection highlights and transform handles
    final selectedElements =
        elements.where((e) => selectedIds.contains(e.id)).toList();
    if (selectedElements.isNotEmpty) {
      SelectionPainter.drawSelection(canvas, selectedElements, zoom, colors);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ElementsCustomPainter oldDelegate) =>
      oldDelegate.elements != elements ||
      oldDelegate.selectedIds != selectedIds ||
      oldDelegate.pan != pan ||
      oldDelegate.zoom != zoom ||
      oldDelegate.colors != colors;
}
