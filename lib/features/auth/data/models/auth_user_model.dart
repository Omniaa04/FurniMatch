import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  AuthUserModel({
    required super.userId,
    required super.name,
    required super.role,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      userId: json['user_id'],
      name: json['name'] ?? '',
      role: json['role'] ?? 'buyer',
    );
  }
}