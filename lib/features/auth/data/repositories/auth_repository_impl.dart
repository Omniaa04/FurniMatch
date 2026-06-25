import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    return remoteDataSource.login(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthUser> signup({
    required String name,
    required String email,
    required String password,
  }) {
    return remoteDataSource.signup(
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> forgotPassword({
    required String email,
  }) {
    return remoteDataSource.forgotPassword(email: email);
  }

  @override
  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) {
    return remoteDataSource.verifyOtp(
      email: email,
      otp: otp,
    );
  }

  @override
  Future<void> resendOtp({
    required String email,
  }) {
    return remoteDataSource.resendOtp(email: email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) {
    return remoteDataSource.resetPassword(
      email: email,
      newPassword: newPassword,
    );
  }
}