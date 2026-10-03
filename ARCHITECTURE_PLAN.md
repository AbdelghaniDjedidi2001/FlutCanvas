# FlutCanvas — Clean Architecture Migration Plan

> **Branch:** `refactor/clean-architecture-bloc-freezed`  
> **Target:** Feature-First Clean Architecture with BLoC + Freezed  
> **Started:** 2026-10-03  
> **Estimated Effort:** 10–14 days  

---

## Overview

Migrate from a monolithic `setState`-based architecture to a feature-first clean architecture using **BLoC** for state management, **Freezed** for immutable models & sealed unions, and **GetIt + Injectable** for dependency injection.

### Current State

| Metric | Value |
|--------|-------|
| Total codebase | ~10,300 lines (6,680 prod + 2,670 test) |
| God Widget (`WhiteboardPage`) | 2,445 lines, 40+ state variables |
| God Model (`BoardElement`) | 560 lines, 29 fields, 19 shape types |
| Services | All static, no DI, no interfaces |
| Test coverage | Services/models only, zero BLoC/widget/integration tests |

### Target State

| Metric | Target |
|--------|--------|
| Largest file | < 300 lines |
| State management | BLoC (events → states) |
| Models | Freezed sealed unions, fully immutable |
| DI | GetIt + Injectable |
| Test coverage | BLoC + Widget + Integration tests |

---

## Progress Tracker

| Phase | Description | Status | Tasks Done |
|-------|-------------|--------|------------|
| 0 | Project Setup & Dependencies | ✅ Complete | 5/5 |
| 1 | Models → Freezed | ✅ Complete | 10/10 |
| 2 | DI & Repository Layer | ✅ Complete | 8/8 |
| 3 | Extract BLoCs from God Widget | ⬜ Not Started | 0/14 |
| 4 | Feature Extraction & UI Cleanup | ⬜ Not Started | 0/12 |
| 5 | Testing & Validation | ⬜ Not Started | 0/10 |
| **Total** | | | **0/59** |

---

## Phase 0 — Project Setup & Dependencies

> **Effort:** 0.5 day | **Risk:** Low  
> **Goal:** Add all new packages and configure code generation tooling.

- [x] **0.1** Add runtime dependencies to `pubspec.yaml`
  - `flutter_bloc: ^9.0.0`
  - `bloc_concurrency: ^0.3.0`
  - `freezed_annotation: ^3.0.0`
  - `json_annotation: ^4.9.0`
  - `get_it: ^8.0.0`
  - `injectable: ^2.5.0`
- [x] **0.2** Add dev dependencies to `pubspec.yaml`
  - `build_runner: ^2.4.0`
  - `freezed: ^3.0.0`
  - `json_serializable: ^6.8.0`
  - `injectable_generator: ^2.7.0`
  - `bloc_test: ^10.0.0`
  - `mocktail: ^1.0.0`
- [x] **0.3** Run `flutter pub get` — verify clean resolution
- [x] **0.4** Create `lib/core/di/injection.dart` with GetIt bootstrap skeleton
- [x] **0.5** Create `build.yaml` if needed for Freezed/json_serializable config

**Acceptance Criteria:**  
✅ `flutter pub get` succeeds  
✅ `dart run build_runner build` runs without errors  
✅ App still compiles and runs identically to `main` branch

---

## Phase 1 — Models → Freezed Sealed Classes

> **Effort:** 1–2 days | **Risk:** Low  
> **Goal:** Replace mutable God Model with type-safe, immutable Freezed sealed unions. No UI changes.

### 1A — BoardElement Refactor

- [x] **1.1** Create `lib/features/canvas/domain/models/` directory structure
- [x] **1.2** Define `BoardElement` as a Freezed model with all fields, custom getters, methods, and serializers
- [x] **1.3** Decouple model bounds/geometry logic cleanly with proper converters
- [x] **1.4** Run `dart run build_runner build` — generate `.freezed.dart` and `.g.dart`
- [x] **1.5** Create `fromLegacyMap` / `toLegacyMap` adapter for backward compatibility with existing saved data in `SharedPreferences`

