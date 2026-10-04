import 'package:flutter/material.dart';
import '../../domain/models/board_element.dart';
import '../../domain/models/snap_guide.dart';
import '../../../../painters/laser_painter.dart';

class CanvasInteractionController extends ChangeNotifier {
  BoardElement? _draft;
  Rect? _marqueeRect;
  List<LaserPoint> _laserTrail = const [];
  List<SnapGuide> _snapGuides = const [];

  BoardElement? get draft => _draft;
  Rect? get marqueeRect => _marqueeRect;
  List<LaserPoint> get laserTrail => _laserTrail;
  List<SnapGuide> get snapGuides => _snapGuides;

  void setDraft(BoardElement? draft) {
    _draft = draft;
    notifyListeners();
  }

  void setMarquee(Rect? marquee) {
    _marqueeRect = marquee;
    notifyListeners();
  }

  void setLaserTrail(List<LaserPoint> trail) {
    _laserTrail = trail;
    notifyListeners();
  }

  void setSnapGuides(List<SnapGuide> guides) {
    _snapGuides = guides;
    notifyListeners();
  }

  void clear() {
    _draft = null;
    _marqueeRect = null;
    _laserTrail = const [];
    _snapGuides = const [];
    notifyListeners();
  }
}
