import 'package:flutter/material.dart';
import '../../../../core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';

abstract interface class ShapeRenderer {
  bool canRender(ShapeType type);
  void render(Canvas canvas, BoardElement element, BoardColors colors);
}
