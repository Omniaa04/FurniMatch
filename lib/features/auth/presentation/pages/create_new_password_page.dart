import 'package:flutter/material.dart';

class CreateNewPasswordPage extends StatefulWidget {
  const CreateNewPasswordPage({super.key});

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final passController = TextEditingController();
  final confirmController = TextEditingController();

  void savePassword() {
    if (passController.text == confirmController.text &&
        passController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully")),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
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
        title: const Text("Create New Password",
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
              child:
                  const Icon(Icons.lock_reset, size: 50, color: Colors.brown),
            ),

            const SizedBox(height: 20),

            const Text(
              "Your new password must be different from previously used password",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: savePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Save",
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
