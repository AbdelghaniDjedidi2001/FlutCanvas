# 🎨 FlutCanvas

> An infinite virtual whiteboard, diagramming, and sketching canvas built with Flutter.

FlutCanvas is a modern, lightweight, and feature-rich digital whiteboard built using Flutter and Dart. Designed for visual thinkers, developers, teams, and presenters, FlutCanvas combines freehand sketching, geometric diagramming, smart magnetic connectors, presentation frames, and template generation on an infinite canvas.

---

## ✨ Features

### 🖌️ Drawing & Diagramming Tools
- **Shapes & Geometrics**: Rectangles, Rounded Rectangles, Ellipses, Diamonds, Triangles, Stars, Lines, and Arrows.
- **Freehand & Annotation**: Smooth Pen tool and semi-transparent Highlighter for natural sketching.
- **Sticky Notes & Text**: Rich inline text editing with customizable fonts, colors, and quick-note cards.
- **Images**: Pick, import, and embed images directly onto the canvas.
- **Styling Options**: 
  - Switch between **Clean** (vector) and **Rough / Sketch** (hand-drawn Excalidraw-like aesthetic).
  - Customizable stroke width, stroke styles (solid, dashed, dotted), and fill styles (none, semi-transparent, solid).
  - Full opacity and rotation control.

### 🔗 Smart Magnetic Connectors
- Automatic anchor point detection (top, bottom, left, right) on shapes.
- Connectors dynamically adapt and follow connected nodes when moved or resized.

### 📑 Multi-Board Workspace & Persistence
- **Board Tabs**: Create, rename, duplicate, and switch between multiple independent whiteboard tabs.
- **Auto-Save**: Automatic debounced state persistence via local storage (`shared_preferences`).
- **History**: Full multi-level Undo / Redo (`Ctrl/Cmd + Z`, `Ctrl/Cmd + Y`).

### 📐 Infinite Canvas & Navigation
- **Smooth Navigation**: Pan freely with middle-click, Space + Drag, or the Hand tool (`H`).
- **Zoom Range**: Zoom smoothly from 10% to 800% with mouse wheel or on-screen controls.
- **Minimap**: Interactive minimap preview for instant spatial awareness.
- **Grid Snapping & Smart Guides**: Toggleable 24px coordinate grid snapping (`G`) and real-time **Dynamic Magnetic Snapping Guidelines** when moving objects.
- **Align & Distribute**: One-click alignment (Left, Center, Right, Top, Middle, Bottom) and equal spacing distribution (Horizontally and Vertically) for multi-selection.

### 📦 Pre-Built Diagram Templates
Instant one-click diagram generators for rapid brainstorming:
- 🔀 **Flowcharts**: Process logic, decision diamonds, and directional connectors.
- 🧠 **Mind Maps**: Central concept branching into subtopics.
- 📋 **Kanban Boards**: To-Do, In-Progress, and Done columns with sticky notes.
- ☁️ **System Architecture**: Client, API Gateway, Backend Services, and Database layouts.

### 🎭 Presentation Mode & Laser Pointer
- **Slide Frames (`F`)**: Define presentation frames and slide boundaries on your canvas.
- **Presentation Viewer (`F5`)**: Step sequentially through slides with animated zoom-to-fit camera framing.
- **Laser Pointer (`K`)**: Ephemeral glowing laser trail with auto-decay for live walkthroughs and demos.

### ☁️ Cloud & Architecture Icon Library (`Alt + I`)
- **40+ Curated Components**: Cloud & Compute (AWS Lambda, EC2, Cloud Run, Azure Functions), Databases (PostgreSQL, MySQL, Redis, MongoDB, Cassandra, S3, DynamoDB), Messaging & Networking (Kafka, RabbitMQ, GraphQL, NGINX, Cloudflare, Webhooks), DevOps (Docker, Kubernetes, Jenkins, GitLab, GitHub, Terraform), and Client Devices (Web, Mobile, Desktop, IoT, IAM).
- **Searchable Slide-Out Drawer**: Instant real-time search, category chips, and one-click insertion onto the infinite canvas.
- **First-Class Architecture Nodes**: Rendered with brand color badges, vector icons, auto-contrast backgrounds, and editable labels.
- **Export & CLI Integration**: Fully supported in Vector SVG export, directional Mermaid export, and Spotlight Command Palette (`Cmd + K`).

### 🚀 Import & Export
- **High-Res PNG Export**: Render the entire board or selected areas at high resolution (with transparent or solid background options).
- **Vector SVG & Presentation PDF**: High-quality scalable vector SVG and multi-page PDF presentation deck exports.
- **Bidirectional Mermaid Flowcharts**: Parse Mermaid markdown into editable canvas elements and export visual diagrams back to clean Mermaid flowchart syntax (`.mmd`).
- **JSON Serialization**: Export boards to formatted JSON files or import existing diagrams.

