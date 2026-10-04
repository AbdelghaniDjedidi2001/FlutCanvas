abstract class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, [this.cause]);

  @override
  String toString() =>
      '$runtimeType: $message${cause != null ? ' ($cause)' : ''}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Failure &&
          other.runtimeType == runtimeType &&
          other.message == message &&
          other.cause == cause);

  @override
  int get hashCode => Object.hash(runtimeType, message, cause);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.cause]);
}

class ExportFailure extends Failure {
  const ExportFailure(super.message, [super.cause]);
}

class ImportFailure extends Failure {
  const ImportFailure(super.message, [super.cause]);
}

class ClipboardFailure extends Failure {
  const ClipboardFailure(super.message, [super.cause]);
}

class CanvasValidationFailure extends Failure {
  const CanvasValidationFailure(super.message, [super.cause]);
}
