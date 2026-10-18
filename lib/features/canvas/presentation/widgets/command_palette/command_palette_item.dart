import 'package:flutter/material.dart';

enum CommandCategory {
  tools('Tools', Icons.brush_outlined),
  actions('Actions', Icons.bolt_outlined),
  view('View & Navigation', Icons.visibility_outlined),
  export('Import & Export', Icons.ios_share_outlined),
  presentation('Presentation', Icons.slideshow_outlined),
  elements('Canvas Elements', Icons.place_outlined);

  final String label;
  final IconData icon;
  const CommandCategory(this.label, this.icon);
}

class CommandPaletteItem {
  final String id;
  final String title;
  final String? subtitle;
  final CommandCategory category;
  final IconData icon;
  final String? shortcut;
  final List<String> keywords;
  final VoidCallback onExecute;
  final Color? iconColor;

  const CommandPaletteItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.category,
    required this.icon,
    this.shortcut,
    this.keywords = const [],
    required this.onExecute,
    this.iconColor,
  });

  bool matches(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;

    if (title.toLowerCase().contains(cleanQuery)) return true;
    if (subtitle != null && subtitle!.toLowerCase().contains(cleanQuery)) return true;
    if (category.label.toLowerCase().contains(cleanQuery)) return true;
    if (shortcut != null && shortcut!.toLowerCase().contains(cleanQuery)) return true;

    for (final kw in keywords) {
      if (kw.toLowerCase().contains(cleanQuery)) return true;
    }

    return false;
  }
}
