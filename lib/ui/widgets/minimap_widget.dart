import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';

class MinimapWidget extends StatefulWidget {
  const MinimapWidget({
    super.key,
    required this.elements,
    required this.pan,
    required this.zoom,
    required this.viewSize,
    required this.onJumpTo,
    required this.colors,
  });

  final List<BoardElement> elements;
  final Offset pan;
  final double zoom;
  final Size viewSize;
  final void Function(Offset newPan) onJumpTo;
  final BoardColors colors;

  @override
  State<MinimapWidget> createState() => _MinimapWidgetState();
}

class _MinimapWidgetState extends State<MinimapWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (!_expanded) {
      return Material(
        color: scheme.surfaceContainerHigh,
        elevation: 3,
        shadowColor: const Color(0x33000000),
        borderRadius: BorderRadius.circular(12),
        child: IconButton(
          tooltip: 'Show Minimap',
          onPressed: () => setState(() => _expanded = true),
          icon: const Icon(Icons.map_outlined, size: 20),
        ),
      );
    }

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 4,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 180,
        height: 120,
        padding: const EdgeInsets.all(6),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onPanDown: (d) => _handleMinimapTap(d.localPosition),
                onPanUpdate: (d) => _handleMinimapTap(d.localPosition),
                child: CustomPaint(
                  painter: _MinimapPainter(
                    elements: widget.elements,
                    pan: widget.pan,
                    zoom: widget.zoom,
                    viewSize: widget.viewSize,
                    colors: widget.colors,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () => setState(() => _expanded = false),
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMinimapTap(Offset localPos) {
    if (widget.elements.isEmpty || widget.viewSize.isEmpty) return;

    Rect contentBounds = widget.elements.first.bounds;
    for (final el in widget.elements) {
      contentBounds = contentBounds.expandToInclude(el.bounds);
    }
    contentBounds = contentBounds.inflate(500);

    const mapSize = Size(168, 108);
    final scaleX = mapSize.width / contentBounds.width;
    final scaleY = mapSize.height / contentBounds.height;
    final scale = math.min(scaleX, scaleY);

    final clickedWorldX = contentBounds.left + localPos.dx / scale;
    final clickedWorldY = contentBounds.top + localPos.dy / scale;

    final newPan = Offset(
      widget.viewSize.width / 2 - clickedWorldX * widget.zoom,
      widget.viewSize.height / 2 - clickedWorldY * widget.zoom,
    );
    widget.onJumpTo(newPan);
  }
}

class _MinimapPainter extends CustomPainter {
  _MinimapPainter({
    required this.elements,
    required this.pan,
    required this.zoom,
    required this.viewSize,
    required this.colors,
  });

  final List<BoardElement> elements;
  final Offset pan;
  final double zoom;
  final Size viewSize;
  final BoardColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = colors.background,
    );

    if (elements.isEmpty || viewSize.isEmpty) return;

    Rect contentBounds = elements.first.bounds;
    for (final el in elements) {
      contentBounds = contentBounds.expandToInclude(el.bounds);
    }
    contentBounds = contentBounds.inflate(500);

    final scaleX = size.width / contentBounds.width;
    final scaleY = size.height / contentBounds.height;
    final scale = math.min(scaleX, scaleY);

    canvas.save();
    canvas.scale(scale);
    canvas.translate(-contentBounds.left, -contentBounds.top);

    // Draw miniature elements
    final elPaint = Paint()
      ..color = colors.ink.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    for (final el in elements) {
      canvas.drawRect(el.bounds, elPaint);
    }

    // Draw Viewport rectangle
    final vpWorld = Rect.fromPoints(
      (Offset.zero - pan) / zoom,
      (Offset(viewSize.width, viewSize.height) - pan) / zoom,
    );

    final vpPaint = Paint()
      ..color = colors.selection.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final vpBorder = Paint()
      ..color = colors.selection
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 / scale;

    canvas.drawRect(vpWorld, vpPaint);
    canvas.drawRect(vpWorld, vpBorder);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter old) => true;
}
