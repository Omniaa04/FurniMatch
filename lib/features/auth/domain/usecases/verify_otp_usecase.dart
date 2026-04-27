import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<void> call({
    required String email,
    required String otp,
  }) {
    return repository.verifyOtp(
      email: email,
      otp: otp,
    );
  }
}