import 'package:flutter/material.dart';
import '../models/tweet_model.dart';
import 'compose_tweet_screen.dart';
import '../models/comment_model.dart';
import 'person_detail_screen.dart';
import '../services/comment_service.dart';
import '../services/tweet_service.dart';

class TweetDetailScreen extends StatefulWidget {
  final Tweet tweet;

  const TweetDetailScreen({super.key, required this.tweet});

  @override
  State<TweetDetailScreen> createState() => _TweetDetailScreenState();
}

class _TweetDetailScreenState extends State<TweetDetailScreen> {
  late Tweet _tweet;
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tweet = widget.tweet;
    _fetchComments();
  }

  final CommentService _commentService = CommentService();
  final TweetService _tweetService = TweetService();

  Future<void> _fetchComments() async {
    if (_tweet.id == null) return;
    try {
      final comments = await _commentService.getComments(_tweet.id!);
      if (mounted) {
        setState(() {
          _comments = comments;
          if (_comments.length != _tweet.comments) {
            _tweet.comments = _comments.length;
          }
        });
      }
    } catch (e) {
      debugPrint("Yorumları getirme hatası: $e");
    }
  }



  Future<void> _toggleRetweet() async {
    if (_tweet.id == null) return;

    final initialRetweeted = _tweet.isRetweeted;
    final initialCount = _tweet.retweets;

    if (_tweet.isRetweeted) {
      // Retweet geri alma
      bool success = await _tweetService.toggleRetweet(_tweet.id!);
      if (success) {
        if (_tweet.isRetweeted == initialRetweeted) {
             // Servis güncellemediyse biz yapalım
            _tweet.isRetweeted = false;
            _tweet.retweets = initialCount - 1;
        }
        setState(() {}); // Refresh UI
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yeniden gönderme kaldırıldı'), duration: Duration(seconds: 2)),
          );
        }
      }
    } else {
      // Retweet Menüsü
      showModalBottomSheet(
        context: context,
        builder: (modalContext) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.repeat, size: 28),
                  title: const Text('Yeniden Gönder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  onTap: () async {
                    Navigator.pop(modalContext);
                    
                    bool success = await _tweetService.toggleRetweet(_tweet.id!);
                    if (success) {
                         if (_tweet.isRetweeted == initialRetweeted) {
                             _tweet.isRetweeted = true;
                             _tweet.retweets = initialCount + 1;
                         }
                        setState(() {});

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tweet yeniden gönderildi'), duration: Duration(seconds: 2)),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.create_outlined, size: 28),
                  title: const Text('Alıntıyla Gönder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  onTap: () async {
                    Navigator.pop(modalContext);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComposeTweetScreen(quotedTweet: _tweet),
                      ),
                    );

                    if (result != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tweet gönderildi'), duration: Duration(seconds: 2)),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _toggleLike() async {
    if (_tweet.id == null) return;

    final initialLiked = _tweet.isLiked;
    final initialCount = _tweet.likes;

    bool success = await _tweetService.toggleLike(_tweet.id!);
    if (success) {
      if (_tweet.isLiked == initialLiked) {
         // Servis değiştirmedi, biz değiştirelim (Örn: ProfileScreen'den geldik)
         _tweet.isLiked = !initialLiked;
         _tweet.likes = initialCount + (initialLiked ? -1 : 1);
      }
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tweet.isLiked ? 'Beğenildi' : 'Beğeni kaldırıldı'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (_tweet.id == null) return;

    final initialBookmarked = _tweet.isBookmarked;

    bool success = await _tweetService.toggleBookmark(_tweet.id!);
    if (success) {
       if (_tweet.isBookmarked == initialBookmarked) {
          _tweet.isBookmarked = !initialBookmarked;
       }
       setState(() {});
       
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tweet.isBookmarked ? 'Tweet işaretlendi' : 'Tweet işareti kaldırıldı'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showCommentDialog(String dialogTitle, [Comment? parentComment]) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Yanıtınızı yazın...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _commentController.clear();
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_commentController.text.isNotEmpty && _tweet.id != null) {
                  bool success = await _commentService.addComment(_tweet.id!, _commentController.text);

                  if (!mounted) return;

                  if (success) {
                    _commentController.clear();
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    _fetchComments(); // Refresh comments
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yorum gönderildi'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yorum gönderilemedi'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                }
              },
              child: const Text('Gönder'),
            ),
          ],
        );
      },
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.mail_outline, size: 28),
                title: const Text('Mesaj Gönder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tweet mesajla gönderildi')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, size: 28),
                title: const Text('Bağlantıyı Kopyala', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bağlantı panoya kopyalandı')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_add_outlined, size: 28),
                title: const Text('Koleksiyona Ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Koleksiyona eklendi')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleFollowAction() {
    if (_isFollowing) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('${_tweet.name} başlığını takip etmeyi bırakmak mı istiyorsun?'),
            content: const Text(
              'Bu kullanıcının gönderileri artık anasayfa zaman akışında görüntülenmeyecek. Gönderileri korumalı değilse kullanıcının profilini görüntülemeye devam edebilirsin.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal et', style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isFollowing = false;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Takibi Bırak'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _isFollowing = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('takip ediliyor'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tweet'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PersonDetailScreen(
                                name: _tweet.name,
                                username: _tweet.username,
                                avatarUrl: _tweet.avatarUrl,
                              ),
                            ),
                          );
                        },

                        child: Row(
                          children: [
                            
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tweet.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _tweet.username,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: (_tweet.avatarUrl != null &&
                                      _tweet.avatarUrl!.isNotEmpty)
                                  ? NetworkImage(_tweet.avatarUrl!)
                                  : null,
                              onBackgroundImageError: (_tweet.avatarUrl !=
                                          null &&
                                      _tweet.avatarUrl!.isNotEmpty)
                                  ? (_, __) {}
                                  : null,
                              child: (_tweet.avatarUrl == null ||
                                      _tweet.avatarUrl!.isEmpty)
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          onPressed: _handleFollowAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing ? Colors.white : Colors.black,
                            foregroundColor: _isFollowing ? Colors.black : Colors.white,
                            side: _isFollowing ? const BorderSide(color: Colors.black) : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero, 
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _isFollowing ? 'Takip ediliyor' : 'Takip et',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const Icon(Icons.more_vert),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tweet Content
                  Text(
                    _tweet.content,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  // Timestamp
                  Text(
                    '${_tweet.time} · 28 Jan 26 · Twitter for iPhone',
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  const Divider(height: 32),
                  // Stats
                  Row(
                    children: [
                      _buildStat(_tweet.comments, 'Yorum'),
                      const SizedBox(width: 20),
                      _buildStat(_tweet.retweets, 'Retweet'),
                      const SizedBox(width: 20),
                      _buildStat(_tweet.likes, 'Beğeni'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 32),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                        onPressed: () => _showCommentDialog('Yanıt Gönder'),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.repeat,
                          color: _tweet.isRetweeted ? Colors.green : Colors.grey,
                        ),
                        onPressed: _toggleRetweet,
                      ),
                      IconButton(
                        icon: Icon(
                          _tweet.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _tweet.isLiked ? Colors.red : Colors.grey,
                        ),
                        onPressed: _toggleLike,
                      ),
                      IconButton(
                        icon: Icon(
                          _tweet.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: _tweet.isBookmarked ? Colors.blue : Colors.grey,
                        ),
                        onPressed: _toggleBookmark,
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: Colors.grey),
                        onPressed: _showShareOptions,
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                ],
              ),
            ),
            // Comments Section
            if (_comments.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Yanıtlar (${_comments.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return _buildCommentCard(comment, index);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(Comment comment, int index) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonDetailScreen(
                        name: comment.name,
                        username: comment.username,
                        avatarUrl: comment.avatarUrl,
                      ),
                    ),
                  );
                },
 child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      (comment.avatarUrl != null && comment.avatarUrl!.isNotEmpty)
                          ? NetworkImage(comment.avatarUrl!)
                          : null,
                  onBackgroundImageError:
                      (comment.avatarUrl != null && comment.avatarUrl!.isNotEmpty)
                          ? (_, __) {}
                          : null,
                  child: (comment.avatarUrl == null || comment.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonDetailScreen(
                              name: comment.name,
                              username: comment.username,
                              avatarUrl: comment.avatarUrl,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            comment.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            comment.username,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '· ${comment.time}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCommentActionButton(
                          Icons.chat_bubble_outline,
                          null,
                          onPressed: () => _showCommentDialog('Yanıt Gönder', comment),
                        ),
                        _buildCommentActionButton(
                          Icons.repeat,
                          null,
                          onPressed: () {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Yorum yeniden gönderildi'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        _buildCommentActionButton(
                          comment.isLiked ? Icons.favorite : Icons.favorite_border,
                          comment.likes,
                          onPressed: () {
                            setState(() {
                              comment.isLiked = !comment.isLiked;
                              comment.likes += comment.isLiked ? 1 : -1;
                            });
                          },
                          color: comment.isLiked ? Colors.red : Colors.grey,
                        ),
                        _buildCommentActionButton(
                          Icons.share_outlined,
                          null,
                          onPressed: _showShareOptions,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Recursive rendering of replies
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 48.0), // Indent replies
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comment.replies.length,
              itemBuilder: (context, replyIndex) {
                return _buildCommentCard(comment.replies[replyIndex], replyIndex);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCommentActionButton(
    IconData icon,
    int? count, {
    VoidCallback? onPressed,
    Color? color,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? Colors.grey,
            size: 18,
          ),
          if (count != null) ...[
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(int count, String label) {
    return Row(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }
}
