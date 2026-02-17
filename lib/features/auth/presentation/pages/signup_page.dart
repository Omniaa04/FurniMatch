import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,   // ← IMPORTANT
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 20),

                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.brown),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 10),

                  const Center(
                    child: Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// NAME
                  const Text("Your Name*", style: TextStyle(color: Colors.brown)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    decoration: _inputDecoration("Enter your name", Icons.person),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your name";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  /// EMAIL
                  const Text("Email or Phone number*",
                      style: TextStyle(color: Colors.brown)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    decoration: _inputDecoration("Enter your email", Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }
                      if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                          .hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  /// PASSWORD
                  const Text("Password*", style: TextStyle(color: Colors.brown)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: _inputDecoration(
                      "Create your Password",
                      Icons.lock_outline,
                      isPassword: true,
                      toggle: () {
                        setState(() => obscurePassword = !obscurePassword);
                      },
                      obscure: obscurePassword,
                    ),
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

                  /// CONFIRM PASS
                  const Text("Confirm Password*",
                      style: TextStyle(color: Colors.brown)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    decoration: _inputDecoration(
                      "Confirm password",
                      Icons.lock_outline,
                      isPassword: true,
                      toggle: () {
                        setState(
                            () => obscureConfirmPassword = !obscureConfirmPassword);
                      },
                      obscure: obscureConfirmPassword,
                    ),
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

                  const SizedBox(height: 30),

                  /// SIGN UP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // VALID — Ready
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Account created successfully!"),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Center(
                    child: Column(
                      children: [
                        const Text("or", style: TextStyle(color: Colors.brown)),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialIcon("assets/google.png"),
                            const SizedBox(width: 25),
                            _socialIcon("assets/facebook.png"),
                            const SizedBox(width: 25),
                            _socialIcon("assets/apple.png"),
                          ],
                        ),

                        const SizedBox(height: 40),

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(color: Colors.black54),
                              children: [
                                TextSpan(
                                  text: "log in",
                                  style: TextStyle(
                                    color: Colors.brown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// INPUT DECORATION
  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    bool isPassword = false,
    VoidCallback? toggle,
    bool obscure = false,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.brown,
              ),
              onPressed: toggle,
            )
          : null,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  /// SOCIAL ICON
  Widget _socialIcon(String path) {
    return Container(
      height: 60, 
      width: 60,  
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          path,
          height: 30,
          width: 30, 
        ),
      ),
    );
  }
}
