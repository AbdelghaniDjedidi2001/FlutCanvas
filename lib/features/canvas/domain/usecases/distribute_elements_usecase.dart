import 'package:injectable/injectable.dart';
import '../../data/services/alignment_service.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';

@injectable
class DistributeElementsUseCase {
  const DistributeElementsUseCase();

  List<BoardElement> call({
    required List<BoardElement> allElements,
    required Set<String> selectedIds,
    required DistributeDirection direction,
  }) {
    return AlignmentService.distributeElements(
      allElements: allElements,
      selectedIds: selectedIds,
      direction: direction,
    );
  }
}
