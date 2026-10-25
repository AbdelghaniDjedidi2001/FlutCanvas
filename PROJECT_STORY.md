# 🎨 Building FlutCanvas: An Infinite AI Whiteboard, LAN Broadcaster & Diagramming Studio Built with Flutter

> *How we built an extensible, privacy-first infinite whiteboard in Flutter—from a monolithic prototype to Clean Architecture, Gemini-powered diagramming, zero-cloud live broadcasting, and smart shape recognition.*

---

## 💡 The Genesis: Why Build Another Whiteboard?

Digital whiteboards have become the modern canvas for visual thinkers: we use them for system architecture diagrams, quick wireframes, sprint retrospectives, mind maps, and technical presentations. 

However, most mainstream solutions (Miro, Mural, Lucidchart) come with noticeable trade-offs:
- **Cloud Lock-in & Privacy Risks**: Every stroke and diagram is stored on external corporate cloud servers. For proprietary engineering designs and confidential team discussions, this is often a dealbreaker.
- **Heavyweight Web Apps**: Many browser-based canvas tools consume gigabytes of RAM and stutter when diagrams grow complex.
- **Subscription Paywalls & Team Limits**: Simple features like exporting scalable vector SVGs or having multiple boards frequently hide behind expensive enterprise tiers.

We asked ourselves: **Can we build a fast, lightweight, 100% offline-first whiteboard in Flutter that runs natively on macOS, Windows, Linux, and Web—combining the organic feel of freehand sketching with the precision of technical architecture modeling, local network live streaming, and embedded AI?**

That vision became **FlutCanvas**.

---

## ✨ What FlutCanvas Can Do

FlutCanvas is packed with features designed for visual thinkers, developers, and presenters:

```
┌────────────────────────────────────────────────────────────────────────┐
│                              FLUTCANVAS                                │
├────────────────────────────────────────────────────────────────────────┤
│  🤖 AI Text-to-Diagram   │ Prompt to Canvas with Gemini 3.8 Flash      │
│  ✍️ Shape Auto-Snapping  │ Draw messy strokes → Snap to crisp vectors  │
│  📡 LAN Live Broadcast   │ Zero-cloud presentation sync over local Wi-Fi│
│  ☁️ Architecture Library │ 40+ AWS, GCP, Azure, K8s & DevOps icons     │
│  🔗 Magnetic Connectors  │ Auto-routing straight, elbow & Bézier lines │
│  🎭 Presentation Mode    │ Slide frames with animated camera zoom      │
│  🌓 Contrast Themes      │ Circular reveal light/dark mode animation   │
│  🚀 Multi-Format Export  │ Scalable SVG, Presentation PDF, Mermaid, PNG│
└────────────────────────────────────────────────────────────────────────┘
```

### 1. 🤖 AI Text-to-Diagram Generator (`Ctrl/Cmd + Shift + A`)
Instead of manually dragging dozens of boxes, you can describe a system in plain English:
> *"Create a microservices architecture with an API gateway, auth service, payment processing queue with RabbitMQ, and PostgreSQL database."*

FlutCanvas connects directly to **Google Gemini** (defaulting to `gemini-3.8-flash` with an automated fallback chain across models) or browser-native **`window.ai`**. 
- **Real-Time Token Streaming HUD**: Rather than showing an opaque spinner, a live terminal HUD streams raw tokens and reports each phase: *Prompting → Streaming → Parsing → Canvas Layout*.
- **Collision-Free Auto-Layout**: The layout engine dynamically calculates rank spacing and node boundaries, eliminating subgraph overlaps and clipped labels.

### 2. ✍️ Freehand Drawing with Smart Shape Recognition
- Switch between **Clean** vector paths and **Rough / Sketch** hand-drawn aesthetics (inspired by Excalidraw).
- High-vibrance pen and highlighter brushes with dark/light mode contrast protection.
- **Shape Auto-Correction**: Draw a messy circle, rough rectangle, diamond, triangle, star, or arrow with the pen tool and hold still for ~380ms—FlutCanvas instantly classifies the gesture and snaps it into a mathematically perfect geometric shape.

