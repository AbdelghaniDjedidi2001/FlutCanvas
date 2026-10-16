import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:flutcanvas/core/constants/board_colors.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/data/services/connector_routing_service.dart';
import 'package:flutcanvas/core/services/text/syntax_highlighter_service.dart';

class SvgExportService {
  static String exportToSvg({
    required List<BoardElement> elements,
    required BoardColors colors,
    bool includeBackground = true,
    double padding = 40.0,
  }) {
    if (elements.isEmpty) {
      return '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300" viewBox="0 0 400 300"></svg>';
    }

    // 1. Calculate entire bounding box
    final visibleElements = elements.where((e) => e.isVisible).toList();
    if (visibleElements.isEmpty) {
      return '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300" viewBox="0 0 400 300"></svg>';
    }

    Rect bounds = visibleElements.first.bounds;
    for (var i = 1; i < visibleElements.length; i++) {
      bounds = bounds.expandToInclude(visibleElements[i].bounds);
    }
    bounds = bounds.inflate(padding);

    final width = bounds.width.ceilToDouble();
    final height = bounds.height.ceilToDouble();
    final minX = bounds.left;
    final minY = bounds.top;

    final buffer = StringBuffer();
    buffer.writeln(
        '<svg width="$width" height="$height" viewBox="$minX $minY $width $height" xmlns="http://www.w3.org/2000/svg">');

    // SVG Defs (Drop Shadows, Styles)
    buffer.writeln('  <defs>');
    buffer.writeln('    <filter id="stickyShadow" x="-10%" y="-10%" width="130%" height="130%">');
    buffer.writeln('      <feDropShadow dx="0" dy="4" stdDeviation="4" flood-color="#000000" flood-opacity="0.12"/>');
    buffer.writeln('    </filter>');
    buffer.writeln('    <style>');
    buffer.writeln('      text { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }');
    buffer.writeln('    </style>');
    buffer.writeln('  </defs>');

    // Background rect
    if (includeBackground) {
      final bgHex = _colorToHex(colors.background);
      buffer.writeln('  <rect x="$minX" y="$minY" width="$width" height="$height" fill="$bgHex" />');
    }

    // Render all visible elements
    for (final el in visibleElements) {
      _renderElementSvg(buffer, el, colors);
    }

    buffer.writeln('</svg>');
    return buffer.toString();
  }

