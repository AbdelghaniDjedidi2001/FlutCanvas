import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../models/board_element.dart';
import '../../../../models/shape_type.dart';
import 'presentation_state.dart';

@injectable
class PresentationCubit extends Cubit<PresentationState> {
  PresentationCubit() : super(const PresentationState());

  void startPresentation(List<BoardElement> allElements) {
    final frames = allElements
        .where((e) => e.type == ShapeType.frame)
        .toList()
      ..sort((a, b) {
        if (a.frameIndex != null && b.frameIndex != null) {
          return a.frameIndex!.compareTo(b.frameIndex!);
        }
        return a.start.dy.compareTo(b.start.dy);
      });

    if (frames.isNotEmpty) {
      emit(state.copyWith(
        isPresenting: true,
        slides: frames,
        currentSlideIndex: 0,
      ));
    }
  }

  void stopPresentation() {
    emit(state.copyWith(isPresenting: false, slides: []));
  }

  void nextSlide() {
    if (state.currentSlideIndex < state.slides.length - 1) {
      emit(state.copyWith(currentSlideIndex: state.currentSlideIndex + 1));
    }
  }

  void previousSlide() {
    if (state.currentSlideIndex > 0) {
      emit(state.copyWith(currentSlideIndex: state.currentSlideIndex - 1));
    }
  }

  void goToSlide(int index) {
    if (index >= 0 && index < state.slides.length) {
      emit(state.copyWith(currentSlideIndex: index));
    }
  }
}