### 1B — Other Models

- [x] **1.6** Convert `BoardDocument` to Freezed (fix mutable fields inconsistency)
- [x] **1.7** Convert `BoardComment` / `CommentReply` to Freezed
- [x] **1.8** Convert `SnapGuide`, `ConnectionBinding` to Freezed
- [x] **1.9** Replace stringly-typed params in `AlignmentService` with enums (`AlignDirection`, `DistributeDirection`)
- [x] **1.10** Update all existing tests to use new model constructors

**Acceptance Criteria:**  
✅ All models are `@freezed` with generated `copyWith`, `==`, `toJson`, `fromJson`  
✅ `BoardElement` is a sealed class with exhaustive pattern matching  
✅ No Flutter rendering imports in any model file  
✅ All existing tests pass with new models  
✅ Existing saved boards can still be loaded (backward compat)

---

## Phase 2 — Dependency Injection & Repository Layer

> **Effort:** 1 day | **Risk:** Low  
> **Goal:** Abstract all data access behind interfaces. Wire up DI. No UI changes yet.

### 2A — Abstract Repositories

- [x] **2.1** Create `BoardRepository` abstract class
  - `saveWorkspace(...)`, `loadWorkspace()`, `clearWorkspace()`
- [x] **2.2** Create `ExportRepository` abstract class
  - `renderToPng(...)`, `exportToSvg(...)`, `exportToPdf(...)`, `exportToJson(...)`, `importFromJson(...)`
- [x] **2.3** Create `ClipboardRepository` abstract class
  - `copy(...)`, `duplicate()`, `pasteFromSystem(...)`, `createImageElement(...)`

### 2B — Concrete Implementations

- [x] **2.4** Implement `SharedPrefsBoardRepository` (migrated from `StorageService`)
- [x] **2.5** Implement `DefaultExportRepository` (migrated from `ExportService`)
- [x] **2.6** Implement `DefaultClipboardRepository` (migrated from `ClipboardService`, eliminate global static state)

### 2C — Wire Up DI

- [x] **2.7** Register all repositories and services in `injection.dart` using `@injectable` / `@module`
- [x] **2.8** Initialize `GetIt` in `main.dart` before `runApp()`

**Acceptance Criteria:**  
✅ All data access goes through abstract repository interfaces  
✅ `ClipboardService._inMemoryClipboard` global static state eliminated  
✅ `ImageService._imageCache` global static state eliminated  
✅ `GetIt.instance<BoardRepository>()` resolves correctly  
✅ App still compiles and runs identically

---

## Phase 3 — Extract BLoCs from God Widget

> **Effort:** 3–5 days | **Risk:** Medium  
> **Goal:** Extract ALL business logic from `_WhiteboardPageState` (~2,445 lines) into testable BLoCs/Cubits.

### 3A — Canvas Core BLoC

- [ ] **3.1** Define `CanvasEvent` sealed class (Freezed):
  - `AddElement`, `DeleteElements`, `UpdateElement`
  - `MoveElements`, `ResizeElement`, `RotateElement`
  - `SelectElement`, `ClearSelection`, `MarqueeSelect`
  - `GroupElements`, `UngroupElements`
  - `Undo`, `Redo`
  - `ZoomChanged`, `PanChanged`
  - `ToggleGrid`, `ToggleSmartGuides`
- [ ] **3.2** Define `CanvasState` (Freezed):
  - `elements`, `selectedIds`, `scale`, `offset`, `gridEnabled`, `previewElement`, `snapGuides`
- [ ] **3.3** Implement `CanvasBloc` with all event handlers
  - Migrate element CRUD logic from `_WhiteboardPageState`
  - Migrate selection logic
  - Migrate grouping logic
  - Integrate `HistoryManager` as internal undo/redo stack
- [ ] **3.4** Extract connected-arrow recalculation (`_updateConnectedArrows`) into `CanvasBloc`

### 3B — Tool Cubit

- [ ] **3.5** Define `ToolState` (Freezed): `tool`, `color`, `fillColor`, `strokeWidth`, `strokeStyle`, `fillStyle`, `drawStyle`, `fontSize`, `opacity`, `rotation`, `connectorStyle`, `codeLanguage`
- [ ] **3.6** Implement `ToolCubit` — simple state emission for tool/property changes

