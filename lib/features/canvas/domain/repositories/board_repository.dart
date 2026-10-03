import '../models/board_document.dart';

class SavedWorkspaceState {
  const SavedWorkspaceState({
    required this.boards,
    required this.activeBoardIndex,
  });

  final List<BoardDocument> boards;
  final int activeBoardIndex;
}

abstract class BoardRepository {
  Future<void> saveWorkspace({
    required List<BoardDocument> boards,
    required int activeBoardIndex,
  });

  Future<SavedWorkspaceState?> loadWorkspace();

  Future<void> clearWorkspace();
}
