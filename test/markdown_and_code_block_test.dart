import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/models/board_colors.dart';
import 'package:flutcanvas/models/board_element.dart';
import 'package:flutcanvas/models/shape_type.dart';
import 'package:flutcanvas/services/clipboard_service.dart';
import 'package:flutcanvas/services/markdown_text_service.dart';
import 'package:flutcanvas/services/svg_export_service.dart';
import 'package:flutcanvas/services/syntax_highlighter_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MarkdownTextService Unit Tests', () {
    test('renders plain text into TextSpan with baseStyle', () {
      const baseStyle = TextStyle(fontSize: 16, color: Colors.black);
      final span = MarkdownTextService.parseMarkdown(
        text: 'Hello World',
        baseStyle: baseStyle,
      );

      expect(span.children, isNotEmpty);
      expect(span.toPlainText(), 'Hello World');
    });

    test('parses markdown headers correctly', () {
      const baseStyle = TextStyle(fontSize: 16, color: Colors.black);
      final h1Span = MarkdownTextService.parseMarkdown(text: '# Heading 1', baseStyle: baseStyle);
      final h2Span = MarkdownTextService.parseMarkdown(text: '## Heading 2', baseStyle: baseStyle);
      final h3Span = MarkdownTextService.parseMarkdown(text: '### Heading 3', baseStyle: baseStyle);

      expect(h1Span.toPlainText(), 'Heading 1');
      expect(h2Span.toPlainText(), 'Heading 2');
      expect(h3Span.toPlainText(), 'Heading 3');
    });

    test('parses bullet lists, numbered lists, and blockquotes', () {
      const baseStyle = TextStyle(fontSize: 16, color: Colors.black);
      final bulletSpan1 = MarkdownTextService.parseMarkdown(text: '- Item 1', baseStyle: baseStyle);
      final bulletSpan2 = MarkdownTextService.parseMarkdown(text: '* Item 2', baseStyle: baseStyle);
      final numSpan = MarkdownTextService.parseMarkdown(text: '1. First item', baseStyle: baseStyle);
      final quoteSpan = MarkdownTextService.parseMarkdown(text: '> A famous quote', baseStyle: baseStyle);

      expect(bulletSpan1.toPlainText(), '• Item 1');
      expect(bulletSpan2.toPlainText(), '• Item 2');
      expect(numSpan.toPlainText(), '1. First item');
      expect(quoteSpan.toPlainText(), '▌ A famous quote');
    });

    test('parses inline bold, italic, strikethrough, inline code, and links', () {
      const baseStyle = TextStyle(fontSize: 16, color: Colors.black);
      final span = MarkdownTextService.parseMarkdown(
        text: 'This is **bold**, *italic*, ~~strikethrough~~, `code`, and [Google](https://google.com)',
        baseStyle: baseStyle,
      );

      final plain = span.toPlainText();
      expect(plain, contains('This is '));
      expect(plain, contains('bold'));
      expect(plain, contains('italic'));
      expect(plain, contains('strikethrough'));
      expect(plain, contains('code'));
      expect(plain, contains('Google'));
    });

    test('handles empty and multiline markdown strings', () {
      const baseStyle = TextStyle(fontSize: 16, color: Colors.black);
      final emptySpan = MarkdownTextService.parseMarkdown(text: '', baseStyle: baseStyle);
      expect(emptySpan.toPlainText(), '');

      final multiline = MarkdownTextService.parseMarkdown(
        text: '# Title\n- Bullet 1\n- Bullet 2\n> Note',
        baseStyle: baseStyle,
      );
      expect(multiline.toPlainText(), 'Title\n• Bullet 1\n• Bullet 2\n▌ Note');
    });
  });

  group('SyntaxHighlighterService Unit Tests', () {
    test('highlights Dart code returning styled TextSpans', () {
      const dartCode = '''
// Main entry point
import 'package:flutter/material.dart';

void main() {
  int count = 42;
  String greeting = "Hello, FlutCanvas!";
  bool isActive = true;
}
''';
      const baseStyle = TextStyle(fontSize: 14, color: Colors.white);
      final span = SyntaxHighlighterService.highlight(
        code: dartCode,
        language: 'dart',
        baseStyle: baseStyle,
        theme: SyntaxThemeColors.dark,
      );

      expect(span.children, isNotEmpty);
      expect(span.toPlainText().trim(), dartCode.trim());
    });

    test('highlights JavaScript / TypeScript / JSON / SQL', () {
      const jsCode = 'const x = async () => { return "done"; };';
      const baseStyle = TextStyle(fontSize: 14, color: Colors.white);
      final jsSpan = SyntaxHighlighterService.highlight(
        code: jsCode,
        language: 'javascript',
        baseStyle: baseStyle,
        theme: SyntaxThemeColors.dark,
      );
      expect(jsSpan.toPlainText(), jsCode);

      const jsonCode = '{"name": "flutcanvas", "version": 2}';
      final jsonSpan = SyntaxHighlighterService.highlight(
        code: jsonCode,
        language: 'json',
        baseStyle: baseStyle,
        theme: SyntaxThemeColors.dark,
      );
      expect(jsonSpan.toPlainText(), jsonCode);
    });

    test('returns distinct theme colors for Dark and Light modes', () {
      const darkTheme = SyntaxThemeColors.dark;
      const lightTheme = SyntaxThemeColors.light;

      expect(darkTheme.background, isNot(equals(lightTheme.background)));
      expect(darkTheme.keyword, isNotNull);
      expect(lightTheme.keyword, isNotNull);
    });

    test('provides human-readable display names for supported languages', () {
      expect(SyntaxHighlighterService.getDisplayName('dart'), 'Dart');
      expect(SyntaxHighlighterService.getDisplayName('ts'), 'TypeScript');
      expect(SyntaxHighlighterService.getDisplayName('py'), 'Python');
      expect(SyntaxHighlighterService.getDisplayName('js'), 'JavaScript');
      expect(SyntaxHighlighterService.getDisplayName('json'), 'JSON');
      expect(SyntaxHighlighterService.getDisplayName('sql'), 'SQL');
      expect(SyntaxHighlighterService.getDisplayName('html'), 'HTML');
      expect(SyntaxHighlighterService.getDisplayName('css'), 'CSS');
      expect(SyntaxHighlighterService.getDisplayName('rust'), 'Rust');
      expect(SyntaxHighlighterService.getDisplayName('go'), 'Go');
    });
  });

  group('BoardElement CodeBlock Serialization Tests', () {
    test('serializes and deserializes ShapeType.codeBlock correctly', () {
      final original = BoardElement(
        id: 'code_1',
        type: ShapeType.codeBlock,
        start: const Offset(100, 150),
        end: const Offset(450, 350),
        color: Colors.transparent,
        fillColor: Colors.transparent,
        text: 'void main() => print("test");',
        codeLanguage: 'dart',
        showLineNumbers: true,
      );

      final map = original.toMap();
      expect(map['type'], 'codeBlock');
      expect(map['codeLanguage'], 'dart');
      expect(map['showLineNumbers'], isTrue);
      expect(map['text'], 'void main() => print("test");');

      final reconstructed = BoardElement.fromMap(map);
      expect(reconstructed.type, ShapeType.codeBlock);
      expect(reconstructed.codeLanguage, 'dart');
      expect(reconstructed.showLineNumbers, isTrue);
      expect(reconstructed.text, 'void main() => print("test");');
      expect(reconstructed.displayName, 'void main() => pri...');

      final emptyTextElement = reconstructed.copyWith(text: '');
      expect(emptyTextElement.displayName, 'Code (dart)');
    });

    test('copyWith updates codeLanguage and showLineNumbers', () {
      final original = BoardElement(
        id: 'code_2',
        type: ShapeType.codeBlock,
        start: const Offset(50, 50),
        end: const Offset(300, 200),
        color: Colors.transparent,
        text: '',
        codeLanguage: 'javascript',
        showLineNumbers: true,
      );

      final updated = original.copyWith(
        codeLanguage: 'typescript',
        showLineNumbers: false,
      );

      expect(updated.codeLanguage, 'typescript');
      expect(updated.showLineNumbers, isFalse);
      expect(updated.displayName, 'Code (typescript)');
    });

    test('hitTest detects clicks within code block bounds', () {
      final codeElement = BoardElement(
        id: 'code_3',
        type: ShapeType.codeBlock,
        start: const Offset(100, 100),
        end: const Offset(400, 300),
        color: Colors.transparent,
      );

      expect(codeElement.hitTest(const Offset(200, 200), 1.0), isTrue);
      expect(codeElement.hitTest(const Offset(50, 50), 1.0), isFalse);
    });
  });

  group('ClipboardService Code Block Detection Tests', () {
    testWidgets('extracts fenced markdown code block on system paste', (tester) async {
      const fencedCode = '```python\ndef fibonacci(n):\n    return n\n```';
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.getData') {
            return {'text': fencedCode};
          }
          return null;
        },
      );

      final result = await ClipboardService.pasteFromSystem(
        targetCanvasPosition: const Offset(100, 100),
      );

      expect(result, isNotNull);
      expect(result!.elements.first.type, ShapeType.codeBlock);
      expect(result.elements.first.codeLanguage, 'python');
      expect(result.elements.first.text, contains('def fibonacci(n):'));
    });

    testWidgets('detects programming snippet heuristics on paste', (tester) async {
      const rawCode = 'function calculateSum(a, b) {\n  return a + b;\n}';
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.getData') {
            return {'text': rawCode};
          }
          return null;
        },
      );

      final result = await ClipboardService.pasteFromSystem(
        targetCanvasPosition: const Offset(100, 100),
      );

      expect(result, isNotNull);
      expect(result!.elements.first.type, ShapeType.codeBlock);
      expect(result.elements.first.text, contains('function calculateSum'));
    });

    testWidgets('pastes multiline non-code text as sticky note', (tester) async {
      const plainNote = 'Buy groceries:\n- Milk\n- Bread\n- Eggs';
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.getData') {
            return {'text': plainNote};
          }
          return null;
        },
      );

      final result = await ClipboardService.pasteFromSystem(
        targetCanvasPosition: const Offset(100, 100),
      );

      expect(result, isNotNull);
      expect(result!.elements.first.type, ShapeType.stickyNote);
      expect(result.elements.first.text, plainNote);
    });
  });

  group('SvgExportService CodeBlock Tests', () {
    test('exports ShapeType.codeBlock with macOS window styling and line numbers', () {
      final codeElement = BoardElement(
        id: 'code_svg_1',
        type: ShapeType.codeBlock,
        start: const Offset(100, 100),
        end: const Offset(450, 350),
        color: Colors.transparent,
        text: 'final app = "FlutCanvas";\nprint(app);',
        codeLanguage: 'dart',
        showLineNumbers: true,
      );

      final svg = SvgExportService.exportToSvg(
        elements: [codeElement],
        colors: BoardColors.light,
        includeBackground: true,
      );

      expect(svg, contains('<svg'));
      // Check titlebar and window controls
      expect(svg, contains('#ED6A5E')); // Red dot
      expect(svg, contains('#F4BF4F')); // Yellow dot
      expect(svg, contains('#61C554')); // Green dot
      // Check language badge
      expect(svg, contains('DART'));
      // Check code content with syntax-highlighted tspans
      expect(svg, contains('&quot;FlutCanvas&quot;'));
      expect(svg, contains('<tspan'));
      expect(svg, contains('print'));
    });
  });
}
