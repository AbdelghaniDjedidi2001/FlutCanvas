import 'package:flutter/material.dart';
import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/snap_guide.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/connection_anchor_painter.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/element_renderer.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/laser_painter.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/selection_painter.dart';
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
            snapGuides: interaction.snapGuides,
            hoveredAnchorElement: interaction.hoveredAnchorElement,
            activeAnchorPoint: interaction.activeAnchorPoint,
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
  final List<SnapGuide> snapGuides;
  final BoardElement? hoveredAnchorElement;
  final Offset? activeAnchorPoint;
  final BoardColors colors;

  const _OverlayCustomPainter({
    required this.pan,
    required this.zoom,
    required this.draft,
    required this.marqueeRect,
    required this.laserTrail,
    required this.snapGuides,
    required this.hoveredAnchorElement,
    required this.activeAnchorPoint,
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
      SelectionPainter.drawMarquee(canvas, marqueeRect!, zoom, colors);
    }

    // 3. Laser trail
    if (laserTrail.isNotEmpty) {
      LaserPainter.draw(canvas, laserTrail, colors.laser);
    }

    // 4. Snap guidelines
    if (snapGuides.isNotEmpty) {
      SelectionPainter.drawSnapGuides(canvas, snapGuides, zoom, colors);
    }

    // 5. Magnetic connection anchor highlights
    if (hoveredAnchorElement != null) {
      ConnectionAnchorPainter.drawAnchors(
        canvas,
        hoveredAnchorElement!,
        activeAnchorPoint,
        zoom,
        colors,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OverlayCustomPainter oldDelegate) => true;
}
