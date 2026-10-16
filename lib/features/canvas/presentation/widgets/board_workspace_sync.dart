import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/canvas/presentation/bloc/boards_cubit.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/boards_state.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_state.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/comments/presentation/bloc/comments_cubit.dart';
import 'package:flutcanvas/features/comments/presentation/bloc/comments_state.dart';

/// Synchronizes Board state with CanvasBloc, CommentsCubit, and Viewport pan/zoom.
class BoardWorkspaceSync extends StatelessWidget {
  final CanvasViewportController viewport;
  final Widget child;

  const BoardWorkspaceSync({
    super.key,
    required this.viewport,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 1. Sync board switch to CanvasBloc and CommentsCubit
        BlocListener<BoardsCubit, BoardsState>(
          listenWhen: (prev, curr) =>
              prev.activeBoardIndex != curr.activeBoardIndex ||
              (prev.boards.isEmpty && curr.boards.isNotEmpty),
          listener: (context, bState) {
            final active = bState.currentBoard;
            context
                .read<CanvasBloc>()
                .add(CanvasEvent.loadElements(active.elements));
            context.read<CommentsCubit>().setComments(active.comments);
            viewport.setPan(active.pan);
            viewport.setZoom(active.zoom);
          },
        ),
        // 2. Persist canvas updates to active board
        BlocListener<CanvasBloc, CanvasState>(
          listenWhen: (prev, curr) => prev.elements != curr.elements,
          listener: (context, cState) {
            context.read<BoardsCubit>().updateCurrentBoard(
                  elements: cState.elements,
                  pan: viewport.pan,
                  zoom: viewport.zoom,
                );
          },
        ),
        // 3. Persist comments updates to active board
        BlocListener<CommentsCubit, CommentsState>(
          listenWhen: (prev, curr) => prev.comments != curr.comments,
          listener: (context, commState) {
            context.read<BoardsCubit>().updateCurrentBoard(
                  comments: commState.comments,
                );
          },
        ),
      ],
      child: child,
    );
  }
}
