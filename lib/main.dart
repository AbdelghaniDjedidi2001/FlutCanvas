import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection.dart';
import 'features/canvas/presentation/bloc/boards_cubit.dart';
import 'features/canvas/presentation/bloc/canvas_bloc.dart';
import 'features/comments/presentation/bloc/comments_cubit.dart';
import 'features/export/presentation/bloc/export_cubit.dart';
import 'features/layers/presentation/bloc/layers_cubit.dart';
import 'features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'features/toolbar/presentation/bloc/tool_cubit.dart';
import 'ui/whiteboard_page.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.unknown,
      };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const WhiteboardApp());
}

class WhiteboardApp extends StatefulWidget {
  const WhiteboardApp({super.key});

  @override
  State<WhiteboardApp> createState() => _WhiteboardAppState();
}

class _WhiteboardAppState extends State<WhiteboardApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(Brightness current) {
    setState(() {
      _themeMode =
          current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF3B5BDB);

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
      ],
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FlutCanvas',
            scrollBehavior: const AppScrollBehavior(),
            themeMode: _themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: seed,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: seed,
              brightness: Brightness.dark,
            ),
            home: child,
          );
        },
        child: WhiteboardPage(onToggleTheme: _toggleTheme),
      ),
    );
  }
}