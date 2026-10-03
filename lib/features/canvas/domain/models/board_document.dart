import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'board_element.dart';
import '../../../comments/domain/models/board_comment.dart';

part 'board_document.freezed.dart';
part 'board_document.g.dart';

@freezed
abstract class BoardDocument with _$BoardDocument {
  @OffsetConverter()
  const factory BoardDocument({
    required String id,
    required String title,
    @Default([]) List<BoardElement> elements,
    @Default([]) List<BoardComment> comments,
    @OffsetConverter() @Default(Offset.zero) Offset pan,
    @Default(1.0) double zoom,
    DateTime? updatedAt,
  }) = _BoardDocument;

  const BoardDocument._();

  factory BoardDocument.fromJson(Map<String, dynamic> json) =>
      _$BoardDocumentFromJson(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'pan': {'x': pan.dx, 'y': pan.dy},
      'zoom': zoom,
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
      'elements': elements.map((e) => e.toMap()).toList(),
      'comments': comments.map((c) => c.toMap()).toList(),
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

    final rawComments = map['comments'] as List<dynamic>? ?? [];
    final comments = rawComments
        .map((c) => BoardComment.fromMap(c as Map<String, dynamic>))
        .toList();

    return BoardDocument(
      id: map['id'] as String? ??
          'board_${DateTime.now().millisecondsSinceEpoch}',
      title: map['title'] as String? ?? 'Untitled Board',
      elements: elements,
      comments: comments,
      pan: pan,
      zoom: (map['zoom'] as num?)?.toDouble() ?? 1.0,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  String toJsonString() => jsonEncode(toMap());
  static BoardDocument fromJsonString(String source) =>
      BoardDocument.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
