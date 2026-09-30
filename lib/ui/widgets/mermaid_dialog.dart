import 'package:flutter/material.dart';

import '../../models/board_element.dart';
import '../../services/mermaid_parser_service.dart';

class MermaidDialog extends StatefulWidget {
  const MermaidDialog({
    super.key,
    required this.onInsert,
    this.initialScript,
    this.targetOrigin = const Offset(200, 200),
  });

  final void Function(List<BoardElement> elements) onInsert;
  final String? initialScript;
  final Offset targetOrigin;

  @override
  State<MermaidDialog> createState() => _MermaidDialogState();
}

class _MermaidDialogState extends State<MermaidDialog> {
  late final TextEditingController _codeController;
  String? _parseSummary;
  int _parsedCount = 0;

  static const _sampleArchitecture = '''graph TD
  Client[Web & Mobile App] --> Gateway[API Gateway]
  Gateway --> Auth[Auth Service]
  Gateway --> Core[Core Engine]
  Core --> Cache[(Redis Cache)]
  Core --> DB[(PostgreSQL DB)]''';

  static const _sampleFlowchart = '''flowchart TD
  Start([Start Request]) --> Check{Has Auth Token?}
  Check -->|Yes| Process[Process Request]
  Check -->|No| Login[Redirect to Login]
  Process --> Result{Success?}
  Result -->|Yes| Done([Complete 200 OK])
  Result -->|No| Retry[Retry Queue]
  Retry --> Process''';

  static const _sampleSubgraphs = '''graph LR
  subgraph Client Tier
    Web[Web Portal]
    App[Mobile App]
  end
  subgraph Backend Tier
    API[API Gateway]
    Micro1[Billing Service]
    Micro2[Analytics Service]
  end
  Web --> API
  App --> API
  API --> Micro1
  API --> Micro2''';

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(
      text: widget.initialScript?.trim().isNotEmpty == true
          ? widget.initialScript!
          : _sampleArchitecture,
    );
    _codeController.addListener(_updateParseSummary);
    _updateParseSummary();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _updateParseSummary() {
    final text = _codeController.text;
    if (text.trim().isEmpty) {
      setState(() {
        _parseSummary = 'Enter Mermaid graph syntax to generate diagram';
        _parsedCount = 0;
      });
      return;
    }

    try {
      final elements = MermaidParserService.parseToElements(
        script: text,
        origin: widget.targetOrigin,
      );
      final shapes = elements.where((e) => e.text.isNotEmpty || e.type.name.contains('rect') || e.type.name.contains('ellipse') || e.type.name.contains('diamond')).length;
      final connectors = elements.where((e) => e.type.name.contains('arrow') || e.type.name.contains('line')).length;
      final frames = elements.where((e) => e.type.name == 'frame').length;

      setState(() {
        _parsedCount = elements.length;
        _parseSummary = 'Parsed: $shapes shapes, $connectors connectors${frames > 0 ? ', $frames subgraphs' : ''}';
      });
    } catch (e) {
      setState(() {
        _parseSummary = 'Syntax error: $e';
        _parsedCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded, size: 24, color: Color(0xFF748FFC)),
          SizedBox(width: 10),
          Text('Mermaid Code to Diagram'),
        ],
      ),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paste or write Mermaid.js flowchart syntax to instantly generate editable canvas shapes and connectors:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Quick Samples Chips in Wrap
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Templates:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ActionChip(
                    label: const Text('Architecture', style: TextStyle(fontSize: 12)),
                    onPressed: () => _codeController.text = _sampleArchitecture,
                    visualDensity: VisualDensity.compact,
                  ),
                  ActionChip(
                    label: const Text('Flowchart', style: TextStyle(fontSize: 12)),
                    onPressed: () => _codeController.text = _sampleFlowchart,
                    visualDensity: VisualDensity.compact,
                  ),
                  ActionChip(
                    label: const Text('Subgraphs', style: TextStyle(fontSize: 12)),
                    onPressed: () => _codeController.text = _sampleSubgraphs,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Code Editor
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.4,
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                    hintText: 'graph TD\n  A[Start] --> B[End]',
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Parse Summary Banner
              if (_parseSummary != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _parsedCount > 0
                        ? scheme.primaryContainer.withValues(alpha: 0.3)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _parsedCount > 0 ? Icons.check_circle_outline : Icons.info_outline,
                        size: 16,
                        color: _parsedCount > 0 ? scheme.primary : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _parseSummary!,
                          style: TextStyle(
                            fontSize: 12,
                            color: _parsedCount > 0 ? scheme.onPrimaryContainer : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _parsedCount == 0
              ? null
              : () {
                  final elements = MermaidParserService.parseToElements(
                    script: _codeController.text,
                    origin: widget.targetOrigin,
                  );
                  if (elements.isNotEmpty) {
                    widget.onInsert(elements);
                    Navigator.of(context).pop();
                  }
                },
          icon: const Icon(Icons.add_to_photos_rounded, size: 18),
          label: Text('Insert Diagram (${_parsedCount > 0 ? '$_parsedCount items' : '0'})'),
        ),
      ],
    );
  }
}
