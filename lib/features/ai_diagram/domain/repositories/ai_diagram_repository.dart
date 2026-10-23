import 'dart:ui';
import '../models/ai_diagram_provider.dart';
import '../models/ai_diagram_result.dart';

abstract class AiDiagramRepository {
  String? getApiKey();
  Future<void> saveApiKey(String apiKey);

  AiDiagramProvider getProvider();
  Future<void> saveProvider(AiDiagramProvider provider);

  String getModel();
  Future<void> saveModel(String model);

  bool get isWindowAiSupported;
  String? get windowAiNote;

  Future<AiDiagramResult> generateDiagram({
    required String prompt,
    required Offset origin,
    Color defaultColor,
    AiDiagramProvider? overrideProvider,
    void Function(String partialCode, String statusMessage)? onProgress,
  });
}
