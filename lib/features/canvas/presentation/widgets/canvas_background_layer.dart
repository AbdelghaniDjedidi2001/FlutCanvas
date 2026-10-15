import 'package:flutter/material.dart';
import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/grid_painter.dart';
import '../controllers/canvas_viewport_controller.dart';

class CanvasBackgroundLayer extends StatelessWidget {
  final CanvasViewportController viewport;

  const CanvasBackgroundLayer({super.key, required this.viewport});

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    return ListenableBuilder(
      listenable: viewport,
      builder: (context, _) {
        return CustomPaint(
          painter: _GridCustomPainter(
            pan: viewport.pan,
            zoom: viewport.zoom,
            colors: colors,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _GridCustomPainter extends CustomPainter {
  final Offset pan;
  final double zoom;
  final BoardColors colors;

  const _GridCustomPainter({
    required this.pan,
    required this.zoom,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(zoom);
    GridPainter.draw(canvas, size, pan, zoom, colors);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GridCustomPainter oldDelegate) =>
      oldDelegate.pan != pan ||
      oldDelegate.zoom != zoom ||
      oldDelegate.colors != colors;
}
