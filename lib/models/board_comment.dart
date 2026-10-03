import 'dart:convert';
import 'package:flutter/material.dart';

/// Represents a single reply inside a threaded canvas comment.
class CommentReply {
  const CommentReply({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String author;
  final String text;
  final DateTime createdAt;

  CommentReply copyWith({
    String? id,
    String? author,
    String? text,
    DateTime? createdAt,
  }) {
    return CommentReply(
      id: id ?? this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommentReply.fromMap(Map<String, dynamic> map) {
    return CommentReply(
      id: map['id'] as String? ?? 'reply_${DateTime.now().millisecondsSinceEpoch}',
      author: map['author'] as String? ?? 'User',
      text: map['text'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory CommentReply.fromJson(String source) =>
      CommentReply.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Represents an interactive coordinate-pinned comment thread on the canvas.
class BoardComment {
  const BoardComment({
    required this.id,
    required this.worldPosition,
    required this.pinNumber,
    required this.author,
    required this.text,
    required this.createdAt,
    this.isResolved = false,
    this.replies = const [],
    this.colorValue,
  });

  final String id;
  final Offset worldPosition;
  final int pinNumber;
  final String author;
  final String text;
  final DateTime createdAt;
  final bool isResolved;
  final List<CommentReply> replies;
  final int? colorValue;

  Color get pinColor =>
      colorValue != null ? Color(colorValue!) : const Color(0xFF6366F1); // Indigo default

  int get totalReplies => replies.length;

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  BoardComment copyWith({
    String? id,
    Offset? worldPosition,
    int? pinNumber,
    String? author,
    String? text,
    DateTime? createdAt,
    bool? isResolved,
    List<CommentReply>? replies,
    int? colorValue,
  }) {
    return BoardComment(
      id: id ?? this.id,
      worldPosition: worldPosition ?? this.worldPosition,
      pinNumber: pinNumber ?? this.pinNumber,
      author: author ?? this.author,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isResolved: isResolved ?? this.isResolved,
      replies: replies ?? this.replies,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  BoardComment addReply({
    required String author,
    required String text,
  }) {
    final reply = CommentReply(
      id: 'reply_${DateTime.now().millisecondsSinceEpoch}_${replies.length}',
      author: author.trim().isEmpty ? 'User' : author.trim(),
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    return copyWith(replies: [...replies, reply]);
  }

  BoardComment removeReply(String replyId) {
    return copyWith(
      replies: replies.where((r) => r.id != replyId).toList(),
    );
  }

  BoardComment toggleResolved() {
    return copyWith(isResolved: !isResolved);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'worldPosition': {'x': worldPosition.dx, 'y': worldPosition.dy},
      'pinNumber': pinNumber,
      'author': author,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'isResolved': isResolved,
      'replies': replies.map((r) => r.toMap()).toList(),
      if (colorValue != null) 'colorValue': colorValue,
    };
  }

  factory BoardComment.fromMap(Map<String, dynamic> map) {
    final posMap = map['worldPosition'] as Map<String, dynamic>?;
    final worldPos = posMap != null
        ? Offset(
            (posMap['x'] as num).toDouble(),
            (posMap['y'] as num).toDouble(),
          )
        : Offset.zero;

    final rawReplies = map['replies'] as List<dynamic>? ?? [];
    final replies = rawReplies
        .map((r) => CommentReply.fromMap(r as Map<String, dynamic>))
        .toList();

    return BoardComment(
      id: map['id'] as String? ?? 'comment_${DateTime.now().millisecondsSinceEpoch}',
      worldPosition: worldPos,
      pinNumber: (map['pinNumber'] as num?)?.toInt() ?? 1,
      author: map['author'] as String? ?? 'User',
      text: map['text'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isResolved: map['isResolved'] as bool? ?? false,
      replies: replies,
      colorValue: (map['colorValue'] as num?)?.toInt(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory BoardComment.fromJson(String source) =>
      BoardComment.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
