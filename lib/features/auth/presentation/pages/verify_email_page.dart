import 'package:flutter/material.dart';
import 'create_new_password_page.dart';
class VerifyEmailPage extends StatefulWidget {
  final String email;
  const VerifyEmailPage({super.key, required this.email});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final List<TextEditingController> otpControllers =
      List.generate(4, (_) => TextEditingController());

  void verifyCode() {
    final code = otpControllers.map((c) => c.text).join();
    if (code.length == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateNewPasswordPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 4-digit code")),
      );
    }
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
        title: const Text("Verify Your Email",
            style: TextStyle(color: Colors.brown)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.yellow.shade100,
              child: const Icon(Icons.mark_email_read,
                  size: 50, color: Colors.brown),
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
                  color: Colors.brown, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) => SizedBox(
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
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {},
              child: const Text("Resend Code",
                  style: TextStyle(color: Colors.brown)),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Verify",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
