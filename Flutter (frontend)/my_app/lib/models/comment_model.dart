import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Comment {
  final int? id;
  final String name;
  final String username;
  final String? avatarUrl;
  final String content;
  final String time;
  
  @JsonKey(name: 'likeCount', defaultValue: 0)
  int likes;
  
  @JsonKey(name: 'liked', defaultValue: false)
  bool isLiked;
  
  @JsonKey(defaultValue: [])
  List<Comment> replies;

  Comment({
    this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    required this.content,
    required this.time,
    this.likes = 0,
    this.isLiked = false,
    List<Comment>? replies,
  }) : replies = replies ?? [];

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}