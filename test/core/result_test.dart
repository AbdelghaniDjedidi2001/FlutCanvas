import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/core/error/failures.dart';
import 'package:flutcanvas/core/utils/result.dart';

void main() {
  group('Result<T> Pattern Tests', () {
    test('Success returns correct data and matches isSuccess', () {
      const result = Success('hello world');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals('hello world'));
      expect(result.failureOrNull, isNull);

      final folded = result.fold(
        onSuccess: (data) => 'Got: $data',
        onFailure: (failure) => 'Failed: ${failure.message}',
      );
      expect(folded, equals('Got: hello world'));
    });

    test('FailureResult returns failure and matches isFailure', () {
      const failure = StorageFailure('Disk full');
      const result = FailureResult<String>(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, equals(failure));

      final folded = result.fold(
        onSuccess: (data) => 'Got: $data',
        onFailure: (f) => 'Failed: ${f.message}',
      );
      expect(folded, equals('Failed: Disk full'));
    });
  });
}
