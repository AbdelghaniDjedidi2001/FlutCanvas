import 'package:flutter/material.dart';

/// SVG Vector Export tab with vector features callout, background toggle, download, and copy SVG XML actions.
class ExportTabSvg extends StatelessWidget {
  final bool includeBackground;
  final ValueChanged<bool> onToggleBackground;
  final bool isProcessing;
  final bool hasElements;
  final VoidCallback onDownloadSvg;
  final VoidCallback onCopySvg;

  const ExportTabSvg({
    super.key,
    required this.includeBackground,
    required this.onToggleBackground,
    required this.isProcessing,
    required this.hasElements,
    required this.onDownloadSvg,
    required this.onCopySvg,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      key: const ValueKey('tab_svg'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Vector Feature Callout
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: isDark ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vector SVG preserves infinite scalability, shadows, connectors, and full syntax-highlighted code blocks with zero pixelation.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Background Toggle Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.035)
                : Colors.black.withValues(alpha: 0.025),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.format_paint_outlined,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Include canvas background in SVG',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: includeBackground,
                  onChanged: isProcessing ? null : onToggleBackground,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              flex: 3,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1.5,
                ),
                onPressed: isProcessing || !hasElements ? null : onDownloadSvg,
                icon: isProcessing
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download_rounded, size: 19),
                label: const Text(
                  'Download SVG',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                onPressed: isProcessing || !hasElements ? null : onCopySvg,
                icon: const Icon(Icons.copy_rounded, size: 17),
                label: const Text(
                  'Copy SVG XML',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
