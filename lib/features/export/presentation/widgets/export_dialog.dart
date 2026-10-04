import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_document.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/data/services/excalidraw_import_service.dart';
import 'package:flutcanvas/features/export/data/services/export_service.dart';
import 'package:flutcanvas/core/services/downloader/file_downloader.dart';
import 'package:flutcanvas/features/canvas/data/services/mermaid_parser_service.dart';

enum ExportFormatTab { png, svg, pdf, json }

class ExportDialog extends StatefulWidget {
  const ExportDialog({
    super.key,
    required this.elements,
    required this.colors,
    required this.onImport,
    this.allBoards,
    this.boardName,
  });

  final List<BoardElement> elements;
  final BoardColors colors;
  final void Function(List<BoardElement> imported) onImport;
  final List<BoardDocument>? allBoards;
  final String? boardName;

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportFormatTab _selectedTab = ExportFormatTab.png;

  // PNG settings
  bool _pngIncludeBackground = true;
  double _pngScale = 2.0;

  // SVG settings
  bool _svgIncludeBackground = true;

  // PDF settings
  PdfExportMode _pdfMode = PdfExportMode.currentBoard;

  bool _isProcessing = false;
  String _processingTitle = 'Processing export...';
  String _processingSubtitle = 'Please wait...';
  String? _statusMessage;
  bool _isError = false;

  String get _safeBaseName {
    final raw = (widget.boardName?.trim().isNotEmpty ?? false)
        ? widget.boardName!.trim()
        : 'flutcanvas_board';
    return raw.replaceAll(RegExp(r'[^\w\-]'), '_').toLowerCase();
  }

  int get _frameCount => widget.elements
      .where((e) => e.type == ShapeType.frame && e.isVisible)
      .length;

  int get _boardCount => widget.allBoards?.length ?? 1;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: scheme.surfaceContainerHigh,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 530,
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header (Icon badge, title, subtitle, close button)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    Icons.ios_share_rounded,
                    size: 20,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export & Share',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Download images, vector graphics, slide decks, or canvas data.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                  icon: Icon(
                    Icons.close_rounded,
                    size: 19,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 2. Modern Segmented Tab Pills
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  _tabPill(
                    tab: ExportFormatTab.png,
                    label: 'PNG',
                    icon: Icons.image_outlined,
                    scheme: scheme,
                    isDark: isDark,
                  ),
                  _tabPill(
                    tab: ExportFormatTab.svg,
                    label: 'SVG',
                    icon: Icons.polyline_outlined,
                    scheme: scheme,
                    isDark: isDark,
                  ),
                  _tabPill(
                    tab: ExportFormatTab.pdf,
                    label: 'PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    scheme: scheme,
                    isDark: isDark,
                  ),
                  _tabPill(
                    tab: ExportFormatTab.json,
                    label: 'Data',
                    icon: Icons.data_object_rounded,
                    scheme: scheme,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Active Processing Indicator Banner
            if (_isProcessing) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _processingTitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 3.5,
                        backgroundColor: scheme.primary.withValues(alpha: 0.15),
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _processingSubtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 4. Tab Content Card
            Flexible(
              child: SingleChildScrollView(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: _buildActiveTabContent(scheme, isDark),
                ),
              ),
            ),

