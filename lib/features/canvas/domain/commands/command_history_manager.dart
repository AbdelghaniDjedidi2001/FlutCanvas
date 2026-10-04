import '../models/board_element.dart';
import 'canvas_command.dart';

class CommandHistoryManager {
  final List<CanvasCommand> _undoStack = [];
  final List<CanvasCommand> _redoStack = [];
  final int maxHistory;

  CommandHistoryManager({this.maxHistory = 60});

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  String? get undoDescription =>
      _undoStack.isNotEmpty ? _undoStack.last.description : null;

  String? get redoDescription =>
      _redoStack.isNotEmpty ? _redoStack.last.description : null;

  void push(CanvasCommand command) {
    _undoStack.add(command);
    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  List<BoardElement>? undo(List<BoardElement> current) {
    if (!canUndo) return null;
    final command = _undoStack.removeLast();
    _redoStack.add(command);
    return command.undo(current);
  }

  List<BoardElement>? redo(List<BoardElement> current) {
    if (!canRedo) return null;
    final command = _redoStack.removeLast();
    _undoStack.add(command);
    return command.execute(current);
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
