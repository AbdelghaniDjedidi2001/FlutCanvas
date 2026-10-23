import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutcanvas/features/ai_diagram/data/repositories/default_ai_diagram_repository.dart';
import 'package:flutcanvas/features/ai_diagram/data/services/ai_prompt_templates.dart';
import 'package:flutcanvas/features/ai_diagram/data/services/gemini_diagram_service.dart';
import 'package:flutcanvas/features/ai_diagram/domain/models/ai_diagram_provider.dart';
import 'package:flutcanvas/features/ai_diagram/presentation/bloc/ai_diagram_cubit.dart';
import 'package:flutcanvas/features/ai_diagram/presentation/bloc/ai_diagram_state.dart';
import 'package:flutcanvas/features/ai_diagram/presentation/widgets/ai_prompt_bar_dialog.dart';
import 'package:flutcanvas/features/canvas/domain/models/shape_type.dart';

class FakeGeminiDiagramService extends GeminiDiagramService {
  final String fakeResponse;
  const FakeGeminiDiagramService({this.fakeResponse = '''flowchart TD
  Client[Web Client] --> Gateway[API Gateway]
  Gateway --> Auth([Auth Service])
  Gateway --> Cache[(Redis Cache)]
  Gateway --> DB[(PostgreSQL DB)]
  style Gateway fill:#FFF9DB,stroke:#F59F00,stroke-width:2px
  style Auth fill:#F3F0FF,stroke:#7950F2,stroke-width:2px
  style Cache fill:#FFF0F6,stroke:#D6336C,stroke-width:2px
  style DB fill:#EBFBEE,stroke:#2F9E44,stroke-width:2px'''});

