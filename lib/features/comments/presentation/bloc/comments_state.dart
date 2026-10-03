import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/board_comment.dart';

part 'comments_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class CommentsState with _$CommentsState {
  const factory CommentsState({
    @Default([]) List<BoardComment> comments,
    String? activeCommentId,
    @Default(false) bool showResolved,
  }) = _CommentsState;

  const CommentsState._();

  List<BoardComment> get visibleComments =>
      showResolved ? comments : comments.where((c) => !c.isResolved).toList();

  BoardComment? get activeComment =>
      comments.where((c) => c.id == activeCommentId).firstOrNull;
}
