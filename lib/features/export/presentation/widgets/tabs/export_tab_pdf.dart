import 'package:flutter/material.dart';

import 'package:flutcanvas/features/export/data/services/export_service.dart';

/// PDF Document Export tab supporting single page, presentation slide decks, and multi-board workspace exports.
class ExportTabPdf extends StatelessWidget {
  final PdfExportMode pdfMode;
  final ValueChanged<PdfExportMode> onModeChanged;
  final int frameCount;
  final int boardCount;
  final bool isProcessing;
  final bool hasElements;
  final VoidCallback onExportPdf;

  const ExportTabPdf({
    super.key,
    required this.pdfMode,
    required this.onModeChanged,
    required this.frameCount,
    required this.boardCount,
    required this.isProcessing,
    required this.hasElements,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      key: const ValueKey('tab_pdf'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPdfCard(
          mode: PdfExportMode.currentBoard,
          title: 'Current Board (Single Page)',
          subtitle: 'Single high-resolution landscape page',
          icon: Icons.crop_landscape_rounded,
          enabled: !isProcessing,
          scheme: scheme,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildPdfCard(
          mode: PdfExportMode.presentationSlides,
          title: 'Presentation Slide Deck',
          subtitle: frameCount > 0
              ? 'Multi-page deck (1 page per Frame)'
              : 'Add Slide Frame elements to enable presentation export',
          badgeText: frameCount > 0 ? '$frameCount slides' : 'No frames',
          icon: Icons.slideshow_rounded,
          enabled: !isProcessing && frameCount > 0,
          scheme: scheme,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildPdfCard(
          mode: PdfExportMode.allBoards,
          title: 'All Workspace Boards',
          subtitle: 'Multi-page document across all board tabs',
          badgeText: '$boardCount boards',
          icon: Icons.dashboard_customize_outlined,
          enabled: !isProcessing && boardCount > 1,
          scheme: scheme,
          isDark: isDark,
        ),
        const SizedBox(height: 16),

        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1.5,
          ),
          onPressed: isProcessing || !hasElements ? null : onExportPdf,
          icon: isProcessing
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.picture_as_pdf_rounded, size: 19),
          label: Text(
            isProcessing
                ? 'Generating PDF...'
                : 'Download PDF Document (.pdf)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
        ),
      ],
    );
  }

  Widget _buildPdfCard({
    required PdfExportMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    String? badgeText,
    required bool enabled,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final isSelected = pdfMode == mode;
    return GestureDetector(
      onTap: enabled ? () => onModeChanged(mode) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: isDark ? 0.14 : 0.08)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.035)
                  : Colors.black.withValues(alpha: 0.025)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primary.withValues(alpha: 0.2)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected
                    ? scheme.primary
                    : (enabled ? scheme.onSurfaceVariant : Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: enabled ? scheme.onSurface : Colors.grey,
                          ),
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? scheme.primary.withValues(alpha: 0.2)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: enabled
                          ? scheme.onSurfaceVariant
                          : Colors.grey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? scheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? scheme.primary : scheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
