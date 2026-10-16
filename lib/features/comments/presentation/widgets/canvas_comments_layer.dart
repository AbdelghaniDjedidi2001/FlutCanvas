import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/comments/presentation/bloc/comments_cubit.dart';
import 'package:flutcanvas/features/comments/presentation/widgets/comment_card_popover.dart';
import 'package:flutcanvas/features/comments/presentation/widgets/comment_pin_badge.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';

/// Renders interactive comment pins and active comment popovers on top of the canvas surface.
class CanvasCommentsLayer extends StatelessWidget {
  final CanvasViewportController viewport;
  final Size viewSize;

  const CanvasCommentsLayer({
    super.key,
    required this.viewport,
    required this.viewSize,
  });

  @override
  Widget build(BuildContext context) {
    final isPresenting =
        context.select<PresentationCubit, bool>((c) => c.state.isPresenting);
    if (isPresenting) return const SizedBox.shrink();

    final commentsState = context.watch<CommentsCubit>().state;
    if (commentsState.comments.isEmpty) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: viewport,
      builder: (context, _) {
        final activeComment = commentsState.activeCommentId != null
            ? commentsState.comments
                .where((c) => c.id == commentsState.activeCommentId)
                .firstOrNull
            : null;

        return Stack(
          children: [
            // Comment Pin Badges
            for (final comment in commentsState.comments)
              Builder(builder: (context) {
                final screenPos = viewport.toScreen(comment.worldPosition);
                if (screenPos.dx < -60 ||
                    screenPos.dx > viewSize.width + 60 ||
                    screenPos.dy < -60 ||
                    screenPos.dy > viewSize.height + 60) {
                  return const SizedBox.shrink();
                }
                final isSelected = commentsState.activeCommentId == comment.id;
                return Positioned(
                  left: screenPos.dx - (isSelected ? 17 : 14),
                  top: screenPos.dy - (isSelected ? 17 : 14),
                  child: CommentPinBadge(
                    comment: comment,
                    isSelected: isSelected,
                    onTap: () {
                      context.read<CommentsCubit>().setActiveCommentId(
                            isSelected ? null : comment.id,
                          );
                    },
                  ),
                );
              }),

            // Active Comment Popover Card
            if (activeComment != null)
              Builder(builder: (context) {
                final screenPos = viewport.toScreen(activeComment.worldPosition);
                return CommentCardPopover(
                  comment: activeComment,
                  screenPosition: screenPos,
                  viewSize: viewSize,
                  onAddReply: (text) => context.read<CommentsCubit>().addReply(
                        commentId: activeComment.id,
                        author: 'User',
                        text: text,
                      ),
                  onToggleResolved: () => context
                      .read<CommentsCubit>()
                      .toggleResolved(activeComment.id),
                  onDeleteComment: () => context
                      .read<CommentsCubit>()
                      .deleteComment(activeComment.id),
                  onSaveInitialText: (text) {
                    final updated = activeComment.copyWith(text: text);
                    context.read<CommentsCubit>().setComments([
                      for (final c in commentsState.comments)
                        if (c.id == activeComment.id) updated else c,
                    ]);
                  },
                  onClose: () =>
                      context.read<CommentsCubit>().setActiveCommentId(null),
                );
              }),
          ],
        );
      },
    );
  }
}
