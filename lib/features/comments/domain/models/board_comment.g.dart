// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentReply _$CommentReplyFromJson(Map json) =>
    $checkedCreate('_CommentReply', json, ($checkedConvert) {
      final val = _CommentReply(
        id: $checkedConvert('id', (v) => v as String),
        author: $checkedConvert('author', (v) => v as String),
        text: $checkedConvert('text', (v) => v as String),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CommentReplyToJson(_CommentReply instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'text': instance.text,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_BoardComment _$BoardCommentFromJson(
  Map json,
) => $checkedCreate('_BoardComment', json, ($checkedConvert) {
  final val = _BoardComment(
    id: $checkedConvert('id', (v) => v as String),
    worldPosition: $checkedConvert(
      'worldPosition',
      (v) => const OffsetConverter().fromJson(v as Map<String, dynamic>),
    ),
    pinNumber: $checkedConvert('pinNumber', (v) => (v as num).toInt()),
    author: $checkedConvert('author', (v) => v as String),
    text: $checkedConvert('text', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    isResolved: $checkedConvert('isResolved', (v) => v as bool? ?? false),
    replies: $checkedConvert(
      'replies',
      (v) =>
          (v as List<dynamic>?)
              ?.map(
                (e) =>
                    CommentReply.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
    ),
    colorValue: $checkedConvert('colorValue', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$BoardCommentToJson(_BoardComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'worldPosition': const OffsetConverter().toJson(instance.worldPosition),
      'pinNumber': instance.pinNumber,
      'author': instance.author,
      'text': instance.text,
      'createdAt': instance.createdAt.toIso8601String(),
      'isResolved': instance.isResolved,
      'replies': instance.replies.map((e) => e.toJson()).toList(),
      'colorValue': instance.colorValue,
    };
