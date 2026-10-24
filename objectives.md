# FlutCanvas — Project Objectives & Roadmap

This document outlines the architectural objectives, completed milestones, and future roadmap for **FlutCanvas**.

---

## 🎯 Project Vision

To build a high-performance, private, extensible, and beautifully crafted virtual whiteboard, diagramming canvas, and visual presentation suite with Flutter. FlutCanvas serves visual thinkers, software architects, engineering teams, and educators with first-class local-first guarantees, AI-assisted diagram generation, and zero-cloud local network broadcasting.

---

## ✅ Completed & Shipped Milestones

### 1. 🤖 AI-Powered Canvas Superpowers
- [x] **AI Text-to-Diagram Generation**: Natural language prompt bar (`Ctrl/Cmd + Shift + A`) powering instant flowchart, cloud architecture, and sequence diagram creation.
- [x] **Multi-Model Support with Automatic Fallback**: Google Gemini (`gemini-3.8-flash`, `gemini-2.5-flash`, `gemini-2.0-flash`, `gemini-1.5-flash`, `gemini-1.5-pro`) and in-browser native `window.ai`.
- [x] **Real-Time Token Streaming HUD**: Live streaming token preview with interactive terminal output and step-by-step progress tracking.
- [x] **Collision-Free Auto-Layout**: Expanded rank spacing and node separation preventing overlaps on complex subgraphs and long labels.
- [x] **Handwritten Sketch-to-Shape Auto-Recognition**: Natural hand-drawn sketches (circles, rectangles, rounded boxes, triangles, diamonds, stars, arrows) automatically classified and snapped to crisp vector shapes when held for 380ms.

### 2. ⚡ Real-Time Collaboration & Presenter Sync
- [x] **Zero-Cloud LAN Live Broadcast (`Alt + B`)**: Built-in HTTP and WebSocket server running locally on port 4040 (automatic fallback to 4041–4049). Hosted via desktop apps (**macOS, Windows, Linux**).
- [x] **Self-Contained Offline Web Viewer**: Zero external CDN scripts or dependencies; audience connects from **any device** (iOS, Android, macOS, Windows, Linux) via local Wi-Fi / hotspot browser.
- [x] **Scan-to-Join QR Code Modal**: Audience members scan a QR code to immediately connect from phone, tablet, or browser.
- [x] **Follow Presenter Mode**: Audience view smoothly tracks presenter pan, zoom, framing (via interpolated camera LERP), and presentation slide jumps.
- [x] **Laser Pointer Sync (`K`)**: Ephemeral glowing laser pointer trails streamed to all audience screens in real-time.
- [x] **Threaded Canvas Comments & Review Pins**: Pin discussion threads directly to canvas locations or specific shapes.

### 3. 📐 Advanced Diagramming & Visual Tools
- [x] **Smart Magnetic Connectors & Routing**:
  - Automatic 4-way anchor point detection on shapes.
  - Straight, orthogonal / elbow step routing, and curved Bézier connectors.
  - Dynamic follow-through when connected shapes move or resize.
- [x] **Tables & Grid Elements**: Configurable rows, columns, direct cell editing (`Tab`/double-click), and styling controls.
- [x] **Syntax-Highlighted Code Blocks (`C`)**: Code snippet cards supporting syntax highlighting for multiple programming languages.
- [x] **Cloud & Tech Architecture Icon Library (`Alt + I`)**: 40+ curated icons (AWS, GCP, Azure, Kubernetes, Docker, PostgreSQL, Redis, Kafka, etc.) with vector SVG and Mermaid export.
- [x] **Command Palette & Spotlight Search (`Ctrl/Cmd + K`)**: Rapid keyboard command execution, element search, tool switching, and direct camera focus.

### 4. 📄 Import, Export & Interoperability
- [x] **Scalable Vector SVG Export**: High-fidelity vector export preserving paths, fills, and icon badges.
- [x] **Multi-Page Presentation PDF Export**: Export presentation frames (`F`) as sequential PDF slides.
- [x] **High-Res PNG Export**: Render canvas at high DPI with transparent or solid background.
- [x] **Bidirectional Mermaid Flowcharts (`.mmd`)**: Convert Mermaid markdown to visual canvas elements and export visual diagrams back to clean Mermaid syntax.
- [x] **Excalidraw (`.excalidraw`) Import**: Load and inspect Excalidraw JSON documents.
- [x] **Clipboard System Integration**: Copy/paste shapes, text, images, and Mermaid definitions seamlessly.

### 5. 🖊️ Performance, Gestures & Layers
- [x] **Feature-First Clean Architecture + BLoC**: Decoupled domain models (`@freezed`), `CanvasBloc`, `BoardsCubit`, and GetIt + Injectable DI.
- [x] **Layers Sidebar & Element Locking (`Alt + L`)**: Reorder Z-indices, toggle visibility, and lock/unlock elements (`Ctrl/Cmd + L`).
- [x] **Smart Magnetic Snapping Guidelines (`S`) & 24px Grid Snap (`G`)**: Real-time bounding-box alignment guides with equal spacing hints.
- [x] **Animated Dark & Light Mode (`Alt + Shift + D`)**: Circular clip reveal transition with high-contrast text and palette handling.

---

## 🔮 Future Roadmap & Next Milestones

### 1. Cloud-Hosted Multiplayer Sync (CRDT)
- Seamless real-time multiplayer editing across the internet using **Yjs / Automerge CRDTs** or **Supabase Realtime / WebSockets**.
- Live multiplayer cursors with collaborator names and custom cursor colors.

### 2. Export as Flutter Code / Widget Tree
- Right-click a UI wireframe drawn on the canvas and export it directly as Flutter `Container`, `Row`, `Column`, `Stack`, and `Text` widget code!

### 3. LaTeX / Math Equation Rendering
- Render LaTeX mathematical formulas ($E = mc^2$, matrices, integrals) directly inside sticky notes, cards, and text labels using KaTeX.

### 4. Pressure-Sensitive Stylus & Tablet Enhancements
- Utilize `PointerEvent.pressure` and tilt angle for variable calligraphy stroke thickness and palm rejection on iPad / Android tablets.

### 5. Audio / Voice Notes & Live Transcripts
- Attach ephemeral voice memos to review pins or presentation frames for asynchronous design critiques.
