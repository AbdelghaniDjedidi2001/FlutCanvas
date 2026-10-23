import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import 'ai_prompt_templates.dart';

@lazySingleton
class GeminiDiagramService {
  const GeminiDiagramService();

  Future<String> generateDiagram({
    required String prompt,
    required String apiKey,
    String modelName = 'gemini-3.8-flash',
    void Function(String partialCode, String statusMessage)? onProgress,
  }) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) {
      throw ArgumentError(
        'Gemini API Key is empty. Please enter your Gemini API key in the AI prompt settings.',
      );
    }

    // Try selected model first, then auto-fallback to compatible models if 404 / deprecated / not found
    final candidateModels = <String>[
      modelName,
      if (modelName != 'gemini-3.8-flash') 'gemini-3.8-flash',
      if (modelName != 'gemini-2.5-flash') 'gemini-2.5-flash',
      if (modelName != 'gemini-1.5-flash-latest') 'gemini-1.5-flash-latest',
      if (modelName != 'gemini-1.5-flash') 'gemini-1.5-flash',
      if (modelName != 'gemini-1.5-pro') 'gemini-1.5-pro',
    ];

    Object? lastError;
    for (final candidate in candidateModels) {
      try {
        onProgress?.call('', 'Connecting to $candidate...');
        final model = GenerativeModel(
          model: candidate,
          apiKey: cleanKey,
          systemInstruction: Content.system(AiPromptTemplates.systemInstruction),
          generationConfig: GenerationConfig(
            temperature: 0.2,
          ),
        );

        final buffer = StringBuffer();
        final stream = model
            .generateContentStream([Content.text(prompt)])
            .timeout(const Duration(seconds: 25));

        await for (final chunk in stream) {
          final chunkText = chunk.text ?? '';
          buffer.write(chunkText);
          final currentRaw = buffer.toString();
          final nodeCount =
              RegExp(r'\[|\(|\{\|\[\(').allMatches(currentRaw).length;
          onProgress?.call(
            cleanMermaidOutput(currentRaw),
            'Streaming diagram ($nodeCount shapes detected)...',
          );
        }

        final rawText = buffer.toString();
        if (rawText.trim().isNotEmpty) {
          onProgress?.call(
            cleanMermaidOutput(rawText),
            'Synthesizing layout & shapes...',
          );
          return cleanMermaidOutput(rawText);
        }
      } on TimeoutException {
        lastError = Exception(
          'Connection to Gemini timed out after 25s. Please check your network or try again.',
        );
      } catch (e) {
        lastError = e;
        final errStr = e.toString().toLowerCase();
        final isModelIssue = errStr.contains('not found') ||
            errStr.contains('404') ||
            errStr.contains('no longer available') ||
            errStr.contains('is not supported for generatecontent') ||
            errStr.contains('deprecated');
        // If not a model-availability issue, don't continue falling back
        if (!isModelIssue) {
          rethrow;
        }
      }
    }

    if (lastError != null) {
      throw lastError;
    }

    return '';
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