            // 5. Status / Feedback Toast Banner
            if (_statusMessage != null && !_isProcessing) ...[
              const SizedBox(height: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: _isError
                      ? scheme.errorContainer.withValues(alpha: 0.7)
                      : (isDark
                          ? scheme.primaryContainer.withValues(alpha: 0.3)
                          : const Color(0xFFEBFBEE)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isError
                        ? scheme.error.withValues(alpha: 0.5)
                        : (isDark ? scheme.primary.withValues(alpha: 0.3) : const Color(0xFFB2F2BB)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
                      size: 16,
                      color: _isError ? scheme.error : const Color(0xFF2B8A3E),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _isError
                              ? scheme.onErrorContainer
                              : (isDark ? scheme.onPrimaryContainer : const Color(0xFF2B8A3E)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabPill({
    required ExportFormatTab tab,
    required String label,
    required IconData icon,
    required ColorScheme scheme,
    required bool isDark,
  }) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: _isProcessing
            ? null
            : () => setState(() {
                  _selectedTab = tab;
                  _statusMessage = null;
                }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 7.5),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? scheme.surfaceContainerHighest : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    )
                  ]
                : null,
            border: Border.all(
              color: isSelected
                  ? scheme.primary.withValues(alpha: isDark ? 0.35 : 0.2)
                  : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant.withValues(alpha: 0.75),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(ColorScheme scheme, bool isDark) {
    return switch (_selectedTab) {
      ExportFormatTab.png => _buildPngTab(scheme, isDark),
      ExportFormatTab.svg => _buildSvgTab(scheme, isDark),
      ExportFormatTab.pdf => _buildPdfTab(scheme, isDark),
      ExportFormatTab.json => _buildJsonTab(scheme, isDark),
    };
  }

  // ── PNG Tab ────────────────────────────────────────────────────────
  Widget _buildPngTab(ColorScheme scheme, bool isDark) {
    final hasElements = widget.elements.isNotEmpty;

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
                      value: _pngIncludeBackground,
                      onChanged: _isProcessing
                          ? null
                          : (v) => setState(() => _pngIncludeBackground = v),
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
          onPressed: _isProcessing || !hasElements ? null : _handleExportPng,
          icon: _isProcessing
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                )
              : const Icon(Icons.download_rounded, size: 19),
          label: Text(
            _isProcessing ? 'Generating PNG...' : 'Download PNG Image (.png)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
        ),
      ],
    );
  }

  Widget _scaleChip(double scale, String label, ColorScheme scheme, bool isDark) {
    final isSelected = _pngScale == scale;
    return GestureDetector(
      onTap: _isProcessing ? null : () => setState(() => _pngScale = scale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
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

  // ── SVG Tab ────────────────────────────────────────────────────────
  Widget _buildSvgTab(ColorScheme scheme, bool isDark) {
    final hasElements = widget.elements.isNotEmpty;

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
              Icon(Icons.format_paint_outlined, size: 18, color: scheme.onSurfaceVariant),
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
                  value: _svgIncludeBackground,
                  onChanged: _isProcessing
                      ? null
                      : (v) => setState(() => _svgIncludeBackground = v),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1.5,
                ),
                onPressed: _isProcessing || !hasElements ? null : _handleDownloadSvg,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, size: 19),
                label: const Text(
                  'Download SVG',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
                ),
                onPressed: _isProcessing || !hasElements ? null : _handleCopySvg,
                icon: const Icon(Icons.copy_rounded, size: 17),
                label: const Text(
                  'Copy SVG XML',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── PDF Tab ────────────────────────────────────────────────────────
  Widget _buildPdfTab(ColorScheme scheme, bool isDark) {
    final hasElements = widget.elements.isNotEmpty;
    final frameCount = _frameCount;
    final boardCount = _boardCount;

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
          enabled: !_isProcessing,
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
          enabled: !_isProcessing && frameCount > 0,
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
          enabled: !_isProcessing && boardCount > 1,
          scheme: scheme,
          isDark: isDark,
        ),
        const SizedBox(height: 16),

        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1.5,
          ),
          onPressed: _isProcessing || !hasElements ? null : _handleExportPdf,
          icon: _isProcessing
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                )
              : const Icon(Icons.picture_as_pdf_rounded, size: 19),
          label: Text(
            _isProcessing ? 'Generating PDF...' : 'Download PDF Document (.pdf)',
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
    final isSelected = _pdfMode == mode;
    return GestureDetector(
      onTap: enabled ? () => setState(() => _pdfMode = mode) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: isDark ? 0.14 : 0.08)
              : (isDark ? Colors.white.withValues(alpha: 0.035) : Colors.black.withValues(alpha: 0.025)),
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
                    : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? scheme.primary : (enabled ? scheme.onSurfaceVariant : Colors.grey),
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
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: enabled ? scheme.onSurface : Colors.grey,
                          ),
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? scheme.primary.withValues(alpha: 0.2)
                                : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
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
                      color: enabled ? scheme.onSurfaceVariant : Colors.grey.withValues(alpha: 0.7),
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

  // ── JSON Data Tab ──────────────────────────────────────────────────
  Widget _buildJsonTab(ColorScheme scheme, bool isDark) {
    final hasElements = widget.elements.isNotEmpty;

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
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isProcessing || !hasElements ? null : _handleDownloadJson,
                      icon: const Icon(Icons.save_alt_rounded, size: 17),
                      label: const Text('Save File'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
                      ),
                      onPressed: _isProcessing || !hasElements ? null : _handleCopyJsonToClipboard,
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
            backgroundColor: scheme.primary.withValues(alpha: isDark ? 0.08 : 0.04),
          ),
          onPressed: _isProcessing ? null : _handleImportFile,
          icon: Icon(Icons.folder_open_rounded, size: 19, color: scheme.primary),
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

  // ── Action Handlers ────────────────────────────────────────────────
  Future<void> _handleExportPng() async {
    setState(() {
      _isProcessing = true;
      _processingTitle = 'Generating High-Resolution PNG Image';
      _processingSubtitle = 'Preparing canvas layers...';
      _statusMessage = null;
      _isError = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 50));

    try {
      final pngBytes = await ExportService.renderToPng(
        elements: widget.elements,
        colors: widget.colors,
        includeBackground: _pngIncludeBackground,
        scale: _pngScale,
        onProgress: (status) {
          if (mounted) setState(() => _processingSubtitle = status);
        },
      );

      if (pngBytes != null) {
        if (mounted) {
          setState(() => _processingSubtitle = 'Triggering file download...');
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final filename = '${_safeBaseName}_${_pngScale.toInt()}x.png';
        FileDownloader.downloadBytes(
          bytes: pngBytes,
          filename: filename,
          mimeType: 'image/png',
        );
        if (mounted) {
          setState(() {
            _statusMessage = 'PNG downloaded ($filename, ${(pngBytes.lengthInBytes / 1024).toStringAsFixed(1)} KB).';
            _isError = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'PNG export failed: $e';
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleDownloadSvg() async {
    setState(() {
      _isProcessing = true;
      _processingTitle = 'Generating Vector SVG Graphic';
      _processingSubtitle = 'Computing vector paths and connector geometries...';
      _statusMessage = null;
      _isError = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 50));

    try {
      final svgStr = ExportService.exportToSvg(
        elements: widget.elements,
        colors: widget.colors,
        includeBackground: _svgIncludeBackground,
      );

      if (mounted) {
        setState(() => _processingSubtitle = 'Triggering SVG file download...');
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final filename = '$_safeBaseName.svg';
      FileDownloader.downloadString(
        content: svgStr,
        filename: filename,
        mimeType: 'image/svg+xml',
      );
      if (mounted) {
        setState(() {
          _statusMessage = 'SVG downloaded ($filename).';
          _isError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'SVG export failed: $e';
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCopySvg() async {
    setState(() {
      _isProcessing = true;
      _processingTitle = 'Generating Vector SVG';
      _processingSubtitle = 'Copying SVG XML code to clipboard...';
      _statusMessage = null;
      _isError = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 50));

    try {
      final svgStr = ExportService.exportToSvg(
        elements: widget.elements,
        colors: widget.colors,
        includeBackground: _svgIncludeBackground,
      );
      await Clipboard.setData(ClipboardData(text: svgStr));
      if (mounted) {
        setState(() {
          _statusMessage = 'SVG XML code copied to clipboard!';
          _isError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Copying SVG failed: $e';
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleExportPdf() async {
    setState(() {
      _isProcessing = true;
      _processingTitle = _pdfMode == PdfExportMode.presentationSlides
          ? 'Generating Presentation Slide Deck (PDF)'
          : _pdfMode == PdfExportMode.allBoards
              ? 'Generating Multi-Board PDF Document'
              : 'Generating Landscape PDF Document';
      _processingSubtitle = 'Initializing document renderer...';
      _statusMessage = null;
      _isError = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 50));

    try {
      final pdfBytes = await ExportService.exportToPdf(
        elements: widget.elements,
        colors: widget.colors,
        allBoards: widget.allBoards,
        mode: _pdfMode,
        onProgress: (status) {
          if (mounted) setState(() => _processingSubtitle = status);
        },
      );

      if (mounted) {
        setState(() => _processingSubtitle = 'Triggering PDF file download...');
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final filename = _pdfMode == PdfExportMode.presentationSlides
          ? '${_safeBaseName}_presentation.pdf'
          : '$_safeBaseName.pdf';

      FileDownloader.downloadBytes(
        bytes: pdfBytes,
        filename: filename,
        mimeType: 'application/pdf',
      );

      if (mounted) {
        setState(() {
          _statusMessage = 'PDF generated ($filename, ${(pdfBytes.lengthInBytes / 1024).toStringAsFixed(1)} KB).';
          _isError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'PDF export failed: $e';
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleDownloadJson() async {
    setState(() {
      _isProcessing = true;
      _processingTitle = 'Saving Whiteboard Project Data';
      _processingSubtitle = 'Formatting JSON data...';
      _statusMessage = null;
      _isError = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 50));

    try {
      final jsonStr = ExportService.exportToJson(widget.elements);
      if (mounted) {
        setState(() => _processingSubtitle = 'Triggering .whiteboard download...');
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final filename = '$_safeBaseName.whiteboard';
      FileDownloader.downloadString(
        content: jsonStr,
        filename: filename,
        mimeType: 'application/json',
      );
      if (mounted) {
        setState(() {
          _statusMessage = 'Project saved ($filename).';
          _isError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Saving project failed: $e';
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCopyJsonToClipboard() async {
    setState(() {
      _isProcessing = true;
      _processingTitle = 'Formatting Whiteboard Data';
      _processingSubtitle = 'Copying JSON to clipboard...';
      _statusMessage = null;
      _isError = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 50));

    try {
      final jsonStr = ExportService.exportToJson(widget.elements);
      await Clipboard.setData(ClipboardData(text: jsonStr));
      if (mounted) {
        setState(() {
          _statusMessage = 'Whiteboard data (${widget.elements.length} elements) copied to clipboard!';
          _isError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Copying JSON failed: $e';
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleImportFile() async {
    setState(() {
      _isProcessing = true;
      _processingTitle = 'Opening File';
      _processingSubtitle = 'Selecting and parsing whiteboard file...';
      _statusMessage = null;
      _isError = false;
    });

    try {
      final result = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'whiteboard', 'excalidraw', 'mermaid', 'mmd', 'txt'],
      );

      if (result.isNotEmpty) {
        final file = result.first;
        final bytes = await file.readAsBytes();
        final content = utf8.decode(bytes);

        List<BoardElement>? imported;
        if (ExcalidrawImportService.isExcalidrawJson(content)) {
          imported = ExcalidrawImportService.importFromExcalidraw(jsonStr: content);
        } else if (MermaidParserService.isMermaidSyntax(content)) {
          imported = MermaidParserService.parseToElements(script: content);
        } else {
          imported = ExportService.importFromJson(content);
        }

        if (imported != null && imported.isNotEmpty) {
          widget.onImport(imported);
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          if (mounted) {
            setState(() {
              _statusMessage = 'Unrecognized file format or empty diagram.';
              _isError = true;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error opening file: $e';
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
