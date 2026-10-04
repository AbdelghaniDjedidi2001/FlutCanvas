import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flutcanvas/features/comments/domain/models/board_comment.dart';
import 'comments_state.dart';

@injectable
class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit() : super(const CommentsState());

  void setComments(List<BoardComment> comments) {
    emit(state.copyWith(comments: comments));
  }

  void setActiveCommentId(String? id) {
    emit(state.copyWith(activeCommentId: id));
  }

  void toggleShowResolved() {
    emit(state.copyWith(showResolved: !state.showResolved));
  }

  void addComment({
    required Offset position,
    required String author,
    required String text,
    int? colorValue,
  }) {
    final now = DateTime.now();
    final pinNumber = state.comments.length + 1;
    final newComment = BoardComment(
      id: 'comment_${now.millisecondsSinceEpoch}',
      worldPosition: position,
      pinNumber: pinNumber,
      author: author.trim().isEmpty ? 'User' : author.trim(),
      text: text.trim(),
      createdAt: now,
      colorValue: colorValue,
    );
    emit(state.copyWith(
      comments: [...state.comments, newComment],
      activeCommentId: newComment.id,
    ));
  }

  void addReply({
    required String commentId,
    required String author,
    required String text,
  }) {
    final updated = [
      for (final c in state.comments)
        if (c.id == commentId)
          c.addReply(author: author, text: text)
        else
          c,
    ];
    emit(state.copyWith(comments: updated));
  }

  void removeReply(String commentId, String replyId) {
    final updated = [
      for (final c in state.comments)
        if (c.id == commentId) c.removeReply(replyId) else c,
    ];
    emit(state.copyWith(comments: updated));
  }

  void toggleResolved(String commentId) {
    final updated = [
      for (final c in state.comments)
        if (c.id == commentId) c.toggleResolved() else c,
    ];
    emit(state.copyWith(comments: updated));
  }

  void deleteComment(String commentId) {
    final updated = state.comments.where((c) => c.id != commentId).toList();
    emit(state.copyWith(
      comments: updated,
      activeCommentId:
          state.activeCommentId == commentId ? null : state.activeCommentId,
    ));
  }
}
