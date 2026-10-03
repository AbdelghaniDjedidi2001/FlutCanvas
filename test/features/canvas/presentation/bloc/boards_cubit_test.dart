import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutcanvas/features/canvas/domain/repositories/board_repository.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/boards_cubit.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/boards_state.dart';

class MockBoardRepository extends Mock implements BoardRepository {}

void main() {
  group('BoardsCubit Tests', () {
    late MockBoardRepository repository;
    late BoardsCubit cubit;

    setUp(() {
      repository = MockBoardRepository();
      when(() => repository.saveWorkspace(
            boards: any(named: 'boards'),
            activeBoardIndex: any(named: 'activeBoardIndex'),
          )).thenAnswer((_) async {});
      cubit = BoardsCubit(repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has 1 main board', () {
      expect(cubit.state.boards.length, equals(1));
      expect(cubit.state.activeBoardIndex, equals(0));
      expect(cubit.state.currentBoard.title, equals('Main Board'));
    });

    blocTest<BoardsCubit, BoardsState>(
      'addNewBoard appends board and activates it',
      build: () => cubit,
      act: (c) => c.addNewBoard(),
      verify: (c) {
        expect(c.state.boards.length, equals(2));
        expect(c.state.activeBoardIndex, equals(1));
        verify(() => repository.saveWorkspace(
              boards: any(named: 'boards'),
              activeBoardIndex: any(named: 'activeBoardIndex'),
            )).called(1);
      },
    );

    blocTest<BoardsCubit, BoardsState>(
      'renameBoard updates title',
      build: () => cubit,
      act: (c) => c.renameBoard(0, 'Architecture Flow'),
      verify: (c) {
        expect(c.state.boards.first.title, equals('Architecture Flow'));
      },
    );

    blocTest<BoardsCubit, BoardsState>(
      'duplicateBoard creates a copy adjacent to source',
      build: () => cubit,
      act: (c) => c.duplicateBoard(0),
      verify: (c) {
        expect(c.state.boards.length, equals(2));
        expect(c.state.boards[1].title, contains('Copy'));
      },
    );
  });
}
