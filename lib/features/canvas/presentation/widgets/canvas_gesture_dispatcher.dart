import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/board_element.dart';
import '../../domain/models/connector_style.dart';
import '../../domain/models/snap_guide.dart';
import '../../domain/models/stroke_fill_style.dart';
import '../../domain/models/tool.dart';
import '../../../../painters/laser_painter.dart';
import '../bloc/canvas_bloc.dart';
import '../bloc/canvas_event.dart';
import '../controllers/canvas_interaction_controller.dart';
import '../controllers/canvas_viewport_controller.dart';
import '../tools/canvas_tool.dart';
import '../tools/canvas_tool_context.dart';
import '../tools/tool_registry.dart';
import '../../../toolbar/presentation/bloc/tool_cubit.dart';

class CanvasGestureDispatcher extends StatefulWidget {
  final CanvasViewportController viewport;
  final CanvasInteractionController interaction;
  final ToolRegistry toolRegistry;
  final void Function(Offset world, Offset screen, {required bool isSticky})?
      onOpenTextEditor;
  final Widget child;

  const CanvasGestureDispatcher({
    super.key,
    required this.viewport,
    required this.interaction,
    required this.toolRegistry,
    this.onOpenTextEditor,
    required this.child,
  });

  @override
  State<CanvasGestureDispatcher> createState() =>
      _CanvasGestureDispatcherState();
}

class _CanvasGestureDispatcherState extends State<CanvasGestureDispatcher>
    implements CanvasToolContext {
  int _idCounter = 0;
  bool _isMiddlePanning = false;
  Offset _lastScreenPos = Offset.zero;

  // CanvasToolContext implementation
  @override
  List<BoardElement> get elements => context.read<CanvasBloc>().state.elements;

  @override
  Set<String> get selectedIds =>
      context.read<CanvasBloc>().state.selectedIds;

  @override
  double get zoom => widget.viewport.zoom;

  @override
  Offset get pan => widget.viewport.pan;

  @override
  Color get strokeColor =>
      context.read<ToolCubit>().state.strokeColor;

  @override
  Color get fillColor =>
      context.read<ToolCubit>().state.fillColor;

  @override
  double get strokeWidth =>
      context.read<ToolCubit>().state.strokeWidth;

  @override
  StrokeStyle get strokeStyle =>
      context.read<ToolCubit>().state.strokeStyle;

  @override
  FillStyle get fillStyle =>
      context.read<ToolCubit>().state.fillStyle;

  @override
  DrawStyle get drawStyle =>
      context.read<ToolCubit>().state.drawStyle;

  @override
  double get fontSize =>
      context.read<ToolCubit>().state.fontSize;

  @override
  double get opacity =>
      context.read<ToolCubit>().state.opacity;

  @override
  ConnectorStyle get connectorStyle =>
      context.read<ToolCubit>().state.connectorStyle;

  @override
  void setDraft(BoardElement? draft) => widget.interaction.setDraft(draft);

  @override
  void setMarquee(Rect? marquee) => widget.interaction.setMarquee(marquee);

  @override
  void setLaserTrail(List<LaserPoint> trail) =>
      widget.interaction.setLaserTrail(trail);

  @override
  void setSnapGuides(List<SnapGuide> guides) =>
      widget.interaction.setSnapGuides(guides);

  @override
  void commitElement(BoardElement element) {
    context.read<CanvasBloc>().add(CanvasEvent.addElement(element));
  }

  @override
  void commitElements(List<BoardElement> elements) {
    context.read<CanvasBloc>().add(CanvasEvent.addElements(elements));
  }

  @override
  void updateElement(BoardElement element) {
    context.read<CanvasBloc>().add(CanvasEvent.updateElement(element));
  }

  @override
  void deleteElements(Set<String> ids) {
    context.read<CanvasBloc>().add(CanvasEvent.deleteElements(ids));
  }

  @override
  void selectElements(Set<String> ids) {
    context.read<CanvasBloc>().add(CanvasEvent.selectElements(ids));
  }

  @override
  void clearSelection() {
    context.read<CanvasBloc>().add(const CanvasEvent.clearSelection());
  }

  @override
  String generateElementId() {
    _idCounter++;
    return 'el_${DateTime.now().millisecondsSinceEpoch}_$_idCounter';
  }

  @override
  BoardElement? hitTestTopmost(Offset worldPos) {
    final tol = 6.0 / widget.viewport.zoom;
    for (final el in elements.reversed) {
      if (el.isVisible && el.hitTest(worldPos, tol)) {
        return el;
      }
    }
    return null;
  }

  CanvasTool _getActiveTool() {
    final activeToolType = context.read<ToolCubit>().state.currentTool;
    return widget.toolRegistry.get(activeToolType);
  }

  void _onPointerDown(PointerDownEvent event) {
    _lastScreenPos = event.position;

    // Middle mouse button or Hand tool -> Pan canvas
    if (event.buttons == kMiddleMouseButton ||
        context.read<ToolCubit>().state.currentTool == Tool.hand) {
      _isMiddlePanning = true;
      return;
    }

    final activeToolType = context.read<ToolCubit>().state.currentTool;
    final world = widget.viewport.toWorld(event.localPosition);

    if (activeToolType == Tool.text || activeToolType == Tool.stickyNote) {
      widget.onOpenTextEditor?.call(
        world,
        event.localPosition,
        isSticky: activeToolType == Tool.stickyNote,
      );
      return;
    }

    _getActiveTool().onPointerDown(world, this);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isMiddlePanning) {
      final delta = event.position - _lastScreenPos;
      widget.viewport.panBy(delta);
      _lastScreenPos = event.position;
      return;
    }

    final world = widget.viewport.toWorld(event.localPosition);
    _getActiveTool().onPointerMove(world, this);
    _lastScreenPos = event.position;
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isMiddlePanning) {
      _isMiddlePanning = false;
      return;
    }

    final world = widget.viewport.toWorld(event.localPosition);
    _getActiveTool().onPointerUp(world, this);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _isMiddlePanning = false;
    _getActiveTool().onPointerCancel(this);
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // Pinch / trackpad zoom with Ctrl/Cmd or standard trackpad 2-finger scroll
      final isZoom = HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed;

      if (isZoom) {
        final factor = event.scrollDelta.dy < 0 ? 1.05 : 0.95;
        widget.viewport.zoomAt(event.localPosition, widget.viewport.zoom * factor);
      } else {
        // Standard pan scroll
        widget.viewport.panBy(-event.scrollDelta);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tool = _getActiveTool();
    return MouseRegion(
      cursor: tool.cursor,
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        onPointerSignal: _onPointerSignal,
        behavior: HitTestBehavior.opaque,
        child: widget.child,
      ),
    );
  }
}
