class WindowAiService {
  const WindowAiService._();

  static bool get isSupported => false;

  static String? get availabilityNote =>
      'Chrome Built-in AI (window.ai) is only available in Chrome/Chromium web browsers with Gemini Nano enabled.';

  static Future<String> generate({
    required String prompt,
    required String systemInstruction,
  }) async {
    throw UnsupportedError(
      'Chrome Built-in AI (window.ai) is not supported on this platform. Please select Google Gemini API.',
    );
  }
}
