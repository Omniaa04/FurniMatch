import 'package:flutter/material.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../widgets/auth_button.dart';
import 'create_new_password_page.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({
    super.key,
    required this.email,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final otpControllers = List.generate(4, (_) => TextEditingController());

  late final VerifyOtpUseCase verifyOtpUseCase;
  late final ResendOtpUseCase resendOtpUseCase;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final repository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(),
    );

    verifyOtpUseCase = VerifyOtpUseCase(repository);
    resendOtpUseCase = ResendOtpUseCase(repository);
  }

  Future<void> verifyCode() async {
    final code = otpControllers.map((controller) => controller.text).join();

    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 4-digit code")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await verifyOtpUseCase(
        email: widget.email,
        otp: code,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateNewPasswordPage(email: widget.email),
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

  Future<void> resendOtp() async {
    try {
      await resendOtpUseCase(email: widget.email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code resent successfully!")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget otpBox(int index) {
    return SizedBox(
      width: 55,
      child: TextField(
        controller: otpControllers[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          counterText: "",
          border: UnderlineInputBorder(),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
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
          "Verify Your Email",
          style: TextStyle(color: Colors.brown),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.yellow.shade100,
              child: const Icon(
                Icons.mark_email_read,
                size: 50,
                color: Colors.brown,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Please enter the 4 digit code sent to",
              style: TextStyle(color: Colors.grey.shade700),
            ),

            const SizedBox(height: 6),

            Text(
              widget.email,
              style: const TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, otpBox),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: resendOtp,
              child: const Text(
                "Resend Code",
                style: TextStyle(color: Colors.brown),
              ),
            ),

            const Spacer(),

            AuthButton(
              text: "Verify",
              isLoading: isLoading,
              onPressed: verifyCode,
            ),
          ],
        ),
      ),
    );
  }
}