  static void _renderElementSvg(
    StringBuffer buffer,
    BoardElement el,
    BoardColors colors,
  ) {
    final strokeColor = _colorToHex(colors.display(el.color));
    final strokeOpacity = el.opacity;
    final strokeWidth = el.strokeWidth;
    final strokeDash = _getStrokeDashArray(el.strokeStyle);

    final isFillable = el.type == ShapeType.rectangle ||
        el.type == ShapeType.roundedRectangle ||
        el.type == ShapeType.ellipse ||
        el.type == ShapeType.diamond ||
        el.type == ShapeType.triangle ||
        el.type == ShapeType.star ||
        el.type == ShapeType.asymmetric;

    String fillAttr = 'fill="none"';
    if (isFillable && el.fillStyle != FillStyle.none) {
      final baseFill = el.fillColor != Colors.transparent ? el.fillColor : el.color;
      final fillHex = _colorToHex(colors.display(baseFill));
      final fillOpacity = (el.fillStyle == FillStyle.semi ? 0.25 : 1.0) * el.opacity;
      fillAttr = 'fill="$fillHex" fill-opacity="$fillOpacity"';
    }

    final hasRotation = el.rotation != 0.0;
    if (hasRotation) {
      final c = el.bounds.center;
      final deg = el.rotation * 180 / math.pi;
      buffer.writeln('  <g transform="rotate($deg ${c.dx} ${c.dy})">');
    }

    switch (el.type) {
      case ShapeType.rectangle:
        final r = el.bounds;
        buffer.writeln(
            '    <rect x="${r.left}" y="${r.top}" width="${r.width}" height="${r.height}" rx="4" $fillAttr stroke="$strokeColor" stroke-width="$strokeWidth" stroke-opacity="$strokeOpacity" $strokeDash/>');
        break;

      case ShapeType.roundedRectangle:
        final r = el.bounds;
        buffer.writeln(
            '    <rect x="${r.left}" y="${r.top}" width="${r.width}" height="${r.height}" rx="16" $fillAttr stroke="$strokeColor" stroke-width="$strokeWidth" stroke-opacity="$strokeOpacity" $strokeDash/>');
        break;

      case ShapeType.ellipse:
        final r = el.bounds;
        buffer.writeln(
            '    <ellipse cx="${r.center.dx}" cy="${r.center.dy}" rx="${r.width / 2}" ry="${r.height / 2}" $fillAttr stroke="$strokeColor" stroke-width="$strokeWidth" stroke-opacity="$strokeOpacity" $strokeDash/>');
        break;

      case ShapeType.diamond:
        final r = el.bounds;
        final p = '${r.center.dx},${r.top} ${r.right},${r.center.dy} ${r.center.dx},${r.bottom} ${r.left},${r.center.dy}';
        buffer.writeln(
            '    <polygon points="$p" $fillAttr stroke="$strokeColor" stroke-width="$strokeWidth" stroke-opacity="$strokeOpacity" $strokeDash/>');
        break;

      case ShapeType.triangle:
        final r = el.bounds;
        final p = '${r.center.dx},${r.top} ${r.right},${r.bottom} ${r.left},${r.bottom}';
        buffer.writeln(
            '    <polygon points="$p" $fillAttr stroke="$strokeColor" stroke-width="$strokeWidth" stroke-opacity="$strokeOpacity" $strokeDash/>');
        break;

      case ShapeType.star:
        final starPoints = _getStarPoints(el.bounds);
        buffer.writeln(
            '    <polygon points="$starPoints" $fillAttr stroke="$strokeColor" stroke-width="$strokeWidth" stroke-opacity="$strokeOpacity" $strokeDash/>');
        break;

      case ShapeType.asymmetric:
        final r = el.bounds;
        final indent = math.min(18.0, r.width * 0.12);
        final p = '${r.left},${r.top} ${r.right - indent},${r.top} ${r.right},${r.center.dy} ${r.right - indent},${r.bottom} ${r.left},${r.bottom} ${r.left + indent},${r.center.dy}';
        buffer.writeln(
            '    <polygon points="$p" $fillAttr stroke="$strokeColor" stroke-width="$strokeWidth" stroke-opacity="$strokeOpacity" $strokeDash/>');
        break;

      case ShapeType.line:
      case ShapeType.arrow:
      case ShapeType.doubleArrow:
        _renderConnectorSvg(buffer, el, strokeColor, strokeWidth, strokeOpacity, strokeDash, colors);
        break;

      case ShapeType.pen:
      case ShapeType.highlighter:
        _renderFreehandSvg(buffer, el, strokeColor, colors);
        break;

      case ShapeType.text:
        _renderTextSvg(buffer, el, strokeColor, strokeOpacity);
        break;

      case ShapeType.stickyNote:
        _renderStickyNoteSvg(buffer, el, colors);
        break;

      case ShapeType.codeBlock:
        _renderCodeBlockSvg(buffer, el);
        break;

      case ShapeType.table:
        _renderTableSvg(buffer, el, strokeColor, colors);
        break;

      case ShapeType.image:
        if (el.imageBase64 != null) {
          final r = el.bounds;
          buffer.writeln(
              '    <image x="${r.left}" y="${r.top}" width="${r.width}" height="${r.height}" href="data:image/png;base64,${el.imageBase64}" />');
        }
        break;

      case ShapeType.frame:
        final r = el.bounds;
        final title = _escapeXml(el.frameTitle ?? 'Frame');
        buffer.writeln(
            '    <rect x="${r.left}" y="${r.top}" width="${r.width}" height="${r.height}" fill="none" stroke="#748FFC" stroke-width="1.5" stroke-dasharray="6,6" opacity="0.8" />');
        buffer.writeln(
            '    <text x="${r.left + 8}" y="${r.top - 6}" font-size="12" font-weight="bold" fill="#748FFC">$title</text>');
        break;
    }

    if (isFillable && el.text.trim().isNotEmpty) {
      _renderShapeTextSvg(buffer, el, strokeColor, colors);
    }

    if (hasRotation) {
      buffer.writeln('  </g>');
    }
  }

