import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_document.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';

class SavedWorkspaceState {
  const SavedWorkspaceState({
    required this.boards,
    required this.activeBoardIndex,
  });

  final List<BoardDocument> boards;
  final int activeBoardIndex;
}

class StorageService {
  static const String _workspaceKey = 'mini_whiteboard_workspace_v2';
  static const String _legacyKey = 'mini_whiteboard_state_v1';

  static Future<void> saveWorkspace({
    required List<BoardDocument> boards,
    required int activeBoardIndex,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'version': 2,
        'timestamp': DateTime.now().toIso8601String(),
        'activeBoardIndex': activeBoardIndex.clamp(0, boards.isEmpty ? 0 : boards.length - 1),
        'boards': boards.map((b) => b.toMap()).toList(),
      };
      await prefs.setString(_workspaceKey, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving workspace: $e');
    }
  }

  static Future<SavedWorkspaceState?> loadWorkspace() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_workspaceKey);
      if (raw != null && raw.isNotEmpty) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final rawBoards = data['boards'] as List<dynamic>? ?? [];
        final boards = rawBoards
            .map((b) => BoardDocument.fromMap(b as Map<String, dynamic>))
            .toList();
        final activeIndex = (data['activeBoardIndex'] as num?)?.toInt() ?? 0;

        if (boards.isNotEmpty) {
          return SavedWorkspaceState(
            boards: boards,
            activeBoardIndex: activeIndex.clamp(0, boards.length - 1),
          );
        }
      }

      // Fallback: Check legacy single-board key
      final legacyRaw = prefs.getString(_legacyKey);
      if (legacyRaw != null && legacyRaw.isNotEmpty) {
        final data = jsonDecode(legacyRaw) as Map<String, dynamic>;
        final panMap = data['pan'] as Map<String, dynamic>?;
        final pan = panMap != null
            ? Offset((panMap['x'] as num).toDouble(), (panMap['y'] as num).toDouble())
            : Offset.zero;
        final zoom = (data['zoom'] as num?)?.toDouble() ?? 1.0;
        final rawElements = data['elements'] as List<dynamic>? ?? [];
        final elements = rawElements
            .map((e) => BoardElement.fromMap(e as Map<String, dynamic>))
            .toList();

        final legacyBoard = BoardDocument(
          id: 'board_legacy_1',
          title: 'Main Board',
          elements: elements,
          pan: pan,
          zoom: zoom,
        );

        return SavedWorkspaceState(
          boards: [legacyBoard],
          activeBoardIndex: 0,
        );
      }
    } catch (e) {
      debugPrint('Error loading workspace: $e');
    }
    return null;
  }

  static Future<void> clearWorkspace() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_workspaceKey);
    await prefs.remove(_legacyKey);
  }
}
