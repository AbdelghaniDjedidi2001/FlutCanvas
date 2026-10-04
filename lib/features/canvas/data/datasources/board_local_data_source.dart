import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class BoardLocalDataSource {
  Future<void> saveWorkspaceJson(String jsonString);
  Future<String?> getWorkspaceJson();
  Future<String?> getLegacyWorkspaceJson();
  Future<void> clearWorkspace();
}

@LazySingleton(as: BoardLocalDataSource)
class SharedPrefsBoardDataSource implements BoardLocalDataSource {
  static const String _workspaceKey = 'mini_whiteboard_workspace_v2';
  static const String _legacyKey = 'mini_whiteboard_state_v1';

  final SharedPreferences? _prefs;

  SharedPrefsBoardDataSource([this._prefs]);

  @override
  Future<void> saveWorkspaceJson(String jsonString) async {
    await _prefs?.setString(_workspaceKey, jsonString);
  }

  @override
  Future<String?> getWorkspaceJson() async {
    return _prefs?.getString(_workspaceKey);
  }

  @override
  Future<String?> getLegacyWorkspaceJson() async {
    return _prefs?.getString(_legacyKey);
  }

  @override
  Future<void> clearWorkspace() async {
    await _prefs?.remove(_workspaceKey);
    await _prefs?.remove(_legacyKey);
  }
}
