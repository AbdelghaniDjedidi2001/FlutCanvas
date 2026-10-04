import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/tool.dart';

class EmptyCanvasGuide extends StatelessWidget {
  const EmptyCanvasGuide({
    super.key,
    required this.onOpenImport,
    required this.onOpenTemplates,
    required this.onOpenHelp,
    required this.onInsertImage,
    required this.onSelectTool,
    this.onOpenMermaid,
  });

  final VoidCallback onOpenImport;
  final VoidCallback onOpenTemplates;
  final VoidCallback onOpenHelp;
  final VoidCallback onInsertImage;
  final void Function(Tool tool) onSelectTool;
  final VoidCallback? onOpenMermaid;

  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final annotationColor = isDark
        ? const Color(0xFF9E9E9E)
        : const Color(0xFF616161);

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

          // 2. Top-Left Annotation Text ("Export, preferences, boards...")
          if (showAnnotations)
            Positioned(
              top: 76.h.clamp(64.0, 92.0),
              left: 48.w.clamp(36.0, 64.0),
              child: IgnorePointer(
                child: Text(
                  'Export, preferences, boards...',
                  style: GoogleFonts.caveat(
                    color: annotationColor,
                    fontSize: 18.sp.clamp(14.0, 22.0),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),

          // 3. Top-Center Navigation Hint (perfectly centered)
          if (showAnnotations)
            Positioned(
              top: 200.h.clamp(48.0, 66.0),
              left: 20,
              right: 20,
              child: IgnorePointer(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'To move canvas, hold ',
                          style: GoogleFonts.caveat(
                            color: annotationColor.withValues(alpha: 0.9),
                            fontSize: 15.sp.clamp(12.0, 18.0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _HintKeyBadge('Scroll wheel', annotationColor, isDark),
                        Text(
                          ' or ',
                          style: GoogleFonts.caveat(
                            color: annotationColor.withValues(alpha: 0.9),
                            fontSize: 15.sp.clamp(12.0, 18.0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _HintKeyBadge('Space', annotationColor, isDark),
                        Text(
                          ' while dragging, or use the hand tool',
                          style: GoogleFonts.caveat(
                            color: annotationColor.withValues(alpha: 0.9),
                            fontSize: 15.sp.clamp(12.0, 18.0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 3.5 Top-Center "Pick a tool & Start drawing!" (centered with generous space below hint)
          if (showAnnotations)
            Positioned(
              top: 112.h.clamp(98.0, 128.0),
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    'Pick a tool &\nStart drawing!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.caveat(
                      color: annotationColor,
                      fontSize: 19.sp.clamp(15.0, 23.0),
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),

          // 4. Bottom-Right Annotation Text ("Shortcuts & help")
          if (showAnnotations)
            Positioned(
              bottom: 66.h.clamp(54.0, 80.0),
              right: 68.w.clamp(56.0, 84.0),
              child: IgnorePointer(
                child: Text(
                  'Shortcuts &\nhelp',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.caveat(
                    color: annotationColor,
                    fontSize: 18.sp.clamp(14.0, 22.0),
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ),

          // 5. Center Welcome Card & Quick Actions
          Center(
            child: SingleChildScrollView(
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: 480.w.clamp(380.0, 520.0)),
                padding: EdgeInsets.symmetric(
                    horizontal: 20.w.clamp(14.0, 28.0),
                    vertical: 20.h.clamp(12.0, 24.0)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Project Logo & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 44.r.clamp(34.0, 52.0),
                          height: 44.r.clamp(34.0, 52.0),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 14.w.clamp(10.0, 18.0)),
                        Text(
                          'FLUTCANVAS',
                          style: TextStyle(
                            fontSize: 26.sp.clamp(20.0, 32.0),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.5,
                            color: colors.ink,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h.clamp(12.0, 22.0)),

                    // Storage description notice
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w.clamp(12.0, 20.0),
                          vertical: 10.h.clamp(8.0, 14.0)),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius:
                            BorderRadius.circular(10.r.clamp(6.0, 12.0)),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your drawings are saved in your browser’s storage.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.caveat(
                              fontSize: 16.sp.clamp(13.5, 18.5),
                              color: annotationColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Save your work to a file regularly to avoid losing it.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.caveat(
                              fontSize: 16.sp.clamp(13.5, 18.5),
                              color: annotationColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h.clamp(12.0, 24.0)),

                    // Quick Action Menu Rows
                    _QuickActionButton(
                      icon: Icons.folder_open_outlined,
                      label: 'Open / Import file',
                      shortcut: 'Cmd+O',
                      onTap: onOpenImport,
                    ),
                    SizedBox(height: 6.h.clamp(3.0, 8.0)),
                    _QuickActionButton(
                      icon: Icons.auto_awesome_mosaic_outlined,
                      label: 'Pre-built Templates',
                      shortcut: 'Templates',
                      onTap: onOpenTemplates,
                    ),
                    SizedBox(height: 6.h.clamp(3.0, 8.0)),
                    if (onOpenMermaid != null) ...[
                      _QuickActionButton(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Mermaid Code to Diagram',
                        shortcut: 'Mermaid',
                        onTap: onOpenMermaid!,
                      ),
                      SizedBox(height: 6.h.clamp(3.0, 8.0)),
                    ],
                    _QuickActionButton(
                      icon: Icons.help_outline_rounded,
                      label: 'Keyboard shortcuts & Help',
                      shortcut: '?',
                      onTap: onOpenHelp,
                    ),
                    SizedBox(height: 6.h.clamp(3.0, 8.0)),
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

class _HintKeyBadge extends StatelessWidget {
  const _HintKeyBadge(this.label, this.color, this.isDark);
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.caveat(
          color: color,
          fontSize: 14.sp.clamp(11.0, 16.5),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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
          padding: EdgeInsets.symmetric(
              horizontal: 14.w.clamp(10.0, 18.0),
              vertical: 9.h.clamp(6.0, 11.0)),
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.04))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r.clamp(6.0, 10.0)),
            border: Border.all(
              color: _isHovered
                  ? scheme.primary.withValues(alpha: 0.25)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20.r.clamp(16.0, 22.0),
                color: _isHovered ? scheme.primary : scheme.onSurfaceVariant,
              ),
              SizedBox(width: 14.w.clamp(10.0, 16.0)),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14.sp.clamp(12.0, 15.5),
                    fontWeight:
                        _isHovered ? FontWeight.w600 : FontWeight.w500,
                    color: _isHovered ? scheme.primary : scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.shortcut,
                  style: TextStyle(
                    fontSize: 11.5.sp.clamp(10.0, 13.0),
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
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
      ..color = color.withValues(alpha: 0.82)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. Top-Left Menu Arrow: curves from left of text up towards board tabs with spacing
    _drawSketchyCurvedArrow(
      canvas,
      start: Offset(40.w.clamp(30.0, 50.0), 86.h.clamp(76.0, 96.0)),
      control: Offset(18.w.clamp(12.0, 26.0), 68.h.clamp(58.0, 78.0)),
      end: Offset(36.w.clamp(28.0, 44.0), 56.h.clamp(50.0, 62.0)),
      paint: paint,
    );

    // 2. Top-Center Toolbar Arrow: starts at "drawing!" below hint and arches up towards tools
    final centerX = size.width / 2;
    _drawSketchyCurvedArrow(
  canvas,
  start: Offset(
    centerX + 45.w.clamp(38.0, 52.0),
    125.h.clamp(115.0, 135.0),
  ),
  control: Offset(
    centerX + 65.w.clamp(55.0, 75.0),
    105.h.clamp(98.0, 112.0),
  ),
  end: Offset(
    centerX + 58.w.clamp(50.0, 68.0),
    82.h.clamp(76.0, 88.0),
  ),
  paint: paint,
);

    // 3. Bottom-Right Arrow: arches up-right from "help" text and points towards ? button with spacing
    _drawSketchyCurvedArrow(
      canvas,
      start: Offset(size.width - 60.w.clamp(50.0, 72.0), size.height - 82.h.clamp(72.0, 92.0)),
      control: Offset(size.width - 22.w.clamp(16.0, 30.0), size.height - 100.h.clamp(86.0, 114.0)),
      end: Offset(size.width - 34.w.clamp(28.0, 42.0), size.height - 64.h.clamp(58.0, 72.0)),
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
    const steps = 28;
    final path = Path()..moveTo(start.dx, start.dy);

    double penultimateX = start.dx;
    double penultimateY = start.dy;

    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final x = (1 - t) * (1 - t) * start.dx +
          2 * (1 - t) * t * control.dx +
          t * t * end.dx;
      final y = (1 - t) * (1 - t) * start.dy +
          2 * (1 - t) * t * control.dy +
          t * t * end.dy;

      final jitter = (i == steps || i == 1) ? 0.0 : math.sin(i * 3.5) * 0.35;
      path.lineTo(x + jitter, y + jitter);

      if (i == steps - 2) {
        penultimateX = x;
        penultimateY = y;
      }
    }

    canvas.drawPath(path, paint);

    // Arrowhead along true tangent of the curve tip
    final tangentX = end.dx - penultimateX;
    final tangentY = end.dy - penultimateY;
    final angle = math.atan2(tangentY, tangentX);
    const arrowLen = 11.5;
    const arrowAngle = math.pi / 5.5; // ~32 degrees

    final leftWing = Offset(
      end.dx - arrowLen * math.cos(angle - arrowAngle),
      end.dy - arrowLen * math.sin(angle - arrowAngle),
    );
    final rightWing = Offset(
      end.dx - arrowLen * math.cos(angle + arrowAngle),
      end.dy - arrowLen * math.sin(angle + arrowAngle),
    );

    canvas.drawLine(end, leftWing, paint);
    canvas.drawLine(end, rightWing, paint);
  }

  @override
  bool shouldRepaint(covariant _GuideAnnotationPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isDark != isDark;
}
