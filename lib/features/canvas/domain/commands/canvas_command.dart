import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';

abstract interface class CanvasCommand {
  String get description;
  List<BoardElement> execute(List<BoardElement> current);
  List<BoardElement> undo(List<BoardElement> current);
}

class AddElementCommand implements CanvasCommand {
  final BoardElement element;

  const AddElementCommand(this.element);

  @override
  String get description => 'Add ${element.displayName}';

  @override
  List<BoardElement> execute(List<BoardElement> current) {
    return [...current, element];
  }

  @override
  List<BoardElement> undo(List<BoardElement> current) {
    return current.where((e) => e.id != element.id).toList();
  }
}

class AddElementsCommand implements CanvasCommand {
  final List<BoardElement> elements;

  const AddElementsCommand(this.elements);

  @override
  String get description => 'Add ${elements.length} elements';

  @override
  List<BoardElement> execute(List<BoardElement> current) {
    return [...current, ...elements];
  }

  @override
  List<BoardElement> undo(List<BoardElement> current) {
    final addedIds = elements.map((e) => e.id).toSet();
    return current.where((e) => !addedIds.contains(e.id)).toList();
  }
}

class DeleteElementsCommand implements CanvasCommand {
  final List<BoardElement> deletedElements;

  const DeleteElementsCommand(this.deletedElements);

  @override
  String get description => 'Delete ${deletedElements.length} elements';

  @override
  List<BoardElement> execute(List<BoardElement> current) {
    final targetIds = deletedElements.map((e) => e.id).toSet();
    return current.where((e) => !targetIds.contains(e.id)).toList();
  }

  @override
  List<BoardElement> undo(List<BoardElement> current) {
    return [...current, ...deletedElements];
  }
}

class UpdateElementCommand implements CanvasCommand {
  final BoardElement before;
  final BoardElement after;

  const UpdateElementCommand({
    required this.before,
    required this.after,
  });

  @override
  String get description => 'Update ${after.displayName}';

  @override
  List<BoardElement> execute(List<BoardElement> current) {
    final idx = current.indexWhere((e) => e.id == after.id);
    if (idx == -1) return current;
    final updated = List<BoardElement>.from(current);
    updated[idx] = after;
    return updated;
  }

  @override
  List<BoardElement> undo(List<BoardElement> current) {
    final idx = current.indexWhere((e) => e.id == before.id);
    if (idx == -1) return current;
    final reverted = List<BoardElement>.from(current);
    reverted[idx] = before;
    return reverted;
  }
}

class MoveElementsCommand implements CanvasCommand {
  final Set<String> elementIds;
  final Offset delta;

  const MoveElementsCommand({
    required this.elementIds,
    required this.delta,
  });

  @override
  String get description => 'Move ${elementIds.length} elements';

  @override
  List<BoardElement> execute(List<BoardElement> current) {
    return current.map((e) {
      if (elementIds.contains(e.id)) {
        return e.translated(delta);
      }
      return e;
    }).toList();
  }

  @override
  List<BoardElement> undo(List<BoardElement> current) {
    return current.map((e) {
      if (elementIds.contains(e.id)) {
        return e.translated(-delta);
      }
      return e;
    }).toList();
  }
}

class BatchCommand implements CanvasCommand {
  final List<CanvasCommand> commands;
  final String _description;

  const BatchCommand(this.commands, [this._description = 'Batch operation']);

  @override
  String get description => _description;

  @override
  List<BoardElement> execute(List<BoardElement> current) {
    var state = current;
    for (final cmd in commands) {
      state = cmd.execute(state);
    }
    return state;
  }

  @override
  List<BoardElement> undo(List<BoardElement> current) {
    var state = current;
    for (final cmd in commands.reversed) {
      state = cmd.undo(state);
    }
    return state;
  }
}

class ReplaceElementsCommand implements CanvasCommand {
  final List<BoardElement> before;
  final List<BoardElement> after;
  @override
  final String description;

  const ReplaceElementsCommand({
    required this.before,
    required this.after,
    this.description = 'Update elements',
  });

  @override
  List<BoardElement> execute(List<BoardElement> current) => after;

  @override
  List<BoardElement> undo(List<BoardElement> current) => before;
}
