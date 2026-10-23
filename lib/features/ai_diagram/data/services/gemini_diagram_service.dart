import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import 'ai_prompt_templates.dart';

@lazySingleton
class GeminiDiagramService {
  const GeminiDiagramService();

  Future<String> generateDiagram({
    required String prompt,
    required String apiKey,
    String modelName = 'gemini-1.5-flash',
  }) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) {
      throw ArgumentError(
        'Gemini API Key is empty. Please enter your Gemini API key in the AI prompt settings.',
      );
    }

    final model = GenerativeModel(
      model: modelName,
      apiKey: cleanKey,
      systemInstruction: Content.system(AiPromptTemplates.systemInstruction),
      generationConfig: GenerationConfig(
        temperature: 0.2,
      ),
    );

    final response = await model.generateContent([Content.text(prompt)]);
    final rawText = response.text ?? '';
    return cleanMermaidOutput(rawText);
  }

  static String cleanMermaidOutput(String raw) {
    var text = raw.trim();

    // Extract content if wrapped inside ```mermaid ... ``` or ``` ... ```
    final codeBlockMatch = RegExp(r'```(?:mermaid)?\s*([\s\S]*?)```', caseSensitive: false)
        .firstMatch(text);
    if (codeBlockMatch != null && codeBlockMatch.group(1) != null) {
      text = codeBlockMatch.group(1)!.trim();
    } else {
      if (text.startsWith('```mermaid')) {
        text = text.substring('```mermaid'.length);
      } else if (text.startsWith('```')) {
        text = text.substring(3);
      }
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3);
      }
    }

    return text.trim();
  }
}
