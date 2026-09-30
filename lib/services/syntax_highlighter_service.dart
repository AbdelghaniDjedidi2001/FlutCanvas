import 'package:flutter/material.dart';

enum CodeThemeMode { dark, light }

class SyntaxThemeColors {
  final Color background;
  final Color foreground;
  final Color headerBackground;
  final Color headerBorder;
  final Color lineNumbers;
  final Color lineNumbersBorder;
  final Color keyword;
  final Color type;
  final Color string;
  final Color number;
  final Color comment;
  final Color function;
  final Color operator;
  final Color punctuation;

  const SyntaxThemeColors({
    required this.background,
    required this.foreground,
    required this.headerBackground,
    required this.headerBorder,
    required this.lineNumbers,
    required this.lineNumbersBorder,
    required this.keyword,
    required this.type,
    required this.string,
    required this.number,
    required this.comment,
    required this.function,
    required this.operator,
    required this.punctuation,
  });

  static const dark = SyntaxThemeColors(
    background: Color(0xFF1E1E2E), // Catppuccin Mocha / OneDark
    foreground: Color(0xFFCDD6F4),
    headerBackground: Color(0xFF181825),
    headerBorder: Color(0xFF313244),
    lineNumbers: Color(0xFF6C7086),
    lineNumbersBorder: Color(0xFF313244),
    keyword: Color(0xFFCBA6F7), // Purple / Mauve
    type: Color(0xFFF9E2AF),    // Yellow
    string: Color(0xFFA6E3A1),  // Green
    number: Color(0xFFFAB387),  // Peach / Orange
    comment: Color(0xFF6C7086), // Muted Gray
    function: Color(0xFF89B4FA),// Blue / Sky
    operator: Color(0xFF89DCEB),// Cyan
    punctuation: Color(0xFF9399B2),
  );

  static const light = SyntaxThemeColors(
    background: Color(0xFFF8F9FA), // GitHub Light
    foreground: Color(0xFF24292F),
    headerBackground: Color(0xFFEAECEF),
    headerBorder: Color(0xFFD0D7DE),
    lineNumbers: Color(0xFF8C959F),
    lineNumbersBorder: Color(0xFFD0D7DE),
    keyword: Color(0xFFCF222E), // Red / Mauve
    type: Color(0xFF953800),    // Brown / Orange
    string: Color(0xFF0A3069),  // Navy Green
    number: Color(0xFF0550AE),  // Blue
    comment: Color(0xFF6E7781), // Muted Gray
    function: Color(0xFF8250DF),// Violet
    operator: Color(0xFF0550AE),// Blue
    punctuation: Color(0xFF57606A),
  );
}

class SyntaxHighlighterService {
  static const List<String> supportedLanguages = [
    'dart',
    'javascript',
    'typescript',
    'python',
    'json',
    'sql',
    'html',
    'css',
    'bash',
    'rust',
    'go',
    'cpp',
    'java',
    'yaml',
    'markdown',
    'plain',
  ];

  static String getDisplayName(String? lang) {
    return switch ((lang ?? 'dart').toLowerCase()) {
      'dart' => 'Dart',
      'javascript' || 'js' => 'JavaScript',
      'typescript' || 'ts' => 'TypeScript',
      'python' || 'py' => 'Python',
      'json' => 'JSON',
      'sql' => 'SQL',
      'html' => 'HTML',
      'css' => 'CSS',
      'bash' || 'sh' || 'shell' => 'Bash / Shell',
      'rust' || 'rs' => 'Rust',
      'go' || 'golang' => 'Go',
      'cpp' || 'c++' || 'c' => 'C / C++',
      'java' => 'Java',
      'yaml' || 'yml' => 'YAML',
      'markdown' || 'md' => 'Markdown',
      _ => 'Plain Text',
    };
  }