### 🔍 Command Palette & Spotlight (`Cmd + K`)
- Fast keyboard-driven command runner to switch tools, invoke actions, toggle theme/grid/layers/icons, insert architecture components directly, and search on-canvas text with instant camera zoom-and-focus.

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| **`Ctrl/Cmd + K`** | **Command Palette / Spotlight Search** |
| **`Alt + I`** | **Toggle Cloud & Tech Icon Library** |
| **`Alt + L`** | Toggle Layers & Object Tree Sidebar |
| **`V`** | Select / Transform Tool |
| **`H`** / **`Space + Drag`** | Hand / Pan Canvas |
| **`R`** / **`Shift + R`** | Rectangle / Rounded Box |
| **`O`** | Ellipse |
| **`D`** | Diamond |
| **`Shift + T`** | Triangle |
| **`L`** / **`A`** | Line / Arrow Connector |
| **`P`** / **`M`** | Pen / Highlighter |
| **`T`** / **`N`** | Text / Sticky Note |
| **`E`** | Eraser |
| **`K`** | Laser Pointer |
| **`F`** | Frame / Slide |
| **`I`** | Insert Image |
| **`G`** | Toggle Grid Snapping |
| **`Ctrl/Cmd + Z`** | Undo |
| **`Ctrl/Cmd + Shift + Z`** / **`Ctrl/Cmd + Y`** | Redo |
| **`Ctrl/Cmd + C`** / **`Ctrl/Cmd + V`** | Copy / Paste |
| **`Ctrl/Cmd + D`** | Duplicate Selected |
| **`Ctrl/Cmd + G`** / **`Ctrl/Cmd + Shift + G`** | Group / Ungroup |
| **`Ctrl/Cmd + ]`** / **`Ctrl/Cmd + [`** | Bring to Front / Send to Back |
| **`Delete`** / **`Backspace`** | Delete Selected |
| **`F5`** | Start Presentation Mode |
| **`Alt + Shift + D`** | Toggle Light / Dark Theme |

---

## 📁 Project Architecture

```
lib/
├── main.dart                   # Application entry point & theme configuration
├── models/
│   ├── board_colors.dart       # Palette & color presets
│   ├── board_document.dart     # Multi-board data document model
│   ├── board_element.dart      # Core element representation & hit-testing
│   ├── connection_binding.dart # Anchor points & dynamic connector bindings
│   ├── shape_type.dart         # Shape enumeration & element types
│   ├── stroke_fill_style.dart  # Stroke, fill, and draw style definitions
│   ├── templates.dart          # Pre-built diagram templates (Flowchart, Mindmap, etc.)
│   ├── tool.dart               # Toolbar tools & shortcut definitions
│   └── transform_handle.dart   # Hit-testing for resize & rotation handles
├── painters/
│   ├── board_painter.dart      # Main CustomPainter orchestrating layers
│   ├── connection_anchor_painter.dart # Dynamic anchor highlight rendering
│   ├── element_renderer.dart   # Element drawing logic
│   ├── grid_painter.dart       # Background grid pattern renderer
│   ├── laser_painter.dart      # Glowing laser trail rendering
│   ├── rough_sketch_painter.dart # Hand-drawn / sketchy stroke generator
│   └── selection_painter.dart  # Multi-select bounding box & transform handles
├── services/
│   ├── clipboard_service.dart  # Element clipboard copy/paste logic
│   ├── export_service.dart     # High-res PNG & JSON export/import
│   ├── history_manager.dart    # Undo/Redo stack manager
│   ├── image_service.dart      # Base64 image picking & conversion
│   └── storage_service.dart    # Local workspace persistence
└── ui/
    ├── inline_text_editor.dart # On-canvas text & sticky note overlay editor
    ├── presentation/           # Presentation mode UI overlay & controls
    ├── toolbar/                # Main toolbar, properties drawer & board tabs
    ├── widgets/                # Minimap, zoom controls, template picker, export dialog
    └── whiteboard_page.dart    # Main interactive whiteboard controller & gestures
```

---

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.13.3`)
- [Dart SDK](https://dart.dev/get-dart) (`>=3.13.3`)

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/flutcanvas.git
   cd flutcanvas
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on your target platform:**
   - **Web:**
     ```bash
     flutter run -d chrome
     ```
   - **macOS Desktop:**
     ```bash
     flutter run -d macos
     ```
   - **Windows / Linux:**
     ```bash
     flutter run -d windows # or linux
     ```

4. **Build for production:**
   ```bash
   flutter build web --release
   ```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).