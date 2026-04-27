import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login({
    required String email,
    required String password,
  });

  Future<AuthUser> signup({
    required String name,
    required String email,
    required String password,
  });

  Future<void> forgotPassword({
    required String email,
  });

  Future<void> verifyOtp({
    required String email,
    required String otp,
  });

  Future<void> resendOtp({
    required String email,
  });

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });
}