  static void _renderConnectorSvg(
    StringBuffer buffer,
    BoardElement el,
    String strokeColor,
    double strokeWidth,
    double strokeOpacity,
    String strokeDash,
    BoardColors colors,
  ) {
    final route = ConnectorRoutingService.computeRoute(el);
    final d = _pathToSvgPathData(route.waypoints, el.connectorStyle);

    buffer.writeln(
        '    <path d="$d" fill="none" stroke="$strokeColor" stroke-width="$strokeWidth" stroke-opacity="$strokeOpacity" stroke-linecap="round" stroke-linejoin="round" $strokeDash/>');

    // Arrow Heads
    final headLen = math.max(el.strokeWidth * 4.5, 14.0);
    const spread = 0.48;

    if (el.type == ShapeType.arrow || el.type == ShapeType.doubleArrow) {
      final angle = route.endAngle;
      final tip1 = el.end - Offset(math.cos(angle - spread), math.sin(angle - spread)) * headLen;
      final tip2 = el.end - Offset(math.cos(angle + spread), math.sin(angle + spread)) * headLen;
      buffer.writeln(
          '    <path d="M ${tip1.dx} ${tip1.dy} L ${el.end.dx} ${el.end.dy} L ${tip2.dx} ${tip2.dy}" fill="none" stroke="$strokeColor" stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round"/>');
    }

    if (el.type == ShapeType.doubleArrow) {
      final angle = route.startAngle;
      final tip1 = el.start - Offset(math.cos(angle - spread), math.sin(angle - spread)) * headLen;
      final tip2 = el.start - Offset(math.cos(angle + spread), math.sin(angle + spread)) * headLen;
      buffer.writeln(
          '    <path d="M ${tip1.dx} ${tip1.dy} L ${el.start.dx} ${el.start.dy} L ${tip2.dx} ${tip2.dy}" fill="none" stroke="$strokeColor" stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round"/>');
    }

    // Connector Label
    final labelText = el.label?.trim() ??
        (el.type != ShapeType.text && el.text.isNotEmpty ? el.text.trim() : '');
    if (labelText.isNotEmpty) {
      final mid = route.midpoint;
      final escaped = _escapeXml(labelText);
      final fontSize = (el.fontSize * 0.75).clamp(11.0, 20.0);
      final estimatedWidth = labelText.length * fontSize * 0.6 + 16;
      final estimatedHeight = fontSize + 8;
      final bgHex = _colorToHex(colors.background);

      buffer.writeln(
          '    <rect x="${mid.dx - estimatedWidth / 2}" y="${mid.dy - estimatedHeight / 2}" width="$estimatedWidth" height="$estimatedHeight" rx="6" fill="$bgHex" stroke="$strokeColor" stroke-width="1" stroke-opacity="0.5"/>');
      buffer.writeln(
          '    <text x="${mid.dx}" y="${mid.dy + fontSize * 0.35}" font-size="$fontSize" font-weight="600" fill="$strokeColor" text-anchor="middle">$escaped</text>');
    }
  }

