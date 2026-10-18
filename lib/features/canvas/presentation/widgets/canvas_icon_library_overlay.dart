import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/tech_icons.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_event.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/icon_library/icon_library_drawer.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';

/// Floating overlay managing the Cloud & Tech Icon Library drawer.
class CanvasIconLibraryOverlay extends StatelessWidget {
  final CanvasViewportController viewport;
  final Size Function() getViewSize;

  const CanvasIconLibraryOverlay({
    super.key,
    required this.viewport,
    required this.getViewSize,
  });

  @override
  Widget build(BuildContext context) {
    final isPresenting =
        context.select<PresentationCubit, bool>((c) => c.state.isPresenting);
    if (isPresenting) return const SizedBox.shrink();

    final toolState = context.watch<ToolCubit>().state;
    if (!toolState.isIconLibraryOpen) return const SizedBox.shrink();

    final canvasState = context.watch<CanvasBloc>().state;
    final isPropertiesVisible =
        toolState.isPropertiesOpen || canvasState.selectedIds.isNotEmpty;
    final leftOffset = isPropertiesVisible ? 260.0 : 12.0;

    return Positioned(
      top: 64,
      left: leftOffset,
      child: IconLibraryDrawer(
        onSelectIcon: (icon) => _insertIconElement(context, icon),
        onClose: () => context.read<ToolCubit>().setIconLibraryOpen(false),
      ),
    );
  }

  void _insertIconElement(BuildContext context, TechIconDefinition icon) {
    final viewSize = getViewSize();
    final center = viewport.toWorld(
      Offset(viewSize.width / 2, viewSize.height / 2),
    );

    const width = 120.0;
    const height = 90.0;
    final colors = BoardColors.of(context);

    final newElement = BoardElement(
      id: 'icon_${DateTime.now().millisecondsSinceEpoch}',
      type: ShapeType.icon,
      start: center - const Offset(width / 2, height / 2),
      end: center + const Offset(width / 2, height / 2),
      iconName: icon.id,
      iconCategory: icon.category.name,
      text: icon.defaultLabel,
      color: icon.brandColor,
      fillColor: colors.isDark ? const Color(0xFF1E222D) : Colors.white,
      strokeWidth: 1.5,
    );

    context.read<CanvasBloc>().add(CanvasEvent.addElement(newElement));
    context.read<CanvasBloc>().add(CanvasEvent.selectElements({newElement.id}));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inserted ${icon.name} onto canvas'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
