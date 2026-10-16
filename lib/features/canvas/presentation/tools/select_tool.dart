import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/snap_guide.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'package:flutcanvas/features/canvas/domain/models/transform_handle.dart';
import 'canvas_tool.dart';
import 'canvas_tool_context.dart';

enum _SelectSubMode {
  none,
  moving,
  resizing,
  rotating,
  marquee,
}

class SelectTool implements CanvasTool {
  _SelectSubMode _subMode = _SelectSubMode.none;
  HandleType? _activeHandle;
  Rect? _initialSelectedBounds;
  List<BoardElement>? _initialElements;
  Set<String>? _activeDragIds;
  double _startRotationAngle = 0.0;
  Offset? _startPoint;

  @override
  Tool get toolType => Tool.select;

  @override
  MouseCursor get cursor {
    if (_subMode == _SelectSubMode.resizing && _activeHandle != null) {
      return TransformHandle.cursorForHandle(_activeHandle!);
    }
    if (_subMode == _SelectSubMode.rotating) {
      return SystemMouseCursors.grab;
    }
    if (_subMode == _SelectSubMode.moving) {
      return SystemMouseCursors.move;
    }
    return SystemMouseCursors.basic;
  }

  Rect? _getBoundsForIds(CanvasToolContext context, Set<String> ids) {
    final selected = context.elements
        .where((e) => ids.contains(e.id))
        .toList();
    if (selected.isEmpty) return null;
    Rect combined = selected.first.bounds;
    for (var i = 1; i < selected.length; i++) {
      combined = combined.expandToInclude(selected[i].bounds);
    }
    return combined;
  }

  Rect? _getSelectedBounds(CanvasToolContext context) {
    return _getBoundsForIds(context, context.selectedIds);
  }

  @override
  void onPointerDown(Offset worldPos, CanvasToolContext context) {
    _startPoint = worldPos;

    // 1. Hit-test transform handles if elements are selected
    final selectedBounds = _getSelectedBounds(context);
    if (selectedBounds != null) {
      final handle = TransformHandle.hitTest(selectedBounds, worldPos, context.zoom);
      if (handle != null) {
        _activeHandle = handle;
        _initialSelectedBounds = selectedBounds;
        _initialElements = List.of(context.elements);
        _activeDragIds = Set<String>.from(context.selectedIds);

        if (handle == HandleType.rotation) {
          final center = selectedBounds.center;
          _startRotationAngle =
              math.atan2(worldPos.dy - center.dy, worldPos.dx - center.dx);
          _subMode = _SelectSubMode.rotating;
        } else {
          _subMode = _SelectSubMode.resizing;
        }
        return;
      }
    }

    // 2. Hit-test elements
    final hit = context.hitTestTopmost(worldPos);

    if (hit != null) {
      final targetIds = <String>{};
      if (hit.groupId != null) {
        for (final el in context.elements) {
          if (el.groupId == hit.groupId) targetIds.add(el.id);
        }
      } else {
        targetIds.add(hit.id);
      }

      final Set<String> effectiveSelection;
      if (context.isShiftDown) {
        final currentSelection = Set<String>.from(context.selectedIds);
        if (currentSelection.containsAll(targetIds)) {
          currentSelection.removeAll(targetIds);
        } else {
          currentSelection.addAll(targetIds);
        }
        context.selectElements(currentSelection);
        effectiveSelection = currentSelection;
      } else {
        if (!context.selectedIds.contains(hit.id)) {
          context.selectElements(targetIds);
          effectiveSelection = targetIds;
        } else {
          effectiveSelection = Set<String>.from(context.selectedIds);
        }
      }

      _activeDragIds = effectiveSelection;
      _initialSelectedBounds = _getBoundsForIds(context, effectiveSelection);
      _initialElements = List.of(context.elements);
      _subMode = _SelectSubMode.moving;
    } else {
      // Clicked on empty canvas -> clear selection & start marquee
      if (!context.isShiftDown) {
        context.clearSelection();
      }
      _activeDragIds = null;
      _subMode = _SelectSubMode.marquee;
      context.setMarquee(Rect.fromPoints(worldPos, worldPos));
    }
  }

