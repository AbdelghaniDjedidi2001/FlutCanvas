import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/board_element.dart';
import '../models/shape_type.dart';
import 'excalidraw_import_service.dart';
import 'export_service.dart';
import 'mermaid_parser_service.dart';
import 'syntax_highlighter_service.dart';

class PasteResult {
  final List<BoardElement> elements;
  final String sourceDescription;

  PasteResult({required this.elements, required this.sourceDescription});
}

class ClipboardService {
  static List<BoardElement> _inMemoryClipboard = [];

  static bool get hasInternalData => _inMemoryClipboard.isNotEmpty;

  /// Copies elements to both internal clipboard and system text clipboard
  static void copy(List<BoardElement> elements) {
    if (elements.isEmpty) return;
    _inMemoryClipboard = elements.map((e) => e.copyWith()).toList();

    // Export formatted JSON to OS clipboard
    final jsonStr = ExportService.exportToJson(elements);
    Clipboard.setData(ClipboardData(text: jsonStr));
  }

  /// Duplicates elements from internal memory buffer
  static List<BoardElement> duplicate({Offset offset = const Offset(24, 24)}) {
    if (_inMemoryClipboard.isEmpty) return [];
    final now = DateTime.now().millisecondsSinceEpoch;
    var counter = 0;
    final pasted = <BoardElement>[];

    for (final el in _inMemoryClipboard) {
      final newId = 'el_${now}_${counter++}';
      final translated = el.translated(offset).copyWith(id: newId);
      pasted.add(translated);
    }
    return pasted;
  }

  /// Intelligently pastes from OS clipboard (Mermaid, Excalidraw, FlutCanvas JSON, or Plain Text)
  static Future<PasteResult?> pasteFromSystem({
    required Offset targetCanvasPosition,
    Color defaultColor = const Color(0xFF1971C2),
  }) async {
    final clipData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipData?.text?.trim();

    if (text != null && text.isNotEmpty) {
      // 1. Mermaid Flowchart / Diagram Syntax
      if (MermaidParserService.isMermaidSyntax(text)) {
        final elements = MermaidParserService.parseToElements(
          script: text,
          origin: targetCanvasPosition,
          defaultColor: defaultColor,
        );
        if (elements.isNotEmpty) {
          return PasteResult(
            elements: elements,
            sourceDescription: 'Mermaid Diagram (${elements.length} items)',
          );
        }
      }

      // 2. Excalidraw Diagram JSON
      if (ExcalidrawImportService.isExcalidrawJson(text)) {
        final rawElements = ExcalidrawImportService.importFromExcalidraw(
          jsonStr: text,
        );
        if (rawElements.isNotEmpty) {
          Rect bounds = rawElements.first.bounds;
          for (var i = 1; i < rawElements.length; i++) {
            bounds = bounds.expandToInclude(rawElements[i].bounds);
          }
          final delta = targetCanvasPosition - bounds.topLeft;
          final positioned = rawElements.map((e) => e.translated(delta)).toList();
          return PasteResult(
            elements: positioned,
            sourceDescription: 'Excalidraw Diagram (${positioned.length} items)',
          );
        }
      }

      // 3. FlutCanvas Native Export JSON
      final nativeElements = ExportService.importFromJson(text);
      if (nativeElements != null && nativeElements.isNotEmpty) {
        // Offset elements relative to target position
        Rect originalBounds = nativeElements.first.bounds;
        for (var i = 1; i < nativeElements.length; i++) {
          originalBounds = originalBounds.expandToInclude(nativeElements[i].bounds);
        }
        final delta = targetCanvasPosition - originalBounds.topLeft;

        final now = DateTime.now().millisecondsSinceEpoch;
        var counter = 0;
        final positioned = nativeElements.map((e) {
          return e.translated(delta).copyWith(id: 'paste_${now}_${counter++}');
        }).toList();

        return PasteResult(
          elements: positioned,
          sourceDescription: 'FlutCanvas Elements (${positioned.length} items)',
        );
      }

      // 4. Markdown Code Fence (```dart ... ```) or Code Snippet
      final codeFenceMatch = RegExp(r'^```(\w+)?\n([\s\S]*?)```$').firstMatch(text.trim());
      final now = DateTime.now().millisecondsSinceEpoch;

      if (codeFenceMatch != null) {
        final lang = codeFenceMatch.group(1)?.toLowerCase() ?? 'dart';
        final code = codeFenceMatch.group(2)?.trim() ?? '';
        final codeEl = BoardElement(
          id: 'code_$now',
          type: ShapeType.codeBlock,
          start: targetCanvasPosition,
          end: targetCanvasPosition + const Offset(360, 220),
          text: code,
          codeLanguage: lang,
          color: Colors.transparent,
          fillColor: Colors.transparent,
          showLineNumbers: true,
        );
        return PasteResult(
          elements: [codeEl],
          sourceDescription: '${SyntaxHighlighterService.getDisplayName(lang)} Code Block',
        );
      }

      if (_looksLikeCode(text)) {
        final lang = _detectLanguage(text);
        final codeEl = BoardElement(
          id: 'code_$now',
          type: ShapeType.codeBlock,
          start: targetCanvasPosition,
          end: targetCanvasPosition + const Offset(360, 220),
          text: text,
          codeLanguage: lang,
          color: Colors.transparent,
          fillColor: Colors.transparent,
          showLineNumbers: true,
        );
        return PasteResult(
          elements: [codeEl],
          sourceDescription: '${SyntaxHighlighterService.getDisplayName(lang)} Code Block',
        );
      }

      // 5. Plain Text -> Create Sticky Note or Text element
      if (text.length > 3 || text.contains('\n')) {
        final isMultiLine = text.contains('\n') || text.length > 50;

        if (isMultiLine) {
          // Create Sticky Note
          final sticky = BoardElement(
            id: 'sticky_$now',
            type: ShapeType.stickyNote,
            start: targetCanvasPosition,
            end: targetCanvasPosition + const Offset(180, 180),
            text: text,
            color: Colors.black,
            fillColor: const Color(0xFFFFF3BF),
          );
          return PasteResult(
            elements: [sticky],
            sourceDescription: 'Text as Sticky Note',
          );
        } else {
          // Create Text element
          final textEl = BoardElement(
            id: 'text_$now',
            type: ShapeType.text,
            start: targetCanvasPosition,
            end: targetCanvasPosition + const Offset(200, 40),
            text: text,
            color: defaultColor,
            fontSize: 16.0,
          );
          return PasteResult(
            elements: [textEl],
            sourceDescription: 'Text Element',
          );
        }
      }
    }

    // Fallback: Internal in-memory clipboard
    if (_inMemoryClipboard.isNotEmpty) {
      final pasted = duplicate(offset: const Offset(24, 24));
      return PasteResult(
        elements: pasted,
        sourceDescription: '${pasted.length} duplicated items',
      );
    }

    return null;
  }

