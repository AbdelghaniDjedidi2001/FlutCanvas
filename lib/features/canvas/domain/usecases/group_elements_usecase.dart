import 'package:injectable/injectable.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';

@injectable
class GroupElementsUseCase {
  const GroupElementsUseCase();

  List<BoardElement> call({
    required List<BoardElement> allElements,
    required Set<String> selectedIds,
    required String groupId,
  }) {
    if (selectedIds.length < 2) return allElements;

    return allElements.map((e) {
      if (selectedIds.contains(e.id)) {
        return e.copyWith(groupId: groupId);
      }
      return e;
    }).toList();
  }
}
