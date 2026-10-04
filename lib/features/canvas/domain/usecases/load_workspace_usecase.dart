import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/board_repository.dart';

@injectable
class LoadWorkspaceUseCase {
  final BoardRepository _repository;

  const LoadWorkspaceUseCase(this._repository);

  Future<Result<SavedWorkspaceState?>> call() async {
    try {
      final state = await _repository.loadWorkspace();
      return Success(state);
    } catch (e) {
      return FailureResult(StorageFailure('Failed to load workspace', e));
    }
  }
}
