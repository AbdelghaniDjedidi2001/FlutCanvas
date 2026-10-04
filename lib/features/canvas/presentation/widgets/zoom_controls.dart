import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';

class ZoomControls extends StatelessWidget {
  const ZoomControls({
    super.key,
    this.controller,
    this.zoom = 1.0,
    this.onZoomIn,
    this.onZoomOut,
    this.onResetZoom,
    this.isGridSnap = false,
    this.onToggleGridSnap,
    this.isSmartGuides = true,
    this.onToggleSmartGuides,
    this.isShapeSnapping = true,
    this.onToggleShapeSnapping,
  });

  final CanvasViewportController? controller;
  final double zoom;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onResetZoom;
  final bool isGridSnap;
  final VoidCallback? onToggleGridSnap;
  final bool isSmartGuides;
  final VoidCallback? onToggleSmartGuides;
  final bool isShapeSnapping;
  final VoidCallback? onToggleShapeSnapping;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 3,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Zoom out',
              onPressed: onZoomOut ??
                  (controller != null
                      ? () => controller!.setZoom(controller!.zoom / 1.25)
                      : null),
              icon: const Icon(Icons.remove, size: 18),
            ),
            Tooltip(
              message: 'Reset view to 100%',
              child: TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: onResetZoom ?? controller?.reset,
                child: Text(
                  '${((controller?.zoom ?? zoom) * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Zoom in',
              onPressed: onZoomIn ??
                  (controller != null
                      ? () => controller!.setZoom(controller!.zoom * 1.25)
                      : null),
              icon: const Icon(Icons.add, size: 18),
            ),
            Container(
              width: 1,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: scheme.outlineVariant,
            ),
            Tooltip(
              message: isGridSnap ? 'Grid snapping: ON (G)' : 'Grid snapping: OFF (G)',
              child: IconButton(
                onPressed: onToggleGridSnap,
                icon: Icon(
                  isGridSnap ? Icons.grid_on : Icons.grid_off_outlined,
                  size: 18,
                  color: isGridSnap ? scheme.primary : null,
                ),
              ),
            ),
            if (onToggleSmartGuides != null)
              Tooltip(
                message: isSmartGuides
                    ? 'Smart Alignment Guides: ON (S)'
                    : 'Smart Alignment Guides: OFF (S)',
                child: IconButton(
                  onPressed: onToggleSmartGuides,
                  icon: Icon(
                    isSmartGuides ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                    size: 18,
                    color: isSmartGuides ? scheme.primary : null,
                  ),
                ),
              ),
            if (onToggleShapeSnapping != null)
              Tooltip(
                message: isShapeSnapping
                    ? 'Sketch-to-Shape Auto Snap (Hold stroke): ON'
                    : 'Sketch-to-Shape Auto Snap: OFF',
                child: IconButton(
                  onPressed: onToggleShapeSnapping,
                  icon: Icon(
                    isShapeSnapping ? Icons.polyline_rounded : Icons.polyline_outlined,
                    size: 18,
                    color: isShapeSnapping ? scheme.primary : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
