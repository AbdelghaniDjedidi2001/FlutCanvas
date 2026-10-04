# FlutCanvas — Production Clean Architecture & Open-Source Scaling Plan

> **Branch:** `refactor/clean-architecture-bloc-freezed`  
> **Target:** Feature-First Clean Architecture, Strategy-Pattern Canvas Tools, Shape Renderer Registry, Command Pattern Undo/Redo, and Contributor-Ready Open-Source Framework.

---

## 1. Executive Summary & Goals

FlutCanvas is being architected as an extensible, community-driven open-source whiteboard (similar to Excalidraw / tldraw / Miro).

### Architectural Bottlenecks to Resolve:
1. **The 2,460-line God-Widget (`WhiteboardPage`)**: Holds all private state (`_boards`, `_elements`, `_selectedIds`, `_history`), 40+ `setState` triggers, complex pointer gestures, and 40+ prop-drilled parameters.
2. **Missing Domain Layer Use Cases**: No interactors exist; business operations are mixed into UI callbacks, static service methods, and BLoC event bodies.
3. **Domain Pollution**: `BoardElement` (domain model) imports `google_fonts` and calls Flutter engine UI layout (`TextPainter`) directly in getters.
4. **Monolithic Shape & Renderer Definitions**: `ElementRenderer` has 850+ lines of switch cases. Adding a shape requires editing 5–6 core files.
5. **Full Snapshot History**: `HistoryManager` clones the entire element array on every edit, causing memory bloat with large boards.
6. **Dual State / Incomplete BLoC Migration**: Toolbars and overlays still receive callbacks from `WhiteboardPage` instead of being driven cleanly by their Cubits.

---

## 2. Target Clean Architecture Blueprint

```
lib/
├── core/
│   ├── di/                               # GetIt + Injectable registration
│   ├── error/                            # Domain Failures & Result<T> pattern
│   ├── extensions/                       # Rect, Offset, Matrix4, Color extensions
│   ├── theme/                            # BoardColors, typography, theme mode
│   └── utils/                            # Geometry, Math, Bezier, Matrix utilities
│
└── features/
    ├── canvas/
    │   ├── domain/
    │   │   ├── commands/                 # Command Pattern for mutations & undo/redo
    │   │   ├── models/                   # Pure domain entities (Freezed)
    │   │   ├── repositories/             # BoardRepository interface
    │   │   └── usecases/                 # SaveWorkspace, AlignElements, GroupElements...
    │   ├── data/
    │   │   ├── datasources/              # SharedPreferences, LocalFile, Cloud (interfaces + impls)
    │   │   └── repositories/             # BoardRepositoryImpl
    │   └── presentation/
    │       ├── bloc/                     # CanvasBloc, BoardsCubit
    │       ├── controllers/              # CanvasViewportController & InteractionState (60/120fps)
    │       ├── tools/                    # CanvasTool Strategy Pattern (Select, Shape, Pen, Eraser...)
    │       ├── renderers/                # ShapeRenderer Registry & individual renderers
    │       ├── painters/                 # GridPainter, ElementsPainter, OverlayPainter
    │       └── widgets/                  # Viewport, GestureDispatcher, Shortcuts, Overlays
    │
    ├── toolbar/                          # ToolCubit, MainToolbar, PropertiesPanel
    ├── comments/                         # CommentsCubit, CommentPins, CommentPopover
    ├── layers/                           # LayersCubit, LayersSidebar
    ├── export/                           # ExportCubit, DefaultExportRepository, ExportDialog
    ├── import/                           # Excalidraw & Mermaid parsers
    ├── clipboard/                        # ClipboardRepository, Clipboard paste handlers
    └── presentation_mode/                # PresentationCubit, PresentationOverlay
```

---

## 3. Work Breakdown & Task Checklist

