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

  bool get isDark => this == dark || background.computeLuminance() < 0.5;

  Color display(Color stored) {
    if (stored == Colors.transparent) return Colors.transparent;

    if (isDark) {
      if (stored == kInk ||
          stored == Colors.black ||
          stored.toARGB32() == 0xFF000000 ||
          stored.toARGB32() == 0xFF1E1E1E ||
          stored.toARGB32() == 0xFF121212 ||
          stored.toARGB32() == 0xFF1F2430 ||
          (stored.computeLuminance() < 0.06 && stored.a > 0.8)) {
        return ink;
      }
    } else {
      if (stored == Colors.white ||
          stored.toARGB32() == 0xFFFFFFFF ||
          stored.toARGB32() == 0xFFFBFBFD ||
          (stored.computeLuminance() > 0.95 && stored.a > 0.8)) {
        return ink;
      }
    }
    return stored;
  }

  static bool isMonochromeOrInk(Color c) {
    if (c == Colors.transparent) return true;
    if (c == kInk || c == Colors.black || c == Colors.white) return true;
    final val = c.toARGB32();
    if (val == 0xFF1F2430 ||
        val == 0xFF000000 ||
        val == 0xFF121212 ||
        val == 0xFF1E1E1E ||
        val == 0xFFFFFFFF ||
        val == 0xFFFBFBFD ||
        val == 0xFFE6E8EE) {
      return true;
    }
    final lum = c.computeLuminance();
    return lum < 0.05 || lum > 0.95;
  }

  Color displayHighlighter(Color stored) {
    if (stored == Colors.transparent) return Colors.transparent;

    // Explicit pure black is black in both modes
    if (stored == Colors.black || stored.toARGB32() == 0xFF000000) {
      return const Color(0xFF1F2430);
    }

    // Explicit pure white is white in both modes
    if (stored == Colors.white || stored.toARGB32() == 0xFFFFFFFF) {
      return Colors.white;
    }

    // In Dark Mode:
    // kInk (the board ink swatch) and ink represent WHITE in dark mode!
    if (isDark) {
      if (stored == kInk ||
          stored.toARGB32() == 0xFF1F2430 ||
          stored == ink ||
          stored.toARGB32() == 0xFFE6E8EE) {
        return Colors.white;
      }
      return stored;
    }

    // In Light Mode (White mode):
    // kInk represents black ink in light mode
    if (stored == kInk || stored.toARGB32() == 0xFF1F2430) {
      return const Color(0xFF1F2430);
    }

    return stored;
  }

  static const Color highlighterDefault = Color(0xFFFFD43B);

  static const List<Color> highlighterPalette = [
    Color(0xFFFFD43B), // Neon Yellow (Classic)
    Color(0xFF69DB7C), // Neon Green
    Color(0xFF4DABF7), // Neon Cyan/Blue
    Color(0xFFFF8787), // Neon Pink
    Color(0xFFFFA94D), // Neon Orange
    Color(0xFFB197FC), // Neon Purple
    Colors.white,      // Pure White Highlighter
    Colors.black,      // Pure Black Highlighter
  ];

  static const List<Color> strokePalette = [
    kInk,
    Color(0xFFE03131),
    Color(0xFFE8590C),
    Color(0xFFFCC419),
    Color(0xFF2F9E44),
    Color(0xFF1098AD),
    Color(0xFF1971C2),
    Color(0xFF7048E8),
    Color(0xFFD6336C),
  ];

  static const List<Color> stickyNoteColors = [
    Color(0xFFFFF3BF),
    Color(0xFFD3F9D8),
    Color(0xFFD0EBFF),
    Color(0xFFFFDEEB),
    Color(0xFFFFE8CC),
    Color(0xFFE5DBFF),
  ];
}
