import 'package:flutter/material.dart';

/// PNG Export tab with background toggle, resolution scaling chips, and download trigger.
class ExportTabPng extends StatelessWidget {
  final bool includeBackground;
  final ValueChanged<bool> onToggleBackground;
  final double scale;
  final ValueChanged<double> onScaleChanged;
  final bool isProcessing;
  final bool hasElements;
  final VoidCallback onExportPng;

  const ExportTabPng({
    super.key,
    required this.includeBackground,
    required this.onToggleBackground,
    required this.scale,
    required this.onScaleChanged,
    required this.isProcessing,
    required this.hasElements,
    required this.onExportPng,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      key: const ValueKey('tab_png'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Settings Card
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
            children: [
              // 1. Background Toggle
              Row(
                children: [
                  Icon(
                    Icons.format_paint_outlined,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Canvas Background',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        Text(
                          'Include solid background or export transparent PNG',
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
              const Divider(height: 20, thickness: 0.8),

              // 2. Resolution Scale Pills
              Row(
                children: [
                  Icon(
                    Icons.aspect_ratio_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resolution Scale',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        Text(
                          'Select output pixel density',
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _scaleChip(1.0, '1x', scheme, isDark),
                  const SizedBox(width: 6),
                  _scaleChip(2.0, '2x', scheme, isDark),
                  const SizedBox(width: 6),
                  _scaleChip(3.0, '3x', scheme, isDark),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Primary Action Button
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1.5,
          ),
          onPressed: isProcessing || !hasElements ? null : onExportPng,
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
          label: Text(
            isProcessing ? 'Generating PNG...' : 'Download PNG Image (.png)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
        ),
      ],
    );
  }

  Widget _scaleChip(
    double chipScale,
    String label,
    ColorScheme scheme,
    bool isDark,
  ) {
    final isSelected = scale == chipScale;
    return GestureDetector(
      onTap: isProcessing ? null : () => onScaleChanged(chipScale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
