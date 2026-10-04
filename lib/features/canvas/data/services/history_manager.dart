import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';

class HistoryManager {
  final List<List<BoardElement>> _undoStack = [];
  final List<List<BoardElement>> _redoStack = [];
  static const int maxHistory = 60;

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void push(List<BoardElement> currentState) {
    _undoStack.add(List.unmodifiable(currentState));
    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  List<BoardElement>? undo(List<BoardElement> currentState) {
    if (!canUndo) return null;
    _redoStack.add(List.unmodifiable(currentState));
    return _undoStack.removeLast();
  }

  List<BoardElement>? redo(List<BoardElement> currentState) {
    if (!canRedo) return null;
    _undoStack.add(List.unmodifiable(currentState));
    return _redoStack.removeLast();
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