  /// Highlights code string and returns formatted TextSpan
  static TextSpan highlight({
    required String code,
    required String language,
    required TextStyle baseStyle,
    required SyntaxThemeColors theme,
  }) {
    if (code.isEmpty) {
      return TextSpan(text: '', style: baseStyle);
    }

    final lang = language.toLowerCase().trim();
    final tokens = tokenize(code, lang);
    final spans = <InlineSpan>[];

    for (final token in tokens) {
      final style = switch (token.type) {
        SyntaxTokenType.keyword => baseStyle.copyWith(color: theme.keyword, fontWeight: FontWeight.bold),
        SyntaxTokenType.type => baseStyle.copyWith(color: theme.type, fontWeight: FontWeight.w600),
        SyntaxTokenType.string => baseStyle.copyWith(color: theme.string),
        SyntaxTokenType.number => baseStyle.copyWith(color: theme.number),
        SyntaxTokenType.comment => baseStyle.copyWith(color: theme.comment, fontStyle: FontStyle.italic),
        SyntaxTokenType.function => baseStyle.copyWith(color: theme.function, fontWeight: FontWeight.w500),
        SyntaxTokenType.operator => baseStyle.copyWith(color: theme.operator),
        SyntaxTokenType.punctuation => baseStyle.copyWith(color: theme.punctuation),
        SyntaxTokenType.plain => baseStyle.copyWith(color: theme.foreground),
      };

      spans.add(TextSpan(text: token.text, style: style));
    }

    return TextSpan(children: spans, style: baseStyle);
  }

  static List<SyntaxToken> tokenize(String code, String lang) {
    final tokens = <SyntaxToken>[];

    // Language Keywords
    final keywords = _getKeywords(lang);
    final types = _getTypes(lang);

    // Regex Tokenizer
    // 1. Comments: //... or /*...*/ or #... or <!--...--> or --...
    final commentPattern = switch (lang) {
      'python' || 'bash' || 'sh' || 'shell' || 'yaml' || 'yml' => r'(#[^\n]*)',
      'sql' => r'(--[^\n]*|/\*[\s\S]*?\*/)',
      'html' || 'xml' => r'(<!--[\s\S]*?-->)',
      _ => r'(//[^\n]*|/\*[\s\S]*?\*/)',
    };

    // 2. Strings: "..." or '...' or `...` or """..."""
    const stringPattern = r'("""[\s\S]*?"""|' r"'''[\s\S]*?'''|" r'"([^"\\]|\\.)*"|' r"'([^'\\]|\\.)*'|" r'`([^`\\]|\\.)*`)';

    // 3. Numbers: 0x123, 123.45, 123
    const numberPattern = r'\b(0x[0-9a-fA-F]+|\d+(\.\d+)?([eE][+-]?\d+)?)\b';

    // 4. Identifiers / Words: [a-zA-Z_$][a-zA-Z0-9_$]*
    const wordPattern = r'[a-zA-Z_$][a-zA-Z0-9_$]*';

    // 5. Operators: =>, ->, ==, !=, <=, >=, &&, ||, +, -, *, /, =, <, >
    const operatorPattern = r'(=>|->|==|!=|<=|>=|&&|\|\||[+\-*\/%=<>!&|^~?:]+)';

    // Combined master regex
    final masterRegex = RegExp(
      '($commentPattern)|($stringPattern)|($numberPattern)|($wordPattern)|($operatorPattern)|([{}()[\\];,])|(\\s+)|(.)',
      multiLine: true,
    );

    for (final match in masterRegex.allMatches(code)) {
      final fullMatch = match.group(0)!;

      // 1. Comment
      if (match.group(1) != null) {
        tokens.add(SyntaxToken(fullMatch, SyntaxTokenType.comment));
      }
      // 2. String
      else if (match.group(2) != null || match.group(3) != null) {
        tokens.add(SyntaxToken(fullMatch, SyntaxTokenType.string));
      }
      // 3. Number
      else if (match.group(4) != null) {
        tokens.add(SyntaxToken(fullMatch, SyntaxTokenType.number));
      }
      // 4. Word / Keyword / Type / Function
      else if (match.group(7) != null) {
        final word = match.group(7)!;
        if (keywords.contains(word)) {
          tokens.add(SyntaxToken(word, SyntaxTokenType.keyword));
        } else if (types.contains(word) || RegExp(r'^[A-Z][a-zA-Z0-9_$]*$').hasMatch(word)) {
          tokens.add(SyntaxToken(word, SyntaxTokenType.type));
        } else {
          // Check if function call (followed by '(')
          final endPos = match.end;
          final isFunc = endPos < code.length && code[endPos] == '(';
          if (isFunc) {
            tokens.add(SyntaxToken(word, SyntaxTokenType.function));
          } else {
            tokens.add(SyntaxToken(word, SyntaxTokenType.plain));
          }
        }
      }
      // 5. Operator
      else if (match.group(8) != null) {
        tokens.add(SyntaxToken(fullMatch, SyntaxTokenType.operator));
      }
      // 6. Punctuation
      else if (match.group(9) != null) {
        tokens.add(SyntaxToken(fullMatch, SyntaxTokenType.punctuation));
      }
      // 7. Whitespace or other characters
      else {
        tokens.add(SyntaxToken(fullMatch, SyntaxTokenType.plain));
      }
    }

    return tokens;
  }

