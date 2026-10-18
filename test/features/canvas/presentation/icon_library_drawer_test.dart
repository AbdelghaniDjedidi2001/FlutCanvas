import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/domain/models/tech_icons.dart';
import 'package:flutcanvas/features/canvas/presentation/widgets/icon_library/icon_library_drawer.dart';

void main() {
  group('IconLibraryDrawer Widget Tests', () {
    testWidgets('renders search field, category chips, and icon grid', (tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconLibraryDrawer(
              onSelectIcon: (_) {},
              onClose: () => closed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title and search bar
      expect(find.text('Cloud & Architecture'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify category chips
      expect(find.text('All Icons'), findsOneWidget);
      expect(find.text('Cloud & Compute'), findsOneWidget);

      // Verify initial icons present
      expect(find.text('AWS Lambda'), findsOneWidget);
      expect(find.text('AWS EC2'), findsOneWidget);

      // Test close button
      final closeButton = find.byIcon(Icons.close_rounded);
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      expect(closed, isTrue);
    });

    testWidgets('filters icons via search text input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconLibraryDrawer(
              onSelectIcon: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query "redis"
      await tester.enterText(find.byType(TextField), 'redis');
      await tester.pumpAndSettle();

      expect(find.text('Redis Cache'), findsOneWidget);
      expect(find.text('AWS Lambda'), findsNothing);
    });

    testWidgets('filters icons when clicking category chip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconLibraryDrawer(
              onSelectIcon: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Cloud & Compute" chip (visible right next to All Icons)
      await tester.tap(find.text('Cloud & Compute'));
      await tester.pumpAndSettle();

      expect(find.text('AWS Lambda'), findsOneWidget);
      expect(find.text('AWS EC2'), findsOneWidget);
    });

    testWidgets('triggers onSelectIcon when an icon card is tapped', (tester) async {
      TechIconDefinition? selectedIcon;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconLibraryDrawer(
              onSelectIcon: (icon) => selectedIcon = icon,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap AWS Lambda
      await tester.tap(find.text('AWS Lambda'));
      await tester.pumpAndSettle();

      expect(selectedIcon, isNotNull);
      expect(selectedIcon!.id, 'aws_lambda');
      expect(selectedIcon!.name, 'AWS Lambda');
      expect(selectedIcon!.category, TechIconCategory.cloudCompute);
    });
  });
}
