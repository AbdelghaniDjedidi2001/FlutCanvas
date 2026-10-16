import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/comments/presentation/bloc/comments_cubit.dart';
import 'package:flutcanvas/features/layers/presentation/widgets/layers_sidebar.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';

/// Floating Layers / Object Tree Sidebar overlay.
class CanvasLayersOverlay extends StatelessWidget {
  final CanvasViewportController viewport;
  final Size Function() getViewSize;

  const CanvasLayersOverlay({
    super.key,
    required this.viewport,
    required this.getViewSize,
  });

  @override
  Widget build(BuildContext context) {
    final isPresenting =
        context.select<PresentationCubit, bool>((c) => c.state.isPresenting);
    if (isPresenting) return const SizedBox.shrink();

    final isLayersOpen =
        context.select<ToolCubit, bool>((c) => c.state.isLayersOpen);
    if (!isLayersOpen) return const SizedBox.shrink();

    return Positioned(
      top: 64,
      right: 12,
      child: LayersSidebar(
        onSelectComment: (commentId) {
          context.read<CommentsCubit>().setActiveCommentId(commentId);
          final comments = context.read<CommentsCubit>().state.comments;
          final comment = comments.where((c) => c.id == commentId).firstOrNull;
          if (comment != null) {
            viewport.panToCenter(comment.worldPosition, getViewSize());
          }
        },
        onClose: () => context.read<ToolCubit>().setLayersOpen(false),
      ),
    );
  }
}