### 3. 📡 Zero-Cloud LAN Live Broadcast & Presenter Sync (`Alt + B`)
Presenting in a conference room, classroom, or team huddle without reliable internet?
- **Embedded Server**: FlutCanvas hosts a native HTTP and WebSocket server directly on your machine (`dart:io` on port 4040).
- **Self-Contained Audience Viewer**: Colleagues simply scan an on-screen QR code or open `http://<your-ip>:4040` on their phone, tablet, or laptop. No apps or cloud accounts required.
- **Smooth Camera LERP & Laser Sync**: Audience screens automatically follow your pan, zoom, and slide transitions with interpolated camera smoothing, complete with real-time glowing laser pointer trails (`K`).

### 4. ☁️ Cloud & Tech Architecture Icon Library (`Alt + I`)
- **40+ Curated Components**: Cloud services (AWS Lambda, EC2, Cloud Run), Databases (PostgreSQL, Redis, MongoDB, DynamoDB), Messaging & DevOps (Kafka, Docker, Kubernetes, NGINX, Terraform).
- **Vector & Mermaid Interoperability**: Every icon is rendered with brand color badges and exports seamlessly to vector SVG or Mermaid flowchart markdown.

### 5. 📊 Real-World Productivity Tools
- **Tables & Grids**: Tabular data matrices with row/column expansion and in-cell editing.
- **Code Blocks (`C`)**: Syntax-highlighted code cards for over 30 languages.
- **Review Pins & Comments**: Drop threaded discussion notes directly onto canvas regions.
- **Spotlight Command Palette (`Ctrl/Cmd + K`)**: Keyboard-driven navigation to search text on the board, switch tools, or run actions instantly.

---

## 🛠️ The Architecture Journey: What Happened Behind the Scenes

Building an infinite canvas is deceptively complex. What began as a rapid prototype quickly hit architectural bottlenecks as features multiplied. Here is how we evolved the codebase.

### The "Before": The Monolithic God Widget
In early prototypes, almost all whiteboard logic lived inside a single stateful widget:
- **`_WhiteboardPageState`**: Over 2,400 lines of code managing 40+ mutable state variables.
- **God Model (`BoardElement`)**: A 560-line mutable class mixing styling, geometry, JSON serialization, and hit-testing.
- **UI Stuttering**: Calling `setState()` on high-frequency mouse movements caused unnecessary rebuilds across toolbar buttons, board tabs, and layers.

### The Refactoring: Feature-First Clean Architecture + BLoC
To support advanced features like live broadcasting and AI streaming without destabilizing the core canvas, we executed a complete architectural migration:

```
lib/
├── core/                           # Foundational cross-cutting utilities
│   ├── constants/                  # Board colors & palette themes
│   ├── di/                         # GetIt + Injectable bootstrap
│   ├── services/                   # Clipboard, media, platform downloaders
│   └── theme/                      # Contrast-aware AppTheme & reveal widgets
│
└── features/                       # Self-contained business capability modules
    ├── ai_diagram/                 # Gemini API, prompt templates & streaming HUD
    ├── broadcast/                  # Native HTTP/WS server & audience web viewer
    ├── canvas/                     # Infinite viewport, tools, painters & BLoC
    ├── comments/                   # Threaded pins & popovers
    ├── export/                     # SVG, PDF, PNG, Mermaid & JSON export
    ├── layers/                     # Z-order hierarchy, locking & visibility
    └── toolbar/                    # Main toolbar & responsive properties panel
```

#### 1. Two-Tier Rendering Loop
We decoupled high-frequency transient interactions from committed board state:
- **60/120 FPS Interaction Layer**: Panning, zooming, transform handle manipulation, and laser trails bypass BLoC entirely during active gestures. They update high-speed `ChangeNotifier` controllers (`CanvasViewportController` and `CanvasInteractionController`) listened to only by dedicated `CustomPainter` widgets.
- **Committed Document State**: Only when a gesture finishes (pointer up) is an immutable `CanvasEvent` dispatched to `CanvasBloc`, adding an entry to the command history stack for effortless multi-level Undo/Redo.

