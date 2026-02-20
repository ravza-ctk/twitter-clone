import 'package:flutter/material.dart';
import '../models/tweet_model.dart';

class TweetCard extends StatelessWidget {
  final Tweet tweet;
  final VoidCallback onTap;
  final VoidCallback onLikePressed;
  final Function(Tweet) onCommentPressed;
  final Function(Tweet) onQuoteRetweet;

  const TweetCard({
    super.key,
    required this.onTap,
    required this.onLikePressed,
    required this.onCommentPressed,
    required this.onQuoteRetweet,
    required this.tweet,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: tweet.avatarUrl != null ? NetworkImage(tweet.avatarUrl!) : null,
              radius: 20,
              child: tweet.avatarUrl == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tweet.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tweet.username,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      Text(
                        tweet.time,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.more_horiz, size: 16, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(tweet.content),
                  if (tweet.mediaUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(tweet.mediaUrl!),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(
                          icon: Icons.chat_bubble_outline,
                          count: tweet.comments,
                          onTap: () => onCommentPressed(tweet),
                        ),
                        _buildActionButton(
                          icon: Icons.repeat,
                          count: tweet.retweets,
                          onTap: () => onQuoteRetweet(tweet),
                        ),
                        _buildActionButton(
                          icon: tweet.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: tweet.isLiked ? Colors.red : null,
                          count: tweet.likes,
                          onTap: onLikePressed,
                        ),
                        const Icon(Icons.share_outlined, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    int? count,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? Colors.grey),
          if (count != null && count > 0) ...[
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(color: color ?? Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}