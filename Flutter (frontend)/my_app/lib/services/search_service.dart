import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../models/tweet_model.dart';
import '../models/user_model.dart';

class SearchService {
  final ApiClient _client = ApiClient();

  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _client.dio.get('/rest/api/search?q=$query&type=user');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Search Users Error: $e");
      return [];
    }
  }

  Future<List<Tweet>> searchTweets(String query, {String? type}) async {
    try {
      String path = '/rest/api/search?q=$query';
      if (type != null && type.isNotEmpty) {
        path += '&type=$type';
      }
      final response = await _client.dio.get(path);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Tweet.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Search Tweets Error: $e");
      return [];
    }
  }
}
