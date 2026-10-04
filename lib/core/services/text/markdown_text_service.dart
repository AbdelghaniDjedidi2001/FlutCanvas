import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lightweight, resilient Markdown-to-TextSpan parser for Sticky Notes and Canvas Text.
/// Supports headers, bullet/numbered lists, blockquotes, bold, italic, strikethrough, inline code, and links.
class MarkdownTextService {
  /// Parses raw markdown text into a styled TextSpan tree
  static TextSpan parseMarkdown({
    required String text,
    required TextStyle baseStyle,
    Color? codeBackgroundColor,
    Color? linkColor,
    bool isDark = false,
  }) {
    if (text.isEmpty) {
      return TextSpan(text: '', style: baseStyle);
    }

    final lines = text.split('\n');
    final children = <InlineSpan>[];

    final codeBg = codeBackgroundColor ??
        (isDark ? const Color(0x33FFFFFF) : const Color(0x18000000));
    final effectiveLinkColor = linkColor ??
        (isDark ? const Color(0xFF748FFC) : const Color(0xFF1971C2));

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isLast = i == lines.length - 1;

      // 1. Headings (# H1, ## H2, ### H3)
      if (line.startsWith('#')) {
        final headingMatch = RegExp(r'^(#{1,3})\s+(.*)$').firstMatch(line);
        if (headingMatch != null) {
          final level = headingMatch.group(1)!.length;
          final content = headingMatch.group(2)!;
          final scale = switch (level) {
            1 => 1.35,
            2 => 1.20,
            _ => 1.10,
          };

          final headingStyle = baseStyle.copyWith(
            fontSize: (baseStyle.fontSize ?? 16.0) * scale,
            fontWeight: FontWeight.bold,
          );

          children.add(_parseInline(content, headingStyle, codeBg, effectiveLinkColor));
          if (!isLast) children.add(const TextSpan(text: '\n'));
          continue;
        }
      }

      // 2. Blockquote (> quote)
      if (line.startsWith('> ') || line == '>') {
        final content = line.length > 2 ? line.substring(2) : '';
        final quoteStyle = baseStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: baseStyle.color?.withValues(alpha: 0.85),
        );
        children.add(TextSpan(text: '▌ ', style: baseStyle.copyWith(fontWeight: FontWeight.bold, color: effectiveLinkColor)));
        children.add(_parseInline(content, quoteStyle, codeBg, effectiveLinkColor));
        if (!isLast) children.add(const TextSpan(text: '\n'));
        continue;
      }

      // 3. Bullet List (- item, * item, • item)
      if (RegExp(r'^\s*[-*•]\s+').hasMatch(line)) {
        final match = RegExp(r'^(\s*)[-*•]\s+(.*)$').firstMatch(line)!;
        final indent = match.group(1)!;
        final content = match.group(2)!;

        children.add(TextSpan(text: '$indent• ', style: baseStyle.copyWith(fontWeight: FontWeight.bold)));
        children.add(_parseInline(content, baseStyle, codeBg, effectiveLinkColor));
        if (!isLast) children.add(const TextSpan(text: '\n'));
        continue;
      }

      // 4. Numbered List (1. item)
      if (RegExp(r'^\s*\d+\.\s+').hasMatch(line)) {
        final match = RegExp(r'^(\s*\d+\.)\s+(.*)$').firstMatch(line)!;
        final numPrefix = match.group(1)!;
        final content = match.group(2)!;

        children.add(TextSpan(text: '$numPrefix ', style: baseStyle.copyWith(fontWeight: FontWeight.w600)));
        children.add(_parseInline(content, baseStyle, codeBg, effectiveLinkColor));
        if (!isLast) children.add(const TextSpan(text: '\n'));
        continue;
      }

      // 5. Standard line with inline formatting
      children.add(_parseInline(line, baseStyle, codeBg, effectiveLinkColor));
      if (!isLast) children.add(const TextSpan(text: '\n'));
    }

    return TextSpan(children: children, style: baseStyle);
  }

  /// Parses inline markdown tags: **bold**, *italic*, ~~strikethrough~~, `code`, [links](url)
  static InlineSpan _parseInline(
    String text,
    TextStyle style,
    Color codeBg,
    Color linkColor,
  ) {
    if (text.isEmpty) return const TextSpan(text: '');

    final spans = <InlineSpan>[];
    // Regex matches inline tokens:
    // 1. `inline code`
    // 2. **bold** or __bold__
    // 3. *italic* or _italic_
    // 4. ~~strikethrough~~
    // 5. [link text](url)
    final tokenRegex = RegExp(
      r'(`([^`]+)`)'
      r'|(\*\*([^*]+)\*\*|__([^_]+)__)'
      r'|(\*([^*]+)\*|_([^_]+)_)'
      r'|(~~([^~]+)~~)'
      r'|(\[([^\]]+)\]\(([^)]+)\))',
    );

    var lastIndex = 0;
    for (final match in tokenRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start), style: style));
      }

      // 1. Inline Code `code`
      if (match.group(1) != null) {
        final codeContent = match.group(2)!;
        spans.add(
          TextSpan(
            text: ' $codeContent ',
            style: GoogleFonts.jetBrainsMono(
              textStyle: style.copyWith(
                backgroundColor: codeBg,
                fontWeight: FontWeight.w600,
                fontSize: (style.fontSize ?? 16.0) * 0.9,
              ),
            ),
          ),
        );
      }
      // 2. Bold **text** / __text__
      else if (match.group(3) != null) {
        final boldContent = match.group(4) ?? match.group(5)!;
        spans.add(
          TextSpan(
            text: boldContent,
            style: style.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      }
      // 3. Italic *text* / _text_
      else if (match.group(6) != null) {
        final italicContent = match.group(7) ?? match.group(8)!;
        spans.add(
          TextSpan(
            text: italicContent,
            style: style.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      }
      // 4. Strikethrough ~~text~~
      else if (match.group(9) != null) {
        final strikeContent = match.group(10)!;
        spans.add(
          TextSpan(
            text: strikeContent,
            style: style.copyWith(decoration: TextDecoration.lineThrough),
          ),
        );
      }
      // 5. Link [text](url)
      else if (match.group(11) != null) {
        final linkText = match.group(12)!;
        spans.add(
          TextSpan(
            text: linkText,
            style: style.copyWith(
              color: linkColor,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: style));
    }

    return TextSpan(children: spans, style: style);
  }
}
