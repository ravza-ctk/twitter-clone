// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tweet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tweet _$TweetFromJson(Map<String, dynamic> json) => Tweet(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  username: json['username'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  content: json['content'] as String,
  time: json['time'] as String,
  comments: (json['commentCount'] as num?)?.toInt() ?? 0,
  retweets: (json['retweetCount'] as num?)?.toInt() ?? 0,
  likes: (json['likeCount'] as num?)?.toInt() ?? 0,
  views: (json['viewCount'] as num?)?.toInt() ?? 0,
  isLiked: json['liked'] as bool? ?? false,
  isRetweeted: json['retweeted'] as bool? ?? false,
  isBookmarked: json['bookmarked'] as bool? ?? false,
  mediaUrl: json['mediaUrl'] as String?,
  isAd: json['ad'] as bool? ?? false,
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  quotedTweet: json['quotedTweet'] == null
      ? null
      : Tweet.fromJson(json['quotedTweet'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TweetToJson(Tweet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'username': instance.username,
  'avatarUrl': instance.avatarUrl,
  'content': instance.content,
  'time': instance.time,
  'commentCount': instance.comments,
  'retweetCount': instance.retweets,
  'likeCount': instance.likes,
  'viewCount': instance.views,
  'liked': instance.isLiked,
  'retweeted': instance.isRetweeted,
  'bookmarked': instance.isBookmarked,
  'mediaUrl': instance.mediaUrl,
  'ad': instance.isAd,
  'replies': instance.replies.map((e) => e.toJson()).toList(),
  'quotedTweet': instance.quotedTweet?.toJson(),
};
