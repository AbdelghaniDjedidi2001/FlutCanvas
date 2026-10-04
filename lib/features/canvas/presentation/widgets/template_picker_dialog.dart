import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/domain/models/templates.dart';

class TemplatePickerDialog extends StatelessWidget {
  const TemplatePickerDialog({
    super.key,
    required this.onSelectTemplate,
    this.onOpenMermaid,
  });

  final void Function(DiagramTemplateType type) onSelectTemplate;
  final VoidCallback? onOpenMermaid;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.auto_awesome_mosaic_outlined, size: 24),
          SizedBox(width: 10),
          Text('Diagram Templates & Generators'),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onOpenMermaid != null) ...[
                Card(
                  elevation: 0,
                  color: scheme.primaryContainer.withValues(alpha: 0.35),
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: scheme.primary.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      child: const Icon(Icons.auto_awesome_rounded, size: 20),
                    ),
                    title: const Text(
                      'Mermaid.js Code to Diagram',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Generate architecture & flowcharts directly from text/markdown syntax',
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.of(context).pop();
                      onOpenMermaid!();
                    },
                  ),
                ),
                const Divider(height: 16),
              ],
              for (final template in DiagramTemplateType.values) ...[
                Card(
                  elevation: 0,
                  color: scheme.surfaceContainerHighest,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: scheme.outlineVariant),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                      child: Icon(template.icon, size: 20),
                    ),
                    title: Text(
                      template.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      template.description,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectTemplate(template);
                    },
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
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
