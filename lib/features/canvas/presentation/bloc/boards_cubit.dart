import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flutcanvas/features/comments/domain/models/board_comment.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_document.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/usecases/load_workspace_usecase.dart';
import 'package:flutcanvas/features/canvas/domain/usecases/save_workspace_usecase.dart';
import '../../domain/repositories/board_repository.dart';
import 'boards_state.dart';

@injectable
class BoardsCubit extends Cubit<BoardsState> {
  final LoadWorkspaceUseCase _loadWorkspace;
  final SaveWorkspaceUseCase _saveWorkspace;
  Timer? _debounceTimer;

  BoardsCubit(
    this._loadWorkspace,
    this._saveWorkspace,
  ) : super(const BoardsState());

  /// Convenience factory for instantiating from a [BoardRepository] directly.
  factory BoardsCubit.fromRepository(BoardRepository repository) {
    return BoardsCubit(
      LoadWorkspaceUseCase(repository),
      SaveWorkspaceUseCase(repository),
    );
  }

  Future<void> loadWorkspace() async {
    emit(state.copyWith(isLoading: true));
    final result = await _loadWorkspace();
    result.fold(
      onSuccess: (saved) {
        if (saved != null && saved.boards.isNotEmpty) {
          emit(state.copyWith(
            boards: saved.boards,
            activeBoardIndex: saved.activeBoardIndex,
            isLoading: false,
          ));
        } else {
          emit(state.copyWith(isLoading: false));
        }
      },
      onFailure: (_) {
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  void saveWorkspace({bool debounce = false}) {
    if (!debounce) {
      _debounceTimer?.cancel();
      _saveWorkspace(
        boards: state.boards,
        activeBoardIndex: state.activeBoardIndex,
      );
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _saveWorkspace(
        boards: state.boards,
        activeBoardIndex: state.activeBoardIndex,
      );
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  void switchBoard(int index) {
    if (index >= 0 && index < state.boards.length) {
      emit(state.copyWith(activeBoardIndex: index));
      saveWorkspace();
    }
  }

  void addNewBoard() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final newBoard = BoardDocument(
      id: 'board_$now',
      title: 'Board ${state.boards.length + 1}',
      elements: [],
      comments: [],
    );
    final updated = [...state.boards, newBoard];
    emit(state.copyWith(
      boards: updated,
      activeBoardIndex: updated.length - 1,
    ));
    saveWorkspace();
  }

  void duplicateBoard(int index) {
    if (index < 0 || index >= state.boards.length) return;
    final source = state.boards[index];
    final now = DateTime.now().millisecondsSinceEpoch;
    final duplicated = source.copyWith(
      id: 'board_$now',
      title: '${source.title} (Copy)',
      updatedAt: DateTime.now(),
    );
    final updated = List<BoardDocument>.from(state.boards)
      ..insert(index + 1, duplicated);
    emit(state.copyWith(
      boards: updated,
      activeBoardIndex: index + 1,
    ));
    saveWorkspace();
  }

  void renameBoard(int index, String newTitle) {
    if (index < 0 || index >= state.boards.length) return;
    final updated = List<BoardDocument>.from(state.boards);
    updated[index] = updated[index].copyWith(title: newTitle);
    emit(state.copyWith(boards: updated));
    saveWorkspace();
  }

  void deleteBoard(int index) {
    if (state.boards.length <= 1 || index < 0 || index >= state.boards.length) {
      return;
    }
    final updated = List<BoardDocument>.from(state.boards)..removeAt(index);
    final newIndex = (state.activeBoardIndex >= updated.length)
        ? updated.length - 1
        : state.activeBoardIndex;
    emit(state.copyWith(
      boards: updated,
      activeBoardIndex: newIndex,
    ));
    saveWorkspace();
  }

  void updateCurrentBoard({
    List<BoardElement>? elements,
    List<BoardComment>? comments,
    Offset? pan,
    double? zoom,
  }) {
    final i = state.activeBoardIndex;
    if (i < 0 || i >= state.boards.length) return;
    final current = state.boards[i];
    final updatedBoard = current.copyWith(
      elements: elements ?? current.elements,
      comments: comments ?? current.comments,
      pan: pan ?? current.pan,
      zoom: zoom ?? current.zoom,
      updatedAt: DateTime.now(),
    );
    final updated = List<BoardDocument>.from(state.boards);
    updated[i] = updatedBoard;
    emit(state.copyWith(boards: updated));
    saveWorkspace(debounce: true);
  }
}
