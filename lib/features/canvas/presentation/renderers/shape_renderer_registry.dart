import 'package:flutter/material.dart';
import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'shape_renderer.dart';

class ShapeRendererRegistry {
  static final ShapeRendererRegistry instance = ShapeRendererRegistry();

  final List<ShapeRenderer> _renderers = [];

  void register(ShapeRenderer renderer) {
    _renderers.add(renderer);
  }

  ShapeRenderer? getRenderer(ShapeType type) {
    for (final r in _renderers.reversed) {
      if (r.canRender(type)) return r;
    }
    return null;
  }

  void render(Canvas canvas, BoardElement el, BoardColors colors) {
    canvas.save();

    // 1. Rotation transform around element bounds center
    if (el.rotation != 0.0) {
      final c = el.bounds.center;
      canvas.translate(c.dx, c.dy);
      canvas.rotate(el.rotation);
      canvas.translate(-c.dx, -c.dy);
    }

    // 2. Dispatch to matching renderer
    final renderer = getRenderer(el.type);
    if (renderer != null) {
      renderer.render(canvas, el, colors);
    }

    canvas.restore();
  }
}
