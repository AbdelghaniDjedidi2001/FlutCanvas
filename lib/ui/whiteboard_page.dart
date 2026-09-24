import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/board_colors.dart';
import '../models/board_document.dart';
import '../models/board_element.dart';
import '../models/connection_binding.dart';
import '../models/shape_type.dart';
import '../models/stroke_fill_style.dart';
import '../models/templates.dart';
import '../models/tool.dart';
import '../models/transform_handle.dart';
import '../painters/board_painter.dart';
import '../painters/laser_painter.dart';
import '../services/clipboard_service.dart';
import '../services/history_manager.dart';
import '../services/image_service.dart';
import '../services/storage_service.dart';
import 'inline_text_editor.dart';
import 'presentation/presentation_overlay.dart';
import 'toolbar/board_tabs_bar.dart';
import 'toolbar/main_toolbar.dart';
import 'toolbar/properties_panel.dart';
import 'widgets/empty_canvas_guide.dart';
import 'widgets/export_dialog.dart';
import 'widgets/minimap_widget.dart';
import 'widgets/shortcuts_help_dialog.dart';
import 'widgets/template_picker_dialog.dart';
import 'widgets/theme_toggle.dart';
import 'widgets/zoom_controls.dart';

enum _DragMode {
  none,
  drawing,
  moving,
  resizing,
  rotating,
  panning,
  marquee,
  erasing,
  lasering,
}

class WhiteboardPage extends StatefulWidget {
  const WhiteboardPage({super.key, required this.onToggleTheme});

  final void Function(Brightness current) onToggleTheme;

  @override
  State<WhiteboardPage> createState() => _WhiteboardPageState();
}

