import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../models/board_colors.dart';
import '../../models/tool.dart';

class EmptyCanvasGuide extends StatelessWidget {
  const EmptyCanvasGuide({
    super.key,
    required this.onOpenImport,
    required this.onOpenTemplates,
    required this.onOpenHelp,
    required this.onInsertImage,
    required this.onSelectTool,
  });

  final VoidCallback onOpenImport;
  final VoidCallback onOpenTemplates;
  final VoidCallback onOpenHelp;
  final VoidCallback onInsertImage;
  final void Function(Tool tool) onSelectTool;

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final annotationColor = isDark
        ? const Color(0xFF9E9E9E)
        : const Color(0xFF616161);
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;
      final showAnnotations = size.width > 600 && size.height > 450;

      return Stack(
        children: [
          // 1. Hand-drawn Annotations & Sketch Arrows
          if (showAnnotations)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GuideAnnotationPainter(
                    color: annotationColor,
                    isDark: isDark,
                  ),
                  size: size,
                ),
              ),
            ),

          // 2. Top-Left Annotation Text
          if (showAnnotations)
            Positioned(
              top: 72,
              left: 36,
              child: IgnorePointer(
                child: Text(
                  'Export, preferences, boards...',
                  style: TextStyle(
                    color: annotationColor,
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.2,
                    fontFamily: 'sans-serif',
                  ),
                ),
              ),
            ),

          // 3. Top-Center Annotation Text & Hint
          if (showAnnotations)
            Positioned(
              top: 66,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'To move canvas, hold  Space  while dragging, or use the hand tool',
                      style: TextStyle(
                        color: annotationColor.withValues(alpha: 0.8),
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Pick a tool &\nStart drawing!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: annotationColor,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Bottom-Right Annotation Text
          if (showAnnotations)
            Positioned(
              bottom: 64,
              right: 28,
              child: IgnorePointer(
                child: Text(
                  'Shortcuts &\nhelp',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: annotationColor,
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    height: 1.2,
                  ),
                ),
              ),
            ),

          // 5. Center Welcome Card & Quick Actions
          Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Project Logo & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 44,
                          height: 44,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.draw_rounded,
                            size: 40,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'FLUTCANVAS',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            color: colors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Storage description notice
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your drawings are saved in your browser’s storage.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: annotationColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Save your work to a file regularly to avoid losing it.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: annotationColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Action Menu Rows
                    _QuickActionButton(
                      icon: Icons.folder_open_outlined,
                      label: 'Open / Import file',
                      shortcut: 'Cmd+O',
                      onTap: onOpenImport,
                    ),
                    const SizedBox(height: 8),
                    _QuickActionButton(
                      icon: Icons.auto_awesome_mosaic_outlined,
                      label: 'Pre-built Templates',
                      shortcut: 'Flowchart, Kanban...',
                      onTap: onOpenTemplates,
                    ),
                    const SizedBox(height: 8),
                    _QuickActionButton(
                      icon: Icons.help_outline_rounded,
                      label: 'Keyboard shortcuts & Help',
                      shortcut: '?',
                      onTap: onOpenHelp,
                    ),
                    const SizedBox(height: 8),
                    _QuickActionButton(
                      icon: Icons.image_outlined,
                      label: 'Insert an Image',
                      shortcut: 'I',
                      onTap: onInsertImage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _QuickActionButton extends StatefulWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.shortcut,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String shortcut;
  final VoidCallback onTap;

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? scheme.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: _isHovered ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        _isHovered ? FontWeight.w600 : FontWeight.w500,
                    color: _isHovered ? scheme.primary : scheme.onSurface,
                  ),
                ),
              ),
              Text(
                widget.shortcut,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideAnnotationPainter extends CustomPainter {
  _GuideAnnotationPainter({
    required this.color,
    required this.isDark,
  });

  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 1. Top-Left Menu Arrow: curves up & left towards top-left board tabs
    _drawSketchyCurvedArrow(
      canvas,
      start: const Offset(120, 68),
      control: const Offset(65, 55),
      end: const Offset(20, 24),
      paint: paint,
    );

    // 2. Top-Center Toolbar Arrow: curves up towards the central tools
    final centerX = size.width / 2;
    _drawSketchyCurvedArrow(
      canvas,
      start: Offset(centerX + 50, 116),
      control: Offset(centerX + 75, 80),
      end: Offset(centerX + 35, 48),
      paint: paint,
    );

    // 3. Bottom-Right Arrow: curves down towards bottom-right shortcuts & theme
    _drawSketchyCurvedArrow(
      canvas,
      start: Offset(size.width - 95, size.height - 68),
      control: Offset(size.width - 55, size.height - 52),
      end: Offset(size.width - 24, size.height - 24),
      paint: paint,
    );
  }

  void _drawSketchyCurvedArrow(
    Canvas canvas, {
    required Offset start,
    required Offset control,
    required Offset end,
    required Paint paint,
  }) {
    // 1. Double pass sketchy quadratic bezier curve
    const steps = 24;
    final path1 = Path()..moveTo(start.dx, start.dy);
    final path2 = Path()..moveTo(start.dx + 0.4, start.dy - 0.4);

    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final x = (1 - t) * (1 - t) * start.dx +
          2 * (1 - t) * t * control.dx +
          t * t * end.dx;
      final y = (1 - t) * (1 - t) * start.dy +
          2 * (1 - t) * t * control.dy +
          t * t * end.dy;

      final jitter1 = math.sin(i * 3.7) * 0.6;
      final jitter2 = math.cos(i * 4.1) * 0.6;

      path1.lineTo(x + jitter1, y + jitter2);
      path2.lineTo(x - jitter1 * 0.5, y - jitter2 * 0.5);
    }

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);

    // 2. Arrowhead at 'end' pointing along tangent
    final tangentX = end.dx - control.dx;
    final tangentY = end.dy - control.dy;
    final angle = math.atan2(tangentY, tangentX);
    const arrowLen = 13.0;
    const arrowAngle = math.pi / 6; // 30 degrees

    final leftWing = Offset(
      end.dx - arrowLen * math.cos(angle - arrowAngle),
      end.dy - arrowLen * math.sin(angle - arrowAngle),
    );
    final rightWing = Offset(
      end.dx - arrowLen * math.cos(angle + arrowAngle),
      end.dy - arrowLen * math.sin(angle + arrowAngle),
    );

    // Draw arrow wings with subtle double sketch
    canvas.drawLine(end, leftWing, paint);
    canvas.drawLine(
        end, Offset(leftWing.dx + 0.5, leftWing.dy - 0.5), paint);
    canvas.drawLine(end, rightWing, paint);
    canvas.drawLine(
        end, Offset(rightWing.dx - 0.5, rightWing.dy + 0.5), paint);
  }

  @override
  bool shouldRepaint(covariant _GuideAnnotationPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isDark != isDark;
}
