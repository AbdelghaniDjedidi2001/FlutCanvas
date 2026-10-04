import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/layers/presentation/widgets/layers_sidebar.dart';

void main() {
  group('BoardElement Locking, Visibility & Naming', () {
    test('default properties are unlocked, visible, and have sensible display names', () {
      final rect = BoardElement(
        id: 'rect_1',
        type: ShapeType.rectangle,
        start: const Offset(10, 10),
        end: const Offset(100, 100),
        color: Colors.black,
      );

      expect(rect.isLocked, isFalse);
      expect(rect.isVisible, isTrue);
      expect(rect.customName, isNull);
      expect(rect.displayName, equals('Rectangle'));
    });

    test('displayName returns customName when present, or text prefix for text/sticky', () {
      final custom = BoardElement(
        id: 'custom_1',
        type: ShapeType.rectangle,
        start: const Offset(10, 10),
        end: const Offset(100, 100),
        color: Colors.black,
        customName: 'Hero Box',
      );
      expect(custom.displayName, equals('Hero Box'));

      final note = BoardElement(
        id: 'note_1',
        type: ShapeType.stickyNote,
        start: const Offset(10, 10),
        end: const Offset(100, 100),
        color: Colors.black,
        text: 'Review meeting agenda and next steps',
      );
      expect(note.displayName, equals('Review meeting age...'));
    });

    test('serialization preserves isLocked, isVisible, and customName', () {
      final original = BoardElement(
        id: 'el_test',
        type: ShapeType.ellipse,
        start: const Offset(50, 50),
        end: const Offset(150, 150),
        color: Colors.black,
        isLocked: true,
        isVisible: false,
        customName: 'Main Circle',
      );

      final map = original.toMap();
      expect(map['isLocked'], isTrue);
      expect(map['isVisible'], isFalse);
      expect(map['customName'], equals('Main Circle'));

      final restored = BoardElement.fromMap(map);
      expect(restored.isLocked, isTrue);
      expect(restored.isVisible, isFalse);
      expect(restored.customName, equals('Main Circle'));
      expect(restored.displayName, equals('Main Circle'));
    });

    test('copyWith updates isLocked, isVisible, and customName correctly', () {
      final el = BoardElement(
        id: 'el_1',
        type: ShapeType.triangle,
        start: const Offset(0, 0),
        end: const Offset(50, 50),
        color: Colors.black,
      );

      final locked = el.copyWith(isLocked: true);
      expect(locked.isLocked, isTrue);
      expect(locked.isVisible, isTrue);

      final hidden = locked.copyWith(isVisible: false);
      expect(hidden.isVisible, isFalse);
      expect(hidden.isLocked, isTrue);

      final renamed = hidden.copyWith(customName: 'Custom Triangle');
      expect(renamed.displayName, equals('Custom Triangle'));
    });
  });

  group('LayersSidebar Widget Tests', () {
    testWidgets('renders layer items in reverse Z-index order and supports search filtering', (tester) async {
      final elements = <BoardElement>[
        BoardElement(
          id: '1',
          type: ShapeType.rectangle,
          start: Offset.zero,
          end: const Offset(100, 100),
          color: Colors.black,
          customName: 'Background Box',
        ),
        BoardElement(
          id: '2',
          type: ShapeType.ellipse,
          start: Offset.zero,
          end: const Offset(100, 100),
          color: Colors.black,
          customName: 'User Avatar',
        ),
        BoardElement(
          id: '3',
          type: ShapeType.arrow,
          start: Offset.zero,
          end: const Offset(100, 100),
          color: Colors.black,
          customName: 'Flow Arrow',
        ),
      ];

      String? selectedId;
      String? toggledLockId;
      String? toggledVisId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayersSidebar(
              elements: elements,
              selectedIds: const {'2'},
              onSelectElement: (id, multi) => selectedId = id,
              onToggleVisibility: (id) => toggledVisId = id,
              onToggleLock: (id) => toggledLockId = id,
              onRenameElement: (id, name) {},
              onDeleteElement: (id) {},
              onReorderElements: (oldI, newI) {},
              onClose: () {},
            ),
          ),
        ),
      );

      // Verify all layers are displayed
      expect(find.text('Flow Arrow'), findsOneWidget);
      expect(find.text('User Avatar'), findsOneWidget);
      expect(find.text('Background Box'), findsOneWidget);

      // Test selecting element
      await tester.tap(find.text('Background Box'));
      await tester.pump(const Duration(milliseconds: 350));
      expect(selectedId, equals('1'));

      // Test search filter
      await tester.enterText(find.byType(TextField).first, 'Flow');
      await tester.pumpAndSettle();

      expect(find.text('Flow Arrow'), findsOneWidget);
      expect(find.text('User Avatar'), findsNothing);
      expect(find.text('Background Box'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pumpAndSettle();

      // Test lock toggle button on topmost element
      final lockIcons = find.byIcon(Icons.lock_open_outlined);
      expect(lockIcons, findsWidgets);
      await tester.tap(lockIcons.first);
      expect(toggledLockId, equals('3'));

      // Test visibility toggle button on topmost element
      final visIcons = find.byIcon(Icons.visibility_outlined);
      expect(visIcons, findsWidgets);
      await tester.tap(visIcons.first);
      expect(toggledVisId, equals('3'));
    });

    testWidgets('double-tapping layer opens rename TextField and submits new name', (tester) async {
      final elements = <BoardElement>[
        BoardElement(
          id: '1',
          type: ShapeType.rectangle,
          start: Offset.zero,
          end: const Offset(100, 100),
          color: Colors.black,
          customName: 'Original Box',
        ),
      ];

      String? renamedId;
      String? renamedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayersSidebar(
              elements: elements,
              selectedIds: const {},
              onSelectElement: (id, multi) {},
              onToggleVisibility: (id) {},
              onToggleLock: (id) {},
              onRenameElement: (id, name) {
                renamedId = id;
                renamedText = name;
              },
              onDeleteElement: (id) {},
              onReorderElements: (oldI, newI) {},
              onClose: () {},
            ),
          ),
        ),
      );

      // Double-tap the layer name
      await tester.tap(find.text('Original Box'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Original Box'));
      await tester.pumpAndSettle();

      // Verify TextField appeared and enter new name
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2)); // Search field + rename field

      await tester.enterText(textFields.last, 'Renamed Hero Box');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(renamedId, equals('1'));
      expect(renamedText, equals('Renamed Hero Box'));
    });
  });
}
