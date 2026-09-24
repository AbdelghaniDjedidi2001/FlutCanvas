import 'dart:convert';
import 'package:flutter/material.dart';
import 'board_element.dart';

class BoardDocument {
  BoardDocument({
    required this.id,
    required this.title,
    required this.elements,
    this.pan = Offset.zero,
    this.zoom = 1.0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String title;
  List<BoardElement> elements;
  Offset pan;
  double zoom;
  DateTime updatedAt;

  BoardDocument copyWith({
    String? id,
    String? title,
    List<BoardElement>? elements,
    Offset? pan,
    double? zoom,
    DateTime? updatedAt,
  }) {
    return BoardDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      elements: elements ?? this.elements,
      pan: pan ?? this.pan,
      zoom: zoom ?? this.zoom,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'pan': {'x': pan.dx, 'y': pan.dy},
      'zoom': zoom,
      'updatedAt': updatedAt.toIso8601String(),
      'elements': elements.map((e) => e.toMap()).toList(),
    };
  }

  factory BoardDocument.fromMap(Map<String, dynamic> map) {
    final panMap = map['pan'] as Map<String, dynamic>?;
    final pan = panMap != null
        ? Offset(
            (panMap['x'] as num).toDouble(), (panMap['y'] as num).toDouble())
        : Offset.zero;

    final rawElements = map['elements'] as List<dynamic>? ?? [];
    final elements = rawElements
        .map((e) => BoardElement.fromMap(e as Map<String, dynamic>))
        .toList();

    return BoardDocument(
      id: map['id'] as String? ?? 'board_${DateTime.now().millisecondsSinceEpoch}',
      title: map['title'] as String? ?? 'Untitled Board',
      elements: elements,
      pan: pan,
      zoom: (map['zoom'] as num?)?.toDouble() ?? 1.0,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory BoardDocument.fromJson(String source) =>
      BoardDocument.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
