import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/board_colors.dart';
import '../models/board_element.dart';
import '../models/connector_style.dart';
import '../models/shape_type.dart';
import '../models/stroke_fill_style.dart';
import 'connector_routing_service.dart';

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
        el.type == ShapeType.star;

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

  static void _renderFreehandSvg(
    StringBuffer buffer,
    BoardElement el,
    String strokeColor,
    BoardColors colors,
  ) {
    if (el.points.isEmpty) return;
    final isHighlighter = el.type == ShapeType.highlighter;
    final strokeWidth = isHighlighter ? math.max(el.strokeWidth * 3.5, 18.0) : el.strokeWidth;
    final opacity = isHighlighter ? 0.35 * el.opacity : el.opacity;

    if (el.points.length == 1) {
      final p = el.points.first;
      buffer.writeln(
          '    <circle cx="${p.dx}" cy="${p.dy}" r="${strokeWidth / 2}" fill="$strokeColor" opacity="$opacity"/>');
      return;
    }

    final d = StringBuffer('M ${el.points.first.dx} ${el.points.first.dy}');
    for (var i = 1; i < el.points.length; i++) {
      final p = el.points[i];
      d.write(' L ${p.dx} ${p.dy}');
    }

    buffer.writeln(
        '    <path d="$d" fill="none" stroke="$strokeColor" stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round" opacity="$opacity"/>');
  }

  static void _renderTextSvg(
    StringBuffer buffer,
    BoardElement el,
    String strokeColor,
    double opacity,
  ) {
    final lines = el.text.split('\n');
    final start = el.start;
    final fontSize = el.fontSize;
    final lineHeight = fontSize * 1.3;

    buffer.writeln('    <g opacity="$opacity">');
    for (var i = 0; i < lines.length; i++) {
      final line = _escapeXml(lines[i]);
      final y = start.dy + fontSize + (i * lineHeight);
      buffer.writeln(
          '      <text x="${start.dx}" y="$y" font-size="$fontSize" font-weight="600" fill="$strokeColor">$line</text>');
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
        '    <rect x="${r.left}" y="${r.top}" width="${r.width}" height="${r.height}" rx="4" fill="$fillHex" filter="url(#stickyShadow)"/>');

    final lines = el.text.split('\n');
    final fontSize = el.fontSize;
    final lineHeight = fontSize * 1.3;
    final textX = r.left + 12;
    var textY = r.top + 20 + fontSize;

    for (final line in lines) {
      final escapedLine = _escapeXml(line);
      buffer.writeln(
          '    <text x="$textX" y="$textY" font-size="$fontSize" font-weight="600" fill="$textColor">$escapedLine</text>');
      textY += lineHeight;
    }
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
}
