import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../models/user_model.dart';

class UserService {
  final ApiClient _client = ApiClient();

  // Get current logged-in user profile
  Future<User?> getMyProfile() async {
    try {
      final response = await _client.dio.get('/rest/api/user/me');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // KRİTİK KONTROL: Payload null mı?
        if (data != null && data['payload'] != null) {
          return User.fromJson(data['payload']);
        } else {
          debugPrint("UYARI: User/me servisi boş veri döndürdü.");
        }
      }
      return null;
    } catch (e) {
      debugPrint("Get My Profile Error: $e");
      return null;
    }
  }

  // Get other user's profile
  Future<User?> getUserById(int userId) async {
    try {
      final response = await _client.dio.get('/rest/api/user/$userId');
      if (response.statusCode == 200) {
        return User.fromJson(response.data['payload']);
      }
      return null;
    } catch (e) {
      debugPrint("Get User Error: $e");
       // MOCK USER DATA FALLBACK (Optional: keep or remove based on preference)
       // For now, returning null to force UI to handle empty state or loading
      return null;
    }
  }

  // Update user profile
  Future<bool> updateProfile(int userId, String name, String bio, String location, String website) async {
    try {
      final response = await _client.dio.post('/rest/api/user/update/$userId', data: {
        "name": name,
        "bio": bio,
        "location": location,
        "website": website
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update Profile Error: $e");
      return false;
    }
  }
}