  static void _renderShapeTextSvg(
    StringBuffer buffer,
    BoardElement el,
    String strokeColor,
    BoardColors colors,
  ) {
    final rawText = el.text.trim();
    if (rawText.isEmpty) return;

    String textColor = strokeColor;
    if (el.fillStyle != FillStyle.none &&
        el.fillColor != Colors.transparent &&
        el.fillColor.a > 0.25) {
      final lum = el.fillColor.computeLuminance();
      textColor = lum > 0.5 ? '#1E1E1E' : '#F8F9FA';
    } else {
      textColor = _colorToHex(colors.ink);
    }

    final lines = rawText.split('\n');
    final fontSize = (el.fontSize > 0 && el.fontSize <= 18 ? el.fontSize : 13.5);
    final lineHeight = fontSize * 1.3;
    final totalH = lines.length * lineHeight;
    final mid = el.bounds.center;
    final startY = mid.dy - (totalH / 2) + (fontSize * 0.85);

    for (var i = 0; i < lines.length; i++) {
      final lineY = startY + i * lineHeight;
      final escaped = _escapeXml(lines[i]);
      buffer.writeln(
          '    <text x="${mid.dx}" y="$lineY" font-size="$fontSize" font-weight="600" fill="$textColor" text-anchor="middle">$escaped</text>');
    }
  }

  static void _renderFreehandSvg(
    StringBuffer buffer,
    BoardElement el,
    String strokeColor,
    BoardColors colors,
  ) {
    if (el.points.isEmpty) return;
    final isHighlighter = el.type == ShapeType.highlighter;
    final strokeWidth = isHighlighter
        ? (el.strokeWidth >= 16.0 ? el.strokeWidth : (el.strokeWidth * 6.0).clamp(18.0, 36.0))
        : el.strokeWidth;
    final effectiveColor = isHighlighter
        ? _colorToHex(colors.displayHighlighter(el.color))
        : strokeColor;
    final opacity = isHighlighter
        ? ((colors.isDark ? 0.60 : 0.50) * el.opacity).clamp(0.1, 1.0)
        : el.opacity;

    if (el.points.length == 1) {
      final p = el.points.first;
      buffer.writeln(
          '    <circle cx="${p.dx}" cy="${p.dy}" r="${strokeWidth / 2}" fill="$effectiveColor" opacity="$opacity"/>');
      return;
    }

    final d = StringBuffer('M ${el.points.first.dx} ${el.points.first.dy}');
    for (var i = 1; i < el.points.length; i++) {
      final p = el.points[i];
      d.write(' L ${p.dx} ${p.dy}');
    }

    buffer.writeln(
        '    <path d="$d" fill="none" stroke="$effectiveColor" stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round" opacity="$opacity"/>');
  }

  static void _renderTextSvg(
    StringBuffer buffer,
    BoardElement el,
    String strokeColor,
    double opacity,
  ) {
    final lines = el.text.split('\n');
    final start = el.start;
    final baseFontSize = el.fontSize;
    final lineHeight = baseFontSize * 1.35;

    buffer.writeln('    <g opacity="$opacity">');
    var textY = start.dy + baseFontSize;

    for (final line in lines) {
      _renderMarkdownLineSvg(
        buffer,
        line,
        start.dx,
        textY,
        baseFontSize,
        strokeColor,
      );
      textY += lineHeight;
    }
    buffer.writeln('    </g>');
  }

  static void _renderStickyNoteSvg(
    StringBuffer buffer,
    BoardElement el,
    BoardColors colors,
  ) {
    final r = el.bounds;
    final fillHex = _colorToHex(el.fillColor != Colors.transparent ? el.fillColor : const Color(0xFFFFF3BF));
    final textColor = _colorToHex(el.color);

    buffer.writeln(
        '    <rect x="${r.left}" y="${r.top}" width="${r.width}" height="${r.height}" rx="6" fill="$fillHex" filter="url(#stickyShadow)"/>');

    final lines = el.text.split('\n');
    final baseFontSize = el.fontSize;
    final lineHeight = baseFontSize * 1.35;
    final textX = r.left + 14;
    var textY = r.top + 20 + baseFontSize;

    for (final line in lines) {
      if (textY > r.bottom - 10) break;
      _renderMarkdownLineSvg(
        buffer,
        line,
        textX,
        textY,
        baseFontSize,
        textColor,
        fontFamily: 'Caveat, cursive, sans-serif',
      );
      textY += lineHeight;
    }
  }

