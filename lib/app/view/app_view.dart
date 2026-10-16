import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutcanvas/core/theme/app_theme.dart';
import 'package:flutcanvas/core/widgets/circular_theme_reveal.dart';
import 'package:flutcanvas/features/canvas/presentation/pages/whiteboard_page.dart';

/// The root application view, configuring MaterialApp, ScreenUtilInit,
/// and the circular theme transition animation.
class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView>
    with SingleTickerProviderStateMixin {
  ThemeMode _themeMode = ThemeMode.system;

  final GlobalKey _repaintKey = GlobalKey();
  late final AnimationController _animController;
  late final Animation<double> _curvedAnimation;

  ui.Image? _snapshotImage;
  Offset _transitionOrigin = Offset.zero;
  bool _isDarkToLight = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isAnimating = false;
            _snapshotImage?.dispose();
            _snapshotImage = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _snapshotImage?.dispose();
    super.dispose();
  }

  Future<void> _toggleTheme(Brightness current, [Offset? origin]) async {
    if (_isAnimating) return;

    final isDark = current == Brightness.dark;
    final targetMode = isDark ? ThemeMode.light : ThemeMode.dark;

    // 1. Capture snapshot before switching theme
    ui.Image? snapshot;
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null && boundary.hasSize) {
        snapshot = await boundary.toImage(pixelRatio: 1.0);
      }
    } catch (_) {
      snapshot = null;
    }

    // 2. Resolve origin point
    Offset startOrigin = origin ?? Offset.zero;
    if (origin == null) {
      final box = _repaintKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        startOrigin = Offset(box.size.width - 48, box.size.height - 48);
      }
    }

    if (!mounted) return;

    // 3. Trigger transition and theme change
    setState(() {
      _isAnimating = true;
      _snapshotImage = snapshot;
      _transitionOrigin = startOrigin;
      _isDarkToLight = isDark;
      _themeMode = targetMode;
    });

    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FlutCanvas',
          scrollBehavior: const AppScrollBehavior(),
          themeMode: _themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                key: _repaintKey,
                child: child!,
              ),
              if (_isAnimating)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _curvedAnimation,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: CircularThemeRevealPainter(
                            oldImage: _snapshotImage,
                            origin: _transitionOrigin,
                            progress: _curvedAnimation.value,
                            isDarkToLight: _isDarkToLight,
                            targetBgColor: _isDarkToLight
                                ? AppTheme.lightBackgroundColor
                                : AppTheme.darkBackgroundColor,
                          ),
                          size: Size.infinite,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      child: WhiteboardPage(onToggleTheme: _toggleTheme),
    );
  }
}
