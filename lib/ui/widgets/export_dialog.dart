import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/board_colors.dart';
import '../../models/board_element.dart';
import '../../services/export_service.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({
    super.key,
    required this.elements,
    required this.colors,
    required this.onImport,
  });

  final List<BoardElement> elements;
  final BoardColors colors;
  final void Function(List<BoardElement> imported) onImport;

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool _includeBackground = true;
  double _scale = 2.0;
  bool _isExporting = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.ios_share_outlined, size: 24),
          SizedBox(width: 10),
          Text('Export & Import Board'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Image (PNG)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Include canvas background'),
              value: _includeBackground,
              onChanged: (v) => setState(() => _includeBackground = v),
            ),
            Row(
              children: [
                const Text('Resolution scale:'),
                const Spacer(),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 1.0, label: Text('1x')),
                    ButtonSegment(value: 2.0, label: Text('2x')),
                    ButtonSegment(value: 3.0, label: Text('3x')),
                  ],
                  selected: {_scale},
                  onSelectionChanged: (set) =>
                      setState(() => _scale = set.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
              onPressed: _isExporting || widget.elements.isEmpty
                  ? null
                  : _handleExportPng,
              icon: _isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download, size: 18),
              label: Text(_isExporting ? 'Generating...' : 'Download PNG Image'),
            ),
            const Divider(height: 28),
            const Text(
              'Whiteboard Data (.json)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.elements.isEmpty
                        ? null
                        : _handleCopyJsonToClipboard,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy JSON'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _handleImportFile,
                    icon: const Icon(Icons.folder_open_outlined, size: 18),
                    label: const Text('Open File...'),
                  ),
                ),
              ],
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(fontSize: 12, color: scheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Future<void> _handleExportPng() async {
    setState(() {
      _isExporting = true;
      _statusMessage = null;
    });

    try {
      final pngBytes = await ExportService.renderToPng(
        elements: widget.elements,
        colors: widget.colors,
        includeBackground: _includeBackground,
        scale: _scale,
      );

      if (pngBytes != null && mounted) {
        setState(() {
          _statusMessage =
              'PNG rendered successfully (${pngBytes.lengthInBytes ~/ 1024} KB).';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = 'Export failed: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _handleCopyJsonToClipboard() {
    final jsonStr = ExportService.exportToJson(widget.elements);
    Clipboard.setData(ClipboardData(text: jsonStr));
    setState(() {
      _statusMessage =
          'Whiteboard data (${widget.elements.length} elements) copied to clipboard!';
    });
  }

  Future<void> _handleImportFile() async {
    try {
      final result = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'whiteboard', 'txt'],
      );

      if (result.isNotEmpty) {
        final file = result.first;
        final bytes = await file.readAsBytes();
        final content = utf8.decode(bytes);
        final imported = ExportService.importFromJson(content);
        if (imported != null && imported.isNotEmpty) {
          widget.onImport(imported);
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          setState(() => _statusMessage = 'Invalid whiteboard JSON format.');
        }
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error opening file: $e');
    }
  }
}