  @override
  Future<String> generateDiagram({
    required String prompt,
    required String apiKey,
    String modelName = 'gemini-3.8-flash',
    void Function(String partialCode, String statusMessage)? onProgress,
  }) async {
    onProgress?.call(fakeResponse, 'Streaming fake response...');
    return GeminiDiagramService.cleanMermaidOutput(fakeResponse);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AI Prompt Templates & Syntax Cleaning Tests', () {
    test('AiPromptTemplates contains system rules and suggestions', () {
      expect(AiPromptTemplates.systemInstruction, contains('flowchart TD'));
      expect(AiPromptTemplates.systemInstruction, contains('flowchart LR'));
      expect(AiPromptTemplates.systemInstruction, contains('style <id> fill:'));
      expect(AiPromptTemplates.suggestions, isNotEmpty);
      expect(
        AiPromptTemplates.suggestions.any((s) => s.title.contains('Microservices')),
        isTrue,
      );
      expect(
        AiPromptTemplates.suggestions.any((s) => s.title.contains('Flutter Web')),
        isTrue,
      );
    });

    test('GeminiDiagramService.cleanMermaidOutput strips markdown code fences', () {
      const wrapped = '''```mermaid
flowchart LR
  A --> B
```''';
      expect(GeminiDiagramService.cleanMermaidOutput(wrapped), equals('flowchart LR\n  A --> B'));

      const genericFence = '''```
flowchart TD
  X --> Y
```''';
      expect(GeminiDiagramService.cleanMermaidOutput(genericFence), equals('flowchart TD\n  X --> Y'));

      const plain = 'flowchart TD\n  A --> B';
      expect(GeminiDiagramService.cleanMermaidOutput(plain), equals(plain));
    });
  });

  group('DefaultAiDiagramRepository Tests', () {
    test('persists and loads API key and provider in SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = DefaultAiDiagramRepository(
        prefs,
        const FakeGeminiDiagramService(),
      );

      expect(repo.getApiKey(), isNull);
      await repo.saveApiKey('test-api-key-12345');
      expect(repo.getApiKey(), equals('test-api-key-12345'));

      expect(repo.getProvider(), equals(AiDiagramProvider.gemini));
      await repo.saveProvider(AiDiagramProvider.gemini);
      expect(repo.getProvider(), equals(AiDiagramProvider.gemini));

      await repo.saveModel('gemini-2.0-flash');
      expect(repo.getModel(), equals('gemini-2.0-flash'));
    });

    test('generateDiagram parses LLM response into native BoardElements with connectors', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('flutcanvas_gemini_api_key', 'valid-api-key');
      final repo = DefaultAiDiagramRepository(
        prefs,
        const FakeGeminiDiagramService(),
      );

      final result = await repo.generateDiagram(
        prompt: 'Create microservices architecture with Gateway, Auth, Redis, and Postgres',
        origin: const Offset(100, 100),
      );

      expect(result.elements, isNotEmpty);
      expect(result.mermaidCode, contains('Gateway[API Gateway]'));

      // Check that Gateway is created as rectangle
      final gateway = result.elements.firstWhere((e) => e.text == 'API Gateway');
      expect(gateway.type, equals(ShapeType.rectangle));

      // Check that DB is created as rounded rectangle / database
      final db = result.elements.firstWhere((e) => e.text == 'PostgreSQL DB');
      expect(db.type, equals(ShapeType.roundedRectangle));

      // Check connectors
      final arrows = result.elements.where((e) => e.type == ShapeType.arrow);
      expect(arrows.length, greaterThanOrEqualTo(3));
    });

    test('throws StateError when Gemini API key is missing', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = DefaultAiDiagramRepository(
        prefs,
        const FakeGeminiDiagramService(),
      );

      expect(
        () => repo.generateDiagram(
          prompt: 'Test prompt',
          origin: Offset.zero,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('AiDiagramCubit Tests', () {
    test('initial state and preference updates', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('flutcanvas_gemini_api_key', 'my-key');
      final repo = DefaultAiDiagramRepository(
        prefs,
        const FakeGeminiDiagramService(),
      );
      final cubit = AiDiagramCubit(repo);

      expect(cubit.state.apiKey, equals('my-key'));
      expect(cubit.state.hasApiKey, isTrue);
      expect(cubit.state.status, equals(AiDiagramStatus.initial));

      cubit.setProvider(AiDiagramProvider.gemini);
      expect(cubit.state.provider, equals(AiDiagramProvider.gemini));

      cubit.toggleSettings(true);
      expect(cubit.state.isSettingsOpen, isTrue);

      await cubit.saveApiKey('updated-key');
      expect(cubit.state.apiKey, equals('updated-key'));
    });

    test('generate emits generating and success states with result', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('flutcanvas_gemini_api_key', 'my-key');
      final repo = DefaultAiDiagramRepository(
        prefs,
        const FakeGeminiDiagramService(),
      );
      final cubit = AiDiagramCubit(repo);

      final result = await cubit.generate(
        prompt: 'Microservices auth architecture',
        origin: const Offset(50, 50),
      );

      expect(result, isNotNull);
      expect(cubit.state.status, equals(AiDiagramStatus.success));
      expect(cubit.state.lastResult, isNotNull);
      expect(cubit.state.errorMessage, isNull);
    });

    test('generate with empty prompt emits error state', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = DefaultAiDiagramRepository(
        prefs,
        const FakeGeminiDiagramService(),
      );
      final cubit = AiDiagramCubit(repo);

      final result = await cubit.generate(
        prompt: '   ',
        origin: Offset.zero,
      );

      expect(result, isNull);
      expect(cubit.state.status, equals(AiDiagramStatus.error));
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('AiPromptBarDialog Widget Tests', () {
    testWidgets('renders dialog UI, shortcut pill, suggestion chips, and triggers insert',
        (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('flutcanvas_gemini_api_key', 'my-key');
      final repo = DefaultAiDiagramRepository(
        prefs,
        const FakeGeminiDiagramService(),
      );
      final cubit = AiDiagramCubit(repo);

      var inserted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AiDiagramCubit>.value(
              value: cubit,
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => BlocProvider<AiDiagramCubit>.value(
                          value: cubit,
                          child: AiPromptBarDialog(
                            targetOrigin: const Offset(100, 100),
                            onInsert: (elements) {
                              inserted = true;
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify header and elements
      expect(find.text('AI Text-to-Diagram'), findsOneWidget);
      expect(find.text('Cmd + Shift + A'), findsOneWidget);
      expect(find.byType(TextField), findsAtLeastNWidgets(1));

      // Verify suggestion chips are present
      expect(find.text('Microservices Auth'), findsOneWidget);
      expect(find.text('Flutter Web Mind Map'), findsOneWidget);

      // Click suggestion chip
      await tester.tap(find.text('Microservices Auth'));
      await tester.pumpAndSettle();

      // Submit generation
      await tester.tap(find.text('Generate & Insert'));
      await tester.pumpAndSettle();

      // Should have inserted elements and closed the dialog
      expect(inserted, isTrue);
      expect(find.text('AI Text-to-Diagram'), findsNothing);
    });
  });
}
