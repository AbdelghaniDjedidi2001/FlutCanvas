import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/services/alignment_service.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/snap_guide.dart';

part 'canvas_event.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class CanvasEvent with _$CanvasEvent {
  const factory CanvasEvent.loadElements(List<BoardElement> elements) =
      LoadElements;

  const factory CanvasEvent.addElement(BoardElement element) = AddElement;

  const factory CanvasEvent.addElements(List<BoardElement> elements) =
      AddElements;

  const factory CanvasEvent.updateElement(BoardElement element) = UpdateElement;

  const factory CanvasEvent.updateElements(List<BoardElement> elements) =
      UpdateElements;

  const factory CanvasEvent.deleteSelected() = DeleteSelected;

  const factory CanvasEvent.deleteElements(Set<String> ids) = DeleteElements;

  const factory CanvasEvent.selectElement(String id,
      {@Default(false) bool toggle}) = SelectElement;

  const factory CanvasEvent.selectElements(Set<String> ids) = SelectElements;

  const factory CanvasEvent.clearSelection() = ClearSelection;

  const factory CanvasEvent.setDraft(BoardElement? draft) = SetDraft;

  const factory CanvasEvent.setMarquee(Rect? marquee) = SetMarquee;

  const factory CanvasEvent.moveSelected(Offset delta) = MoveSelected;

  const factory CanvasEvent.resizeElement(String id, Rect newBounds) =
      ResizeElement;

  const factory CanvasEvent.rotateSelected(double deltaAngle) = RotateSelected;

  const factory CanvasEvent.groupSelected() = GroupSelected;

  const factory CanvasEvent.ungroupSelected() = UngroupSelected;

  const factory CanvasEvent.bringSelectedToFront() = BringSelectedToFront;

  const factory CanvasEvent.sendSelectedToBack() = SendSelectedToBack;

  const factory CanvasEvent.toggleLockSelected() = ToggleLockSelected;

  const factory CanvasEvent.toggleVisibilitySelected() =
      ToggleVisibilitySelected;

  const factory CanvasEvent.alignSelected(AlignDirection direction) =
      AlignSelected;

  const factory CanvasEvent.distributeSelected(DistributeDirection direction) =
      DistributeSelected;

  const factory CanvasEvent.updateConnectedArrows() = UpdateConnectedArrows;

  const factory CanvasEvent.setSnapGuides(List<SnapGuide> guides) =
      SetSnapGuides;

  const factory CanvasEvent.undo() = Undo;

  const factory CanvasEvent.redo() = Redo;

  const factory CanvasEvent.clearHistory() = ClearHistory;
}
