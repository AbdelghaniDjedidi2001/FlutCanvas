import 'package:flutter/material.dart';
import 'package:flutcanvas/features/export/data/services/mermaid_export_service.dart';

/// Tab widget for exporting canvas elements into Mermaid flowchart syntax.
class ExportTabMermaid extends StatelessWidget {
  final bool isProcessing;
  final bool hasElements;
  final MermaidDirection direction;
  final bool includeStyles;
  final String mermaidCode;
  final ValueChanged<MermaidDirection> onDirectionChanged;
  final ValueChanged<bool> onIncludeStylesChanged;
  final VoidCallback onCopyMermaid;
  final VoidCallback onDownloadMmd;

  const ExportTabMermaid({
    super.key,
    required this.isProcessing,
    required this.hasElements,
    required this.direction,
    required this.includeStyles,
    required this.mermaidCode,
    required this.onDirectionChanged,
    required this.onIncludeStylesChanged,
    required this.onCopyMermaid,
    required this.onDownloadMmd,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      key: const ValueKey('tab_mermaid'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Controls Row: Layout Direction & Styling Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.035)
                : Colors.black.withValues(alpha: 0.025),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Layout Flow',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  SegmentedButton<MermaidDirection>(
                    segments: const [
                      ButtonSegment(
                        value: MermaidDirection.auto,
                        label: Text('Auto', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment(
                        value: MermaidDirection.td,
                        label: Text('Top-Down', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment(
                        value: MermaidDirection.lr,
                        label: Text('Left-Right', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                    selected: {direction},
                    onSelectionChanged: (selected) {
                      if (selected.isNotEmpty) {
                        onDirectionChanged(selected.first);
                      }
                    },
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Include Color Styles',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        'Generate style statements for fills and strokes',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: includeStyles,
                      onChanged: isProcessing ? null : onIncludeStylesChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Code Preview Box
        Container(
          height: 140,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141820) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              mermaidCode,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                height: 1.4,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasElements && !isProcessing ? onCopyMermaid : null,
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy Mermaid'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: hasElements && !isProcessing ? onDownloadMmd : null,
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Download .mmd'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
