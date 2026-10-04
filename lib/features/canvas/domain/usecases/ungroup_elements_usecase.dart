import 'package:injectable/injectable.dart';
import '../models/board_element.dart';

@injectable
class UngroupElementsUseCase {
  const UngroupElementsUseCase();

  List<BoardElement> call({
    required List<BoardElement> allElements,
    required Set<String> selectedIds,
  }) {
    if (selectedIds.isEmpty) return allElements;

    final targetGroupIds = allElements
        .where((e) => selectedIds.contains(e.id) && e.groupId != null)
        .map((e) => e.groupId!)
        .toSet();

    if (targetGroupIds.isEmpty) return allElements;

    return allElements.map((e) {
      if (e.groupId != null && targetGroupIds.contains(e.groupId)) {
        return e.copyWith(groupId: null);
      }
      return e;
    }).toList();
  }
}
