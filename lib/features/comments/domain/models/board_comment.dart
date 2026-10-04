import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';

part 'board_comment.freezed.dart';
part 'board_comment.g.dart';

@freezed
abstract class CommentReply with _$CommentReply {
  const factory CommentReply({
    required String id,
    required String author,
    required String text,
    required DateTime createdAt,
  }) = _CommentReply;

  const CommentReply._();

  factory CommentReply.fromJson(Map<String, dynamic> json) =>
      _$CommentReplyFromJson(json);

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
      id: map['id'] as String? ??
          'reply_${DateTime.now().millisecondsSinceEpoch}',
      author: map['author'] as String? ?? 'User',
      text: map['text'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJsonString() => jsonEncode(toMap());
  static CommentReply fromJsonString(String source) =>
      CommentReply.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

@freezed
abstract class BoardComment with _$BoardComment {
  @OffsetConverter()
  const factory BoardComment({
    required String id,
    @OffsetConverter() required Offset worldPosition,
    required int pinNumber,
    required String author,
    required String text,
    required DateTime createdAt,
    @Default(false) bool isResolved,
    @Default([]) List<CommentReply> replies,
    int? colorValue,
  }) = _BoardComment;

  const BoardComment._();

  factory BoardComment.fromJson(Map<String, dynamic> json) =>
      _$BoardCommentFromJson(json);

  Color get pinColor =>
      colorValue != null ? Color(colorValue!) : const Color(0xFF6366F1);

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
      id: map['id'] as String? ??
          'comment_${DateTime.now().millisecondsSinceEpoch}',
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

  String toJsonString() => jsonEncode(toMap());
  static BoardComment fromJsonString(String source) =>
      BoardComment.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
