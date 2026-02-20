// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  username: json['username'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  content: json['content'] as String,
  time: json['time'] as String,
  likes: (json['likeCount'] as num?)?.toInt() ?? 0,
  isLiked: json['liked'] as bool? ?? false,
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
  'avatarUrl': instance.avatarUrl,
  'content': instance.content,
  'time': instance.time,
  'likeCount': instance.likes,
  'liked': instance.isLiked,
  'replies': instance.replies.map((e) => e.toJson()).toList(),
};
