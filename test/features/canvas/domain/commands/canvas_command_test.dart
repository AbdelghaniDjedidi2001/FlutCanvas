import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/domain/commands/canvas_command.dart';
import 'package:flutcanvas/features/canvas/domain/commands/command_history_manager.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';

void main() {
  group('CanvasCommand & CommandHistoryManager Tests', () {
    final el1 = BoardElement(
      id: 'el_1',
      type: ShapeType.rectangle,
      start: const Offset(10, 10),
      end: const Offset(100, 100),
    );

    final el2 = BoardElement(
      id: 'el_2',
      type: ShapeType.ellipse,
      start: const Offset(50, 50),
      end: const Offset(150, 150),
    );

    test('AddElementCommand executes and undos cleanly', () {
      final cmd = AddElementCommand(el1);
      final initial = <BoardElement>[];

      final executed = cmd.execute(initial);
      expect(executed.length, 1);
      expect(executed.first.id, 'el_1');

      final undone = cmd.undo(executed);
      expect(undone.isEmpty, isTrue);
    });

    test('DeleteElementsCommand executes and undos cleanly', () {
      final initial = [el1, el2];
      final cmd = DeleteElementsCommand([el1]);

      final executed = cmd.execute(initial);
      expect(executed.length, 1);
      expect(executed.first.id, 'el_2');

      final undone = cmd.undo(executed);
      expect(undone.length, 2);
      expect(undone.map((e) => e.id), containsAll(['el_1', 'el_2']));
    });

    test('MoveElementsCommand translates matching elements and undos with opposite delta', () {
      final initial = [el1, el2];
      const delta = Offset(20, 30);
      final cmd = MoveElementsCommand(elementIds: {'el_1'}, delta: delta);

      final executed = cmd.execute(initial);
      final moved = executed.firstWhere((e) => e.id == 'el_1');
      expect(moved.start, const Offset(30, 40));
      expect(moved.end, const Offset(120, 130));

      final unMoved = executed.firstWhere((e) => e.id == 'el_2');
      expect(unMoved.start, const Offset(50, 50)); // untouched

      final undone = cmd.undo(executed);
      final reverted = undone.firstWhere((e) => e.id == 'el_1');
      expect(reverted.start, const Offset(10, 10));
      expect(reverted.end, const Offset(100, 100));
    });

    test('CommandHistoryManager maintains undo and redo stack correctly', () {
      final history = CommandHistoryManager(maxHistory: 5);
      var elements = <BoardElement>[];

      expect(history.canUndo, isFalse);
      expect(history.canRedo, isFalse);

      final cmd1 = AddElementCommand(el1);
      elements = cmd1.execute(elements);
      history.push(cmd1);

      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);
      expect(history.undoDescription, contains('Add Rectangle'));

      // Undo
      final afterUndo = history.undo(elements);
      expect(afterUndo, isNotNull);
      expect(afterUndo!.isEmpty, isTrue);
      expect(history.canRedo, isTrue);
      expect(history.canUndo, isFalse);

      // Redo
      final afterRedo = history.redo(afterUndo);
      expect(afterRedo, isNotNull);
      expect(afterRedo!.length, 1);
      expect(afterRedo.first.id, 'el_1');
      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);
    });
  });
}
