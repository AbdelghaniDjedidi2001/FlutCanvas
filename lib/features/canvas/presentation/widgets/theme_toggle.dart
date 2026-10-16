import 'package:flutter/material.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key, required this.onToggleTheme});

  final void Function(Brightness current, [Offset? origin]) onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      elevation: 3,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(12),
      child: Builder(
        builder: (btnContext) {
          return IconButton(
            tooltip: isDark
                ? 'Switch to light mode (Alt+Shift+D)'
                : 'Switch to dark mode (Alt+Shift+D)',
            onPressed: () {
              final box = btnContext.findRenderObject() as RenderBox?;
              final origin = box != null && box.hasSize
                  ? box.localToGlobal(box.size.center(Offset.zero))
                  : null;
              onToggleTheme(brightness, origin);
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) {
                return RotationTransition(
                  turns: Tween<double>(begin: 0.75, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  ),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                    ),
                    child: child,
                  ),
                );
              },
              child: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                key: ValueKey(isDark),
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}
