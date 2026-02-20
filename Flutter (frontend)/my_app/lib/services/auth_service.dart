import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/auth_response.dart';

class AuthService {
  final ApiClient _client = ApiClient();
  final _storage = const FlutterSecureStorage();

  // GİRİŞ YAP
  Future<bool> login(String username, String password) async {
    try {
      final response = await _client.dio.post('/rest/api/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        // Gelen token'ı al
        final authResponse = AuthResponse.fromJson(response.data['payload']);
        
        // Token'ı telefonun güvenli hafızasına kaydet
        await _storage.write(key: 'auth_token', value: authResponse.token);
        
        // Kullanıcı ID ve Adını SharedPreferences'a kaydet (Diğer ekranlar için)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', authResponse.userId);
        await prefs.setString('username', authResponse.username);
        
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint("LOGIN ERROR DATA: ${e.response!.data}");
      }
      debugPrint("Login Hatası: $e");
      return false;
    } catch (e) {
      debugPrint("Login Hatası: $e");
      return false;
    }
  }

  // ADIM 2.5: Şifre Belirleme
  Future<bool> setPassword(int userId, String password) async {
    try {
      final response = await _client.dio.post('/rest/api/auth/password', data: {
        'userId': userId,
        'password': password
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Set Password Hatası: $e");
      return false;
    }
  }

  // ÇIKIŞ YAP
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Tüm oturum verilerini temizle
  }

  // TOKEN VAR MI KONTROL ET (Splash Screen için lazım olacak)
  Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  // --- KAYIT ADIMLARI ---

  // ADIM 1: Temel Bilgiler -> UserId Döner
  Future<int?> registerStep1(String name, String emailOrPhone, String dob) async {
    try {
      final response = await _client.dio.post('/rest/api/auth/step1', data: {
        'name': name,
        'email': emailOrPhone, 
        'dateOfBirth': dob
      });

      if (response.statusCode == 200) {
        return response.data['payload']; 
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        // Backend'den gelen hata mesajını yakala
        final errorData = e.response!.data;
        if (errorData is Map && errorData.containsKey('errorMessage')) {
           throw Exception(errorData['errorMessage']);
        } else if (errorData is Map && errorData.containsKey('message')) {
           throw Exception(errorData['message']);
        }
      }
      throw Exception("Bağlantı hatası: ${e.message}");
    } catch (e) {
      debugPrint("Register Step 1 Hatası: $e");
      throw Exception("Bir hata oluştu: $e");
    }
  }

  // ADIM 2: Kod Doğrulama
  Future<bool> verifyCode(int userId, String code) async {
    try {
      final response = await _client.dio.post('/rest/api/auth/verify', data: {
        'userId': userId,
        'code': code
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Verify Code Hatası: $e");
      return false;
    }
  }

  // ADIM 4: Kullanıcı Adı Seçimi
  Future<String?> setUsername(int userId, String username) async {
    try {
      final response = await _client.dio.post('/rest/api/auth/username', data: {
        'userId': userId,
        'username': username
      });

      if (response.statusCode == 200) {
         // Backend RootEntity<String> döner
         return response.data['payload'];
      }
      return null;
    } catch (e) {
      debugPrint("Set Username Hatası: $e");
      return null;
    }
  }

  // ADIM 5: Kaydı Tamamla
  Future<bool> completeRegistration(int userId) async {
    try {
      final response = await _client.dio.post('/rest/api/auth/complete/$userId');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Complete Registration Hatası: $e");
      return false;
    }
  }
  // Profil Resmi Yükleme
  Future<bool> uploadProfilePhoto(int userId, String filePath) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "userId": userId,
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _client.dio.post(
        '/rest/api/auth/profile-image',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Upload Profile Photo Error: $e");
      return false;
    }
  }
}