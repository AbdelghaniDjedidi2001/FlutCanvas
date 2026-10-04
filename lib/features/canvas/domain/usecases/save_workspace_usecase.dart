import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../models/board_document.dart';
import '../repositories/board_repository.dart';

@injectable
class SaveWorkspaceUseCase {
  final BoardRepository _repository;

  const SaveWorkspaceUseCase(this._repository);

  Future<Result<void>> call({
    required List<BoardDocument> boards,
    required int activeBoardIndex,
  }) async {
    try {
      if (boards.isEmpty) {
        return const FailureResult(
          StorageFailure('Cannot save an empty workspace with no boards.'),
        );
      }
      await _repository.saveWorkspace(
        boards: boards,
        activeBoardIndex: activeBoardIndex,
      );
      return const Success(null);
    } catch (e) {
      return FailureResult(StorageFailure('Failed to save workspace', e));
    }
  }
}
