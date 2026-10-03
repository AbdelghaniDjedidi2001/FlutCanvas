import 'dart:typed_data';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutcanvas/features/export/domain/repositories/export_repository.dart';
import 'package:flutcanvas/features/export/presentation/bloc/export_cubit.dart';
import 'package:flutcanvas/features/export/presentation/bloc/export_state.dart';
import 'package:flutcanvas/models/board_colors.dart';
import 'package:flutcanvas/models/board_element.dart';
import 'package:flutcanvas/models/shape_type.dart';

class MockExportRepository extends Mock implements ExportRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(BoardColors.light);
  });

  group('ExportCubit Tests', () {
    late MockExportRepository repository;
    late ExportCubit cubit;

    setUp(() {
      repository = MockExportRepository();
      cubit = ExportCubit(repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial format defaults to PNG', () {
      expect(cubit.state.format, equals(ExportFormat.png));
      expect(cubit.state.isExporting, isFalse);
    });

    blocTest<ExportCubit, ExportState>(
      'setFormat changes target format',
      build: () => cubit,
      act: (c) => c.setFormat(ExportFormat.svg),
      expect: () => [
        const ExportState(format: ExportFormat.svg),
      ],
    );

    blocTest<ExportCubit, ExportState>(
      'exportPng calls repository and manages progress state',
      build: () {
        when(() => repository.renderToPng(
              elements: any(named: 'elements'),
              colors: any(named: 'colors'),
              includeBackground: any(named: 'includeBackground'),
              scale: any(named: 'scale'),
              padding: any(named: 'padding'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
        return cubit;
      },
      act: (c) => c.exportPng(
        elements: [
          const BoardElement(
            id: '1',
            type: ShapeType.rectangle,
            start: Offset.zero,
            end: Offset(10, 10),
          )
        ],
        colors: BoardColors.light,
      ),
      verify: (c) {
        verify(() => repository.renderToPng(
              elements: any(named: 'elements'),
              colors: any(named: 'colors'),
              includeBackground: any(named: 'includeBackground'),
              scale: any(named: 'scale'),
              padding: any(named: 'padding'),
              onProgress: any(named: 'onProgress'),
            )).called(1);
      },
    );
  });
}