  static void _renderMarkdownLineSvg(
    StringBuffer buffer,
    String rawLine,
    double x,
    double y,
    double baseFontSize,
    String defaultColor, {
    String fontFamily = 'sans-serif',
  }) {
    var text = rawLine;
    var fontSize = baseFontSize;
    var fontWeight = '600';
    var fontStyle = 'normal';
    var color = defaultColor;

    // 1. Heading (# H1, ## H2, ### H3)
    if (text.startsWith('#')) {
      final headingMatch = RegExp(r'^(#{1,3})\s+(.*)$').firstMatch(text);
      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        text = headingMatch.group(2)!;
        fontSize = baseFontSize * (level == 1 ? 1.35 : (level == 2 ? 1.20 : 1.10));
        fontWeight = 'bold';
      }
    }
    // 2. Bullet list (- or *)
    else if (RegExp(r'^\s*[-*]\s+(.*)$').hasMatch(text)) {
      final m = RegExp(r'^\s*[-*]\s+(.*)$').firstMatch(text)!;
      text = '• ${m.group(1)}';
    }
    // 3. Numbered list (1. item)
    else if (RegExp(r'^\s*(\d+\.)\s+(.*)$').hasMatch(text)) {
      final m = RegExp(r'^\s*(\d+\.)\s+(.*)$').firstMatch(text)!;
      text = '${m.group(1)} ${m.group(2)}';
    }
    // 4. Blockquote (> quote)
    else if (RegExp(r'^\s*>\s*(.*)$').hasMatch(text)) {
      final m = RegExp(r'^\s*>\s*(.*)$').firstMatch(text)!;
      text = '▌ ${m.group(1)}';
      color = '#748FFC';
    }