  static Set<String> _getKeywords(String lang) {
    switch (lang) {
      case 'dart':
        return {
          'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch',
          'class', 'const', 'continue', 'covariant', 'default', 'deferred', 'do',
          'dynamic', 'else', 'enum', 'export', 'extends', 'extension', 'external',
          'factory', 'false', 'final', 'finally', 'for', 'Function', 'get', 'hide',
          'if', 'implements', 'import', 'in', 'interface', 'is', 'late', 'library',
          'mixin', 'new', 'null', 'on', 'operator', 'part', 'required', 'rethrow',
          'return', 'sealed', 'set', 'show', 'static', 'super', 'switch', 'sync',
          'this', 'throw', 'true', 'try', 'typedef', 'var', 'void', 'when', 'while',
          'with', 'yield',
        };

      case 'javascript':
      case 'typescript':
      case 'js':
      case 'ts':
        return {
          'async', 'await', 'break', 'case', 'catch', 'class', 'const', 'continue',
          'debugger', 'default', 'delete', 'do', 'else', 'export', 'extends',
          'false', 'finally', 'for', 'function', 'if', 'import', 'in', 'instanceof',
          'let', 'new', 'null', 'return', 'super', 'switch', 'this', 'throw',
          'true', 'try', 'typeof', 'var', 'void', 'while', 'with', 'yield',
          'interface', 'type', 'namespace', 'implements', 'declare', 'enum',
          'from', 'as', 'readonly',
        };

      case 'python':
      case 'py':
        return {
          'and', 'as', 'assert', 'async', 'await', 'break', 'class', 'continue',
          'def', 'del', 'elif', 'else', 'except', 'False', 'finally', 'for',
          'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'None',
          'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'True', 'try',
          'while', 'with', 'yield', 'self', 'cls',
        };

      case 'sql':
        return {
          'SELECT', 'FROM', 'WHERE', 'INSERT', 'INTO', 'UPDATE', 'DELETE',
          'CREATE', 'TABLE', 'ALTER', 'DROP', 'JOIN', 'INNER', 'LEFT', 'RIGHT',
          'FULL', 'OUTER', 'ON', 'GROUP', 'BY', 'ORDER', 'HAVING', 'LIMIT',
          'OFFSET', 'AS', 'AND', 'OR', 'NOT', 'NULL', 'IS', 'IN', 'LIKE',
          'BETWEEN', 'EXISTS', 'COUNT', 'SUM', 'AVG', 'MIN', 'MAX', 'PRIMARY',
          'KEY', 'FOREIGN', 'REFERENCES', 'INDEX', 'UNIQUE', 'DEFAULT', 'CHECK',
          'UNION', 'ALL', 'DISTINCT', 'CASE', 'WHEN', 'THEN', 'ELSE', 'END',
          'select', 'from', 'where', 'insert', 'into', 'update', 'delete',
          'create', 'table', 'alter', 'drop', 'join', 'inner', 'left', 'right',
          'group', 'by', 'order', 'having', 'limit', 'offset', 'as', 'and', 'or',
        };

      case 'rust':
      case 'rs':
        return {
          'as', 'async', 'await', 'break', 'const', 'continue', 'crate', 'dyn',
          'else', 'enum', 'extern', 'false', 'fn', 'for', 'if', 'impl', 'in',
          'let', 'loop', 'match', 'mod', 'move', 'mut', 'pub', 'ref', 'return',
          'self', 'Self', 'static', 'struct', 'super', 'trait', 'true', 'type',
          'unsafe', 'use', 'where', 'while',
        };

      case 'go':
      case 'golang':
        return {
          'break', 'case', 'chan', 'const', 'continue', 'default', 'defer',
          'else', 'fallthrough', 'for', 'func', 'go', 'goto', 'if', 'import',
          'interface', 'map', 'package', 'range', 'return', 'select', 'struct',
          'switch', 'type', 'var', 'nil', 'true', 'false',
        };

      case 'html':
      case 'xml':
        return {
          'html', 'head', 'body', 'div', 'span', 'p', 'a', 'img', 'script',
          'style', 'link', 'meta', 'title', 'button', 'input', 'form', 'table',
          'tr', 'td', 'th', 'ul', 'ol', 'li', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
          'header', 'footer', 'nav', 'main', 'section', 'article',
        };

      case 'css':
        return {
          'color', 'background', 'margin', 'padding', 'border', 'display',
          'flex', 'grid', 'position', 'width', 'height', 'top', 'left', 'right',
          'bottom', 'font', 'size', 'family', 'weight', 'align', 'justify',
          'overflow', 'opacity', 'transform', 'transition', 'animation',
        };

      case 'bash':
      case 'sh':
      case 'shell':
        return {
          'if', 'then', 'else', 'elif', 'fi', 'case', 'esac', 'for', 'while',
          'until', 'do', 'done', 'in', 'function', 'select', 'time', 'return',
          'exit', 'echo', 'cd', 'export', 'source', 'alias', 'unset',
        };

      default:
        return {
          'if', 'else', 'for', 'while', 'do', 'return', 'function', 'class',
          'import', 'export', 'const', 'var', 'let', 'true', 'false', 'null',
        };
    }
  }

  static Set<String> _getTypes(String lang) {
    return {
      'int', 'double', 'num', 'bool', 'String', 'List', 'Map', 'Set', 'Future',
      'Stream', 'Widget', 'BuildContext', 'State', 'StatelessWidget', 'StatefulWidget',
      'void', 'Object', 'dynamic', 'Iterable', 'Duration', 'DateTime',
      'number', 'string', 'boolean', 'any', 'unknown', 'never', 'Promise', 'Array',
      'float', 'str', 'dict', 'tuple', 'bytes', 'i32', 'i64', 'u32', 'u64', 'f32', 'f64',
      'Vec', 'Option', 'Result', 'Some', 'None', 'Ok', 'Err', 'int64', 'byte',
      'VARCHAR', 'INT', 'BIGINT', 'TEXT', 'BOOLEAN', 'TIMESTAMP', 'DATE', 'FLOAT',
    };
  }
}

enum SyntaxTokenType {
  keyword,
  type,
  string,
  number,
  comment,
  function,
  operator,
  punctuation,
  plain,
}

class SyntaxToken {
  final String text;
  final SyntaxTokenType type;

  SyntaxToken(this.text, this.type);
}
