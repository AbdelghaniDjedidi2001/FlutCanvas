import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/core/di/injection.dart';
import 'package:flutcanvas/features/ai_diagram/presentation/bloc/ai_diagram_cubit.dart';
import 'package:flutcanvas/features/broadcast/presentation/bloc/broadcast_cubit.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/boards_cubit.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/comments/presentation/bloc/comments_cubit.dart';
import 'package:flutcanvas/features/export/presentation/bloc/export_cubit.dart';
import 'package:flutcanvas/features/layers/presentation/bloc/layers_cubit.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';

/// Provides application-level Blocs and Cubits to the widget tree.
class AppBlocProviders extends StatelessWidget {
  final Widget child;

  const AppBlocProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CanvasBloc>(create: (_) => getIt<CanvasBloc>()),
        BlocProvider<ToolCubit>(create: (_) => getIt<ToolCubit>()),
        BlocProvider<BoardsCubit>(create: (_) => getIt<BoardsCubit>()),
        BlocProvider<CommentsCubit>(create: (_) => getIt<CommentsCubit>()),
        BlocProvider<LayersCubit>(create: (_) => getIt<LayersCubit>()),
        BlocProvider<ExportCubit>(create: (_) => getIt<ExportCubit>()),
        BlocProvider<PresentationCubit>(
          create: (_) => getIt<PresentationCubit>(),
        ),
        BlocProvider<BroadcastCubit>(
          create: (_) => getIt<BroadcastCubit>(),
        ),
        BlocProvider<AiDiagramCubit>(
          create: (_) => getIt<AiDiagramCubit>(),
        ),
      ],
      child: child,
    );
  }
}
