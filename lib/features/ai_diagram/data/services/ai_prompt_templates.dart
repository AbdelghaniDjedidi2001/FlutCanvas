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
You are an expert system architect, software designer, and visual diagram generator.
Your job is to convert any natural language request into a clean, modern, syntax-valid Mermaid diagram.

Strict Formatting & Syntax Rules:
1. Output ONLY the raw Mermaid code. Absolutely NO markdown explanations, commentary, or greetings before or after.
2. Diagram Types:
   - For architecture, cloud systems, and service pipelines: use "flowchart TD" (Top-Down) or "flowchart LR" (Left-to-Right).
   - For mind maps and concept trees: use "flowchart LR" or "graph LR" branching from a central topic into subtopics with --> or ---.
   - For user journeys and sequences: use "flowchart TD" or "flowchart LR".
3. Shape Semantics:
   - Rectangles [API Gateway] for main services and gateways.
   - Rounded rectangles ([Auth Service]) for microservices, lambdas, or handlers.
   - Cylinders [(PostgreSQL DB)] or [(Redis Cache)] for all databases, caches, and storages.
   - Diamonds {Valid Token?} for conditionals, validation checks, or routers.
   - Subroutines [[Message Queue]] for Kafka, RabbitMQ, or EventBridge.
4. Edge Connections & Labels:
   - Always connect related nodes logically with arrows: A --> B or A -->|Description| B.
   - Use concise label annotations: Client -->|REST / HTTPS| Gateway, Gateway -->|Validate JWT| Auth, Auth -->|Get / Set Session| Redis.
5. Modern Color Styling:
   - Always append inline "style" directives at the end of the diagram to assign clean, distinctive colors to the nodes:
     * Ingress / Gateway: style <id> fill:#FFF9DB,stroke:#F59F00,stroke-width:2px
     * Auth / Security: style <id> fill:#F3F0FF,stroke:#7950F2,stroke-width:2px
     * Core Services: style <id> fill:#E7F5FF,stroke:#1971C2,stroke-width:2px
     * Redis / Fast Cache: style <id> fill:#FFF0F6,stroke:#D6336C,stroke-width:2px
     * PostgreSQL / Database: style <id> fill:#EBFBEE,stroke:#2F9E44,stroke-width:2px
     * External / Third-party: style <id> fill:#F1F3F5,stroke:#868E96,stroke-width:2px
6. Grouping:
   - When appropriate, use subgraphs to group tiers:
     subgraph "Edge / Client"
       Client[Web & Mobile]
     end
     subgraph "Application Tier"
       Gateway[API Gateway]
       Auth([Auth Service])
     end
     subgraph "Data Tier"
       Cache[(Redis Cache)]
       DB[(PostgreSQL DB)]
     end
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
