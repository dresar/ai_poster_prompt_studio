import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Development API base URL (Menggunakan IP Wi-Fi Laptop: 10.166.197.180)
const String _localBaseUrl = 'http://10.166.197.180:3000/api';

// Production API base URL
const String _productionBaseUrl = 'https://porto.apprentice.cyou/api';

// Set ke true jika ingin memaksa pakai production meskipun di debug mode
const bool _forceProduction = true;

// Get baseline API URL based on Platform
String get baseUrl {
  if (kDebugMode && !_forceProduction) {
    return _localBaseUrl;
  }
  return _productionBaseUrl;
}

final Dio dioClient = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 120),
    receiveTimeout: const Duration(seconds: 120),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ),
);

// Interceptors config
void setupDioInterceptors() {
  dioClient.interceptors.clear();
  
  dioClient.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // If Unauthorized (401) and token has expired, try to refresh
        if (error.response?.statusCode == 401 && 
            error.response?.data != null && 
            error.response?.data['code'] == 'TOKEN_EXPIRED') {
          
          final prefs = await SharedPreferences.getInstance();
          final refreshToken = prefs.getString('refresh_token');
          
          if (refreshToken != null) {
            try {
              // Fetch new tokens bypassing interceptor
              final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
              final response = await refreshDio.post('/auth/refresh', data: {
                'refreshToken': refreshToken,
              });

              if (response.data['success'] == true) {
                final newAccessToken = response.data['data']['accessToken'];
                final newRefreshToken = response.data['data']['refreshToken'];

                await prefs.setString('access_token', newAccessToken);
                await prefs.setString('refresh_token', newRefreshToken);

                // Retry failed request with new access token
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $newAccessToken';
                
                final retryResponse = await dioClient.fetch(options);
                return handler.resolve(retryResponse);
              }
            } catch (e) {
              // Refresh token failed, force logout
              await prefs.remove('access_token');
              await prefs.remove('refresh_token');
              await prefs.remove('user');
            }
          }
        }
        return handler.next(error);
      },
    ),
  );
}
