import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutcanvas/features/canvas/data/datasources/board_local_data_source.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_document.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import '../../domain/repositories/board_repository.dart';

@LazySingleton(as: BoardRepository)
class SharedPrefsBoardRepository implements BoardRepository {
  final BoardLocalDataSource _localDataSource;

  SharedPrefsBoardRepository(this._localDataSource);

  /// Backwards-compatible constructor for initializing with [SharedPreferences] directly.
  factory SharedPrefsBoardRepository.fromPrefs([SharedPreferences? prefs]) {
    return SharedPrefsBoardRepository(SharedPrefsBoardDataSource(prefs));
  }

  @override
  Future<void> saveWorkspace({
    required List<BoardDocument> boards,
    required int activeBoardIndex,
  }) async {
    try {
      final data = {
        'version': 2,
        'timestamp': DateTime.now().toIso8601String(),
        'activeBoardIndex':
            activeBoardIndex.clamp(0, boards.isEmpty ? 0 : boards.length - 1),
        'boards': boards.map((b) => b.toMap()).toList(),
      };
      await _localDataSource.saveWorkspaceJson(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving workspace: $e');
    }
  }

  @override
  Future<SavedWorkspaceState?> loadWorkspace() async {
    try {
      final raw = await _localDataSource.getWorkspaceJson();
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
      final legacyRaw = await _localDataSource.getLegacyWorkspaceJson();
      if (legacyRaw != null && legacyRaw.isNotEmpty) {
        final data = jsonDecode(legacyRaw) as Map<String, dynamic>;
        final panMap = data['pan'] as Map<String, dynamic>?;
        final pan = panMap != null
            ? Offset((panMap['x'] as num).toDouble(),
                (panMap['y'] as num).toDouble())
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

  @override
  Future<void> clearWorkspace() async {
    await _localDataSource.clearWorkspace();
  }
}
