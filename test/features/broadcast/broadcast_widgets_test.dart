import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:flutcanvas/features/broadcast/data/services/lan_broadcast_server.dart';
import 'package:flutcanvas/features/broadcast/presentation/bloc/broadcast_cubit.dart';
import 'package:flutcanvas/features/broadcast/presentation/widgets/broadcast_dialog.dart';
import 'package:flutcanvas/features/broadcast/presentation/widgets/broadcast_hud_pill.dart';
import 'package:flutcanvas/features/canvas/data/datasources/board_local_data_source.dart';
import 'package:flutcanvas/features/canvas/data/repositories/shared_prefs_board_repository.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/boards_cubit.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/shortcuts_handler.dart';
import 'package:flutcanvas/features/toolbar/presentation/bloc/tool_cubit.dart';

class FakeBoardDataSource implements BoardLocalDataSource {
  @override
  Future<void> clearWorkspace() async {}

  @override
  Future<String?> getWorkspaceJson() async => null;

  @override
  Future<String?> getLegacyWorkspaceJson() async => null;

  @override
  Future<void> saveWorkspaceJson(String jsonString) async {}
}

class FakeLanBroadcastServer extends LanBroadcastServer {
  bool _running = false;
  final StreamController<int> _controller = StreamController<int>.broadcast();

  @override
  bool get isRunning => _running;
  @override
  int get port => 4040;
  @override
  String get localIp => '192.168.1.100';
  @override
  String get url => 'http://192.168.1.100:4040';
  @override
  int get connectedViewersCount => 0;
  @override
  Stream<int> get viewerCountStream => _controller.stream;

  @override
  Future<bool> start({int initialPort = 4040, int maxPortAttempts = 10}) async {
    _running = true;
    return true;
  }

  @override
  Future<void> stop() async {
    _running = false;
  }

  @override
  void dispose() {
    _controller.close();
  }
}

void main() {
  group('Broadcast Widgets & Shortcuts Tests', () {
    late FakeLanBroadcastServer server;
    late BroadcastCubit broadcastCubit;
    late CanvasBloc canvasBloc;
    late BoardsCubit boardsCubit;
    late CanvasViewportController viewport;

    setUp(() {
      server = FakeLanBroadcastServer();
      broadcastCubit = BroadcastCubit(server: server);
      canvasBloc = CanvasBloc();
      boardsCubit = BoardsCubit.fromRepository(
        SharedPrefsBoardRepository(FakeBoardDataSource()),
      );
      viewport = CanvasViewportController();
    });

    tearDown(() async {
      await broadcastCubit.close();
      await canvasBloc.close();
      await boardsCubit.close();
      viewport.dispose();
    });

    Widget buildTestApp({required Widget child}) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: broadcastCubit),
          BlocProvider.value(value: canvasBloc),
          BlocProvider.value(value: boardsCubit),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: child,
          ),
        ),
      );
    }

    testWidgets('BroadcastHudPill is hidden when not broadcasting and visible when live', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestApp(
          child: BroadcastHudPill(
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      // Inactive: should be hidden
      expect(find.text('Live'), findsNothing);

      // Start broadcast on cubit
      await broadcastCubit.startBroadcast(
        port: 4991,
        initialElements: const [],
        isDark: false,
      );
      await tester.pump();

      // Active: should show Live badge
      expect(find.text('Live'), findsOneWidget);

      // Tap on the pill
      await tester.tap(find.text('Live'));
      await tester.pump();
      expect(tapped, isTrue);

      await broadcastCubit.stopBroadcast();
      await tester.pump();
      expect(find.text('Live'), findsNothing);

      // Cleanly unmount to dispose AnimationController
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('BroadcastDialog renders inactive setup with port input and features', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: BroadcastDialog(viewport: viewport),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LAN Live Broadcast'), findsOneWidget);
      expect(find.text('Real-time Camera & Pan Sync'), findsOneWidget);
      expect(find.text('Laser Pointer Streaming'), findsOneWidget);
      expect(find.text('Slide Frame Transition Sync'), findsOneWidget);
      expect(find.text('Start Live Broadcast'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('BroadcastDialog renders QR code, audience link, and stop button when live', (tester) async {
      await broadcastCubit.startBroadcast(
        port: 4992,
        initialElements: const [],
        isDark: false,
      );

      await tester.pumpWidget(
        buildTestApp(
          child: BroadcastDialog(viewport: viewport),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BROADCASTING LIVE ON LAN'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('Stop Broadcast'), findsOneWidget);
      expect(find.text('Audience can scan with phone camera to join'), findsOneWidget);

      // Tap stop broadcast button
      await tester.ensureVisible(find.text('Stop Broadcast'));
      await tester.tap(find.text('Stop Broadcast'));
      await tester.pumpAndSettle();

      expect(broadcastCubit.state.isBroadcasting, isFalse);
      expect(find.text('Start Live Broadcast'), findsOneWidget);
    });

    testWidgets('CanvasShortcutsHandler triggers onOpenBroadcast on Alt+B', (tester) async {
      bool opened = false;
      final toolCubit = ToolCubit();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: canvasBloc),
            BlocProvider.value(value: toolCubit),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CanvasShortcutsHandler(
                onOpenBroadcast: () => opened = true,
                child: const SizedBox(key: Key('canvas_child')),
              ),
            ),
          ),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();

      expect(opened, isTrue);

      await toolCubit.close();
    });
  });
}
