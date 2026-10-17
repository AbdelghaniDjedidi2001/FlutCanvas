import 'package:flutter/material.dart';

/// Whiteboard project data export and file import tab (Native JSON, Excalidraw, Mermaid).
class ExportTabData extends StatelessWidget {
  final bool isProcessing;
  final bool hasElements;
  final VoidCallback onDownloadJson;
  final VoidCallback onCopyJson;
  final VoidCallback onImportFile;

  const ExportTabData({
    super.key,
    required this.isProcessing,
    required this.hasElements,
    required this.onDownloadJson,
    required this.onCopyJson,
    required this.onImportFile,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      key: const ValueKey('tab_json'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Save & Copy Actions Box
        Container(
          padding: const EdgeInsets.all(14),
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
              Text(
                'Save Native Whiteboard Data',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Export entire canvas elements with styles, layers and connections.',
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isProcessing || !hasElements ? null : onDownloadJson,
                      icon: const Icon(Icons.save_alt_rounded, size: 17),
                      label: const Text('Save File'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      onPressed: isProcessing || !hasElements
                          ? null
                          : onCopyJson,
                      icon: const Icon(Icons.copy_rounded, size: 17),
                      label: const Text('Copy JSON'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Import Section Button
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
            backgroundColor:
                scheme.primary.withValues(alpha: isDark ? 0.08 : 0.04),
          ),
          onPressed: isProcessing ? null : onImportFile,
          icon: Icon(
            Icons.folder_open_rounded,
            size: 19,
            color: scheme.primary,
          ),
          label: Text(
            'Open / Import File...',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: scheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
