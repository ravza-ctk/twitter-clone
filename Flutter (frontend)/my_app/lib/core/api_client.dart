import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'navigation.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  // Android Emulator için localhost: 10.0.2.2
  // Gerçek cihaz: Bilgisayarın IP'si (örn: 192.168.1.35)
  // Web: localhost
  static String get baseUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // ADB Reverse Proxy ile localhost kullanımı (10.0.2.2 yerine)
      return 'http://10.0.3.2:8080';
    }
    return 'http://localhost:8080';
  } 

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    debugPrint("API Client initialized with Base URL: $baseUrl");
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Eğer istek Login veya Register ise Token yok
          if (options.path.contains('/auth/login') || options.path.contains('/auth/register') || options.path.contains('/auth/step1')) {
             return handler.next(options);
          }

          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          debugPrint("API Error: ${e.response?.statusCode} -> ${e.message}");
          if (e.response?.statusCode == 401) {
            await _storage.delete(key: 'auth_token');
            navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
          }
          return handler.next(e);
        },
      ),
    );
  }
}