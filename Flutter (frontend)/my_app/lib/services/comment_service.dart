import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../models/comment_model.dart';


class CommentService {
  final ApiClient _client = ApiClient();


  Future<List<Comment>> getComments(int tweetId) async {
    try {
      final response = await _client.dio.get('/rest/api/comment/list/$tweetId');
      
      if (response.statusCode == 200) {
        if (response.data['data'] != null) {
          final List<dynamic> data = response.data['data'];
          return data.map((json) => Comment.fromJson(json)).toList();
        }
        return [];
      }
      return [];
    } catch (e) {
      debugPrint("Get Comments Hatası: $e");
      return [];
    }
  }

  // Yorum Yap
  Future<bool> addComment(int tweetId, String content) async {
    try {
      final response = await _client.dio.post('/rest/api/comment/save/$tweetId', data: {
        'content': content
      });
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint("ADD COMMENT ERROR DATA: ${e.response!.data}");
      }
      debugPrint("Add Comment Hatası: $e");
      return false;
    } catch (e) {
      debugPrint("Add Comment Hatası: $e");
      return false;
    }
  }
  
  // Yorumu Beğen
  Future<bool> likeComment(int commentId) async {
     try {
      final response = await _client.dio.post('/rest/api/comment/like/$commentId');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Like Comment Hatası: $e");
      return false;
    }
  }
}
