import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutcanvas/features/canvas/data/repositories/shared_prefs_board_repository.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_document.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('SharedPrefsBoardRepository Tests', () {
    late MockSharedPreferences prefs;
    late SharedPrefsBoardRepository repository;

    final doc = BoardDocument(
      id: 'b1',
      title: 'Design Ideas',
      elements: [
        const BoardElement(
          id: 'e1',
          type: ShapeType.rectangle,
          start: Offset.zero,
          end: Offset(50, 50),
        ),
      ],
    );

    setUp(() {
      prefs = MockSharedPreferences();
      repository = SharedPrefsBoardRepository(prefs);
    });

    test('saveWorkspace encodes data and writes to SharedPreferences', () async {
      when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);

      await repository.saveWorkspace(boards: [doc], activeBoardIndex: 0);

      verify(() => prefs.setString('mini_whiteboard_workspace_v2', any())).called(1);
    });

    test('loadWorkspace parses JSON from SharedPreferences', () async {
      final jsonPayload = jsonEncode({
        'version': 2,
        'activeBoardIndex': 0,
        'boards': [doc.toMap()],
      });

      when(() => prefs.getString('mini_whiteboard_workspace_v2'))
          .thenReturn(jsonPayload);

      final result = await repository.loadWorkspace();

      expect(result, isNotNull);
      expect(result!.boards.length, equals(1));
      expect(result.boards.first.title, equals('Design Ideas'));
      expect(result.activeBoardIndex, equals(0));
    });

    test('clearWorkspace removes workspace and legacy keys', () async {
      when(() => prefs.remove(any())).thenAnswer((_) async => true);

      await repository.clearWorkspace();

      verify(() => prefs.remove('mini_whiteboard_workspace_v2')).called(1);
      verify(() => prefs.remove('mini_whiteboard_state_v1')).called(1);
    });
  });
}
