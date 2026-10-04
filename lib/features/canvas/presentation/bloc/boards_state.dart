import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutcanvas/features/comments/domain/models/board_comment.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_document.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';

part 'boards_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class BoardsState with _$BoardsState {
  const factory BoardsState({
    @Default([
      BoardDocument(id: 'board_1', title: 'Main Board', elements: []),
    ])
    List<BoardDocument> boards,
    @Default(0) int activeBoardIndex,
    @Default(false) bool isLoading,
  }) = _BoardsState;

  const BoardsState._();

  BoardDocument get currentBoard =>
      boards.isNotEmpty && activeBoardIndex < boards.length
          ? boards[activeBoardIndex]
          : (boards.isNotEmpty
              ? boards.first
              : const BoardDocument(id: 'default', title: 'Main Board'));

  List<BoardElement> get currentElements => currentBoard.elements;
  List<BoardComment> get currentComments => currentBoard.comments;
  Offset get currentPan => currentBoard.pan;
  double get currentZoom => currentBoard.zoom;
}
