import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../services/history_manager.dart';
import '../../data/services/alignment_service.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connection_binding.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'canvas_event.dart';
import 'canvas_state.dart';

@injectable
class CanvasBloc extends Bloc<CanvasEvent, CanvasState> {
  final HistoryManager _history = HistoryManager();

  CanvasBloc() : super(const CanvasState()) {
    on<LoadElements>(_onLoadElements);
    on<AddElement>(_onAddElement);
    on<AddElements>(_onAddElements);
    on<UpdateElement>(_onUpdateElement);
    on<UpdateElements>(_onUpdateElements);
    on<DeleteSelected>(_onDeleteSelected);
    on<DeleteElements>(_onDeleteElements);
    on<SelectElement>(_onSelectElement);
    on<SelectElements>(_onSelectElements);
    on<ClearSelection>(_onClearSelection);
    on<SetDraft>(_onSetDraft);
    on<SetMarquee>(_onSetMarquee);
    on<MoveSelected>(_onMoveSelected);
    on<ResizeElement>(_onResizeElement);
    on<RotateSelected>(_onRotateSelected);
    on<GroupSelected>(_onGroupSelected);
    on<UngroupSelected>(_onUngroupSelected);
    on<BringSelectedToFront>(_onBringSelectedToFront);
    on<SendSelectedToBack>(_onSendSelectedToBack);
    on<ToggleLockSelected>(_onToggleLockSelected);
    on<ToggleVisibilitySelected>(_onToggleVisibilitySelected);
    on<AlignSelected>(_onAlignSelected);
    on<DistributeSelected>(_onDistributeSelected);
    on<UpdateConnectedArrows>(_onUpdateConnectedArrows);
    on<SetSnapGuides>(_onSetSnapGuides);
    on<Undo>(_onUndo);
    on<Redo>(_onRedo);
    on<ClearHistory>(_onClearHistory);
  }

  void _pushHistory(List<BoardElement> elements) {
    _history.push(elements);
  }

  void _onLoadElements(LoadElements event, Emitter<CanvasState> emit) {
    _history.clear();
    emit(state.copyWith(
      elements: event.elements,
      selectedIds: {},
      draft: null,
      marqueeRect: null,
      snapGuides: [],
      canUndo: false,
      canRedo: false,
    ));
  }