  @override
  void onPointerMove(Offset worldPos, CanvasToolContext context) {
    if (_startPoint == null) return;

    if (_subMode == _SelectSubMode.marquee) {
      final marqueeRect = Rect.fromPoints(_startPoint!, worldPos);
      context.setMarquee(marqueeRect);

      final selectedInMarquee = <String>{};
      for (final el in context.elements) {
        if (!el.isLocked && el.bounds.overlaps(marqueeRect)) {
          selectedInMarquee.add(el.id);
        }
      }
      context.selectElements(selectedInMarquee);
    } else if (_subMode == _SelectSubMode.resizing) {
      final initialBounds = _initialSelectedBounds;
      final handle = _activeHandle;
      final initialEls = _initialElements;
      final targetIds = _activeDragIds ?? context.selectedIds;
      if (initialBounds != null && handle != null && initialEls != null) {
        final totalDelta = worldPos - _startPoint!;
        var newBounds =
            TransformHandle.resizeRect(initialBounds, handle, totalDelta);

        if (context.gridSnap) {
          const snap = 24.0;
          double left = newBounds.left;
          double top = newBounds.top;
          double right = newBounds.right;
          double bottom = newBounds.bottom;

          switch (handle) {
            case HandleType.topLeft:
              left = (left / snap).roundToDouble() * snap;
              top = (top / snap).roundToDouble() * snap;
              break;
            case HandleType.topCenter:
              top = (top / snap).roundToDouble() * snap;
              break;
            case HandleType.topRight:
              right = (right / snap).roundToDouble() * snap;
              top = (top / snap).roundToDouble() * snap;
              break;
            case HandleType.centerLeft:
              left = (left / snap).roundToDouble() * snap;
              break;
            case HandleType.centerRight:
              right = (right / snap).roundToDouble() * snap;
              break;
            case HandleType.bottomLeft:
              left = (left / snap).roundToDouble() * snap;
              bottom = (bottom / snap).roundToDouble() * snap;
              break;
            case HandleType.bottomCenter:
              bottom = (bottom / snap).roundToDouble() * snap;
              break;
            case HandleType.bottomRight:
              right = (right / snap).roundToDouble() * snap;
              bottom = (bottom / snap).roundToDouble() * snap;
              break;
            case HandleType.rotation:
              break;
          }

          if (right < left + snap) {
            if (handle == HandleType.topLeft ||
                handle == HandleType.centerLeft ||
                handle == HandleType.bottomLeft) {
              left = right - snap;
            } else {
              right = left + snap;
            }
          }
          if (bottom < top + snap) {
            if (handle == HandleType.topLeft ||
                handle == HandleType.topCenter ||
                handle == HandleType.topRight) {
              top = bottom - snap;
            } else {
              bottom = top + snap;
            }
          }
          newBounds = Rect.fromLTRB(left, top, right, bottom);
        } else if (context.smartGuides) {
          final otherElements = context.elements
              .where((e) => !targetIds.contains(e.id) && e.isVisible)
              .toList();
          final snapResult = SnapService.calculateResizeSnap(
            newBounds: newBounds,
            handle: handle,
            otherElements: otherElements,
            zoom: context.zoom,
          );
          newBounds = snapResult.snappedBounds;
          context.setSnapGuides(snapResult.guides);
        }

        for (final el in initialEls) {
          if (targetIds.contains(el.id) && !el.isLocked) {
            context.updateElement(el.scaled(initialBounds, newBounds));
          }
        }
      }
    } else if (_subMode == _SelectSubMode.rotating) {
      final initialBounds = _initialSelectedBounds;
      final initialEls = _initialElements;
      final targetIds = _activeDragIds ?? context.selectedIds;
      if (initialBounds != null && initialEls != null) {
        final center = initialBounds.center;
        final currentAngle =
            math.atan2(worldPos.dy - center.dy, worldPos.dx - center.dx);
        var deltaAngle = currentAngle - _startRotationAngle;

        if (context.isShiftDown) {
          const step = math.pi / 12; // 15 degrees snap
          deltaAngle = (deltaAngle / step).roundToDouble() * step;
        }

        for (final el in initialEls) {
          if (targetIds.contains(el.id) && !el.isLocked) {
            context.updateElement(el.rotated(deltaAngle));
          }
        }
      }
    } else if (_subMode == _SelectSubMode.moving) {
      final initialBounds = _initialSelectedBounds;
      final initialEls = _initialElements;
      final targetIds = _activeDragIds ?? context.selectedIds;
      if (initialBounds != null && initialEls != null) {
        var totalDelta = worldPos - _startPoint!;

        if (context.gridSnap) {
          const snap = 24.0;
          final targetTopLeft = initialBounds.topLeft + totalDelta;
          final snappedTopLeft = Offset(
            (targetTopLeft.dx / snap).roundToDouble() * snap,
            (targetTopLeft.dy / snap).roundToDouble() * snap,
          );
          totalDelta = snappedTopLeft - initialBounds.topLeft;
        } else if (context.smartGuides) {
          final otherElements = context.elements
              .where((e) => !targetIds.contains(e.id) && e.isVisible)
              .toList();
          final snapResult = SnapService.calculateSnap(
            initialBounds: initialBounds,
            rawDisplacement: totalDelta,
            otherElements: otherElements,
            zoom: context.zoom,
          );
          context.setSnapGuides(snapResult.guides);
          totalDelta = snapResult.snappedDisplacement;
        }

        for (final el in initialEls) {
          if (targetIds.contains(el.id) && !el.isLocked) {
            context.updateElement(el.translated(totalDelta));
          }
        }
      }
    }
  }

  @override
  void onPointerUp(Offset worldPos, CanvasToolContext context) {
    if (_subMode == _SelectSubMode.marquee) {
      context.setMarquee(null);
    } else if (_subMode == _SelectSubMode.moving ||
        _subMode == _SelectSubMode.resizing) {
      context.setSnapGuides(const []);
    }
    _subMode = _SelectSubMode.none;
    _activeHandle = null;
    _initialSelectedBounds = null;
    _initialElements = null;
    _activeDragIds = null;
    _startPoint = null;
  }

  @override
  void onPointerCancel(CanvasToolContext context) {
    if (_subMode == _SelectSubMode.marquee) {
      context.setMarquee(null);
    } else if (_subMode == _SelectSubMode.moving ||
        _subMode == _SelectSubMode.resizing) {
      context.setSnapGuides(const []);
    }
    _subMode = _SelectSubMode.none;
    _activeHandle = null;
    _initialSelectedBounds = null;
    _initialElements = null;
    _activeDragIds = null;
    _startPoint = null;
  }

  @override
  void onPointerHover(Offset worldPos, CanvasToolContext context) {}
}
