import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../models/board_element.dart';

part 'presentation_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class PresentationState with _$PresentationState {
  const factory PresentationState({
    @Default(false) bool isPresenting,
    @Default(0) int currentSlideIndex,
    @Default([]) List<BoardElement> slides,
  }) = _PresentationState;

  const PresentationState._();

  BoardElement? get currentSlide =>
      slides.isNotEmpty && currentSlideIndex < slides.length
          ? slides[currentSlideIndex]
          : null;

  int get totalSlides => slides.length;
}
