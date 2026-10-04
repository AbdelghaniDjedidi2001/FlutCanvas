import 'package:flutter/material.dart';
import '../../domain/models/board_element.dart';
import '../../domain/models/connector_style.dart';
import '../../domain/models/snap_guide.dart';
import '../../domain/models/stroke_fill_style.dart';
import '../../../../painters/laser_painter.dart';

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

  // Transient State Setters
  void setDraft(BoardElement? draft);
  void setMarquee(Rect? marquee);
  void setLaserTrail(List<LaserPoint> trail);
  void setSnapGuides(List<SnapGuide> guides);

  // Committed State Mutations
  void commitElement(BoardElement element);
  void commitElements(List<BoardElement> elements);
  void updateElement(BoardElement element);
  void deleteElements(Set<String> ids);
  void selectElements(Set<String> ids);
  void clearSelection();

  // Helper
  String generateElementId();
  BoardElement? hitTestTopmost(Offset worldPos);
}
