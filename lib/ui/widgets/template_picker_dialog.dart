import 'package:flutter/material.dart';
import '../../models/templates.dart';

class TemplatePickerDialog extends StatelessWidget {
  const TemplatePickerDialog({super.key, required this.onSelectTemplate});

  final void Function(DiagramTemplateType type) onSelectTemplate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.auto_awesome_mosaic_outlined, size: 24),
          SizedBox(width: 10),
          Text('Choose a Diagram Template'),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
