import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'forget_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  bool rememberMe = false;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                      "Login to your Account",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Email or Phone number*",
                    style: TextStyle(color: Colors.brown, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: "Enter your email or phone number",
                      filled: true,
                      fillColor: Colors.white,
                      errorStyle: const TextStyle(
                        fontSize: 14, // ← تكبير Error Text
                        color: Colors.red,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field can't be empty";
                      }
                      if (!value.contains("@") && value.length < 10) {
                        return "Enter valid email or phone number";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Password*",
                    style: TextStyle(color: Colors.brown, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.brown,
                        ),
                        onPressed: () {
                          setState(() => obscurePassword = !obscurePassword);
                        },
                      ),
                      hintText: "Your Password",
                      filled: true,
                      fillColor: Colors.white,
                      errorStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password can't be empty";
                      }
                      if (value.length < 8) {
                        return "Password must be at least 8 characters";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (v) {
                              setState(() => rememberMe = v!);
                            },
                          ),
                          const Text("Remember me"),
                        ],
                      ),
                      // TextButton(
                      //   onPressed: () {},
                      //   child: const Text(
                      //     "Forget Password?",
                      //     style: TextStyle(color: Colors.brown),
                      //   ),
                      // ),
                      TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ForgetPasswordPage(),
      ),
    );
  },
  child: const Text(
    "Forgot Password?",
    style: TextStyle(color: Colors.brown),
  ),
)
                    ],
                  ),

                  const SizedBox(height: 10),

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
                          print("Login Success");
                        }
                      },
                      child: const Text(
                        "Log In",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "or",
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpPage()),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
