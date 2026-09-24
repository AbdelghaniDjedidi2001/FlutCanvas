import 'package:flutter/material.dart';

const Color kInk = Color(0xFF1F2430);

@immutable
class BoardColors {
  const BoardColors({
    required this.background,
    required this.grid,
    required this.selection,
    required this.ink,
    required this.laser,
  });

  final Color background;
  final Color grid;
  final Color selection;
  final Color ink;
  final Color laser;

  static const light = BoardColors(
    background: Color(0xFFFBFBFD),
    grid: Color(0xFFD5D8E0),
    selection: Color(0xFF3B5BDB),
    ink: kInk,
    laser: Color(0xFFFF3366),
  );

  static const dark = BoardColors(
    background: Color(0xFF15171C),
    grid: Color(0xFF2C3038),
    selection: Color(0xFF748FFC),
    ink: Color(0xFFE6E8EE),
    laser: Color(0xFFFF5252),
  );

  static BoardColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// How a stored element color should appear in this theme.
  Color display(Color stored) => stored == kInk ? ink : stored;

  /// Standard palette colors for strokes and shapes
  static const List<Color> strokePalette = [
    kInk,
    Color(0xFFE03131), // Red
    Color(0xFFE8590C), // Orange
    Color(0xFFFCC419), // Yellow
    Color(0xFF2F9E44), // Green
    Color(0xFF1098AD), // Cyan
    Color(0xFF1971C2), // Blue
    Color(0xFF7048E8), // Violet
    Color(0xFFD6336C), // Pink
  ];

  /// Pastel sticky note background colors
  static const List<Color> stickyNoteColors = [
    Color(0xFFFFF3BF), // Pastel Yellow
    Color(0xFFD3F9D8), // Pastel Green
    Color(0xFFD0EBFF), // Pastel Blue
    Color(0xFFFFDEEB), // Pastel Pink
    Color(0xFFFFE8CC), // Pastel Orange
    Color(0xFFE5DBFF), // Pastel Purple
  ];
}
