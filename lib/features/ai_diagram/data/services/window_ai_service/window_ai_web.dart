import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;

import '../gemini_diagram_service.dart';

class WindowAiService {
  const WindowAiService._();

  static bool get isSupported {
    try {
      final ai = web.window.getProperty<JSObject?>('ai'.toJS);
      if (ai != null) {
        final lm = ai.getProperty<JSObject?>('languageModel'.toJS);
        if (lm != null) return true;
        if (ai.hasProperty('createTextSession'.toJS).toDart) return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static String? get availabilityNote {
    if (!isSupported) {
      return 'Chrome Built-in AI not detected. To enable on-device Gemini Nano, use Chrome Canary / Dev and enable flags in chrome://flags (#prompt-api-for-gemini-nano).';
    }
    return null;
  }

  static Future<String> generate({
    required String prompt,
    required String systemInstruction,
  }) async {
    if (!isSupported) {
      throw StateError(
        'Chrome Built-in AI (window.ai) is not available in this browser. Please use Google Gemini API with your API key.',
      );
    }

    try {
      final ai = web.window.getProperty<JSObject?>('ai'.toJS);
      if (ai == null) {
        throw StateError('window.ai is null');
      }

      JSObject? session;

      if (ai.hasProperty('languageModel'.toJS).toDart) {
        final lm = ai.getProperty<JSObject>('languageModel'.toJS);
        final options = JSObject();
        options.setProperty('systemPrompt'.toJS, systemInstruction.toJS);

        final createPromise = lm.callMethod<JSPromise<JSObject>>('create'.toJS, options);
        session = await createPromise.toDart;
      } else if (ai.hasProperty('createTextSession'.toJS).toDart) {
        final createPromise = ai.callMethod<JSPromise<JSObject>>('createTextSession'.toJS);
        session = await createPromise.toDart;
      }

      if (session == null) {
        throw StateError('Could not initialize window.ai session');
      }

      final fullPrompt = '$systemInstruction\n\nUser Request: $prompt';
      final promptPromise = session.callMethod<JSPromise<JSString>>('prompt'.toJS, fullPrompt.toJS);
      final rawResult = await promptPromise.toDart;

      try {
        if (session.hasProperty('destroy'.toJS).toDart) {
          session.callMethod('destroy'.toJS);
        }
      } catch (_) {}

      final resultString = rawResult.toDart;
      return GeminiDiagramService.cleanMermaidOutput(resultString);
    } catch (e) {
      throw Exception('Chrome Built-in AI error: $e');
    }
  }
}
