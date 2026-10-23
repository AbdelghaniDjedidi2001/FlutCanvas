import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'ai_diagram_provider.dart';

class AiDiagramResult {
  final String prompt;
  final String mermaidCode;
  final List<BoardElement> elements;
  final AiDiagramProvider provider;

  const AiDiagramResult({
    required this.prompt,
    required this.mermaidCode,
    required this.elements,
    required this.provider,
  });
}
