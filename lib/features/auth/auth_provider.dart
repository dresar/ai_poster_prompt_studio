import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class AuthUser {
  final String id;
  final String email;
  final String role;
  final String createdAt;
  final String subscriptionStatus;
  final int credits;

  AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.subscriptionStatus,
    required this.credits,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'USER',
      createdAt: json['createdAt'] ?? '',
      subscriptionStatus: json['subscriptionStatus'] ?? 'FREE',
      credits: json['credits'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        'createdAt': createdAt,
        'subscriptionStatus': subscriptionStatus,
        'credits': credits,
      };
}

class AuthState {
  final AuthUser? user;
  final String? accessToken;
  final String? refreshToken;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthUser? user,
    String? accessToken,
    String? refreshToken,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isLoading: true)) {
    loadSession();
  }

  // Load saved session from SharedPreferences
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');
      final userStr = prefs.getString('user');

      if (accessToken != null && refreshToken != null && userStr != null) {
        final user = AuthUser.fromJson(jsonDecode(userStr));
        state = AuthState(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
          isLoading: false,
        );
      } else {
        state = AuthState(isLoading: false);
      }
    } catch (e) {
      state = AuthState(isLoading: false, errorMessage: 'Failed to load session');
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await dioClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final user = AuthUser.fromJson(data['user']);
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        await prefs.setString('user', jsonEncode(user.toJson()));

        state = AuthState(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
          isLoading: false,
        );
        return true;
      } else {
        state = AuthState(
          isLoading: false,
          errorMessage: response.data['message'] ?? 'Login failed',
        );
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Login Exception: $e\n$stackTrace');
      state = AuthState(
        isLoading: false,
        errorMessage: _handleException(e),
      );
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await dioClient.post('/auth/register', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final user = AuthUser.fromJson(data['user']);
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        await prefs.setString('user', jsonEncode(user.toJson()));

        state = AuthState(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
          isLoading: false,
        );
        return true;
      } else {
        state = AuthState(
          isLoading: false,
          errorMessage: response.data['message'] ?? 'Registration failed',
        );
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Register Exception: $e\n$stackTrace');
      state = AuthState(
        isLoading: false,
        errorMessage: _handleException(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
    state = AuthState(isLoading: false);
  }

  void updateSubscriptionStatus(String status) async {
    if (state.user != null) {
      final updatedUser = AuthUser(
        id: state.user!.id,
        email: state.user!.email,
        role: state.user!.role,
        createdAt: state.user!.createdAt,
        subscriptionStatus: status,
        credits: state.user!.credits,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(updatedUser.toJson()));
      state = state.copyWith(user: updatedUser);
    }
  }

  void updateUserCredits(int credits) async {
    if (state.user != null) {
      final updatedUser = AuthUser(
        id: state.user!.id,
        email: state.user!.email,
        role: state.user!.role,
        createdAt: state.user!.createdAt,
        subscriptionStatus: state.user!.subscriptionStatus,
        credits: credits,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(updatedUser.toJson()));
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await dioClient.get('/auth/profile');
      if (response.data['success'] == true && response.data['data']['user'] != null) {
        final user = AuthUser.fromJson(response.data['data']['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user.toJson()));
        state = state.copyWith(user: user);
      }
    } catch (e) {
      debugPrint('Failed to refresh user profile: $e');
    }
  }

  String _handleException(dynamic e) {
    if (e is DioException) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data.containsKey('message') && data['message'] != null) {
            return data['message'].toString();
          }
          if (data.containsKey('error') && data['error'] != null) {
            return data['error'].toString();
          }
        }
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return 'Email atau password salah, atau akses tidak diizinkan.';
        } else if (statusCode == 403) {
          return 'Akses ditolak.';
        } else if (statusCode == 404) {
          return 'Layanan tidak ditemukan di server.';
        } else if (statusCode != null && statusCode >= 500) {
          return 'Server sedang mengalami gangguan/pemeliharaan. Silakan coba lagi nanti.';
        }
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return 'Tidak dapat terhubung ke server. Silakan periksa koneksi internet Anda atau coba beberapa saat lagi.';
      }
      return 'Gagal terhubung ke server. Silakan coba lagi nanti.';
    }
    return e.toString();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
