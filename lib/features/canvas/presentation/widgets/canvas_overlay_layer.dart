import 'package:flutter/material.dart';
import '../../../../core/constants/board_colors.dart';
import '../../../../painters/element_renderer.dart';
import '../../../../painters/laser_painter.dart';
import '../controllers/canvas_interaction_controller.dart';
import '../controllers/canvas_viewport_controller.dart';

class CanvasOverlayLayer extends StatelessWidget {
  final CanvasViewportController viewport;
  final CanvasInteractionController interaction;

  const CanvasOverlayLayer({
    super.key,
    required this.viewport,
    required this.interaction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([viewport, interaction]),
      builder: (context, _) {
        return CustomPaint(
          painter: _OverlayCustomPainter(
            pan: viewport.pan,
            zoom: viewport.zoom,
            draft: interaction.draft,
            marqueeRect: interaction.marqueeRect,
            laserTrail: interaction.laserTrail,
            colors: colors,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _OverlayCustomPainter extends CustomPainter {
  final Offset pan;
  final double zoom;
  final dynamic draft;
  final Rect? marqueeRect;
  final List<LaserPoint> laserTrail;
  final BoardColors colors;

  const _OverlayCustomPainter({
    required this.pan,
    required this.zoom,
    required this.draft,
    required this.marqueeRect,
    required this.laserTrail,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(zoom);

    // 1. Live Draft element
    if (draft != null) {
      ElementRenderer.draw(canvas, draft, colors);
    }

    // 2. Marquee selection rectangle
    if (marqueeRect != null) {
      final fillPaint = Paint()
        ..color = const Color(0xFF3B5BDB).withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = const Color(0xFF3B5BDB)
        ..strokeWidth = 1.0 / zoom
        ..style = PaintingStyle.stroke;

      canvas.drawRect(marqueeRect!, fillPaint);
      canvas.drawRect(marqueeRect!, borderPaint);
    }

    // 3. Laser trail
    if (laserTrail.isNotEmpty) {
      LaserPainter.draw(canvas, laserTrail, zoom);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OverlayCustomPainter oldDelegate) => true;
}
