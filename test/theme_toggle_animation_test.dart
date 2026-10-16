import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/core/widgets/circular_theme_reveal.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/theme_toggle.dart';
import 'package:flutcanvas/main.dart';
import 'package:flutcanvas/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  group('ThemeToggle Animation & Circular Reveal Tests', () {
    testWidgets('ThemeToggle passes global center origin when tapped',
        (WidgetTester tester) async {
      Offset? capturedOrigin;
      Brightness? capturedBrightness;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Center(
              child: ThemeToggle(
                onToggleTheme: (brightness, [origin]) {
                  capturedBrightness = brightness;
                  capturedOrigin = origin;
                },
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(ThemeToggle);
      expect(buttonFinder, findsOneWidget);

      final buttonCenter = tester.getCenter(buttonFinder);

      await tester.tap(buttonFinder);
      await tester.pump();

      expect(capturedBrightness, equals(Brightness.light));
      expect(capturedOrigin, isNotNull);
      // The captured origin must match the button's screen center coordinates
      expect((capturedOrigin!.dx - buttonCenter.dx).abs(), lessThan(1.0));
      expect((capturedOrigin!.dy - buttonCenter.dy).abs(), lessThan(1.0));
    });

    test('CircularThemeRevealPainter paints without throwing errors at different progress stages',
        () {
      final painter = CircularThemeRevealPainter(
        oldImage: null,
        origin: const Offset(500, 500),
        progress: 0.5,
        isDarkToLight: true,
        targetBgColor: const Color(0xFFF8F9FA),
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(1000, 800);

      expect(() => painter.paint(canvas, size), returnsNormally);

      // Verify at start (0.0)
      final painterStart = CircularThemeRevealPainter(
        oldImage: null,
        origin: const Offset(500, 500),
        progress: 0.0,
        isDarkToLight: false,
        targetBgColor: const Color(0xFF121212),
      );
      expect(() => painterStart.paint(canvas, size), returnsNormally);

      // Verify at completion (1.0)
      final painterEnd = CircularThemeRevealPainter(
        oldImage: null,
        origin: const Offset(500, 500),
        progress: 1.0,
        isDarkToLight: false,
        targetBgColor: const Color(0xFF121212),
      );
      expect(() => painterEnd.paint(canvas, size), returnsNormally);
    });

    testWidgets('WhiteboardApp triggers animated circular reveal for both expanding light and contracting dark modes',
        (WidgetTester tester) async {
      await tester.pumpWidget(const WhiteboardApp());
      await tester.pumpAndSettle();

      final toggleFinder = find.byType(ThemeToggle);
      expect(toggleFinder, findsOneWidget);

      // 1. First tap: trigger transition (e.g. system/light -> dark)
      await tester.tap(toggleFinder);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CustomPaint), findsWidgets);
      await tester.pumpAndSettle();

      // 2. Second tap: trigger reverse transition (e.g. dark -> light sunshine spread)
      await tester.tap(toggleFinder);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CustomPaint), findsWidgets);
      await tester.pumpAndSettle();
    });
  });
}
