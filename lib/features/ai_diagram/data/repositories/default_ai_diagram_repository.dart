import 'dart:ui';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutcanvas/features/canvas/data/services/mermaid_parser_service.dart';
import '../../domain/models/ai_diagram_provider.dart';
import '../../domain/models/ai_diagram_result.dart';
import '../../domain/repositories/ai_diagram_repository.dart';
import '../services/ai_prompt_templates.dart';
import '../services/gemini_diagram_service.dart';
import '../services/window_ai_service/window_ai_service.dart';

@LazySingleton(as: AiDiagramRepository)
class DefaultAiDiagramRepository implements AiDiagramRepository {
  static const _keyApiKey = 'flutcanvas_gemini_api_key';
  static const _keyProvider = 'flutcanvas_ai_provider';
  static const _keyModel = 'flutcanvas_gemini_model';

  final SharedPreferences _prefs;
  final GeminiDiagramService _geminiService;

  DefaultAiDiagramRepository(
    this._prefs,
    this._geminiService,
  );

  @override
  String? getApiKey() {
    return _prefs.getString(_keyApiKey);
  }

  @override
  Future<void> saveApiKey(String apiKey) async {
    await _prefs.setString(_keyApiKey, apiKey.trim());
  }

  @override
  AiDiagramProvider getProvider() {
    final val = _prefs.getString(_keyProvider);
    if (val == AiDiagramProvider.chromeNano.name && isWindowAiSupported) {
      return AiDiagramProvider.chromeNano;
    }
    return AiDiagramProvider.gemini;
  }

  @override
  Future<void> saveProvider(AiDiagramProvider provider) async {
    await _prefs.setString(_keyProvider, provider.name);
  }

  @override
  String getModel() {
    return _prefs.getString(_keyModel) ?? 'gemini-3.8-flash';
  }

  @override
  Future<void> saveModel(String model) async {
    await _prefs.setString(_keyModel, model.trim());
  }

  @override
  bool get isWindowAiSupported => WindowAiService.isSupported;

  @override
  String? get windowAiNote => WindowAiService.availabilityNote;

  @override
  Future<AiDiagramResult> generateDiagram({
    required String prompt,
    required Offset origin,
    Color defaultColor = const Color(0xFF1971C2),
    AiDiagramProvider? overrideProvider,
    void Function(String partialCode, String statusMessage)? onProgress,
  }) async {
    final provider = overrideProvider ?? getProvider();
    String mermaidCode;

    if (provider == AiDiagramProvider.chromeNano) {
      onProgress?.call('', 'Running on-device Gemini Nano model...');
      mermaidCode = await WindowAiService.generate(
        prompt: prompt,
        systemInstruction: AiPromptTemplates.systemInstruction,
      );
    } else {
      final apiKey = getApiKey() ?? '';
      if (apiKey.isEmpty) {
        throw StateError(
          'Please enter a Google Gemini API Key in the settings before generating diagrams.',
        );
      }
      mermaidCode = await _geminiService.generateDiagram(
        prompt: prompt,
        apiKey: apiKey,
        modelName: getModel(),
        onProgress: onProgress,
      );
    }

    if (mermaidCode.trim().isEmpty) {
      throw StateError('The AI returned an empty diagram response.');
    }

    onProgress?.call(mermaidCode, 'Placing shapes & routing connectors...');

    // Parse the generated Mermaid code into native BoardElement shapes & connectors
    final elements = MermaidParserService.parseToElements(
      script: mermaidCode,
      origin: origin,
      defaultColor: defaultColor,
    );

    if (elements.isEmpty) {
      throw StateError(
        'Could not parse diagram into FlutCanvas shapes. Raw AI output:\n$mermaidCode',
      );
    }

    return AiDiagramResult(
      prompt: prompt,
      mermaidCode: mermaidCode,
      elements: elements,
      provider: provider,
    );
  }
}
