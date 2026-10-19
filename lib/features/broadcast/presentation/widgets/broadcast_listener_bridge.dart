import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/broadcast/presentation/bloc/broadcast_cubit.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_state.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_interaction_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_state.dart';

/// Invisible listener bridging Viewport, CanvasBloc, PresentationCubit,
/// and LaserTool interactions directly to BroadcastCubit.
class BroadcastListenerBridge extends StatefulWidget {
  final CanvasViewportController viewport;
  final CanvasInteractionController interaction;
  final Widget child;

  const BroadcastListenerBridge({
    super.key,
    required this.viewport,
    required this.interaction,
    required this.child,
  });

  @override
  State<BroadcastListenerBridge> createState() => _BroadcastListenerBridgeState();
}

class _BroadcastListenerBridgeState extends State<BroadcastListenerBridge> {
  @override
  void initState() {
    super.initState();
    widget.viewport.addListener(_onViewportChanged);
    widget.interaction.addListener(_onInteractionChanged);
  }

  @override
  void didUpdateWidget(BroadcastListenerBridge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewport != widget.viewport) {
      oldWidget.viewport.removeListener(_onViewportChanged);
      widget.viewport.addListener(_onViewportChanged);
    }
    if (oldWidget.interaction != widget.interaction) {
      oldWidget.interaction.removeListener(_onInteractionChanged);
      widget.interaction.addListener(_onInteractionChanged);
    }
  }

  @override
  void dispose() {
    widget.viewport.removeListener(_onViewportChanged);
    widget.interaction.removeListener(_onInteractionChanged);
    super.dispose();
  }

  void _onViewportChanged() {
    final broadcastCubit = context.read<BroadcastCubit>();
    if (broadcastCubit.state.isBroadcasting) {
      broadcastCubit.broadcastViewportThrottled(
        widget.viewport.pan,
        widget.viewport.zoom,
      );
    }
  }

  void _onInteractionChanged() {
    final broadcastCubit = context.read<BroadcastCubit>();
    if (broadcastCubit.state.isBroadcasting) {
      if (widget.interaction.laserTrail.isNotEmpty) {
        broadcastCubit.broadcastLaser(widget.interaction.laserTrail);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 1. Listen for element additions, edits, deletes
        BlocListener<CanvasBloc, CanvasState>(
          listenWhen: (prev, curr) =>
              prev.elements != curr.elements &&
              context.read<BroadcastCubit>().state.isBroadcasting,
          listener: (context, state) {
            context
                .read<BroadcastCubit>()
                .broadcastElementsUpdate(state.elements);
          },
        ),

        // 2. Listen for presentation slide transitions
        BlocListener<PresentationCubit, PresentationState>(
          listenWhen: (prev, curr) =>
              (prev.currentSlideIndex != curr.currentSlideIndex ||
                  prev.isPresenting != curr.isPresenting) &&
              context.read<BroadcastCubit>().state.isBroadcasting,
          listener: (context, state) {
            if (state.isPresenting && state.slides.isNotEmpty) {
              final activeSlide = state.slides[state.currentSlideIndex];
              context.read<BroadcastCubit>().broadcastSlideChange(
                    slideIndex: state.currentSlideIndex,
                    totalSlides: state.slides.length,
                    title: activeSlide.frameTitle,
                    bounds: activeSlide.bounds,
                  );
            }
          },
        ),
      ],
      child: widget.child,
    );
  }
}