class _WhiteboardPageState extends State<WhiteboardPage>
    with SingleTickerProviderStateMixin {
  // Multi-board Workspace
  List<BoardDocument> _boards = [
    BoardDocument(id: 'board_1', title: 'Main Board', elements: []),
  ];
  int _activeBoardIndex = 0;

  BoardDocument get _currentBoard => _boards[_activeBoardIndex];
  List<BoardElement> get _elements => _currentBoard.elements;
  set _elements(List<BoardElement> val) => _currentBoard.elements = val;

  Set<String> _selectedIds = {};
  BoardElement? _draft;
  Rect? _marqueeRect;
  List<LaserPoint> _laserTrail = [];
  int _idCounter = 0;

  // History & Timers
  final HistoryManager _history = HistoryManager();
  Timer? _autoSaveTimer;
  Timer? _laserDecayTimer;

  // Active Tool & Properties
  Tool _tool = Tool.rectangle;
  Color _color = kInk;
  Color _fillColor = Colors.transparent;
  double _strokeWidth = 2.5;
  StrokeStyle _strokeStyle = StrokeStyle.solid;
  FillStyle _fillStyle = FillStyle.none;
  DrawStyle _drawStyle = DrawStyle.clean;
  double _fontSize = 22.0;
  double _opacity = 1.0;
  double _rotation = 0.0;
  bool _isPropertiesOpen = false;
  bool _gridSnap = false;

  // Magnetic Connection Anchoring
  BoardElement? _hoveredAnchorElement;
  Offset? _activeAnchorPoint;
  ConnectionBinding? _draftStartBinding;
  ConnectionBinding? _draftEndBinding;

  // Viewport / Camera
  Offset get _pan => _currentBoard.pan;
  set _pan(Offset val) => _currentBoard.pan = val;

  double get _zoom => _currentBoard.zoom;
  set _zoom(double val) => _currentBoard.zoom = val;

  Size _viewSize = Size.zero;

  // Gesture Tracking
  _DragMode _mode = _DragMode.none;
  Offset _lastScreen = Offset.zero;
  Offset _lastWorld = Offset.zero;
  Offset _startWorld = Offset.zero;
  List<BoardElement>? _beforeGestureElements;
  HandleType? _activeResizeHandle;
  Rect? _initialSelectedBounds;
  double _startRotationAngle = 0.0;
  bool _spaceDown = false;
  bool _shiftDown = false;

  // Inline Text Editing
  String? _editingElementId;
  Offset? _editingScreenPos;
  bool _isEditingSticky = false;

  // Presentation Mode
  bool _isPresentationMode = false;
  int _currentSlideIndex = 0;

  final FocusNode _focus = FocusNode();

  List<BoardElement> get _frames =>
      _elements.where((e) => e.type == ShapeType.frame).toList();

  @override
  void initState() {
    super.initState();
    _loadInitialWorkspace();
    _startLaserTicker();
  }

  @override
  void dispose() {
    _focus.dispose();
    _autoSaveTimer?.cancel();
    _laserDecayTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialWorkspace() async {
    final saved = await StorageService.loadWorkspace();
    if (saved != null && saved.boards.isNotEmpty && mounted) {
      setState(() {
        _boards = saved.boards;
        _activeBoardIndex = saved.activeBoardIndex.clamp(0, _boards.length - 1);
      });
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 600), () {
      StorageService.saveWorkspace(
        boards: _boards,
        activeBoardIndex: _activeBoardIndex,
      );
    });
  }

  void _startLaserTicker() {
    _laserDecayTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (_laserTrail.isEmpty) return;
      final now = DateTime.now();
      setState(() {
        _laserTrail = _laserTrail
            .where((p) => now.difference(p.time).inMilliseconds < 1500)
            .toList();
      });
    });
  }

  // ── Multi-Board Workspace Operations ────────────────────────
  void _switchBoard(int index) {
    if (index < 0 || index >= _boards.length || index == _activeBoardIndex) {
      return;
    }
    setState(() {
      _activeBoardIndex = index;
      _selectedIds.clear();
      _draft = null;
      _history.clear();
    });
    _scheduleAutoSave();
  }

  void _createBoard() {
    final newId = 'board_${DateTime.now().millisecondsSinceEpoch}';
    final newBoard = BoardDocument(
      id: newId,
      title: 'Board ${_boards.length + 1}',
      elements: [],
    );
    setState(() {
      _boards.add(newBoard);
      _activeBoardIndex = _boards.length - 1;
      _selectedIds.clear();
      _history.clear();
    });
    _scheduleAutoSave();
  }

  void _renameBoard(int index, String newTitle) {
    setState(() {
      _boards[index].title = newTitle;
    });
    _scheduleAutoSave();
  }

  void _deleteBoard(int index) {
    if (_boards.length <= 1) return;
    setState(() {
      _boards.removeAt(index);
      if (_activeBoardIndex >= _boards.length) {
        _activeBoardIndex = _boards.length - 1;
      }
      _selectedIds.clear();
      _history.clear();
    });
    _scheduleAutoSave();
  }

  void _duplicateBoard(int index) {
    final orig = _boards[index];
    final dupId = 'board_${DateTime.now().millisecondsSinceEpoch}';
    final dupBoard = BoardDocument(
      id: dupId,
      title: '${orig.title} (Copy)',
      elements: orig.elements.map((e) => e.copyWith()).toList(),
      pan: orig.pan,
      zoom: orig.zoom,
    );
    setState(() {
      _boards.insert(index + 1, dupBoard);
      _activeBoardIndex = index + 1;
      _selectedIds.clear();
      _history.clear();
    });
    _scheduleAutoSave();
  }

  // ── Coordinates & Anchors ──────────────────────────────────
  Offset _toWorld(Offset screen) {
    var world = (screen - _pan) / _zoom;
    if (_gridSnap) {
      const snap = 24.0;
      world = Offset(
        (world.dx / snap).roundToDouble() * snap,
        (world.dy / snap).roundToDouble() * snap,
      );
    }
    return world;
  }

  Offset _toScreen(Offset world) => world * _zoom + _pan;

  BoardElement? _hitTestTopmost(Offset world) {
    for (final el in _elements.reversed) {
      if (el.hitTest(world, 6 / _zoom)) return el;
    }
    return null;
  }

  (BoardElement, AnchorPoint, Offset)? _findNearestAnchorAround(Offset world) {
    for (final el in _elements.reversed) {
      if (el.type == ShapeType.line ||
          el.type == ShapeType.arrow ||
          el.type == ShapeType.doubleArrow) {
        continue;
      }
      final anchorMatch = ConnectionBinding.findNearestAnchor(
        el,
        world,
        maxDistance: 28.0 / _zoom,
      );
      if (anchorMatch != null) {
        return (el, anchorMatch.$1, anchorMatch.$2);
      }
    }
    return null;
  }

  Rect? get _currentSelectedBounds {
    if (_selectedIds.isEmpty) return null;
    final selected =
        _elements.where((e) => _selectedIds.contains(e.id)).toList();
    if (selected.isEmpty) return null;
    Rect combined = selected.first.bounds;
    for (var i = 1; i < selected.length; i++) {
      combined = combined.expandToInclude(selected[i].bounds);
    }
    return combined;
  }

  // ── History & Operations ───────────────────────────────────
  void _pushUndo(List<BoardElement> before) {
    _history.push(before);
    _scheduleAutoSave();
  }

  void _undoAction() {
    final prev = _history.undo(_elements);
    if (prev != null) {
      setState(() {
        _elements = prev;
        _selectedIds.clear();
      });
      _scheduleAutoSave();
    }
  }

  void _redoAction() {
    final next = _history.redo(_elements);
    if (next != null) {
      setState(() {
        _elements = next;
        _selectedIds.clear();
      });
      _scheduleAutoSave();
    }
  }

  void _deleteSelected() {
    if (_selectedIds.isEmpty) return;
    setState(() {
      _pushUndo(_elements);
      _elements =
          _elements.where((e) => !_selectedIds.contains(e.id)).toList();
      _selectedIds.clear();
    });
  }

  void _clearBoard() {
    if (_elements.isEmpty) return;
    setState(() {
      _pushUndo(_elements);
      _elements = [];
      _selectedIds.clear();
    });
  }

  void _duplicateSelected() {
    if (_selectedIds.isEmpty) return;
    final selected =
        _elements.where((e) => _selectedIds.contains(e.id)).toList();
    ClipboardService.copy(selected);
    final pasted = ClipboardService.paste(offset: const Offset(20, 20));
    setState(() {
      _pushUndo(_elements);
      _elements = [..._elements, ...pasted];
      _selectedIds = pasted.map((e) => e.id).toSet();
    });
  }

  void _copySelected() {
    if (_selectedIds.isEmpty) return;
    final selected =
        _elements.where((e) => _selectedIds.contains(e.id)).toList();
    ClipboardService.copy(selected);
  }

  void _pasteClipboard() {
    if (!ClipboardService.hasData) return;
    final pasted = ClipboardService.paste();
    setState(() {
      _pushUndo(_elements);
      _elements = [..._elements, ...pasted];
      _selectedIds = pasted.map((e) => e.id).toSet();
    });
  }

  void _groupSelected() {
    if (_selectedIds.length < 2) return;
    final newGroupId = 'grp_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _pushUndo(_elements);
      _elements = [
        for (final el in _elements)
          if (_selectedIds.contains(el.id))
            el.copyWith(groupId: newGroupId)
          else
            el,
      ];
    });
  }

  void _ungroupSelected() {
    if (_selectedIds.isEmpty) return;
    setState(() {
      _pushUndo(_elements);
      _elements = [
        for (final el in _elements)
          if (_selectedIds.contains(el.id))
            el.copyWith(clearGroupId: true)
          else
            el,
      ];
    });
  }

  void _bringToFront() {
    if (_selectedIds.isEmpty) return;
    setState(() {
      _pushUndo(_elements);
      final selected =
          _elements.where((e) => _selectedIds.contains(e.id)).toList();
      final remaining =
          _elements.where((e) => !_selectedIds.contains(e.id)).toList();
      _elements = [...remaining, ...selected];
    });
  }

  void _sendToBack() {
    if (_selectedIds.isEmpty) return;
    setState(() {
      _pushUndo(_elements);
      final selected =
          _elements.where((e) => _selectedIds.contains(e.id)).toList();
      final remaining =
          _elements.where((e) => !_selectedIds.contains(e.id)).toList();
      _elements = [...selected, ...remaining];
    });
  }

  void _alignSelected(String alignment) {
    if (_selectedIds.length < 2) return;
    final bounds = _currentSelectedBounds;
    if (bounds == null) return;

    setState(() {
      _pushUndo(_elements);
      _elements = [
        for (final el in _elements)
          if (!_selectedIds.contains(el.id))
            el
          else
            switch (alignment) {
              'left' => el.translated(Offset(bounds.left - el.bounds.left, 0)),
              'right' =>
                el.translated(Offset(bounds.right - el.bounds.right, 0)),
              'center' => el.translated(
                  Offset(bounds.center.dx - el.bounds.center.dx, 0)),
              'top' => el.translated(Offset(0, bounds.top - el.bounds.top)),
              'bottom' =>
                el.translated(Offset(0, bounds.bottom - el.bounds.bottom)),
              'middle' => el.translated(
                  Offset(0, bounds.center.dy - el.bounds.center.dy)),
              _ => el,
            },
      ];
    });
  }

  void _zoomAt(Offset focal, double newZoom) {
    newZoom = newZoom.clamp(0.1, 8.0);
    final world = (focal - _pan) / _zoom;
    setState(() {
      _zoom = newZoom;
      _pan = focal - world * _zoom;
    });
  }

  // ── Dynamic Connector Follow-Through ────────────────────────
  List<BoardElement> _updateConnectedArrows(List<BoardElement> elements) {
    final elementMap = {for (final e in elements) e.id: e};
    return elements.map((el) {
      if (el.type != ShapeType.line &&
          el.type != ShapeType.arrow &&
          el.type != ShapeType.doubleArrow) {
        return el;
      }

      Offset newStart = el.start;
      Offset newEnd = el.end;

      if (el.startBinding != null &&
          elementMap.containsKey(el.startBinding!.elementId)) {
        final boundEl = elementMap[el.startBinding!.elementId]!;
        newStart = ConnectionBinding.getAnchorPosition(
            boundEl, el.startBinding!.anchor);
      }

      if (el.endBinding != null &&
          elementMap.containsKey(el.endBinding!.elementId)) {
        final boundEl = elementMap[el.endBinding!.elementId]!;
        newEnd =
            ConnectionBinding.getAnchorPosition(boundEl, el.endBinding!.anchor);
      }

      if (newStart != el.start || newEnd != el.end) {
        return el.copyWith(start: newStart, end: newEnd);
      }
      return el;
    }).toList();
  }

  // ── Styling Updates ────────────────────────────────────────
  void _updateColor(Color c) {
    setState(() {
      _color = c;
      if (_selectedIds.isNotEmpty) {
        _pushUndo(_elements);
        _elements = [
          for (final el in _elements)
            _selectedIds.contains(el.id) ? el.copyWith(color: c) : el,
        ];
      }
    });
  }

  void _updateFillColor(Color c) {
    setState(() {
      _fillColor = c;
      if (_selectedIds.isNotEmpty) {
        _pushUndo(_elements);
        _elements = [
          for (final el in _elements)
            _selectedIds.contains(el.id) ? el.copyWith(fillColor: c) : el,
        ];
      }
    });
  }

  void _updateStrokeWidth(double w) {
    setState(() {
      _strokeWidth = w;
      if (_selectedIds.isNotEmpty) {
        _pushUndo(_elements);
        _elements = [
          for (final el in _elements)
            _selectedIds.contains(el.id) ? el.copyWith(strokeWidth: w) : el,
        ];
      }
    });
  }

  void _updateStrokeStyle(StrokeStyle s) {
    setState(() {
      _strokeStyle = s;
      if (_selectedIds.isNotEmpty) {
        _pushUndo(_elements);
        _elements = [
          for (final el in _elements)
            _selectedIds.contains(el.id) ? el.copyWith(strokeStyle: s) : el,
        ];
      }
    });
  }

  void _updateFillStyle(FillStyle f) {
    setState(() {
      _fillStyle = f;
      if (_selectedIds.isNotEmpty) {
        _pushUndo(_elements);
        _elements = [
          for (final el in _elements)
            _selectedIds.contains(el.id) ? el.copyWith(fillStyle: f) : el,
        ];
      }
    });
  }

  void _updateDrawStyle(DrawStyle s) {
    setState(() {
      _drawStyle = s;
      if (_selectedIds.isNotEmpty) {
        _pushUndo(_elements);
        _elements = [
          for (final el in _elements)
            _selectedIds.contains(el.id) ? el.copyWith(drawStyle: s) : el,
        ];
      }
    });
  }

  void _updateFontSize(double s) {
    setState(() {
      _fontSize = s;
      if (_selectedIds.isNotEmpty) {
        _pushUndo(_elements);
        _elements = [
          for (final el in _elements)
            _selectedIds.contains(el.id) ? el.copyWith(fontSize: s) : el,
        ];
      }
    });
  }

  void _updateOpacity(double o) {
    setState(() {
      _opacity = o;
      if (_selectedIds.isNotEmpty) {
        _pushUndo(_elements);
        _elements = [
          for (final el in _elements)
            _selectedIds.contains(el.id) ? el.copyWith(opacity: o) : el,
        ];
      }
    });
  }

  void _updateRotation(double r) {
    setState(() {
      _rotation = r;
      if (_selectedIds.isNotEmpty) {
        _pushUndo(_elements);
        _elements = [
          for (final el in _elements)
            _selectedIds.contains(el.id) ? el.copyWith(rotation: r) : el,
        ];
      }
    });
  }

  // ── Image Upload & Insertion ───────────────────────────────
  Future<void> _handleInsertImage() async {
    final picked = await ImageService.pickImage();
    if (picked != null) {
      final centerWorld = _toWorld(_viewSize.center(Offset.zero));
      const targetWidth = 240.0;
      final targetHeight = (targetWidth / picked.width) * picked.height;

      final newElement = BoardElement(
        id: 'img_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}',
        type: ShapeType.image,
        start: centerWorld - Offset(targetWidth / 2, targetHeight / 2),
        end: centerWorld + Offset(targetWidth / 2, targetHeight / 2),
        color: Colors.transparent,
        imageBase64: picked.base64,
      );

      setState(() {
        _pushUndo(_elements);
        _elements = [..._elements, newElement];
        _selectedIds = {newElement.id};
      });
    }
  }

  // ── Template Insertion ─────────────────────────────────────
  void _handleInsertTemplate(DiagramTemplateType type) {
    final centerWorld = _toWorld(_viewSize.center(Offset.zero));
    final templateElements = TemplateGenerator.generate(type, centerWorld);
    setState(() {
      _pushUndo(_elements);
      _elements = [..._elements, ...templateElements];
      _selectedIds = templateElements.map((e) => e.id).toSet();
    });
  }

  // ── Dialog Helpers ─────────────────────────────────────────
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (_) => ExportDialog(
        elements: _elements,
        colors: BoardColors.of(context),
        onImport: (imported) {
          setState(() {
            _pushUndo(_elements);
            _elements = imported;
            _selectedIds.clear();
          });
        },
      ),
    );
  }

  void _showTemplatesDialog() {
    showDialog(
      context: context,
      builder: (_) => TemplatePickerDialog(
        onSelectTemplate: _handleInsertTemplate,
      ),
    );
  }

  void _showShortcutsHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => const ShortcutsHelpDialog(),
    );
  }

  // ── Presentation Mode ──────────────────────────────────────
  void _startPresentation() {
    if (_frames.isEmpty) return;
    setState(() {
      _isPresentationMode = true;
      _currentSlideIndex = 0;
      _selectedIds.clear();
    });
    _navigateToSlide(0);
  }

  void _navigateToSlide(int index) {
    if (index < 0 || index >= _frames.length) return;
    final frame = _frames[index];
    final bounds = frame.bounds.inflate(40);

    final scaleX = _viewSize.width / bounds.width;
    final scaleY = _viewSize.height / bounds.height;
    final targetZoom = math.min(scaleX, scaleY).clamp(0.2, 3.0);

    final targetPan = Offset(
      _viewSize.width / 2 - bounds.center.dx * targetZoom,
      _viewSize.height / 2 - bounds.center.dy * targetZoom,
    );

    setState(() {
      _currentSlideIndex = index;
      _zoom = targetZoom;
      _pan = targetPan;
    });
  }

  // ── Pointer Input ──────────────────────────────────────────
  void _onPointerDown(PointerDownEvent e) {
    _focus.requestFocus();
    if (e.buttons == kSecondaryMouseButton) return;

    final screen = e.localPosition;
    final world = _toWorld(screen);
    _lastScreen = screen;
    _lastWorld = world;
    _startWorld = world;

    if (e.buttons == kMiddleMouseButton || _tool == Tool.hand || _spaceDown) {
      setState(() => _mode = _DragMode.panning);
      return;
    }

    if (_tool == Tool.laser) {
      setState(() {
        _mode = _DragMode.lasering;
        _laserTrail = [
          ..._laserTrail,
          LaserPoint(point: world, time: DateTime.now())
        ];
      });
      return;
    }

    if (_tool == Tool.eraser) {
      setState(() {
        _mode = _DragMode.erasing;
        _eraseAt(world);
      });
      return;
    }

    if (_tool == Tool.image) {
      _handleInsertImage();
      return;
    }

    if (_tool == Tool.text || _tool == Tool.stickyNote) {
      _openTextEditor(world, screen, isSticky: _tool == Tool.stickyNote);
      return;
    }

    if (_tool == Tool.select) {
      // 1. Check if clicking on transform handles (resize or rotation)
      final selectedBounds = _currentSelectedBounds;
      if (selectedBounds != null) {
        final box = selectedBounds.inflate(8.0 / _zoom);
        final handle = TransformHandle.hitTest(box, world, _zoom);
        if (handle != null) {
          _beforeGestureElements = _elements;
          _activeResizeHandle = handle;
          _initialSelectedBounds = selectedBounds;

          if (handle == HandleType.rotation) {
            final center = selectedBounds.center;
            _startRotationAngle =
                math.atan2(world.dy - center.dy, world.dx - center.dx);
            setState(() => _mode = _DragMode.rotating);
          } else {
            setState(() => _mode = _DragMode.resizing);
          }
          return;
        }
      }

      // 2. Hit test shapes
      final hit = _hitTestTopmost(world);
      if (hit != null) {
        // Group expansion: if hit element is grouped, select all elements in that group
        final targetIds = <String>{};
        if (hit.groupId != null) {
          targetIds.addAll(
            _elements.where((el) => el.groupId == hit.groupId).map((e) => e.id),
          );
        } else {
          targetIds.add(hit.id);
        }

        setState(() {
          if (_shiftDown) {
            if (_selectedIds.containsAll(targetIds)) {
              _selectedIds.removeAll(targetIds);
            } else {
              _selectedIds.addAll(targetIds);
            }
          } else {
            if (!_selectedIds.contains(hit.id)) {
              _selectedIds = targetIds;
            }
          }
          _beforeGestureElements = _elements;
          _mode = _DragMode.moving;
        });
      } else {
        // Clicked empty space -> start marquee
        setState(() {
          if (!_shiftDown) _selectedIds.clear();
          _marqueeRect = Rect.fromPoints(world, world);
          _mode = _DragMode.marquee;
        });
      }
      return;
    }

    // Line / Arrow / Shape / Frame Tool
    final shapeType = _tool.shapeType;
    if (shapeType != null) {
      // Check magnetic anchor start snap for connectors
      var startPos = world;
      _draftStartBinding = null;
      if (shapeType == ShapeType.line ||
          shapeType == ShapeType.arrow ||
          shapeType == ShapeType.doubleArrow) {
        final anchorMatch = _findNearestAnchorAround(world);
        if (anchorMatch != null) {
          startPos = anchorMatch.$3;
          _draftStartBinding = ConnectionBinding(
            elementId: anchorMatch.$1.id,
            anchor: anchorMatch.$2,
          );
        }
      }

      final frameCount = _frames.length + 1;
      setState(() {
        _draft = BoardElement(
          id: 'el_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}',
          type: shapeType,
          start: startPos,
          end: startPos,
          points: (shapeType == ShapeType.pen ||
                  shapeType == ShapeType.highlighter)
              ? [startPos]
              : const [],
          color: _color,
          fillColor: _fillColor,
          strokeWidth: _strokeWidth,
          strokeStyle: _strokeStyle,
          fillStyle: _fillStyle,
          drawStyle: _drawStyle,
          fontSize: _fontSize,
          opacity: _opacity,
          startBinding: _draftStartBinding,
          frameTitle: shapeType == ShapeType.frame ? 'Slide $frameCount' : null,
          frameIndex: shapeType == ShapeType.frame ? frameCount : null,
        );
        _mode = _DragMode.drawing;
      });
    }
  }

  void _onPointerMove(PointerMoveEvent e) {
    final screen = e.localPosition;
    final world = _toWorld(screen);

    switch (_mode) {
      case _DragMode.panning:
        setState(() => _pan += screen - _lastScreen);
        break;

      case _DragMode.lasering:
        setState(() {
          _laserTrail = [
            ..._laserTrail,
            LaserPoint(point: world, time: DateTime.now())
          ];
        });
        break;

      case _DragMode.erasing:
        _eraseAt(world);
        break;

      case _DragMode.moving:
        final d = world - _lastWorld;
        _lastWorld = world;
        final movedElements = [
          for (final el in _elements)
            _selectedIds.contains(el.id) ? el.translated(d) : el,
        ];
        setState(() {
          _elements = _updateConnectedArrows(movedElements);
        });
        break;

      case _DragMode.resizing:
        final initialBounds = _initialSelectedBounds;
        final handle = _activeResizeHandle;
        if (initialBounds != null && handle != null) {
          final totalDelta = world - _startWorld;
          final newBounds =
              TransformHandle.resizeRect(initialBounds, handle, totalDelta);

          if (_beforeGestureElements != null) {
            final resizedElements = [
              for (final el in _beforeGestureElements!)
                if (_selectedIds.contains(el.id))
                  el.scaled(initialBounds, newBounds)
                else
                  el,
            ];
            setState(() {
              _elements = _updateConnectedArrows(resizedElements);
            });
          }
        }
        break;

      case _DragMode.rotating:
        final initialBounds = _initialSelectedBounds;
        if (initialBounds != null && _beforeGestureElements != null) {
          final center = initialBounds.center;
          final currentAngle =
              math.atan2(world.dy - center.dy, world.dx - center.dx);
          var deltaAngle = currentAngle - _startRotationAngle;

          // Snap to 15 degrees if shift is pressed
          if (_shiftDown) {
            const step = math.pi / 12; // 15 deg
            deltaAngle = (deltaAngle / step).roundToDouble() * step;
          }

          setState(() {
            _elements = [
              for (final el in _beforeGestureElements!)
                if (_selectedIds.contains(el.id))
                  el.rotated(deltaAngle)
                else
                  el,
            ];
          });
        }
        break;

      case _DragMode.marquee:
        final r = Rect.fromPoints(_startWorld, world);
        final intersecting = _elements
            .where((el) => el.bounds.overlaps(r) || r.contains(el.start))
            .map((e) => e.id)
            .toSet();
        setState(() {
          _marqueeRect = r;
          _selectedIds = _shiftDown
              ? (_selectedIds.union(intersecting))
              : intersecting;
        });
        break;

      case _DragMode.drawing:
        final d = _draft!;
        var endPos = world;
        _draftEndBinding = null;

        // Magnetic connector end snap
        if (d.type == ShapeType.line ||
            d.type == ShapeType.arrow ||
            d.type == ShapeType.doubleArrow) {
          final anchorMatch = _findNearestAnchorAround(world);
          if (anchorMatch != null) {
            endPos = anchorMatch.$3;
            _hoveredAnchorElement = anchorMatch.$1;
            _activeAnchorPoint = anchorMatch.$3;
            _draftEndBinding = ConnectionBinding(
              elementId: anchorMatch.$1.id,
              anchor: anchorMatch.$2,
            );
          } else {
            _hoveredAnchorElement = null;
            _activeAnchorPoint = null;
          }
        }

        setState(() {
          _draft = (d.type == ShapeType.pen ||
                  d.type == ShapeType.highlighter)
              ? d.copyWith(points: [...d.points, world], end: world)
              : d.copyWith(
                  end: endPos,
                  endBinding: _draftEndBinding,
                );
        });
        break;

      case _DragMode.none:
        // When not dragging, check for hover anchors if line or arrow tool is active
        if (_tool == Tool.line || _tool == Tool.arrow) {
          final anchorMatch = _findNearestAnchorAround(world);
          setState(() {
            _hoveredAnchorElement = anchorMatch?.$1;
            _activeAnchorPoint = anchorMatch?.$3;
          });
        }
        break;
    }
    _lastScreen = screen;
  }

  void _onPointerUp(PointerEvent e) {
    setState(() {
      switch (_mode) {
        case _DragMode.drawing:
          final d = _draft!;
          final isFreehand = d.type == ShapeType.pen ||
              d.type == ShapeType.highlighter;
          final valid = isFreehand
              ? d.points.length > 1
              : (d.end - d.start).distance > 4 / _zoom;
          if (valid) {
            _pushUndo(_elements);
            _elements = [..._elements, d];
          }
          _draft = null;
          _hoveredAnchorElement = null;
          _activeAnchorPoint = null;
          break;

        case _DragMode.moving:
        case _DragMode.resizing:
        case _DragMode.rotating:
          final before = _beforeGestureElements;
          if (before != null && !identical(before, _elements)) {
            _pushUndo(before);
          }
          _beforeGestureElements = null;
          _activeResizeHandle = null;
          _initialSelectedBounds = null;
          break;

        case _DragMode.marquee:
          _marqueeRect = null;
          break;

        case _DragMode.erasing:
        case _DragMode.lasering:
        case _DragMode.panning:
        case _DragMode.none:
          break;
      }
      _mode = _DragMode.none;
    });
  }

  void _eraseAt(Offset world) {
    final hit = _hitTestTopmost(world);
    if (hit != null) {
      setState(() {
        _pushUndo(_elements);
        _elements = _elements.where((e) => e.id != hit.id).toList();
        _selectedIds.remove(hit.id);
      });
    }
  }

  void _openTextEditor(Offset world, Offset screen, {required bool isSticky}) {
    final newId = 'el_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';
    final newElement = BoardElement(
      id: newId,
      type: isSticky ? ShapeType.stickyNote : ShapeType.text,
      start: world,
      end: isSticky
          ? world + const Offset(180, 160)
          : world + const Offset(200, 40),
      color: isSticky ? const Color(0xFF212529) : _color,
      fillColor: isSticky ? BoardColors.stickyNoteColors[0] : _fillColor,
      fontSize: isSticky ? 18.0 : _fontSize,
      drawStyle: _drawStyle,
      opacity: 1.0,
      text: '',
    );

    setState(() {
      _elements = [..._elements, newElement];
      _editingElementId = newId;
      _editingScreenPos = screen;
      _isEditingSticky = isSticky;
    });
  }

  void _onDoubleTapDown(TapDownDetails d) {
    final world = _toWorld(d.localPosition);
    final hit = _hitTestTopmost(world);
    if (hit != null &&
        (hit.type == ShapeType.text || hit.type == ShapeType.stickyNote)) {
      setState(() {
        _editingElementId = hit.id;
        _editingScreenPos = _toScreen(hit.start);
        _isEditingSticky = hit.type == ShapeType.stickyNote;
      });
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    // If currently typing in inline text editor, pass all keys to the TextField!
    if (_editingElementId != null) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
        setState(() {
          final el = _elements.firstWhere(
            (e) => e.id == _editingElementId,
            orElse: () => _elements.first,
          );
          if (el.text.trim().isEmpty) {
            _elements = _elements.where((e) => e.id != _editingElementId).toList();
          }
          _editingElementId = null;
          _editingScreenPos = null;
        });
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.space) {
      if (event is KeyDownEvent) setState(() => _spaceDown = true);
      if (event is KeyUpEvent) setState(() => _spaceDown = false);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight) {
      if (event is KeyDownEvent) setState(() => _shiftDown = true);
      if (event is KeyUpEvent) setState(() => _shiftDown = false);
    }

    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final kb = HardwareKeyboard.instance;
    final mod = kb.isControlPressed || kb.isMetaPressed;

    // Presentation Mode Esc / Arrows
    if (_isPresentationMode) {
      if (key == LogicalKeyboardKey.escape) {
        setState(() => _isPresentationMode = false);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.space) {
        if (_currentSlideIndex < _frames.length - 1) {
          _navigateToSlide(_currentSlideIndex + 1);
        }
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowLeft) {
        if (_currentSlideIndex > 0) {
          _navigateToSlide(_currentSlideIndex - 1);
        }
        return KeyEventResult.handled;
      }
    }

    // F5 Presentation start
    if (key == LogicalKeyboardKey.f5) {
      _startPresentation();
      return KeyEventResult.handled;
    }

    // Theme toggle
    if (kb.isAltPressed &&
        kb.isShiftPressed &&
        key == LogicalKeyboardKey.keyD) {
      widget.onToggleTheme(Theme.of(context).brightness);
      return KeyEventResult.handled;
    }

    // Grid snap toggle
    if (key == LogicalKeyboardKey.keyG && !mod) {
      setState(() => _gridSnap = !_gridSnap);
      return KeyEventResult.handled;
    }

    // Help & Shortcuts dialog (?)
    if ((key == LogicalKeyboardKey.slash && kb.isShiftPressed) ||
        key == LogicalKeyboardKey.question) {
      _showShortcutsHelpDialog();
      return KeyEventResult.handled;
    }

    // Open / Import (Cmd/Ctrl + O)
    if (mod && key == LogicalKeyboardKey.keyO) {
      _showExportDialog();
      return KeyEventResult.handled;
    }

    // Export (Cmd/Ctrl + E)
    if (mod && key == LogicalKeyboardKey.keyE) {
      _showExportDialog();
      return KeyEventResult.handled;
    }

    // Undo / Redo
    if (mod && key == LogicalKeyboardKey.keyZ) {
      kb.isShiftPressed ? _redoAction() : _undoAction();
      return KeyEventResult.handled;
    }
    if (mod && key == LogicalKeyboardKey.keyY) {
      _redoAction();
      return KeyEventResult.handled;
    }

    // Clipboard, Grouping & Layering
    if (mod && key == LogicalKeyboardKey.keyC) {
      _copySelected();
      return KeyEventResult.handled;
    }
    if (mod && key == LogicalKeyboardKey.keyV) {
      _pasteClipboard();
      return KeyEventResult.handled;
    }
    if (mod && key == LogicalKeyboardKey.keyD) {
      _duplicateSelected();
      return KeyEventResult.handled;
    }
    if (mod && key == LogicalKeyboardKey.keyG) {
      kb.isShiftPressed ? _ungroupSelected() : _groupSelected();
      return KeyEventResult.handled;
    }
    if (mod && key == LogicalKeyboardKey.bracketRight) {
      _bringToFront();
      return KeyEventResult.handled;
    }
    if (mod && key == LogicalKeyboardKey.bracketLeft) {
      _sendToBack();
      return KeyEventResult.handled;
    }

    // Delete
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      _deleteSelected();
      return KeyEventResult.handled;
    }

    // Tool shortcuts
    if (!mod && ToolExtension.shortcuts.containsKey(key)) {
      final t = ToolExtension.shortcuts[key]!;
      setState(() {
        _tool = t;
        if (t != Tool.select) _selectedIds.clear();
      });
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  MouseCursor get _cursor {
    if (_mode == _DragMode.panning) return SystemMouseCursors.grabbing;
    if (_mode == _DragMode.resizing && _activeResizeHandle != null) {
      return TransformHandle.cursorForHandle(_activeResizeHandle!);
    }
    if (_mode == _DragMode.rotating) return SystemMouseCursors.grab;
    if (_tool == Tool.hand || _spaceDown) return SystemMouseCursors.grab;
    if (_tool == Tool.select) return SystemMouseCursors.basic;
    if (_tool == Tool.eraser) return SystemMouseCursors.cell;
    if (_tool == Tool.laser) return SystemMouseCursors.precise;
    if (_tool == Tool.text) return SystemMouseCursors.text;
    return SystemMouseCursors.precise;
  }

  // ── Build UI ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = BoardColors.of(context);
    final selectedElements =
        _elements.where((e) => _selectedIds.contains(e.id)).toList();

    return Scaffold(
      backgroundColor: colors.background,
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: LayoutBuilder(builder: (context, constraints) {
          _viewSize = constraints.biggest;
          return Stack(
            children: [
              // 1. Canvas Layer
              Positioned.fill(
                child: GestureDetector(
                  onDoubleTapDown: _onDoubleTapDown,
                  child: Listener(
                    onPointerDown: _onPointerDown,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerUp,
                    onPointerCancel: _onPointerUp,
                    onPointerSignal: (e) {
                      if (e is PointerScrollEvent) {
                        final factor = math.exp(-e.scrollDelta.dy / 380);
                        _zoomAt(e.localPosition, _zoom * factor);
                      }
                    },
                    child: MouseRegion(
                      cursor: _cursor,
                      child: CustomPaint(
                        painter: BoardPainter(
                          elements: _elements,
                          draft: _draft,
                          selectedIds: _selectedIds,
                          marqueeRect: _marqueeRect,
                          laserTrail: _laserTrail,
                          hoveredAnchorElement: _hoveredAnchorElement,
                          activeAnchorPoint: _activeAnchorPoint,
                          pan: _pan,
                          zoom: _zoom,
                          colors: colors,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),

              // 1.5 Empty Canvas Onboarding Guide (when no elements are present)
              if (_elements.isEmpty && !_isPresentationMode)
                Positioned.fill(
                  child: EmptyCanvasGuide(
                    onOpenImport: _showExportDialog,
                    onOpenTemplates: _showTemplatesDialog,
                    onOpenHelp: _showShortcutsHelpDialog,
                    onInsertImage: _handleInsertImage,
                    onSelectTool: (t) => setState(() {
                      _tool = t;
                      if (t != Tool.select) _selectedIds.clear();
                    }),
                  ),
                ),

              // 2. Unified Top Bar (Board selector on left, Main Toolbar centered/scrollable)
              if (!_isPresentationMode)
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: ExcludeFocus(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BoardTabsBar(
                          boards: _boards,
                          activeIndex: _activeBoardIndex,
                          onSelectBoard: _switchBoard,
                          onCreateBoard: _createBoard,
                          onRenameBoard: _renameBoard,
                          onDeleteBoard: _deleteBoard,
                          onDuplicateBoard: _duplicateBoard,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Center(
                            child: MainToolbar(
                              currentTool: _tool,
                              currentColor: _color,
                              canUndo: _history.canUndo,
                              canRedo: _history.canRedo,
                              hasElements: _elements.isNotEmpty,
                              hasFrames: _frames.isNotEmpty,
                              isPropertiesOpen: _isPropertiesOpen,
                              onSelectTool: (t) => setState(() {
                                _tool = t;
                                if (t != Tool.select) _selectedIds.clear();
                              }),
                              onSelectColor: _updateColor,
                              onUndo: _undoAction,
                              onRedo: _redoAction,
                              onClear: _clearBoard,
                              onOpenExport: _showExportDialog,
                              onOpenTemplates: _showTemplatesDialog,
                              onStartPresentation: _startPresentation,
                              onToggleProperties: () => setState(
                                  () => _isPropertiesOpen = !_isPropertiesOpen),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. Floating Properties Panel
              if (!_isPresentationMode &&
                  (_isPropertiesOpen || _selectedIds.isNotEmpty))
                Positioned(
                  top: 64,
                  left: 12,
                  child: ExcludeFocus(
                    child: PropertiesPanel(
                      selectedElements: selectedElements,
                      currentColor: _color,
                      currentFillColor: _fillColor,
                      currentStrokeWidth: _strokeWidth,
                      currentStrokeStyle: _strokeStyle,
                      currentFillStyle: _fillStyle,
                      currentDrawStyle: _drawStyle,
                      currentFontSize: _fontSize,
                      currentOpacity: _opacity,
                      currentRotation: _rotation,
                      onColorChanged: _updateColor,
                      onFillColorChanged: _updateFillColor,
                      onStrokeWidthChanged: _updateStrokeWidth,
                      onStrokeStyleChanged: _updateStrokeStyle,
                      onFillStyleChanged: _updateFillStyle,
                      onDrawStyleChanged: _updateDrawStyle,
                      onFontSizeChanged: _updateFontSize,
                      onOpacityChanged: _updateOpacity,
                      onRotationChanged: _updateRotation,
                      onGroup: _groupSelected,
                      onUngroup: _ungroupSelected,
                      onBringToFront: _bringToFront,
                      onSendToBack: _sendToBack,
                      onDuplicate: _duplicateSelected,
                      onDelete: _deleteSelected,
                      onAlign: _alignSelected,
                      onClose: () => setState(() => _isPropertiesOpen = false),
                    ),
                  ),
                ),

              // 5. Bottom-Left Zoom & Grid Controls
              if (!_isPresentationMode)
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: ExcludeFocus(
                    child: ZoomControls(
                      zoom: _zoom,
                      onZoomIn: () => _zoomAt(
                          _viewSize.center(Offset.zero), _zoom * 1.25),
                      onZoomOut: () => _zoomAt(
                          _viewSize.center(Offset.zero), _zoom / 1.25),
                      onResetZoom: () => setState(() {
                        _zoom = 1.0;
                        _pan = Offset.zero;
                      }),
                      isGridSnap: _gridSnap,
                      onToggleGridSnap: () =>
                          setState(() => _gridSnap = !_gridSnap),
                    ),
                  ),
                ),

              // 6. Bottom-Right Radar Minimap, Theme Toggle & Shortcuts/Help
              if (!_isPresentationMode)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: ExcludeFocus(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_viewSize.width > 540) ...[
                          MinimapWidget(
                            elements: _elements,
                            pan: _pan,
                            zoom: _zoom,
                            viewSize: _viewSize,
                            colors: colors,
                            onJumpTo: (newPan) => setState(() => _pan = newPan),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ThemeToggle(onToggleTheme: widget.onToggleTheme),
                        const SizedBox(width: 8),
                        Material(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          elevation: 3,
                          shadowColor: const Color(0x33000000),
                          borderRadius: BorderRadius.circular(12),
                          child: IconButton(
                            tooltip: 'Shortcuts & Help (?)',
                            onPressed: _showShortcutsHelpDialog,
                            icon: const Icon(
                              Icons.help_outline_rounded,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 7. Floating In-Canvas Text Editor
              if (_editingElementId != null && _editingScreenPos != null)
                InlineTextEditor(
                  initialText: _elements
                      .firstWhere((e) => e.id == _editingElementId,
                          orElse: () => _elements.first)
                      .text,
                  fontSize: _fontSize,
                  color: _color,
                  screenPosition: _editingScreenPos!,
                  isStickyNote: _isEditingSticky,
                  onSubmitted: (newText) {
                    setState(() {
                      _pushUndo(_elements);
                      _elements = [
                        for (final el in _elements)
                          if (el.id == _editingElementId)
                            el.copyWith(text: newText)
                          else
                            el,
                      ];
                      _editingElementId = null;
                      _editingScreenPos = null;
                    });
                  },
                  onCanceled: () => setState(() {
                    final el = _elements.firstWhere(
                      (e) => e.id == _editingElementId,
                      orElse: () => _elements.first,
                    );
                    if (el.text.trim().isEmpty) {
                      _elements = _elements
                          .where((e) => e.id != _editingElementId)
                          .toList();
                    }
                    _editingElementId = null;
                    _editingScreenPos = null;
                  }),
                ),

              // 8. Full-screen Presentation Slides Overlay
              if (_isPresentationMode)
                PresentationOverlay(
                  frames: _frames,
                  currentSlideIndex: _currentSlideIndex,
                  onNextSlide: () => _navigateToSlide(_currentSlideIndex + 1),
                  onPrevSlide: () => _navigateToSlide(_currentSlideIndex - 1),
                  onExit: () => setState(() => _isPresentationMode = false),
                ),
            ],
          );
        }),
      ),
    );
  }
}