### 3C — Board Management Cubit

- [ ] **3.7** Define `BoardsState` (Freezed): `boards`, `activeBoardIndex`
- [ ] **3.8** Implement `BoardsCubit` — add/remove/switch/duplicate/rename boards
  - Migrate from `_boards` / `_activeBoardIndex` in `_WhiteboardPageState`

### 3D — Gesture Handler Extraction

- [ ] **3.9** Create `CanvasGestureHandler` widget — translates raw gestures to BLoC events
  - Extract `_DragMode` state machine
  - Extract hit-testing into `HitTestService`
  - Extract anchor snapping logic
- [ ] **3.10** Create `ShortcutsHandler` widget — translates keyboard shortcuts to BLoC events

### 3E — Wire UI to BLoCs

- [ ] **3.11** Rewrite `WhiteboardPage` as a thin shell:
  - `MultiBlocProvider` at the top
  - `BlocBuilder` / `BlocSelector` for granular rebuilds
  - Delegate ALL logic to BLoC events
- [ ] **3.12** Update `BoardPainter` to read from `CanvasState` instead of raw fields
- [ ] **3.13** Update `ElementRenderer` — replace static service calls with injected dependencies
- [ ] **3.14** Verify `WhiteboardPage` is under 300 lines

**Acceptance Criteria:**  
✅ `_WhiteboardPageState` reduced from 2,445 lines to < 300 lines  
✅ ALL business logic lives in BLoCs/Cubits  
✅ No `setState` calls remain in `WhiteboardPage`  
✅ Gesture handling is a separate widget  
✅ Keyboard shortcuts are a separate widget  
✅ App functionality identical to `main` branch

---

## Phase 4 — Feature Extraction & UI Cleanup

> **Effort:** 2–3 days | **Risk:** Low  
> **Goal:** Extract remaining features into self-contained feature modules. Fix prop drilling.

### 4A — Toolbar Feature

- [ ] **4.1** Create `PropertiesCubit` — reads from `CanvasBloc` selected elements, emits property panel state
- [ ] **4.2** Refactor `PropertiesPanel` — read from `PropertiesCubit` via `BlocBuilder` instead of 42 constructor params
- [ ] **4.3** Refactor `MainToolbar` — read from `ToolCubit` via `BlocBuilder` instead of 19 constructor params

### 4B — Export Feature

- [ ] **4.4** Create `ExportCubit` — handles export format selection, progress, and execution
- [ ] **4.5** Move `ExportDialog` to `features/export/presentation/widgets/`
- [ ] **4.6** Split `ExportService` static facade into individual service classes (`SvgExportService`, `PdfExportService`, `PngExportService`, `JsonExportService`)

### 4C — Comments Feature

- [ ] **4.7** Create `CommentsCubit` — CRUD for comments/replies, resolve/unresolve
- [ ] **4.8** Move comment widgets to `features/comments/presentation/widgets/`

### 4D — Layers Feature

- [ ] **4.9** Create `LayersCubit` — z-order, lock, visibility, rename, search
- [ ] **4.10** Refactor `LayersSidebar` to read from `LayersCubit`

### 4E — Other Features

- [ ] **4.11** Create `PresentationCubit` — slide ordering, navigation, present/exit
- [ ] **4.12** Move import-related code (`ExcalidrawImportService`, `ImageService`, `TemplatePicker`) to `features/import/`

**Acceptance Criteria:**  
✅ Zero prop-drilling chains longer than 3 params  
✅ Each feature is a self-contained directory with its own BLoC/Cubit  
✅ `PropertiesPanel` reads state from Cubit, not 42 constructor params  
✅ `MainToolbar` reads state from Cubit, not 19 constructor params  
✅ App functionality identical to `main` branch

---

## Phase 5 — Testing & Validation

> **Effort:** 2–3 days | **Risk:** Low  
> **Goal:** Comprehensive test coverage across all layers.

### 5A — BLoC Tests (highest priority)

