import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection.dart';
import 'features/canvas/data/repositories/shared_prefs_board_repository.dart';
import 'features/canvas/presentation/bloc/boards_cubit.dart';
import 'features/canvas/presentation/bloc/canvas_bloc.dart';
import 'features/comments/presentation/bloc/comments_cubit.dart';
import 'features/export/data/services/default_export_repository.dart';
import 'features/export/presentation/bloc/export_cubit.dart';
import 'features/layers/presentation/bloc/layers_cubit.dart';
import 'features/presentation_mode/presentation/bloc/presentation_cubit.dart';
import 'features/toolbar/presentation/bloc/tool_cubit.dart';
import 'ui/whiteboard_page.dart';

T _resolve<T extends Object>(T Function() fallback) {
  try {
    if (getIt.isRegistered<T>()) {
      return getIt<T>();
    }
  } catch (_) {}
  return fallback();
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
        BlocProvider<CanvasBloc>(create: (_) => _resolve(() => CanvasBloc())),
        BlocProvider<ToolCubit>(create: (_) => _resolve(() => ToolCubit())),
        BlocProvider<BoardsCubit>(
          create: (_) => _resolve(
            () => BoardsCubit(SharedPrefsBoardRepository(null)),
          ),
        ),
        BlocProvider<CommentsCubit>(
          create: (_) => _resolve(() => CommentsCubit()),
        ),
        BlocProvider<LayersCubit>(
          create: (_) => _resolve(() => LayersCubit()),
        ),
        BlocProvider<ExportCubit>(
          create: (_) => _resolve(
            () => ExportCubit(DefaultExportRepository()),
          ),
        ),
        BlocProvider<PresentationCubit>(
          create: (_) => _resolve(() => PresentationCubit()),
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