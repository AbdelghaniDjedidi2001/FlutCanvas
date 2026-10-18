import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/command_palette/command_palette_dialog.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/command_palette/command_palette_item.dart';
import 'package:flutcanvas/features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';

void main() {
  group('CommandPaletteItem Model', () {
    test('matches query by title, category, keywords, or shortcut', () {
      final item = CommandPaletteItem(
        id: 'test_rect',
        title: 'Rectangle',
        subtitle: 'Geometric shape',
        category: CommandCategory.tools,
        icon: Icons.crop_square,
        shortcut: 'R',
        keywords: const ['box', 'square'],
        onExecute: () {},
      );

      expect(item.matches(''), isTrue);
      expect(item.matches('rect'), isTrue);
      expect(item.matches('RECTANGLE'), isTrue);
      expect(item.matches('box'), isTrue);
      expect(item.matches('tools'), isTrue);
      expect(item.matches('R'), isTrue);
      expect(item.matches('nonexistent'), isFalse);
    });
  });

  group('CommandPaletteDialog Widget', () {
    late CanvasViewportController viewport;
    late CanvasBloc canvasBloc;
    late ToolCubit toolCubit;
    late PresentationCubit presentationCubit;

    setUp(() {
      viewport = CanvasViewportController();
      canvasBloc = CanvasBloc();
      toolCubit = ToolCubit();
      presentationCubit = PresentationCubit();
    });

    tearDown(() {
      viewport.dispose();
      canvasBloc.close();
      toolCubit.close();
      presentationCubit.close();
    });

    Widget buildTestWidget() {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: canvasBloc),
          BlocProvider.value(value: toolCubit),
          BlocProvider.value(value: presentationCubit),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CommandPaletteDialog(
              viewport: viewport,
              viewSize: const Size(1200, 800),
            ),
          ),
        ),
      );
    }

    testWidgets('renders search field and command categories', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('ESC'), findsOneWidget);
      expect(find.text('TOOLS'), findsOneWidget);
      expect(find.text('Rectangle'), findsOneWidget);
      expect(find.text('Select & Transform'), findsOneWidget);
    });

    testWidgets('filters commands when typing query', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Diamond');
      await tester.pumpAndSettle();

      expect(find.text('Diamond / Decision'), findsOneWidget);
      expect(find.text('Rectangle'), findsNothing);
    });

    testWidgets('shows no results message when query has no matches', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'xyz123_not_found');
      await tester.pumpAndSettle();

      expect(find.text('No results found for "xyz123_not_found"'), findsOneWidget);
    });

    testWidgets('executing a tool command switches active tool', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Click on Rectangle command
      final rectFinder = find.text('Rectangle');
      expect(rectFinder, findsOneWidget);
      await tester.tap(rectFinder);
      await tester.pumpAndSettle();

      expect(toolCubit.state.currentTool, equals(Tool.rectangle));
    });

    testWidgets('searches on-canvas text and focuses viewport on element', (tester) async {
      const targetElement = BoardElement(
        id: 'sticky_auth',
        type: ShapeType.stickyNote,
        start: Offset(500, 300),
        end: Offset(650, 450),
        text: 'Auth Microservice Architecture',
      );
      canvasBloc.emit(canvasBloc.state.copyWith(elements: [targetElement]));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Microservice');
      await tester.pumpAndSettle();

      expect(find.text('CANVAS ELEMENTS'), findsOneWidget);
      expect(find.text('Auth Microservice Architecture'), findsOneWidget);

      await tester.tap(find.text('Auth Microservice Architecture'));
      await tester.pumpAndSettle();

      // Verify viewport was panned towards the element's center (575, 375)
      expect(canvasBloc.state.selectedIds, contains('sticky_auth'));
      expect(viewport.pan, isNot(equals(Offset.zero)));
    });
  });
}
