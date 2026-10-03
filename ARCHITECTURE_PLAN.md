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
| 3 | Extract BLoCs from God Widget | ✅ Complete | 14/14 |
| 4 | Feature Extraction & UI Cleanup | ✅ Complete | 12/12 |
| 5 | Testing & Validation | ✅ Complete | 10/10 |
| **Total** | | ✅ **Complete** | **59/59** |

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

- [x] **3.1** Define `CanvasEvent` sealed class (Freezed):
  - `AddElement`, `DeleteElements`, `UpdateElement`
  - `MoveElements`, `ResizeElement`, `RotateElement`
  - `SelectElement`, `ClearSelection`, `MarqueeSelect`
  - `GroupElements`, `UngroupElements`
  - `Undo`, `Redo`
  - `ZoomChanged`, `PanChanged`
  - `ToggleGrid`, `ToggleSmartGuides`
- [x] **3.2** Define `CanvasState` (Freezed):
  - `elements`, `selectedIds`, `scale`, `offset`, `gridEnabled`, `previewElement`, `snapGuides`
- [x] **3.3** Implement `CanvasBloc` with all event handlers
  - Migrate element CRUD logic from `_WhiteboardPageState`
  - Migrate selection logic
  - Migrate grouping logic
  - Integrate `HistoryManager` as internal undo/redo stack
- [x] **3.4** Extract connected-arrow recalculation (`_updateConnectedArrows`) into `CanvasBloc`

### 3B — Tool Cubit

- [x] **3.5** Define `ToolState` (Freezed): `tool`, `color`, `fillColor`, `strokeWidth`, `strokeStyle`, `fillStyle`, `drawStyle`, `fontSize`, `opacity`, `rotation`, `connectorStyle`, `codeLanguage`
- [x] **3.6** Implement `ToolCubit` — simple state emission for tool/property changes

### 3C — Board Management Cubit

- [x] **3.7** Define `BoardsState` (Freezed): `boards`, `activeBoardIndex`
- [x] **3.8** Implement `BoardsCubit` — add/remove/switch/duplicate/rename boards
  - Migrate from `_boards` / `_activeBoardIndex` in `_WhiteboardPageState`

### 3D — Gesture Handler Extraction

- [x] **3.9** Create `CanvasGestureHandler` widget — translates raw gestures to BLoC events
- [x] **3.10** Create `ShortcutsHandler` widget — translates keyboard shortcuts to BLoC events

### 3E — Wire UI to BLoCs

- [x] **3.11** Set up BLoC providers for canvas architecture
- [x] **3.12** Update `BoardPainter` to work with Freezed domain models
- [x] **3.13** Update `ElementRenderer` with clean domain types
- [x] **3.14** Ensure all test suites pass without regression

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

- [x] **4.1** Create `ToolCubit` and `ToolState` managing styling and tool options
- [x] **4.2** Structure toolbar models with clean state emitters
- [x] **4.3** Refactor tool state flow without excessive prop drilling

### 4B — Export Feature

- [x] **4.4** Create `ExportCubit` and `ExportState` for export format configuration and progress
- [x] **4.5** Implement `DefaultExportRepository` integrating PNG, SVG, PDF, and JSON serializers
- [x] **4.6** Split export capabilities into clean repository services

### 4C — Comments Feature

- [x] **4.7** Create `CommentsCubit` and `CommentsState` with CRUD and threading
- [x] **4.8** Structure comments domain and presentation models

### 4D — Layers Feature

- [x] **4.9** Create `LayersCubit` and `LayersState` for sidebar filtering and search
- [x] **4.10** Integrate layer state management with canvas selection

### 4E — Other Features

- [x] **4.11** Create `PresentationCubit` and `PresentationState` for frame/slide presentation
- [x] **4.12** Modularize feature packages under `lib/features/`

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

- [x] **5.1** `CanvasBloc` tests — element CRUD, selection, move, resize, rotate, group, undo/redo
- [x] **5.2** `ToolCubit` tests — tool selection, property changes
- [x] **5.3** `BoardsCubit` tests — add/remove/switch/duplicate boards
- [x] **5.4** `CommentsCubit` tests — CRUD, resolve, threading
- [x] **5.5** `LayersCubit` tests — z-order, lock, visibility
- [x] **5.6** `ExportCubit` tests — format selection, execution
- [x] **5.7** `PresentationCubit` tests — slide navigation

### 5B — Repository Tests

- [x] **5.8** `SharedPrefsBoardRepository` tests — save/load/list/delete with mocked SharedPreferences

### 5C — Widget & Integration Tests

- [x] **5.9** Widget tests for `CanvasShortcutsHandler` and `ToolCubit`
- [x] **5.10** Verification of complete 120-test suite across all features and platforms

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
