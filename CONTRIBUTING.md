# Contributing to FlutCanvas

Thank you for your interest in contributing to **FlutCanvas**! FlutCanvas is an extensible, open-source collaborative whiteboard application built with Flutter, Clean Architecture, and BLoC.

---

## 🏛️ Architecture Overview

FlutCanvas follows **Feature-First Clean Architecture**:

```
lib/
├── core/                           # Cross-cutting concerns & infrastructure
│   ├── constants/                  # BoardColors and canvas styling
│   ├── di/                         # Dependency injection (GetIt + Injectable)
│   ├── error/                      # Failures & Result<T> pattern
│   ├── extensions/                 # Geometry extensions (Rect, Offset, Matrix4)
│   ├── services/                   # Infrastructure services (clipboard, downloader, media, text)
│   ├── theme/                      # AppTheme & color schemes
│   └── utils/                      # Pure mathematical & geometric algorithms
│
└── features/
    ├── ai_diagram/                 # AI text-to-diagram generation
    │   ├── data/                   # Gemini API client, window.ai service, prompt templates
    │   ├── domain/                 # AI models & repository contract
    │   └── presentation/           # AiDiagramCubit & prompt bar dialog with streaming HUD
    │
    ├── broadcast/                  # Zero-cloud LAN live presenter broadcast
    │   ├── data/                   # Embedded dart:io HTTP & WebSocket server, IP resolver
    │   ├── domain/                 # Live broadcast models & packet framing
    │   └── presentation/           # BroadcastCubit, QR modal & live viewer count HUD
    │
    ├── canvas/                     # Core infinite whiteboard canvas
    │   ├── data/                   # Data sources (shared_prefs) & geometric services
    │   ├── domain/                 # Pure models, commands, repositories, use cases
    │   │   ├── commands/           # Command Pattern for undo/redo (CanvasCommand)
    │   │   ├── models/             # Immutable Freezed entities (BoardElement, etc.)
    │   │   └── usecases/           # SaveWorkspace, AlignElements, GroupElements...
    │   └── presentation/           # Viewports, tools, renderers, painters, BLoC
    │       ├── bloc/               # CanvasBloc (committed state) & BoardsCubit
    │       ├── controllers/        # ViewportController & InteractionController (60/120fps)
    │       ├── tools/              # Strategy Pattern for canvas tools (CanvasTool)
    │       ├── renderers/          # Modular Shape Renderers (ShapeRendererRegistry)
    │       └── widgets/            # Multi-layer canvas widgets & gesture dispatcher
    │
    ├── clipboard/                  # System & internal clipboard synchronization
    ├── comments/                   # Sticky comments & canvas review pins
    ├── export/                     # PNG, SVG, PDF, Mermaid & JSON export
    ├── layers/                     # Layer reordering, locking, visibility
    ├── presentation_mode/          # Frame/slide presentation mode
    └── toolbar/                    # Main toolbar & Properties panel
```

---

## 🚀 How-To Guides for Contributors

### 1. How to Add a New Canvas Tool

To add a new tool (e.g. Polygon, Mindmap node, Callout bubble):

1. **Implement `CanvasTool`** in `lib/features/canvas/presentation/tools/`:
   ```dart
   class MyCustomTool implements CanvasTool {
     @override
     Tool get toolType => Tool.myTool;

     @override
     MouseCursor get cursor => SystemMouseCursors.precise;

     @override
     void onPointerDown(Offset worldPos, CanvasToolContext context) {
       // Set live draft or initialize interaction
     }

     @override
     void onPointerMove(Offset worldPos, CanvasToolContext context) {
       // Update live draft or guides
     }

     @override
     void onPointerUp(Offset worldPos, CanvasToolContext context) {
       // Commit element to CanvasBloc via context.commitElement(...)
     }

     @override
     void onPointerCancel(CanvasToolContext context) {}
   }
   ```

2. **Register your tool** in `ToolRegistry` (`lib/features/canvas/presentation/tools/tool_registry.dart`):
   ```dart
   register(MyCustomTool());
   ```

---

### 2. How to Add a New Shape Renderer

To add or customize how a shape is rendered on the canvas:

1. **Implement `ShapeRenderer`** in `lib/features/canvas/presentation/renderers/`:
   ```dart
   class CylinderRenderer implements ShapeRenderer {
     @override
     bool canRender(ShapeType type) => type == ShapeType.cylinder;

     @override
     void render(Canvas canvas, BoardElement element, BoardColors colors) {
       final strokePaint = Paint()
         ..color = colors.display(element.color)
         ..strokeWidth = element.strokeWidth
         ..style = PaintingStyle.stroke;
       
       // Draw custom paths/shapes on canvas
     }
   }
   ```

2. **Register the renderer** in `ShapeRendererRegistry`:
   ```dart
   ShapeRendererRegistry.instance.register(CylinderRenderer());
   ```

---

### 3. How to Add a New Mutation Command

Mutations on the canvas follow the **Command Pattern** (`CanvasCommand`):

1. Define your command in `lib/features/canvas/domain/commands/`:
   ```dart
   class ChangeColorCommand implements CanvasCommand {
     final Set<String> elementIds;
     final Color previousColor;
     final Color newColor;

     const ChangeColorCommand({
       required this.elementIds,
       required this.previousColor,
       required this.newColor,
     });

     @override
     String get description => 'Change element color';

     @override
     List<BoardElement> execute(List<BoardElement> current) =>
         current.map((e) => elementIds.contains(e.id) ? e.copyWith(color: newColor) : e).toList();

     @override
     List<BoardElement> undo(List<BoardElement> current) =>
         current.map((e) => elementIds.contains(e.id) ? e.copyWith(color: previousColor) : e).toList();
   }
   ```

---

### 4. How to Extend AI Text-to-Diagram Generation

The AI diagram generation pipeline (`lib/features/ai_diagram/`) uses a modular service architecture:
- **`GeminiDiagramService`**: Calls Gemini models via `google_generative_ai` with streaming response parsing and fallback chaining.
- **`AiPromptTemplates`**: Houses system prompts and diagram generation instructions for converting user prompts into strict Mermaid flowcharts and graph definitions.
- **`MermaidParserService`**: Automatically converts Mermaid code into positioned native canvas elements with collision prevention and rank spacing.

---

## 🧪 Testing Guidelines

- **Domain Use Cases & Commands**: Write pure Dart unit tests verifying input/output transformations without Flutter UI bindings.
- **Tools & Strategies**: Mock `CanvasToolContext` with `mocktail` to test pointer down, move, and up lifecycles.
- **BLoCs & Cubits**: Use `bloc_test` for verifying states emitted for each event.
- **Live Broadcast**: Test network packet framing and WebSocket handlers with mocked socket connections.

Run the test suite:
```bash
flutter test
```

---

## 📝 Code Style & Conventions

- All data models in `domain/models/` must be immutable using `@freezed`.
- Run code generation after modifying models or dependency injection:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- Keep UI widgets decoupled from business logic:
  - High-frequency drawing/transient gestures -> `CanvasViewportController` & `CanvasInteractionController`.
  - Committed document state -> `CanvasBloc` & `BoardsCubit`.
  - Feature UI options -> Feature Cubits (`ToolCubit`, `AiDiagramCubit`, `BroadcastCubit`, `CommentsCubit`, `LayersCubit`, `ExportCubit`).
