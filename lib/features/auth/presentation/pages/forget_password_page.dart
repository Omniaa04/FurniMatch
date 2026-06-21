import 'package:flutter/material.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import 'verify_email_page.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  late final ForgotPasswordUseCase forgotPasswordUseCase;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final repository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(),
    );

    forgotPasswordUseCase = ForgotPasswordUseCase(repository);
  }

  Future<void> sendOtp() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await forgotPasswordUseCase(
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailPage(
            email: emailController.text.trim(),
          ),
        ),
      );
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
    emailController.dispose();
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
          "Forgot Password",
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

              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xfff2d8be),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 55,
                    color: Colors.brown,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Reset your password",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Enter your email address and we will send you a verification code to reset your password.",
                style: TextStyle(color: Colors.black87),
              ),

              const SizedBox(height: 30),

              AuthTextField(
                controller: emailController,
                hint: "Email Address",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  if (!value.contains("@")) return "Enter a valid email";
                  return null;
                },
              ),

              const SizedBox(height: 40),

              AuthButton(
                text: "Send Reset Link",
                isLoading: isLoading,
                onPressed: sendOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}