### Phase 1: Pure Domain Layer & Foundation
- [x] **1.1 Standardized Error & Result Pattern**: Create `lib/core/error/failures.dart` and `lib/core/utils/result.dart`.
- [x] **1.2 Domain Model Purification**: Remove Flutter `TextPainter` and `google_fonts` from `BoardElement.dart`; extract text measurement to a presentation layout service.
- [x] **1.3 Extract Domain Use Cases**:
  - `SaveWorkspaceUseCase` & `LoadWorkspaceUseCase`
  - `AlignElementsUseCase` & `DistributeElementsUseCase`
  - `GroupElementsUseCase` & `UngroupElementsUseCase`
- [x] **1.4 Implement Command Pattern for Undo/Redo**:
  - Define `CanvasCommand` (`execute()`, `undo()`).
  - Create commands: `AddElementCommand`, `DeleteElementsCommand`, `MoveElementsCommand`, `UpdateElementCommand`, `BatchCommand`.
  - Created `CommandHistoryManager` to store lightweight commands instead of full element-list copies.

### Phase 2: Canvas Tool Strategy Pattern (Contributor Extensibility)
- [x] **2.1 Define Tool Interfaces**:
  - `CanvasTool` interface (`onPointerDown`, `onPointerMove`, `onPointerUp`, `onPointerCancel`).
  - `CanvasToolContext` (access to viewport, selection, committed elements, transient draft).
- [x] **2.2 Implement Discrete Tool Strategies**:
  - `SelectTool`: Selection, marquee rectangle, moving.
  - `ShapeTool`: Rectangles, diamonds, ellipses, triangles, stars, frames.
  - `FreehandTool`: Pen and highlighter drawing with stroke smoothing.
  - `ConnectorTool`: Arrows and lines with anchor snapping.
  - `EraserTool`: Element deletion on stroke intersection.
  - `LaserTool`: Ephemeral presentation trail.
- [x] **2.3 Create `ToolRegistry`**: Allows plug-and-play tool registration.

### Phase 3: Shape Renderer Registry
- [x] **3.1 Define `ShapeRenderer` Interface**: `render(canvas, element, colors)`, `canRender(type)`.
- [x] **3.2 Modularize Renderers**:
  - `BasicShapeRenderer` (rectangles, rounded boxes, ellipses, diamonds, polygons).
- [x] **3.3 Create `ShapeRendererRegistry`**: Central registry dispatching rendering by `ShapeType` with seamless fallback in `ElementRenderer`.

### Phase 4: Two-Tier State & Decomposing `WhiteboardPage`
- [x] **4.1 Viewport & Transient Interaction Controllers**:
  - `CanvasViewportController`: Manages scale, offset, pan, trackpad scroll, zoom clamping.
  - `CanvasInteractionController`: Holds transient draft, live marquee, laser trail, and active snap guides.
- [x] **4.2 Modular Canvas Widgets**:
  - `CanvasViewport`: Matrix-transformed rendering container.
  - `CanvasGestureDispatcher`: Routes pointer events to active `CanvasTool`.
  - Multi-layer `CustomPaint` (`CanvasBackgroundLayer`, `CanvasElementsLayer`, `CanvasOverlayLayer`).
- [ ] **4.3 Clean UI Binding**:
  - Integrate modular widgets into `WhiteboardPage` and eliminate prop-drilled callbacks.

### Phase 5: Codebase Cleanup & Directory Consolidation
- [ ] **5.1 Eliminate Shims**: Remove `lib/models/` legacy export files and update all imports to `features/canvas/domain/models/`.
- [ ] **5.2 Feature Relocation**: Move lingering files from `lib/services/` and `lib/painters/` into corresponding feature packages.
- [ ] **5.3 Directory Pruning**: Delete empty folders in `lib/core/` and `lib/features/`.
- [ ] **5.4 Clean Dependency Injection**: Remove fallback `_resolve()` in `main.dart`; ensure clean `getIt` registration.

### Phase 6: Open-Source Collaboration & Quality Assurance
- [x] **6.1 Add `CONTRIBUTING.md`**: Guide for new developers explaining architecture, how to add a tool, and how to add a shape.
- [ ] **6.2 Lint & Analysis Hardening**: Update `analysis_options.yaml` with strict rules.
- [x] **6.3 Comprehensive Test Suite**: Unit tests for Result pattern, Use Cases, Commands, and Tool Strategies.
