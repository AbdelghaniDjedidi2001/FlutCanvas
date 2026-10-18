import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/core/services/downloader/file_downloader.dart';
import 'package:flutcanvas/features/canvas/data/services/excalidraw_import_service.dart';
import 'package:flutcanvas/features/canvas/data/services/mermaid_parser_service.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_document.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/export/data/services/export_service.dart';
import 'package:flutcanvas/features/export/presentation/widgets/tabs/export_processing_banner.dart';
import 'package:flutcanvas/features/export/presentation/widgets/tabs/export_status_banner.dart';
import 'package:flutcanvas/features/export/presentation/widgets/tabs/export_tab_data.dart';
import 'package:flutcanvas/features/export/presentation/widgets/tabs/export_tab_mermaid.dart';
import 'package:flutcanvas/features/export/presentation/widgets/tabs/export_tab_pdf.dart';
import 'package:flutcanvas/features/export/presentation/widgets/tabs/export_tab_png.dart';
import 'package:flutcanvas/features/export/presentation/widgets/tabs/export_tab_svg.dart';

enum ExportFormatTab { png, svg, pdf, mermaid, json }

/// Dialog for exporting canvas elements to PNG, SVG, PDF, or JSON data,
/// as well as importing external diagram formats (Excalidraw, Mermaid, JSON).
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

  // Mermaid settings
  MermaidDirection _mermaidDirection = MermaidDirection.auto;
  bool _mermaidIncludeStyles = true;

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
                    color:
                        scheme.primary.withValues(alpha: isDark ? 0.18 : 0.12),
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

            // 2. Segmented Tab Pills
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
                    tab: ExportFormatTab.mermaid,
                    label: 'Mermaid',
                    icon: Icons.account_tree_outlined,
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
            if (_isProcessing)
              ExportProcessingBanner(
                title: _processingTitle,
                subtitle: _processingSubtitle,
              ),

            // 4. Tab Content Card
            Flexible(
              child: SingleChildScrollView(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: _buildActiveTabContent(),
                ),
              ),
            ),

            // 5. Status / Feedback Toast Banner
            if (_statusMessage != null && !_isProcessing) ...[
              const SizedBox(height: 12),
              ExportStatusBanner(
                message: _statusMessage!,
                isError: _isError,
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
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
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
                color: isSelected
                    ? scheme.primary
                    : scheme.onSurfaceVariant.withValues(alpha: 0.75),
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

  Widget _buildActiveTabContent() {
    final hasElements = widget.elements.isNotEmpty;

    return switch (_selectedTab) {
      ExportFormatTab.png => ExportTabPng(
          includeBackground: _pngIncludeBackground,
          onToggleBackground: (val) =>
              setState(() => _pngIncludeBackground = val),
          scale: _pngScale,
          onScaleChanged: (scale) => setState(() => _pngScale = scale),
          isProcessing: _isProcessing,
          hasElements: hasElements,
          onExportPng: _handleExportPng,
        ),
      ExportFormatTab.svg => ExportTabSvg(
          includeBackground: _svgIncludeBackground,
          onToggleBackground: (val) =>
              setState(() => _svgIncludeBackground = val),
          isProcessing: _isProcessing,
          hasElements: hasElements,
          onDownloadSvg: _handleDownloadSvg,
          onCopySvg: _handleCopySvg,
        ),
      ExportFormatTab.pdf => ExportTabPdf(
          pdfMode: _pdfMode,
          onModeChanged: (mode) => setState(() => _pdfMode = mode),
          frameCount: _frameCount,
          boardCount: _boardCount,
          isProcessing: _isProcessing,
          hasElements: hasElements,
          onExportPdf: _handleExportPdf,
        ),
      ExportFormatTab.mermaid => ExportTabMermaid(
          isProcessing: _isProcessing,
          hasElements: hasElements,
          direction: _mermaidDirection,
          includeStyles: _mermaidIncludeStyles,
          mermaidCode: _getMermaidPreview(),
          onDirectionChanged: (dir) => setState(() => _mermaidDirection = dir),
          onIncludeStylesChanged: (val) =>
              setState(() => _mermaidIncludeStyles = val),
          onCopyMermaid: _handleCopyMermaid,
          onDownloadMmd: _handleDownloadMmd,
        ),
      ExportFormatTab.json => ExportTabData(
          isProcessing: _isProcessing,
          hasElements: hasElements,
          onDownloadJson: _handleDownloadJson,
          onCopyJson: _handleCopyJsonToClipboard,
          onImportFile: _handleImportFile,
        ),
    };
  }

  // ── Mermaid Export Handlers ─────────────────────────────────────────
  String _getMermaidPreview() {
    return ExportService.exportToMermaid(
      elements: widget.elements,
      direction: _mermaidDirection,
      includeStyles: _mermaidIncludeStyles,
    );
  }

  Future<void> _handleCopyMermaid() async {
    setState(() {
      _isProcessing = true;
      _processingTitle = 'Generating Mermaid Script';
      _processingSubtitle = 'Copying flowchart markdown to clipboard...';
      _statusMessage = null;
      _isError = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 30));

    try {
      final code = _getMermaidPreview();
      final markdown = '```mermaid\n$code```';
      await Clipboard.setData(ClipboardData(text: markdown));
      if (mounted) {
        setState(() {
          _statusMessage = 'Mermaid markdown copied to clipboard!';
          _isError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Copy failed: $e';
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleDownloadMmd() async {
    setState(() {
      _isProcessing = true;
      _processingTitle = 'Exporting Mermaid File';
      _processingSubtitle = 'Generating .mmd diagram file...';
      _statusMessage = null;
      _isError = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 30));

    try {
      final code = _getMermaidPreview();
      final filename = '$_safeBaseName.mmd';
      FileDownloader.downloadString(
        content: code,
        filename: filename,
        mimeType: 'text/plain',
      );
      if (mounted) {
        setState(() {
          _statusMessage = 'Mermaid file downloaded ($filename).';
          _isError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Mermaid export failed: $e';
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
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
            _statusMessage =
                'PNG downloaded ($filename, ${(pngBytes.lengthInBytes / 1024).toStringAsFixed(1)} KB).';
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
      _processingSubtitle =
          'Computing vector paths and connector geometries...';
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
          _statusMessage =
              'PDF generated ($filename, ${(pdfBytes.lengthInBytes / 1024).toStringAsFixed(1)} KB).';
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
        setState(
            () => _processingSubtitle = 'Triggering .whiteboard download...');
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
          _statusMessage =
              'Whiteboard data (${widget.elements.length} elements) copied to clipboard!';
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
        allowedExtensions: [
          'json',
          'whiteboard',
          'excalidraw',
          'mermaid',
          'mmd',
          'txt',
        ],
      );

      if (result.isNotEmpty) {
        final file = result.first;
        final bytes = await file.readAsBytes();
        final content = utf8.decode(bytes);

        List<BoardElement>? imported;
        if (ExcalidrawImportService.isExcalidrawJson(content)) {
          imported =
              ExcalidrawImportService.importFromExcalidraw(jsonStr: content);
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
