import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_state.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';

void main() {
  group('PresentationCubit Tests', () {
    final frame1 = const BoardElement(
      id: 'f1',
      type: ShapeType.frame,
      start: Offset(0, 0),
      end: Offset(400, 300),
      frameIndex: 0,
      frameTitle: 'Slide 1',
    );

    final frame2 = const BoardElement(
      id: 'f2',
      type: ShapeType.frame,
      start: Offset(500, 0),
      end: Offset(900, 300),
      frameIndex: 1,
      frameTitle: 'Slide 2',
    );

    test('initial state is not presenting', () {
      final cubit = PresentationCubit();
      expect(cubit.state.isPresenting, isFalse);
      expect(cubit.state.slides, isEmpty);
      cubit.close();
    });

    blocTest<PresentationCubit, PresentationState>(
      'startPresentation extracts frames and activates slide 0',
      build: () => PresentationCubit(),
      act: (c) => c.startPresentation([frame1, frame2]),
      verify: (c) {
        expect(c.state.isPresenting, isTrue);
        expect(c.state.slides.length, equals(2));
        expect(c.state.currentSlideIndex, equals(0));
        expect(c.state.currentSlide?.frameTitle, equals('Slide 1'));
      },
    );

    blocTest<PresentationCubit, PresentationState>(
      'nextSlide and previousSlide navigate through frames',
      build: () => PresentationCubit(),
      act: (c) {
        c.startPresentation([frame1, frame2]);
        c.nextSlide();
        c.previousSlide();
      },
      verify: (c) {
        expect(c.state.currentSlideIndex, equals(0));
      },
    );
  });
}
