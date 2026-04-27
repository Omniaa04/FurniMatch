import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';

import '../models/auth_user_model.dart';

class AuthRemoteDataSource {
  Future<Map<String, dynamic>> _post({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['message'] ?? 'Something went wrong');
  }

  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _post(
      endpoint: '/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Login failed');
    }

    return AuthUserModel.fromJson(data);
  }

  Future<AuthUserModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _post(
      endpoint: '/signup',
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return AuthUserModel(
      userId: data['user_id'],
      name: name,
      role: 'buyer',
    );
  }

  Future<void> forgotPassword({
    required String email,
  }) async {
    final data = await _post(
      endpoint: '/forgot-password',
      body: {
        'email': email,
      },
    );

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final data = await _post(
      endpoint: '/verify-otp',
      body: {
        'email': email,
        'otp': otp,
      },
    );

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Invalid code');
    }
  }

  Future<void> resendOtp({
    required String email,
  }) async {
    await _post(
      endpoint: '/forgot-password',
      body: {
        'email': email,
      },
    );
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final data = await _post(
      endpoint: '/reset-password',
      body: {
        'email': email,
        'new_password': newPassword,
      },
    );

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Password reset failed');
    }
  }
}