- [ ] **5.1** `CanvasBloc` tests — element CRUD, selection, move, resize, rotate, group, undo/redo
- [ ] **5.2** `ToolCubit` tests — tool selection, property changes
- [ ] **5.3** `BoardsCubit` tests — add/remove/switch/duplicate boards
- [ ] **5.4** `CommentsCubit` tests — CRUD, resolve, threading
- [ ] **5.5** `LayersCubit` tests — z-order, lock, visibility
- [ ] **5.6** `ExportCubit` tests — format selection, execution
- [ ] **5.7** `PresentationCubit` tests — slide navigation

### 5B — Repository Tests

- [ ] **5.8** `SharedPrefsBoardRepository` tests — save/load/list/delete with mocked SharedPreferences

### 5C — Widget & Integration Tests

- [ ] **5.9** Widget tests for `WhiteboardPage`, `MainToolbar`, `PropertiesPanel` with mocked BLoCs
- [ ] **5.10** Integration test: create element → move → undo → redo → export → verify

**Acceptance Criteria:**  
✅ All BLoC tests pass with `bloc_test`  
✅ All repository tests pass with `mocktail` mocks  
✅ Widget tests cover key UI interactions  
✅ At least one full integration test exists  
✅ All existing tests still pass  
✅ `flutter test` passes with zero failures

---

## File Migration Map

Reference for where each current file moves in the new structure:

