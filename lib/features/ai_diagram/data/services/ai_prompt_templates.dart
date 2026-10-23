class AiPromptSuggestion {
  final String title;
  final String prompt;
  final String category;

  const AiPromptSuggestion({
    required this.title,
    required this.prompt,
    required this.category,
  });
}

class AiPromptTemplates {
  const AiPromptTemplates._();

  static const String systemInstruction = '''
You are an expert system architect, visual designer, and diagram generator for FlutCanvas.
Your job is to convert any natural language prompt into a beautifully organized, clean, modern Mermaid diagram.

CORE DESIGN RULES FOR MAXIMUM AESTHETICS & LEGIBILITY:
1. Output ONLY valid Mermaid syntax (flowchart TD or flowchart LR). NO markdown text, code blocks, or explanations.
2. SIMPLICITY & CLEAN LAYOUT:
   - Keep the diagram focused: between 4 to 8 key nodes.
   - Flow in ONE clean direction:
     * Architecture & Services: use "flowchart TD" (Top-Down).
     * Mind maps, user journeys & pipelines: use "flowchart LR" (Left-to-Right).
   - DO NOT USE SUBGRAPHS. Keep the canvas layout flat, open, and unboxed for maximum breathing room.
   - Avoid circular criss-crossing loops. Flow logically from client -> gateway -> services -> storage.
3. ARROW LABELS MUST BE ULTRA SHORT:
   - 1 to 3 words maximum per label (e.g. |HTTPS|, |Validate Token|, |Query User|, |Cache Hit|, |Session|).
   - NEVER write numbered steps or long sentences on arrows (DO NOT write |4. Store Session & Token Metadata|).
4. SHAPES:
   - Rectangles [Node Name] for apps, gateways, and services.
   - Rounded rectangles ([Service Name]) for auth or worker lambdas.
   - Cylinders [(Database Name)] for databases and caches: [(PostgreSQL DB)], [(Redis Cache)], [(DynamoDB)].
   - Diamonds {Condition?} for decision checks or routing.
5. CLEAN PASTEL COLOR PALETTE:
   - Always append inline "style" directives at the end of the diagram:
     * Ingress / Gateway: style <id> fill:#FFF9DB,stroke:#F59F00,stroke-width:2px
     * Auth / Security: style <id> fill:#F3F0FF,stroke:#7950F2,stroke-width:2px
     * Core Services: style <id> fill:#E7F5FF,stroke:#1971C2,stroke-width:2px
     * Cache: style <id> fill:#FFF0F6,stroke:#D6336C,stroke-width:2px
     * Databases: style <id> fill:#EBFBEE,stroke:#2F9E44,stroke-width:2px

EXAMPLE FOR MICROSERVICES AUTH ARCHITECTURE:
flowchart TD
  Client[Web & Mobile Clients] -->|HTTPS| Gateway[API Gateway]
  Gateway -->|Verify Token| Auth([Auth Service])
  Auth -->|Check Cache| Redis[(Redis Cache)]
  Auth -->|Query Credentials| DB[(PostgreSQL DB)]
  Gateway -->|Authorized Request| Services[Core Services]

  style Client fill:#E7F5FF,stroke:#1971C2,stroke-width:2px
  style Gateway fill:#FFF9DB,stroke:#F59F00,stroke-width:2px
  style Auth fill:#F3F0FF,stroke:#7950F2,stroke-width:2px
  style Redis fill:#FFF0F6,stroke:#D6336C,stroke-width:2px
  style DB fill:#EBFBEE,stroke:#2F9E44,stroke-width:2px
  style Services fill:#F8F9FA,stroke:#495057,stroke-width:2px
''';

  static const List<AiPromptSuggestion> suggestions = [
    AiPromptSuggestion(
      title: 'Microservices Auth',
      prompt:
          'Create a microservices authentication architecture with API Gateway, Auth Service, Redis Cache, and PostgreSQL',
      category: 'Architecture',
    ),
    AiPromptSuggestion(
      title: 'Flutter Web Mind Map',
      prompt:
          'Generate a mind map for learning Flutter Web covering Widgets, State Management, Routing, Web Interop, and Performance',
      category: 'Mind Map',
    ),
    AiPromptSuggestion(
      title: 'Checkout & Payment Flow',
      prompt:
          'Design an e-commerce checkout flow with Cart, Stripe Payment Gateway, Inventory Reservation, and Email Notifications',
      category: 'Flowchart',
    ),
    AiPromptSuggestion(
      title: 'AWS Serverless Pipeline',
      prompt:
          'Create an AWS Serverless architecture with CloudFront, S3, API Gateway, Lambda, DynamoDB, and EventBridge',
      category: 'Cloud',
    ),
  ];
}
