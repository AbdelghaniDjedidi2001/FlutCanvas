import 'package:flutter/material.dart';
import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import 'package:flutcanvas/features/canvas/domain/models/connector_style.dart';
import 'package:flutcanvas/features/canvas/domain/models/snap_guide.dart';
import 'package:flutcanvas/features/canvas/domain/models/stroke_fill_style.dart';
import 'package:flutcanvas/features/canvas/presentation/painters/laser_painter.dart';

abstract interface class CanvasToolContext {
  List<BoardElement> get elements;
  Set<String> get selectedIds;
  double get zoom;
  Offset get pan;

  // Active Tool Style Properties
  Color get strokeColor;
  Color get fillColor;
  double get strokeWidth;
  StrokeStyle get strokeStyle;
  FillStyle get fillStyle;
  DrawStyle get drawStyle;
  double get fontSize;
  double get opacity;
  ConnectorStyle get connectorStyle;

  // Options & Modifiers
  bool get smartGuides;
  bool get autoShapeRecognition;
  bool get isShiftDown;
  String get codeLanguage;

  // Transient State Setters
  void setDraft(BoardElement? draft);
  void setMarquee(Rect? marquee);
  void setLaserTrail(List<LaserPoint> trail);
  void setSnapGuides(List<SnapGuide> guides);
  void setConnectionAnchor({BoardElement? element, Offset? point});

  // Committed State Mutations
  void commitElement(BoardElement element);
  void commitElements(List<BoardElement> elements);
  void updateElement(BoardElement element);
  void updateElements(List<BoardElement> elements);
  void deleteElements(Set<String> ids);
  void selectElements(Set<String> ids);
  void clearSelection();

  // Helper
  String generateElementId();
  BoardElement? hitTestTopmost(Offset worldPos);
}
