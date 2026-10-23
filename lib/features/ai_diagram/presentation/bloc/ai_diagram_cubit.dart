import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/models/ai_diagram_provider.dart';
import '../../domain/models/ai_diagram_result.dart';
import '../../domain/repositories/ai_diagram_repository.dart';
import 'ai_diagram_state.dart';

@injectable
class AiDiagramCubit extends Cubit<AiDiagramState> {
  final AiDiagramRepository _repository;

  AiDiagramCubit(this._repository) : super(const AiDiagramState()) {
    _loadPreferences();
  }

  void _loadPreferences() {
    final key = _repository.getApiKey() ?? '';
    final provider = _repository.getProvider();
    final model = _repository.getModel();

    emit(
      state.copyWith(
        apiKey: key,
        provider: provider,
        model: model,
      ),
    );
  }

  void setProvider(AiDiagramProvider provider) {
    _repository.saveProvider(provider);
    emit(state.copyWith(provider: provider, clearError: true));
  }

  void setModel(String model) {
    _repository.saveModel(model);
    emit(state.copyWith(model: model, clearError: true));
  }

  Future<void> saveApiKey(String key) async {
    await _repository.saveApiKey(key);
    emit(state.copyWith(apiKey: key.trim(), clearError: true));
  }

  void toggleSettings([bool? open]) {
    emit(state.copyWith(isSettingsOpen: open ?? !state.isSettingsOpen));
  }

  void clearStatus() {
    emit(
      state.copyWith(
        status: AiDiagramStatus.initial,
        loadingMessage: null,
        clearError: true,
      ),
    );
  }

  Future<AiDiagramResult?> generate({
    required String prompt,
    required Offset origin,
    Color defaultColor = const Color(0xFF1971C2),
  }) async {
    final cleanPrompt = prompt.trim();
    if (cleanPrompt.isEmpty) {
      emit(
        state.copyWith(
          status: AiDiagramStatus.error,
          errorMessage: 'Please enter a description for the diagram to generate.',
        ),
      );
      return null;
    }

    if (state.provider == AiDiagramProvider.gemini && !state.hasApiKey) {
      emit(
        state.copyWith(
          status: AiDiagramStatus.error,
          isSettingsOpen: true,
          errorMessage:
              'Gemini API key is required. Please enter your API key below.',
        ),
      );
      return null;
    }

    emit(
      state.copyWith(
        status: AiDiagramStatus.generating,
        loadingMessage: state.provider == AiDiagramProvider.chromeNano
            ? 'Generating on-device with Gemini Nano (window.ai)...'
            : 'Designing architecture & routing shapes with Gemini AI...',
        clearError: true,
      ),
    );

    try {
      final result = await _repository.generateDiagram(
        prompt: cleanPrompt,
        origin: origin,
        defaultColor: defaultColor,
        overrideProvider: state.provider,
      );

      emit(
        state.copyWith(
          status: AiDiagramStatus.success,
          loadingMessage: null,
          lastResult: result,
          clearError: true,
        ),
      );

      return result;
    } catch (e) {
      String message = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('StateError: ', '');
      if (message.contains('SocketException') ||
          message.contains('ClientException')) {
        message =
            'Network connection failed. Please check your internet connection or verify that network permissions are granted.';
      }
      emit(
        state.copyWith(
          status: AiDiagramStatus.error,
          loadingMessage: null,
          errorMessage: message,
        ),
      );
      return null;
    }
  }
}
