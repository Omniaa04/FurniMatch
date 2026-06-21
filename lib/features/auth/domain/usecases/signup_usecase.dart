import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<AuthUser> call({
    required String name,
    required String email,
    required String password,
  }) {
    return repository.signup(
      name: name,
      email: email,
      password: password,
    );
  }
}