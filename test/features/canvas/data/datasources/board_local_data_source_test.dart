import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutcanvas/features/canvas/data/datasources/board_local_data_source.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('SharedPrefsBoardDataSource Tests', () {
    late MockSharedPreferences prefs;
    late SharedPrefsBoardDataSource dataSource;

    setUp(() {
      prefs = MockSharedPreferences();
      dataSource = SharedPrefsBoardDataSource(prefs);
    });

    test('saveWorkspaceJson writes to SharedPreferences', () async {
      when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);

      await dataSource.saveWorkspaceJson('{"key":"value"}');

      verify(() => prefs.setString('mini_whiteboard_workspace_v2', '{"key":"value"}')).called(1);
    });

    test('getWorkspaceJson reads from SharedPreferences', () async {
      when(() => prefs.getString('mini_whiteboard_workspace_v2'))
          .thenReturn('{"key":"value"}');

      final result = await dataSource.getWorkspaceJson();

      expect(result, equals('{"key":"value"}'));
    });

    test('getLegacyWorkspaceJson reads legacy key', () async {
      when(() => prefs.getString('mini_whiteboard_state_v1'))
          .thenReturn('{"legacy":"value"}');

      final result = await dataSource.getLegacyWorkspaceJson();

      expect(result, equals('{"legacy":"value"}'));
    });

    test('clearWorkspace removes both keys', () async {
      when(() => prefs.remove(any())).thenAnswer((_) async => true);

      await dataSource.clearWorkspace();

      verify(() => prefs.remove('mini_whiteboard_workspace_v2')).called(1);
      verify(() => prefs.remove('mini_whiteboard_state_v1')).called(1);
    });
  });
}
