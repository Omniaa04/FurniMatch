import 'package:flutter/material.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class CreateNewPasswordPage extends StatefulWidget {
  final String email;

  const CreateNewPasswordPage({
    super.key,
    required this.email,
  });

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  late final ResetPasswordUseCase resetPasswordUseCase;

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final repository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(),
    );

    resetPasswordUseCase = ResetPasswordUseCase(repository);
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await resetPasswordUseCase(
        email: widget.email,
        newPassword: passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successfully! ✅")),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create New Password",
          style: TextStyle(color: Colors.brown),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              const Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xfff2d8be),
                  child: Icon(
                    Icons.lock_outline,
                    size: 55,
                    color: Colors.brown,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "New Password",
                style: TextStyle(color: Colors.brown, fontSize: 16),
              ),

              const SizedBox(height: 8),

              AuthTextField(
                controller: passwordController,
                hint: "Enter new password",
                icon: Icons.lock_outline,
                obscureText: obscurePassword,
                isPassword: true,
                onTogglePassword: () {
                  setState(() => obscurePassword = !obscurePassword);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a password";
                  }
                  if (value.length < 8) {
                    return "Password must be at least 8 characters";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                "Confirm Password",
                style: TextStyle(color: Colors.brown, fontSize: 16),
              ),

              const SizedBox(height: 8),

              AuthTextField(
                controller: confirmController,
                hint: "Confirm new password",
                icon: Icons.lock_outline,
                obscureText: obscureConfirm,
                isPassword: true,
                onTogglePassword: () {
                  setState(() => obscureConfirm = !obscureConfirm);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your password";
                  }
                  if (value != passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              AuthButton(
                text: "Reset Password",
                isLoading: isLoading,
                onPressed: resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}