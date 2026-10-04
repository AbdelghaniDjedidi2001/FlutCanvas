import 'package:flutter/material.dart';
import '../controllers/canvas_viewport_controller.dart';

class CanvasViewport extends StatelessWidget {
  final CanvasViewportController controller;
  final Widget child;

  const CanvasViewport({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return ClipRect(
          child: Transform(
            transform: Matrix4.identity()
              ..translate(controller.pan.dx, controller.pan.dy)
              ..scale(controller.zoom),
            child: child,
          ),
        );
      },
    );
  }
}
