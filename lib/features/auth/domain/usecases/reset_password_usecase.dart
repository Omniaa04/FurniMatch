import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call({
    required String email,
    required String newPassword,
  }) {
    return repository.resetPassword(
      email: email,
      newPassword: newPassword,
    );
  }
}