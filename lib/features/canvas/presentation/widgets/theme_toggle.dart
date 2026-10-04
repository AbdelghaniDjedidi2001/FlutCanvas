import 'package:flutter/material.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key, required this.onToggleTheme});

  final void Function(Brightness current) onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      elevation: 3,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(12),
      child: IconButton(
        tooltip: isDark
            ? 'Switch to light mode (Alt+Shift+D)'
            : 'Switch to dark mode (Alt+Shift+D)',
        onPressed: () => onToggleTheme(brightness),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              RotationTransition(turns: anim, child: child),
          child: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            key: ValueKey(isDark),
            size: 20,
          ),
        ),
      ),
    );
  }
}
