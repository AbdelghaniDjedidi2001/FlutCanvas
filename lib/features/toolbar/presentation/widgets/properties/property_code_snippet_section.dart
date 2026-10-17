import 'package:flutter/material.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';

/// Section for configuring code snippet blocks (language syntax, line numbers, copy).
class PropertyCodeSnippetSection extends StatelessWidget {
  final BoardElement? codeElement;
  final String activeLanguage;
  final bool activeShowLineNumbers;
  final void Function(String language) onSelectLanguage;
  final void Function(bool show) onToggleLineNumbers;
  final VoidCallback onCopyCode;

  static const supportedLanguages = [
    'dart',
    'javascript',
    'typescript',
    'python',
    'html',
    'css',
    'json',
    'sql',
    'bash',
    'markdown',
    'cpp',
    'rust',
    'go',
  ];

  const PropertyCodeSnippetSection({
    super.key,
    this.codeElement,
    required this.activeLanguage,
    required this.activeShowLineNumbers,
    required this.onSelectLanguage,
    required this.onToggleLineNumbers,
    required this.onCopyCode,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Code Snippet',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('Language:', style: TextStyle(fontSize: 10)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: supportedLanguages.contains(activeLanguage.toLowerCase())
                          ? activeLanguage.toLowerCase()
                          : 'dart',
                      isDense: true,
                      isExpanded: true,
                      iconSize: 16,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      items: supportedLanguages
                          .map((lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ))
                          .toList(),
                      onChanged: (newLang) {
                        if (newLang != null) onSelectLanguage(newLang);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => onToggleLineNumbers(!activeShowLineNumbers),
              icon: Icon(
                activeShowLineNumbers
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 13,
              ),
              label: Text(
                activeShowLineNumbers
                    ? 'Line Numbers: ON'
                    : 'Line Numbers: OFF',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          if (codeElement != null) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onCopyCode,
                icon: const Icon(Icons.copy_rounded, size: 13),
                label: const Text('Copy Code', style: TextStyle(fontSize: 10)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