#### 2. Immutable Domain Models with Freezed
Every entity (`BoardElement`, `BoardDocument`, `ConnectionBinding`, `SnapGuide`) was converted to `@freezed` sealed unions. This eliminated accidental in-place mutations and gave us pattern matching for type-safe rendering.

#### 3. Command Pattern for Mutations
Canvas modifications (moving, resizing, restyling, grouping) are encapsulated into `CanvasCommand` objects with symmetrical `execute()` and `undo()` operations, keeping history clean and testable.

---

## 🧠 Technical Deep Dives: Challenges & Solutions

### 1. Viewport Coordinate Transformations
An infinite canvas requires translating between **Screen Coordinates** (pixels on the user's physical monitor) and **World Coordinates** (arbitrary floating-point units in the infinite canvas space):

$$\text{World Position} = \frac{\text{Screen Position} - \text{Pan Offset}}{\text{Zoom Scale}}$$

By centralizing these calculations in extension methods and matrix helpers, features like grid snapping (24px grid) and magnetic alignment guidelines compute bounding-box snapping purely in world space before painting.

### 2. Zero-Cloud Broadcast over Local Sockets
To achieve 100% offline broadcasting without third-party services:
- On desktop platforms (macOS, Windows, Linux), we use `dart:io` `HttpServer.bind(InternetAddress.anyIPv4, 4040)` and `WebSocketTransformer.upgrade(request)`.
- The server serves a single, inlined HTML/JavaScript web application containing an interactive SVG canvas renderer.
- Whenever the presenter moves their camera or laser, a lightweight binary/JSON packet is broadcasted to all connected WebSockets.
- On client browsers, an interpolated Linear Interpolation (LERP) loop smooths out network jitter, keeping audience displays fluid and synchronized.

### 3. AI Text-to-Diagram Streaming & Auto-Layout
Generating diagrams with LLMs often fails when the model outputs invalid syntax or clumps nodes on top of each other. We addressed this with a multi-step pipeline:
1. **Strict Prompt Contracts**: System prompts instruct Gemini to output clean, strictly bounded Mermaid diagram definitions.
2. **Real-Time Token Streaming**: We consume chunks as they arrive from Gemini, displaying the raw token stream in a retro HUD window.
3. **Collision-Free Parser**: Our parser decomposes nodes and edges into a directed acyclic graph (DAG), computing layer ranks and horizontal spacing to ensure nodes never overlap even with long descriptive labels.

---

## 📈 Results & Impact

- **Rock-Solid Stability**: Over 120 automated unit, BLoC, and widget tests protecting the geometry, routing, and serialization logic.
- **Zero Cloud Dependence**: Full diagramming, presentation, and broadcasting work in airplane mode or air-gapped environments.
- **Cross-Platform Parity**: Runs smoothly on macOS Desktop (with native entitlements for sockets and networking), Windows, Linux, and modern Web browsers.

---

## 🔮 What's Next?

We're continuing to push the boundaries of what Flutter can do on desktop and web:
- **Multiplayer CRDT Sync**: Peer-to-peer real-time collaborative editing using Yjs/Automerge.
- **Flutter Widget Code Export**: Right-click any visual UI wireframe drawn on canvas and instantly copy working Flutter `Container`, `Row`, `Column`, and `Text` code.
- **LaTeX Math Formula Rendering**: In-line KaTeX equations for scientific and engineering diagrams.

---

## 🚀 Get Involved

FlutCanvas is completely open-source! Check out the repository, run it locally, and build your next architecture diagram or presentation on it:

- 💻 **GitHub Repository**: [FlutCanvas on GitHub](https://github.com/AbdelghaniDjedidi2001/FlutCanvas)
- 🤝 **Contributions**: We welcome new tools, shape renderers, and ideas—check out `CONTRIBUTING.md`!
- 📄 **License**: MIT
