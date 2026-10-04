import 'package:injectable/injectable.dart';
import '../../data/services/alignment_service.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';

@injectable
class AlignElementsUseCase {
  const AlignElementsUseCase();

  List<BoardElement> call({
    required List<BoardElement> allElements,
    required Set<String> selectedIds,
    required AlignDirection direction,
  }) {
    return AlignmentService.alignElements(
      allElements: allElements,
      selectedIds: selectedIds,
      alignment: direction,
    );
  }
}
