import 'package:json_annotation/json_annotation.dart';
import 'comment_model.dart';

part 'tweet_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Tweet {
  final int? id;
  final String name;
  final String username;
  final String? avatarUrl;
  final String content;
  final String time;
  
  @JsonKey(name: 'commentCount', defaultValue: 0)
  int comments;
  
  @JsonKey(name: 'retweetCount', defaultValue: 0)
  int retweets;
  
  @JsonKey(name: 'likeCount', defaultValue: 0)
  int likes;
  
  @JsonKey(name: 'viewCount', defaultValue: 0)
  int views;

  @JsonKey(name: 'liked', defaultValue: false)
  bool isLiked;
  
  @JsonKey(name: 'retweeted', defaultValue: false)
  bool isRetweeted;
  
  @JsonKey(name: 'bookmarked', defaultValue: false)
  bool isBookmarked;
  
  final String? mediaUrl;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool hasVideo;
  
  @JsonKey(name: 'ad', defaultValue: false)
  final bool isAd;
  
  @JsonKey(defaultValue: [])
  List<Comment> replies;
  
  final Tweet? quotedTweet;

  Tweet({
    this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    required this.content,
    required this.time,
    required this.comments,
    required this.retweets,
    required this.likes,
    this.views = 0,
    this.isLiked = false,
    this.isRetweeted = false,
    this.isBookmarked = false,
    this.mediaUrl,
    this.hasVideo = false,
    this.isAd = false,
    List<Comment>? replies,
    this.quotedTweet,
  }) : replies = replies ?? [] {
    hasVideo = mediaUrl != null && mediaUrl.toString().endsWith('.mp4');
  }

  factory Tweet.fromJson(Map<String, dynamic> json) => _$TweetFromJson(json);
  Map<String, dynamic> toJson() => _$TweetToJson(this);
}