  void _onAddElement(AddElement event, Emitter<CanvasState> emit) {
    _pushHistory(state.elements);
    final updated = [...state.elements, event.element];
    emit(state.copyWith(
      elements: updated,
      draft: null,
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onAddElements(AddElements event, Emitter<CanvasState> emit) {
    if (event.elements.isEmpty) return;
    _pushHistory(state.elements);
    final updated = [...state.elements, ...event.elements];
    emit(state.copyWith(
      elements: updated,
      selectedIds: event.elements.map((e) => e.id).toSet(),
      draft: null,
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onUpdateElement(UpdateElement event, Emitter<CanvasState> emit) {
    final idx = state.elements.indexWhere((e) => e.id == event.element.id);
    if (idx == -1) return;
    _pushHistory(state.elements);
    final updated = List<BoardElement>.from(state.elements);
    updated[idx] = event.element;
    emit(state.copyWith(
      elements: _recalculateConnectedArrows(updated),
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onUpdateElements(UpdateElements event, Emitter<CanvasState> emit) {
    if (event.elements.isEmpty) return;
    _pushHistory(state.elements);
    final elementMap = {for (final e in event.elements) e.id: e};
    final updated = [
      for (final el in state.elements) elementMap[el.id] ?? el,
    ];
    emit(state.copyWith(
      elements: _recalculateConnectedArrows(updated),
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onDeleteSelected(DeleteSelected event, Emitter<CanvasState> emit) {
    if (state.selectedIds.isEmpty) return;
    _pushHistory(state.elements);
    final updated = state.elements
        .where((e) => !state.selectedIds.contains(e.id))
        .toList();
    emit(state.copyWith(
      elements: updated,
      selectedIds: {},
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onDeleteElements(DeleteElements event, Emitter<CanvasState> emit) {
    if (event.ids.isEmpty) return;
    _pushHistory(state.elements);
    final updated =
        state.elements.where((e) => !event.ids.contains(e.id)).toList();
    final newSelected =
        state.selectedIds.where((id) => !event.ids.contains(id)).toSet();
    emit(state.copyWith(
      elements: updated,
      selectedIds: newSelected,
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onSelectElement(SelectElement event, Emitter<CanvasState> emit) {
    final target = state.elements.where((e) => e.id == event.id).firstOrNull;
    if (target == null) return;

    Set<String> newSelection;
    if (event.toggle) {
      newSelection = Set<String>.from(state.selectedIds);
      if (newSelection.contains(event.id)) {
        newSelection.remove(event.id);
      } else {
        newSelection.add(event.id);
        if (target.groupId != null) {
          final groupMembers = state.elements
              .where((e) => e.groupId == target.groupId)
              .map((e) => e.id);
          newSelection.addAll(groupMembers);
        }
      }
    } else {
      if (target.groupId != null) {
        newSelection = state.elements
            .where((e) => e.groupId == target.groupId)
            .map((e) => e.id)
            .toSet();
      } else {
        newSelection = {event.id};
      }
    }
    emit(state.copyWith(selectedIds: newSelection));
  }

  void _onSelectElements(SelectElements event, Emitter<CanvasState> emit) {
    emit(state.copyWith(selectedIds: event.ids));
  }

  void _onClearSelection(ClearSelection event, Emitter<CanvasState> emit) {
    if (state.selectedIds.isEmpty) return;
    emit(state.copyWith(selectedIds: {}));
  }

  void _onSetDraft(SetDraft event, Emitter<CanvasState> emit) {
    emit(state.copyWith(draft: event.draft));
  }

  void _onSetMarquee(SetMarquee event, Emitter<CanvasState> emit) {
    emit(state.copyWith(marqueeRect: event.marquee));
  }

  void _onMoveSelected(MoveSelected event, Emitter<CanvasState> emit) {
    if (state.selectedIds.isEmpty || event.delta == Offset.zero) return;
    final updated = [
      for (final el in state.elements)
        if (state.selectedIds.contains(el.id) && !el.isLocked)
          el.translated(event.delta)
        else
          el,
    ];
    emit(state.copyWith(
      elements: _recalculateConnectedArrows(updated),
    ));
  }

  void _onResizeElement(ResizeElement event, Emitter<CanvasState> emit) {
    final idx = state.elements.indexWhere((e) => e.id == event.id);
    if (idx == -1) return;
    final el = state.elements[idx];
    if (el.isLocked) return;

    final updatedEl = el.scaled(el.bounds, event.newBounds);
    final updated = List<BoardElement>.from(state.elements);
    updated[idx] = updatedEl;
    emit(state.copyWith(
      elements: _recalculateConnectedArrows(updated),
    ));
  }

  void _onRotateSelected(RotateSelected event, Emitter<CanvasState> emit) {
    if (state.selectedIds.isEmpty) return;
    final updated = [
      for (final el in state.elements)
        if (state.selectedIds.contains(el.id) && !el.isLocked)
          el.rotated(event.deltaAngle)
        else
          el,
    ];
    emit(state.copyWith(elements: updated));
  }

  void _onGroupSelected(GroupSelected event, Emitter<CanvasState> emit) {
    if (state.selectedIds.length < 2) return;
    _pushHistory(state.elements);
    final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
    final updated = [
      for (final el in state.elements)
        if (state.selectedIds.contains(el.id))
          el.copyWith(groupId: groupId)
        else
          el,
    ];
    emit(state.copyWith(
      elements: updated,
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onUngroupSelected(UngroupSelected event, Emitter<CanvasState> emit) {
    if (state.selectedIds.isEmpty) return;
    _pushHistory(state.elements);
    final updated = [
      for (final el in state.elements)
        if (state.selectedIds.contains(el.id))
          el.copyWith(groupId: null)
        else
          el,
    ];
    emit(state.copyWith(
      elements: updated,
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onBringSelectedToFront(
      BringSelectedToFront event, Emitter<CanvasState> emit) {
    if (state.selectedIds.isEmpty) return;
    _pushHistory(state.elements);
    final unselected =
        state.elements.where((e) => !state.selectedIds.contains(e.id)).toList();
    final selected =
        state.elements.where((e) => state.selectedIds.contains(e.id)).toList();
    emit(state.copyWith(
      elements: [...unselected, ...selected],
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onSendSelectedToBack(
      SendSelectedToBack event, Emitter<CanvasState> emit) {
    if (state.selectedIds.isEmpty) return;
    _pushHistory(state.elements);
    final unselected =
        state.elements.where((e) => !state.selectedIds.contains(e.id)).toList();
    final selected =
        state.elements.where((e) => state.selectedIds.contains(e.id)).toList();
    emit(state.copyWith(
      elements: [...selected, ...unselected],
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onToggleLockSelected(
      ToggleLockSelected event, Emitter<CanvasState> emit) {
    if (state.selectedIds.isEmpty) return;
    _pushHistory(state.elements);
    final allLocked = state.selectedElements.every((e) => e.isLocked);
    final updated = [
      for (final el in state.elements)
        if (state.selectedIds.contains(el.id))
          el.copyWith(isLocked: !allLocked)
        else
          el,
    ];
    emit(state.copyWith(
      elements: updated,
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onToggleVisibilitySelected(
      ToggleVisibilitySelected event, Emitter<CanvasState> emit) {
    if (state.selectedIds.isEmpty) return;
    _pushHistory(state.elements);
    final allVisible = state.selectedElements.every((e) => e.isVisible);
    final updated = [
      for (final el in state.elements)
        if (state.selectedIds.contains(el.id))
          el.copyWith(isVisible: !allVisible)
        else
          el,
    ];
    emit(state.copyWith(
      elements: updated,
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onAlignSelected(AlignSelected event, Emitter<CanvasState> emit) {
    if (state.selectedIds.length < 2) return;
    _pushHistory(state.elements);
    final aligned = AlignmentService.alignElements(
      allElements: state.elements,
      selectedIds: state.selectedIds,
      alignment: event.direction,
    );
    emit(state.copyWith(
      elements: _recalculateConnectedArrows(aligned),
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onDistributeSelected(
      DistributeSelected event, Emitter<CanvasState> emit) {
    if (state.selectedIds.length < 3) return;
    _pushHistory(state.elements);
    final distributed = AlignmentService.distributeElements(
      allElements: state.elements,
      selectedIds: state.selectedIds,
      direction: event.direction,
    );
    emit(state.copyWith(
      elements: _recalculateConnectedArrows(distributed),
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    ));
  }

  void _onUpdateConnectedArrows(
      UpdateConnectedArrows event, Emitter<CanvasState> emit) {
    emit(state.copyWith(
      elements: _recalculateConnectedArrows(state.elements),
    ));
  }

  void _onSetSnapGuides(SetSnapGuides event, Emitter<CanvasState> emit) {
    emit(state.copyWith(snapGuides: event.guides));
  }

  void _onUndo(Undo event, Emitter<CanvasState> emit) {
    final previous = _history.undo(state.elements);
    if (previous != null) {
      emit(state.copyWith(
        elements: previous,
        selectedIds: {},
        canUndo: _history.canUndo,
        canRedo: _history.canRedo,
      ));
    }
  }

  void _onRedo(Redo event, Emitter<CanvasState> emit) {
    final next = _history.redo(state.elements);
    if (next != null) {
      emit(state.copyWith(
        elements: next,
        selectedIds: {},
        canUndo: _history.canUndo,
        canRedo: _history.canRedo,
      ));
    }
  }

  void _onClearHistory(ClearHistory event, Emitter<CanvasState> emit) {
    _history.clear();
    emit(state.copyWith(
      canUndo: false,
      canRedo: false,
    ));
  }

  List<BoardElement> _recalculateConnectedArrows(List<BoardElement> elements) {
    final elementMap = {for (final e in elements) e.id: e};

    return [
      for (final el in elements)
        if (el.type == ShapeType.arrow ||
            el.type == ShapeType.doubleArrow ||
            el.type == ShapeType.line) ...[
          () {
            var updated = el;
            if (el.startBinding != null &&
                elementMap.containsKey(el.startBinding!.elementId)) {
              final target = elementMap[el.startBinding!.elementId]!;
              final newStart = ConnectionBinding.getAnchorPosition(
                target.bounds,
                el.startBinding!.anchor,
              );
              updated = updated.copyWith(start: newStart);
            }
            if (el.endBinding != null &&
                elementMap.containsKey(el.endBinding!.elementId)) {
              final target = elementMap[el.endBinding!.elementId]!;
              final newEnd = ConnectionBinding.getAnchorPosition(
                target.bounds,
                el.endBinding!.anchor,
              );
              updated = updated.copyWith(end: newEnd);
            }
            return updated;
          }()
        ] else
          el,
    ];
  }
}
