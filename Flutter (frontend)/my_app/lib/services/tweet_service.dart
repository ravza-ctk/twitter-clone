import 'package:flutter/foundation.dart';
import  '../models/tweet_model.dart';
import '../core/api_client.dart';

class TweetService {
  static final TweetService _instance = TweetService._internal();

  factory TweetService() {
    return _instance;
  }

  TweetService._internal();

  final ValueNotifier<List<Tweet>> tweets = ValueNotifier<List<Tweet>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  final ApiClient _client = ApiClient();



  Future<void> fetchFeed() async {
    if (isLoading.value) return;

    isLoading.value = true;
    
    try {
      final response = await _client.dio.get('/rest/api/tweet/feed');

      if (response.statusCode == 200) {
        // Backend'den RootEntity<List<DtoTweet>> dönüyor: { "data": [...], "result": true }
        if (response.data['data'] != null) {
          final List<dynamic> data = response.data['data'];
          tweets.value = data.map((json) => Tweet.fromJson(json)).toList();
        } else {
          tweets.value = [];
          debugPrint(" UYARI: Feed verisi boş (null) döndü.");
        }
      }
    } catch (e) {
      debugPrint("Feed Fetch Hatası: $e");

      // MOCK DATA FALLBACK
      tweets.value = [
        Tweet(
          id: 1,
          name: "Test User",
          username: "test_user_123",
          avatarUrl: "https://i.pravatar.cc/150?u=1",
          content: "This is a mock tweet.",
          time: "5m",
          likes: 5,
          retweets: 2,
          comments: 1,
        ),
        
        Tweet(
          id: 2,
          name: "Demo User",
          username: "demo_user",
          avatarUrl: "https://i.pravatar.cc/150?u=2",
          content: "Another mock tweet for demonstration purposes.",
          time: "1h",
          likes: 12,
          retweets: 0,
          comments: 3,
        ),
        Tweet(
          id: 3,
          name: "NASA",
          username: "NASA_official",
          avatarUrl: "https://www.citypng.com/public/uploads/preview/hd-nasa-logo-transparent-background-7017516947129576ypz4kes8x.png",
          content: "The weather is very sunny today in Mars.",
          time: "1h",
          likes: 56987,
          retweets: 2604,
          comments: 1236,
        ),
      ];
    } finally {
      isLoading.value = false;
    }
  }

  // Called when returning from Compose Screen with a full Tweet object
  void addTweet(Tweet tweet) {
    tweets.value = [tweet, ...tweets.value];
  }

 Future<Tweet?> createTweet({required int userId, required String content}) async {
  try {
    final response = await _client.dio.post(
      '/rest/api/tweet/save/$userId', 
      data: {
        'content': content,
      },
    );

    if (response.statusCode == 200) {
      final responseData = response.data;
      
      if (responseData['data'] != null) {
         return Tweet.fromJson(responseData['data']);
      } else if (responseData['payload'] != null) {
         // Ne olur ne olmaz diye payload kontrolü de bırakıyorum
         return Tweet.fromJson(responseData['payload']);
      }
    }
    return null;
  } catch (e) {
    debugPrint("Tweet atma hatası: $e");
    return null;
  }
}

  Future<List<Tweet>> fetchUserTweets(String username) async {
    try {
      final response = await _client.dio.get('/rest/api/tweet/list/$username');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Tweet.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("User Tweets Fetch Hatası: $e");
      return [];
    }
  }

  Future<bool> toggleLike(int tweetId) async {
    // 1. Önce UI'ı Güncelle (Optimistic Update)
    _optimisticUpdate(tweetId, (t) {
      t.isLiked = !t.isLiked;
      t.likes += t.isLiked ? 1 : -1;
    });

    try {
      // 2. İsteği Gönder
      final response = await _client.dio.post('/rest/api/tweet/like/$tweetId');
      
      if (response.statusCode == 200) {
        return true; 
      }
      
      // Başarılı değilse (örn: 401, 500) hata bloğuna düşmesi için hata fırlatabilirsin
      throw Exception("Status code: ${response.statusCode}");

    } catch (e) {
      debugPrint("LIKE HATASI: $e"); // Hatayı gör
      
      // 3. Hata olursa işlemi geri al (Revert)
      _optimisticUpdate(tweetId, (t) {
        t.isLiked = !t.isLiked; // Eski haline döndür
        t.likes += t.isLiked ? 1 : -1;
      });
      return false;
    }
  }

  Future<bool> toggleRetweet(int tweetId) async {
    // 1. Önce UI'ı Güncelle (Optimistic Update)
    _optimisticUpdate(tweetId, (t) {
      t.isRetweeted = !t.isRetweeted;
      t.retweets += t.isRetweeted ? 1 : -1;
    });

    try {
      // 2. İsteği Gönder
      final response = await _client.dio.post('/rest/api/tweet/retweet/$tweetId');
      
      if (response.statusCode == 200) {
        return true; 
      }
      
      throw Exception("Status code: ${response.statusCode}");

    } catch (e) {
      debugPrint("RETWEET HATASI: $e");
      
      // 3. Hata olursa işlemi geri al (Revert)
      _optimisticUpdate(tweetId, (t) {
        t.isRetweeted = !t.isRetweeted;
        t.retweets += t.isRetweeted ? 1 : -1;
      });
      return false;
    }
  }

  Future<bool> toggleBookmark(int tweetId) async {
    // 1. Önce UI'ı Güncelle (Optimistic Update)
    _optimisticUpdate(tweetId, (t) {
      t.isBookmarked = !t.isBookmarked;
    });

    try {
      // 2. İsteği Gönder
      final response = await _client.dio.post('/rest/api/tweet/bookmark/$tweetId');
      
      if (response.statusCode == 200) {
        return true; 
      }
      
      throw Exception("Status code: ${response.statusCode}");

    } catch (e) {
      debugPrint("BOOKMARK HATASI: $e");
      
      // 3. Hata olursa işlemi geri al (Revert)
      _optimisticUpdate(tweetId, (t) {
        t.isBookmarked = !t.isBookmarked;
      });
      return false;
    }
  }

  void _optimisticUpdate(int tweetId, Function(Tweet) updateFn) {
    final List<Tweet> currentTweets = List.from(tweets.value);
    for (int i = 0; i < currentTweets.length; i++) {
        if (currentTweets[i].id == tweetId) {
            updateFn(currentTweets[i]);
            tweets.value = currentTweets;
            // tweets.notifyListeners(); // ValueNotifier does this on assignment
            break;
        }
    }
  }
}