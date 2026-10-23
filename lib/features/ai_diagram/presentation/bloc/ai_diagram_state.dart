import '../../domain/models/ai_diagram_provider.dart';
import '../../domain/models/ai_diagram_result.dart';

enum AiDiagramStatus { initial, generating, success, error }

class AiDiagramState {
  final AiDiagramStatus status;
  final AiDiagramProvider provider;
  final String apiKey;
  final String model;
  final String streamingCode;
  final int currentStep;
  final String? loadingMessage;
  final String? errorMessage;
  final AiDiagramResult? lastResult;
  final bool isSettingsOpen;

  const AiDiagramState({
    this.status = AiDiagramStatus.initial,
    this.provider = AiDiagramProvider.gemini,
    this.apiKey = '',
    this.model = 'gemini-3.8-flash',
    this.streamingCode = '',
    this.currentStep = 1,
    this.loadingMessage,
    this.errorMessage,
    this.lastResult,
    this.isSettingsOpen = false,
  });

  bool get isGenerating => status == AiDiagramStatus.generating;
  bool get hasApiKey => apiKey.trim().isNotEmpty;
  bool get hasStreamingOutput => streamingCode.isNotEmpty;

  AiDiagramState copyWith({
    AiDiagramStatus? status,
    AiDiagramProvider? provider,
    String? apiKey,
    String? model,
    String? streamingCode,
    int? currentStep,
    String? loadingMessage,
    String? errorMessage,
    AiDiagramResult? lastResult,
    bool? isSettingsOpen,
    bool clearError = false,
    bool clearLastResult = false,
    bool clearStreaming = false,
  }) {
    return AiDiagramState(
      status: status ?? this.status,
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      streamingCode: clearStreaming ? '' : (streamingCode ?? this.streamingCode),
      currentStep: currentStep ?? this.currentStep,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastResult:
          clearLastResult ? null : (lastResult ?? this.lastResult),
      isSettingsOpen: isSettingsOpen ?? this.isSettingsOpen,
    );
  }
}
