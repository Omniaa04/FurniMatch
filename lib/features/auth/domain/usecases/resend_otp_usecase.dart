import '../repositories/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository repository;

  ResendOtpUseCase(this.repository);

  Future<void> call({
    required String email,
  }) {
    return repository.resendOtp(email: email);
  }
}