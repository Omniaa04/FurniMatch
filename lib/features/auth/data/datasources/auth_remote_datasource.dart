import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    },
    body: jsonEncode(body),
  );

  Map<String, dynamic> data;

  try {
    data = jsonDecode(response.body);
  } catch (_) {
    throw Exception(
      'Server is offline or returned invalid response. Check ngrok URL.',
    );
  }

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return data;
  }

  throw Exception(data['message'] ?? 'Something went wrong');
}

  Future<AuthUserModel> googleLogin() async {
    final googleSignIn = GoogleSignIn(
      clientId: '66308516080-om2rl60vcdnubtf8bqvitpeltjil84tb.apps.googleusercontent.com',
    );

    await googleSignIn.signOut();

    final account = await googleSignIn.signIn();
    if (account == null) throw Exception('Google sign in cancelled');

    final auth = await account.authentication;
    final token = auth.idToken;
    if (token == null) throw Exception('Failed to get Google token');

    final data = await _post(
      endpoint: '/auth/google',
      body: {'token': token},
    );

    return AuthUserModel(
      userId: data['user_id'],
      name: data['name'] ?? '',
      role: data['role'] ?? 'buyer',
    );
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
      body: {'email': email},
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
      body: {'email': email},
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