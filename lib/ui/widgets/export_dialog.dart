import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/board_colors.dart';
import '../../models/board_document.dart';
import '../../models/board_element.dart';
import '../../models/shape_type.dart';
import '../../services/excalidraw_import_service.dart';
import '../../services/export_service.dart';
import '../../services/file_downloader.dart';
import '../../services/mermaid_parser_service.dart';

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

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.ios_share_outlined, size: 24),
          SizedBox(width: 10),
          Text('Export & Share'),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Format Selector Tabs
              SegmentedButton<ExportFormatTab>(
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
                segments: const [
                  ButtonSegment(
                    value: ExportFormatTab.png,
                    label: Text('PNG'),
                    icon: Icon(Icons.image_outlined, size: 16),
                  ),
                  ButtonSegment(
                    value: ExportFormatTab.svg,
                    label: Text('SVG'),
                    icon: Icon(Icons.polyline_outlined, size: 16),
                  ),
                  ButtonSegment(
                    value: ExportFormatTab.pdf,
                    label: Text('PDF'),
                    icon: Icon(Icons.picture_as_pdf_outlined, size: 16),
                  ),
                  ButtonSegment(
                    value: ExportFormatTab.json,
                    label: Text('Data'),
                    icon: Icon(Icons.code_rounded, size: 16),
                  ),
                ],
                selected: {_selectedTab},
                onSelectionChanged: _isProcessing
                    ? null
                    : (set) => setState(() {
                          _selectedTab = set.first;
                          _statusMessage = null;
                        }),
              ),
              const SizedBox(height: 16),

              // Active Processing Indicator Banner
              if (_isProcessing) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _processingTitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          backgroundColor: scheme.primary.withValues(alpha: 0.2),
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _processingSubtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Tab Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: _buildActiveTabContent(scheme),
              ),

              // Status Message Display
              if (_statusMessage != null && !_isProcessing) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isError
                        ? scheme.errorContainer.withValues(alpha: 0.7)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isError
                          ? scheme.error.withValues(alpha: 0.5)
                          : scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isError ? Icons.error_outline : Icons.check_circle_outline,
                        size: 16,
                        color: _isError ? scheme.error : scheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: _isError ? scheme.onErrorContainer : scheme.onSurface,
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildActiveTabContent(ColorScheme scheme) {
    return switch (_selectedTab) {
      ExportFormatTab.png => _buildPngTab(scheme),
      ExportFormatTab.svg => _buildSvgTab(scheme),
      ExportFormatTab.pdf => _buildPdfTab(scheme),
      ExportFormatTab.json => _buildJsonTab(scheme),
    };
  }

  // ── PNG Tab ────────────────────────────────────────────────────────
  Widget _buildPngTab(ColorScheme scheme) {
    final hasElements = widget.elements.isNotEmpty;

    return Column(
      key: const ValueKey('tab_png'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Include canvas background', style: TextStyle(fontSize: 14)),
          value: _pngIncludeBackground,
          onChanged: _isProcessing ? null : (v) => setState(() => _pngIncludeBackground = v),
        ),
        Row(
          children: [
            const Text('Resolution scale:', style: TextStyle(fontSize: 14)),
            const Spacer(),
            SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 1.0, label: Text('1x')),
                ButtonSegment(value: 2.0, label: Text('2x')),
                ButtonSegment(value: 3.0, label: Text('3x')),
              ],
              selected: {_pngScale},
              onSelectionChanged: _isProcessing ? null : (set) => setState(() => _pngScale = set.first),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(42),
          ),
          onPressed: _isProcessing || !hasElements ? null : _handleExportPng,
          icon: _isProcessing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : const Icon(Icons.download_rounded, size: 18),
          label: Text(_isProcessing ? 'Generating PNG...' : 'Download PNG Image (.png)'),
        ),
      ],
    );
  }

  // ── SVG Tab ────────────────────────────────────────────────────────
  Widget _buildSvgTab(ColorScheme scheme) {
    final hasElements = widget.elements.isNotEmpty;

    return Column(
      key: const ValueKey('tab_svg'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Vector graphics export preserves crisp lines, curves, arrowheads, connector labels, and shadows at any scale.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Include canvas background', style: TextStyle(fontSize: 14)),
          value: _svgIncludeBackground,
          onChanged: _isProcessing ? null : (v) => setState(() => _svgIncludeBackground = v),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(42)),
                onPressed: _isProcessing || !hasElements ? null : _handleDownloadSvg,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, size: 18),
                label: Text(_isProcessing ? 'Generating...' : 'Download SVG'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(42)),
                onPressed: _isProcessing || !hasElements ? null : _handleCopySvg,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy SVG XML'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── PDF Tab ────────────────────────────────────────────────────────
  Widget _buildPdfTab(ColorScheme scheme) {
    final hasElements = widget.elements.isNotEmpty;
    final frameCount = _frameCount;
    final boardCount = _boardCount;

    return Column(
      key: const ValueKey('tab_pdf'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Export high-resolution landscape document or presentation slide deck:',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _buildPdfModeOption(
          mode: PdfExportMode.currentBoard,
          title: 'Current Board (Single Page)',
          subtitle: 'Entire active canvas on landscape A4',
          enabled: !_isProcessing,
        ),
        _buildPdfModeOption(
          mode: PdfExportMode.presentationSlides,
          title: 'Slide Deck Presentation ($frameCount ${frameCount == 1 ? 'slide' : 'slides'})',
          subtitle: frameCount > 0
              ? 'Exports each Frame as an individual presentation page'
              : 'Add Slide Frame elements to enable presentation export',
          enabled: !_isProcessing && frameCount > 0,
        ),
        _buildPdfModeOption(
          mode: PdfExportMode.allBoards,
          title: 'All Workspace Boards ($boardCount ${boardCount == 1 ? 'board' : 'boards'})',
          subtitle: 'Exports each board tab as a separate page',
          enabled: !_isProcessing && boardCount > 1,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(42)),
          onPressed: _isProcessing || !hasElements ? null : _handleExportPdf,
          icon: _isProcessing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : const Icon(Icons.picture_as_pdf_rounded, size: 18),
          label: Text(_isProcessing ? 'Generating PDF...' : 'Download PDF Document (.pdf)'),
        ),
      ],
    );
  }

  Widget _buildPdfModeOption({
    required PdfExportMode mode,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    final isSelected = _pdfMode == mode;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: enabled ? () => setState(() => _pdfMode = mode) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<PdfExportMode>(
              value: mode,
              // ignore: deprecated_member_use
              groupValue: _pdfMode,
              // ignore: deprecated_member_use
              onChanged: enabled ? (v) => setState(() => _pdfMode = v!) : null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: enabled ? null : Colors.grey,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: enabled ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── JSON Data Tab ──────────────────────────────────────────────────
  Widget _buildJsonTab(ColorScheme scheme) {
    final hasElements = widget.elements.isNotEmpty;

    return Column(
      key: const ValueKey('tab_json'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Save or load whiteboard document files (.whiteboard / .json):',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(42)),
                onPressed: _isProcessing || !hasElements ? null : _handleDownloadJson,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.save_alt_rounded, size: 18),
                label: Text(_isProcessing ? 'Saving...' : 'Save File'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(42)),
                onPressed: _isProcessing || !hasElements ? null : _handleCopyJsonToClipboard,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy JSON'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
          onPressed: _isProcessing ? null : _handleImportFile,
          icon: const Icon(Icons.folder_open_outlined, size: 18),
          label: const Text('Open / Import File...'),
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
