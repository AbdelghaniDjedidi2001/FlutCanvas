import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_state.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/widgets/presentation_overlay.dart';

/// Presentation layer that listens to [PresentationCubit], adjusts viewport zoom,
/// and displays the presentation overlay controls.
class PresentationLayer extends StatelessWidget {
  final CanvasViewportController viewport;
  final Size Function() getViewSize;

  const PresentationLayer({
    super.key,
    required this.viewport,
    required this.getViewSize,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PresentationCubit, PresentationState>(
      listenWhen: (prev, curr) =>
          (curr.isPresenting && !prev.isPresenting) ||
          (curr.isPresenting && prev.currentSlideIndex != curr.currentSlideIndex),
      listener: (context, state) {
        final slide = state.currentSlide;
        if (slide != null) {
          viewport.zoomToFit([slide], getViewSize(), padding: 40.0);
        }
      },
      builder: (context, state) {
        if (!state.isPresenting || state.slides.isEmpty) {
          return const SizedBox.shrink();
        }

        return PresentationOverlay(
          frames: state.slides,
          currentSlideIndex: state.currentSlideIndex,
          onNextSlide: () => context.read<PresentationCubit>().nextSlide(),
          onPrevSlide: () => context.read<PresentationCubit>().previousSlide(),
          onExit: () => context.read<PresentationCubit>().stopPresentation(),
        );
      },
    );
  }
}