| Current Path | New Path | Phase |
|---|---|---|
| `lib/models/board_element.dart` | `lib/features/canvas/domain/models/board_element.dart` | 1 |
| `lib/models/board_document.dart` | `lib/features/canvas/domain/models/board_document.dart` | 1 |
| `lib/models/board_comment.dart` | `lib/features/comments/domain/models/board_comment.dart` | 1 |
| `lib/models/tool.dart` | `lib/features/canvas/domain/models/tool.dart` | 1 |
| `lib/models/shape_type.dart` | `lib/features/canvas/domain/models/shape_type.dart` | 1 |
| `lib/models/snap_guide.dart` | `lib/features/canvas/domain/models/snap_guide.dart` | 1 |
| `lib/models/connector_style.dart` | `lib/features/canvas/domain/models/connector_style.dart` | 1 |
| `lib/models/connection_binding.dart` | `lib/features/canvas/domain/models/connection_binding.dart` | 1 |
| `lib/models/stroke_fill_style.dart` | `lib/features/canvas/domain/models/stroke_fill_style.dart` | 1 |
| `lib/models/transform_handle.dart` | `lib/features/canvas/domain/models/transform_handle.dart` | 1 |
| `lib/models/board_colors.dart` | `lib/core/constants/board_colors.dart` | 1 |
| `lib/models/templates.dart` | `lib/features/import/data/templates.dart` | 4 |
| `lib/services/storage_service.dart` | `lib/features/canvas/data/repositories/shared_prefs_board_repository.dart` | 2 |
| `lib/services/export_service.dart` | `lib/features/export/data/services/` (split) | 2 |
| `lib/services/svg_export_service.dart` | `lib/features/export/data/services/svg_export_service.dart` | 2 |
| `lib/services/pdf_export_service.dart` | `lib/features/export/data/services/pdf_export_service.dart` | 2 |
| `lib/services/clipboard_service.dart` | `lib/features/clipboard/data/services/clipboard_service.dart` | 2 |
| `lib/services/mermaid_parser_service.dart` | `lib/features/clipboard/data/services/mermaid_service.dart` | 2 |
| `lib/services/connector_routing_service.dart` | `lib/features/canvas/data/services/connector_routing_service.dart` | 2 |
| `lib/services/alignment_service.dart` | `lib/features/canvas/data/services/alignment_service.dart` | 2 |
| `lib/services/shape_recognition_service.dart` | `lib/features/canvas/data/services/shape_recognition_service.dart` | 2 |
| `lib/services/history_manager.dart` | `lib/features/canvas/data/services/history_manager.dart` | 3 |
| `lib/services/image_service.dart` | `lib/features/import/data/services/image_service.dart` | 4 |
| `lib/services/excalidraw_import_service.dart` | `lib/features/import/data/services/excalidraw_import_service.dart` | 4 |
| `lib/services/markdown_text_service.dart` | `lib/features/canvas/data/services/markdown_text_service.dart` | 2 |
| `lib/services/syntax_highlighter_service.dart` | `lib/features/canvas/data/services/syntax_highlighter_service.dart` | 2 |
| `lib/ui/whiteboard_page.dart` | `lib/features/canvas/presentation/pages/whiteboard_page.dart` | 3 |
| `lib/ui/toolbar/main_toolbar.dart` | `lib/features/toolbar/presentation/widgets/main_toolbar.dart` | 4 |
| `lib/ui/toolbar/properties_panel.dart` | `lib/features/toolbar/presentation/widgets/properties_panel.dart` | 4 |
| `lib/ui/toolbar/board_tabs_bar.dart` | `lib/features/canvas/presentation/widgets/board_tabs_bar.dart` | 3 |
| `lib/ui/inline_text_editor.dart` | `lib/features/canvas/presentation/widgets/inline_text_editor.dart` | 3 |
| `lib/ui/presentation/presentation_overlay.dart` | `lib/features/presentation_mode/presentation/widgets/presentation_overlay.dart` | 4 |
| `lib/ui/widgets/export_dialog.dart` | `lib/features/export/presentation/widgets/export_dialog.dart` | 4 |
| `lib/ui/widgets/mermaid_dialog.dart` | `lib/features/clipboard/presentation/widgets/mermaid_dialog.dart` | 4 |
| `lib/ui/widgets/layers_sidebar.dart` | `lib/features/layers/presentation/widgets/layers_sidebar.dart` | 4 |
| `lib/ui/widgets/minimap_widget.dart` | `lib/features/canvas/presentation/widgets/minimap_widget.dart` | 3 |
| `lib/ui/widgets/zoom_controls.dart` | `lib/features/canvas/presentation/widgets/zoom_controls.dart` | 3 |
| `lib/ui/widgets/empty_canvas_guide.dart` | `lib/features/canvas/presentation/widgets/empty_canvas_guide.dart` | 3 |
| `lib/ui/widgets/shortcuts_help_dialog.dart` | `lib/features/canvas/presentation/widgets/shortcuts_help_dialog.dart` | 3 |
| `lib/ui/widgets/template_picker_dialog.dart` | `lib/features/import/presentation/widgets/template_picker_dialog.dart` | 4 |
| `lib/ui/widgets/theme_toggle.dart` | `lib/core/widgets/theme_toggle.dart` | 3 |
| `lib/ui/widgets/comment_card_popover.dart` | `lib/features/comments/presentation/widgets/comment_card_popover.dart` | 4 |
| `lib/ui/widgets/comment_pin_badge.dart` | `lib/features/comments/presentation/widgets/comment_pin_badge.dart` | 4 |
| `lib/painters/board_painter.dart` | `lib/features/canvas/presentation/painters/board_painter.dart` | 3 |
| `lib/painters/element_renderer.dart` | `lib/features/canvas/presentation/painters/element_renderer.dart` | 3 |
| `lib/painters/grid_painter.dart` | `lib/features/canvas/presentation/painters/grid_painter.dart` | 3 |
| `lib/painters/selection_painter.dart` | `lib/features/canvas/presentation/painters/selection_painter.dart` | 3 |
| `lib/painters/laser_painter.dart` | `lib/features/canvas/presentation/painters/laser_painter.dart` | 3 |
| `lib/painters/rough_sketch_painter.dart` | `lib/features/canvas/presentation/painters/rough_sketch_painter.dart` | 3 |
| `lib/painters/connection_anchor_painter.dart` | `lib/features/canvas/presentation/painters/connection_anchor_painter.dart` | 3 |

---

## Rules

1. **Each phase must leave the app in a working state** — no broken intermediate commits
2. **Commit after each completed task** with a descriptive message
3. **Run `flutter test` after every task** — no regressions
4. **No big-bang rewrites** — migrate incrementally
5. **Keep backward compatibility** for saved board data during Phase 1
