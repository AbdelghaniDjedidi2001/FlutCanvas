enum AiDiagramProvider {
  gemini('Google Gemini API', 'Cloud AI (Fast & versatile)'),
  chromeNano('Chrome On-Device AI', 'window.ai (Private & zero key required)');

  final String title;
  final String subtitle;
  const AiDiagramProvider(this.title, this.subtitle);
}