  /// Creates an image element from base64 string
  static BoardElement createImageElement({
    required String base64Image,
    required Offset position,
    double width = 320.0,
    double height = 220.0,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return BoardElement(
      id: 'img_$now',
      type: ShapeType.image,
      start: position,
      end: position + Offset(width, height),
      color: Colors.transparent,
      imageBase64: base64Image,
    );
  }

  static bool _looksLikeCode(String text) {
    final trimmed = text.trim();
    if (!trimmed.contains('\n') && trimmed.length < 40) return false;

    final codePatterns = [
      RegExp(r'^(import\s+|export\s+|from\s+|package\s+|using\s+|#include\s+)', multiLine: true),
      RegExp(r'^(class\s+\w+|interface\s+\w+|struct\s+\w+|enum\s+\w+)', multiLine: true),
      RegExp(r'^(def\s+\w+|function\s+\w+|const\s+\w+\s*=|let\s+\w+\s*=|var\s+\w+\s*=)', multiLine: true),
      RegExp(r'^(public\s+|private\s+|protected\s+|void\s+|async\s+)', multiLine: true),
      RegExp(r'^(SELECT\s+.*?\s+FROM\s+|CREATE\s+TABLE\s+|INSERT\s+INTO\s+)', caseSensitive: false, multiLine: true),
      RegExp(r'^(<!DOCTYPE\s+html|<html|<div|<script|<style)', caseSensitive: false, multiLine: true),
      RegExp(r'([{};]\s*\n|\b(console\.log|print\(|System\.out\.println))'),
    ];

    for (final p in codePatterns) {
      if (p.hasMatch(trimmed)) return true;
    }
    return false;
  }

  static String _detectLanguage(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('void main()') || lower.contains('widget build') || lower.contains('import \'package:')) {
      return 'dart';
    }
    if (lower.contains('def ') || lower.contains('import pandas') || lower.contains('import numpy') || lower.contains('__init__') || (lower.contains('print(') && !lower.contains(';'))) {
      return 'python';
    }
    if (lower.contains('select ') && lower.contains(' from ') || lower.contains('create table')) {
      return 'sql';
    }
    if (lower.contains('<!doctype html') || lower.contains('<div') || lower.contains('<html>')) {
      return 'html';
    }
    if (lower.contains('interface ') || lower.contains(': string') || lower.contains(': number')) {
      return 'typescript';
    }
    if (lower.contains('const ') || lower.contains('let ') || lower.contains('console.log') || lower.contains('function(')) {
      return 'javascript';
    }
    if ((lower.startsWith('{') && lower.endsWith('}')) || (lower.startsWith('[') && lower.endsWith(']'))) {
      return 'json';
    }
    if (lower.contains('fn main()') || lower.contains('let mut ') || lower.contains('impl ')) {
      return 'rust';
    }
    if (lower.contains('package main') || lower.contains('func ')) {
      return 'go';
    }
    return 'dart';
  }
}