    // Strip remaining inline bold/italic markers for clean SVG
    text = text.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m.group(1)!);
    text = text.replaceAllMapped(RegExp(r'~~(.+?)~~'), (m) => m.group(1)!);
    text = text.replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => m.group(1)!);
    text = text.replaceAllMapped(RegExp(r'`(.+?)`'), (m) => m.group(1)!);
    text = text.replaceAllMapped(RegExp(r'\[(.*?)\]\((.*?)\)'), (m) => '${m.group(1)} (${m.group(2)})');

    final escaped = _escapeXml(text);
    buffer.writeln(
        '      <text x="$x" y="$y" font-size="$fontSize" font-weight="$fontWeight" font-style="$fontStyle" font-family="$fontFamily" fill="$color">$escaped</text>');
  }

  static void _renderCodeBlockSvg(
    StringBuffer buffer,
    BoardElement el,
  ) {
    final r = el.bounds;
    final lang = el.codeLanguage ?? 'Dart';
    final showNumbers = el.showLineNumbers;
    final rawText = el.text.isEmpty ? '// Type code here...' : el.text;
    final lines = rawText.split('\n');
    const theme = SyntaxThemeColors.dark;

    // Outer card container
    buffer.writeln(
        '    <rect x="${r.left}" y="${r.top}" width="${r.width}" height="${r.height}" rx="10" fill="#181825" stroke="#313244" stroke-width="1.2"/>');

    // Window titlebar
    buffer.writeln(
        '    <path d="M ${r.left} ${r.top + 10} A 10 10 0 0 1 ${r.left + 10} ${r.top} L ${r.right - 10} ${r.top} A 10 10 0 0 1 ${r.right} ${r.top + 10} L ${r.right} ${r.top + 32} L ${r.left} ${r.top + 32} Z" fill="#11111B"/>');

    // macOS Window Controls (dots)
    buffer.writeln('    <circle cx="${r.left + 16}" cy="${r.top + 16}" r="5" fill="#ED6A5E"/>');
    buffer.writeln('    <circle cx="${r.left + 30}" cy="${r.top + 16}" r="5" fill="#F4BF4F"/>');
    buffer.writeln('    <circle cx="${r.left + 44}" cy="${r.top + 16}" r="5" fill="#61C554"/>');

    // Language Badge
    final escapedLang = _escapeXml(lang.toUpperCase());
    buffer.writeln(
        '    <text x="${r.right - 14}" y="${r.top + 20}" font-size="10" font-family="monospace" font-weight="bold" fill="#6C7086" text-anchor="end">$escapedLang</text>');

    // Code Content
    final fontSize = 13.0;
    final lineHeight = fontSize * 1.5;
    final lineNumberGutter = showNumbers ? 42.0 : 0.0;
    final codeX = r.left + 14 + lineNumberGutter;
    var currentY = r.top + 32 + 18;

    for (var i = 0; i < lines.length; i++) {
      if (currentY + lineHeight > r.bottom - 8) break;

      if (showNumbers) {
        final lineNum = '${i + 1}';
        buffer.writeln(
            '    <text x="${r.left + 12}" y="$currentY" font-size="11" font-family="monospace" fill="#585B70">$lineNum</text>');
      }

      final lineTokens = SyntaxHighlighterService.tokenize(lines[i], lang);
      final lineSpans = StringBuffer();

      for (final token in lineTokens) {
        final colorHex = _getTokenHexColor(token.type, theme);
        final escaped = _escapeXml(token.text);
        lineSpans.write('<tspan fill="$colorHex">$escaped</tspan>');
      }

      buffer.writeln(
          '    <text x="$codeX" y="$currentY" font-size="$fontSize" font-family="monospace">$lineSpans</text>');
      currentY += lineHeight;
    }
  }

  static String _getTokenHexColor(SyntaxTokenType type, SyntaxThemeColors theme) {
    final color = switch (type) {
      SyntaxTokenType.keyword => theme.keyword,
      SyntaxTokenType.type => theme.type,
      SyntaxTokenType.string => theme.string,
      SyntaxTokenType.number => theme.number,
      SyntaxTokenType.comment => theme.comment,
      SyntaxTokenType.function => theme.function,
      SyntaxTokenType.operator => theme.operator,
      SyntaxTokenType.punctuation => theme.punctuation,
      SyntaxTokenType.plain => theme.foreground,
    };
    return _colorToHex(color);
  }

  static String _pathToSvgPathData(List<Offset> waypoints, ConnectorStyle style) {
    if (waypoints.isEmpty) return 'M 0 0';
    if (waypoints.length == 2 || style == ConnectorStyle.straight) {
      return 'M ${waypoints.first.dx} ${waypoints.first.dy} L ${waypoints.last.dx} ${waypoints.last.dy}';
    }

    if (style == ConnectorStyle.curved && waypoints.length == 4) {
      final p0 = waypoints[0];
      final c1 = waypoints[1];
      final c2 = waypoints[2];
      final p3 = waypoints[3];
      return 'M ${p0.dx} ${p0.dy} C ${c1.dx} ${c1.dy}, ${c2.dx} ${c2.dy}, ${p3.dx} ${p3.dy}';
    }

    // Orthogonal waypoints
    final buf = StringBuffer('M ${waypoints[0].dx} ${waypoints[0].dy}');
    for (var i = 1; i < waypoints.length; i++) {
      buf.write(' L ${waypoints[i].dx} ${waypoints[i].dy}');
    }
    return buf.toString();
  }

  static String _getStarPoints(Rect rect) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final rOuter = math.min(rect.width, rect.height) / 2;
    final rInner = rOuter * 0.45;
    const points = 5;
    final step = math.pi / points;

    var angle = -math.pi / 2;
    final buf = StringBuffer();

    for (var i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? rOuter : rInner;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      buf.write('$x,$y ');
      angle += step;
    }
    return buf.toString().trim();
  }

  static String _getStrokeDashArray(StrokeStyle style) {
    return switch (style) {
      StrokeStyle.solid => '',
      StrokeStyle.dashed => 'stroke-dasharray="10,7"',
      StrokeStyle.dotted => 'stroke-dasharray="3,4"',
    };
  }

  static String _colorToHex(Color color) {
    final hex = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${hex.substring(2)}';
  }

  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static void _renderTableSvg(
    StringBuffer buffer,
    BoardElement el,
    String strokeColor,
    BoardColors colors,
  ) {
    final r = el.bounds;
    final table = el.safeTableData;
    final rows = table.length;
    final cols = table.isNotEmpty ? table.first.length : 1;
    if (rows == 0 || cols == 0) return;

    final cellW = r.width / cols;
    final cellH = r.height / rows;
    final hasHeader = el.tableHasHeader;
    final isDark = colors.isDark;

    final bgHex = el.fillColor != Colors.transparent
        ? _colorToHex(colors.display(el.fillColor))
        : (isDark ? '#1E222B' : '#FFFFFF');
    final headerBgHex = isDark ? '#2C313D' : '#F1F3F9';
    final zebraBgHex = isDark ? '#252A34' : '#F8F9FA';
    final gridHex = isDark ? '#383E4C' : '#E2E6EE';
    final textColor = isDark ? '#F1F3F5' : '#212529';
    final headerTextColor = isDark ? '#FFFFFF' : '#111827';
    final fontSize = math.max(10.0, math.min(el.fontSize, cellH * 0.45));

    // Outer container card
    buffer.writeln(
        '    <rect x="${r.left}" y="${r.top}" width="${r.width}" height="${r.height}" rx="8" fill="$bgHex" stroke="$strokeColor" stroke-width="${math.max(1.0, el.strokeWidth)}" />');

    // Header & Zebra Rows
    for (var row = 0; row < rows; row++) {
      final isHeader = row == 0 && hasHeader;
      final isEven = row % 2 == 1;
      if (isHeader) {
        buffer.writeln(
            '    <rect x="${r.left}" y="${r.top}" width="${r.width}" height="$cellH" rx="8" fill="$headerBgHex" />');
      } else if (isEven) {
        buffer.writeln(
            '    <rect x="${r.left}" y="${r.top + row * cellH}" width="${r.width}" height="$cellH" fill="$zebraBgHex" />');
      }
    }

    // Grid Dividers
    for (var row = 1; row < rows; row++) {
      final y = r.top + row * cellH;
      buffer.writeln(
          '    <line x1="${r.left}" y1="$y" x2="${r.right}" y2="$y" stroke="$gridHex" stroke-width="1" />');
    }
    for (var col = 1; col < cols; col++) {
      final x = r.left + col * cellW;
      buffer.writeln(
          '    <line x1="$x" y1="${r.top}" x2="$x" y2="${r.bottom}" stroke="$gridHex" stroke-width="1" />');
    }

    // Cell Texts
    for (var row = 0; row < rows; row++) {
      final isHeader = row == 0 && hasHeader;
      for (var col = 0; col < cols; col++) {
        if (col >= table[row].length) continue;
        final rawText = table[row][col];
        if (rawText.isEmpty) continue;
        final escaped = _escapeXml(rawText);
        final x = r.left + col * cellW + 8;
        final y = r.top + row * cellH + cellH / 2 + (fontSize * 0.35);
        final fill = isHeader ? headerTextColor : textColor;
        final weight = isHeader ? 'bold' : '500';

        buffer.writeln(
            '    <text x="$x" y="$y" font-size="$fontSize" font-weight="$weight" fill="$fill">$escaped</text>');
      }
    }
  }
}
