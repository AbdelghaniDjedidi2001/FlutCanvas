import 'package:flutter/material.dart';

import '../models/board_colors.dart';
import '../models/board_element.dart';
import '../models/snap_guide.dart';
import 'connection_anchor_painter.dart';
import 'element_renderer.dart';
import 'grid_painter.dart';
import 'laser_painter.dart';
import 'selection_painter.dart';

class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.elements,
    required this.draft,
    required this.selectedIds,
    required this.marqueeRect,
    required this.laserTrail,
    required this.hoveredAnchorElement,
    required this.activeAnchorPoint,
    required this.activeSnapGuides,
    required this.pan,
    required this.zoom,
    required this.colors,
  });

  final List<BoardElement> elements;
  final BoardElement? draft;
  final Set<String> selectedIds;
  final Rect? marqueeRect;
  final List<LaserPoint> laserTrail;
  final BoardElement? hoveredAnchorElement;
  final Offset? activeAnchorPoint;
  final List<SnapGuide> activeSnapGuides;
  final Offset pan;
  final double zoom;
  final BoardColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(zoom);

    // 1. Grid
    GridPainter.draw(canvas, size, pan, zoom, colors);

    // 2. Visible elements culling
    final visible = Rect.fromPoints(
      (Offset.zero - pan) / zoom,
      (Offset(size.width, size.height) - pan) / zoom,
    ).inflate(80 / zoom);

    for (final el in elements) {
      if (el.bounds.overlaps(visible) || el.bounds.isEmpty) {
        ElementRenderer.draw(canvas, el, colors);
      }
    }

    // 3. Draft element (being drawn right now)
    if (draft != null) {
      ElementRenderer.draw(canvas, draft!, colors);
    }

    // 4. Marquee selection rect
    if (marqueeRect != null) {
      SelectionPainter.drawMarquee(canvas, marqueeRect!, zoom, colors);
    }

    // 5. Selected elements bounding box & handles
    if (selectedIds.isNotEmpty) {
      final selectedElements =
          elements.where((e) => selectedIds.contains(e.id)).toList();
      if (selectedElements.isNotEmpty) {
        SelectionPainter.drawSelection(canvas, selectedElements, zoom, colors);
      }
    }

    // 5b. Dynamic Magnetic Snapping Guidelines
    if (activeSnapGuides.isNotEmpty) {
      SelectionPainter.drawSnapGuides(canvas, activeSnapGuides, zoom, colors);
    }

    // 6. Magnetic Connection Anchors (when hovering with line/arrow tool)
    if (hoveredAnchorElement != null) {
      ConnectionAnchorPainter.drawAnchors(
        canvas,
        hoveredAnchorElement!,
        activeAnchorPoint,
        zoom,
        colors,
      );
    }

    // 7. Laser pointer trail
    if (laserTrail.isNotEmpty) {
      LaserPainter.draw(canvas, laserTrail, colors.laser);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BoardPainter old) =>
      old.elements != elements ||
      old.draft != draft ||
      old.selectedIds != selectedIds ||
      old.marqueeRect != marqueeRect ||
      old.laserTrail.length != laserTrail.length ||
      old.hoveredAnchorElement != hoveredAnchorElement ||
      old.activeAnchorPoint != activeAnchorPoint ||
      old.activeSnapGuides != activeSnapGuides ||
      old.pan != pan ||
      old.zoom != zoom ||
      old.colors != colors;
}
