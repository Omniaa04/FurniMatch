// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../data/datasources/auth_remote_datasource.dart';
// import '../../data/repositories/auth_repository_impl.dart';
// import '../../domain/usecases/signup_usecase.dart';
// import '../widgets/auth_button.dart';
// import '../widgets/auth_text_field.dart';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final formKey = GlobalKey<FormState>();

//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   late final SignupUseCase signupUseCase;
//   late final AuthRemoteDataSource _dataSource;

//   bool obscurePassword = true;
//   bool obscureConfirmPassword = true;
//   bool isLoading = false;
//   bool isGoogleLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _dataSource = AuthRemoteDataSource();
//     final repository = AuthRepositoryImpl(remoteDataSource: _dataSource);
//     signupUseCase = SignupUseCase(repository);
//   }

//   Future<void> signUp() async {
//     if (!formKey.currentState!.validate()) return;
//     setState(() => isLoading = true);
//     try {
//       final user = await signupUseCase(
//         name: nameController.text.trim(),
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('user_id', int.parse(user.userId.toString()));
//       await prefs.setString('name', user.name);
//       await prefs.setString('role', user.role);
//       if (!mounted) return;
//       Navigator.pop(context, {
//         'user_id': user.userId,
//         'name': user.name,
//         'role': user.role,
//       });
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
//       );
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   Future<void> googleLogin() async {
//     setState(() => isGoogleLoading = true);
//     try {
//       final user = await _dataSource.googleLogin();
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('user_id', user.userId);
//       await prefs.setString('name', user.name);
//       await prefs.setString('role', user.role);
//       if (!mounted) return;
//       Navigator.pop(context, {
//         'user_id': user.userId,
//         'name': user.name,
//         'role': user.role,
//       });
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
//       );
//     } finally {
//       if (mounted) setState(() => isGoogleLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff6eadf),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: SingleChildScrollView(
//             child: Form(
//               key: formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.brown),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   const SizedBox(height: 10),
//                   const Center(
//                     child: Text(
//                       "Create your account",
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.brown,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   const Text("Your Name*", style: TextStyle(color: Colors.brown)),
//                   const SizedBox(height: 8),
//                   AuthTextField(
//                     controller: nameController,
//                     hint: "Enter your name",
//                     icon: Icons.person,
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) return "Please enter your name";
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   const Text("Email*", style: TextStyle(color: Colors.brown)),
//                   const SizedBox(height: 8),
//                   AuthTextField(
//                     controller: emailController,
//                     hint: "Enter your email",
//                     icon: Icons.email_outlined,
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) return "Please enter your email";
//                       if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
//                         return "Enter a valid email";
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   const Text("Password*", style: TextStyle(color: Colors.brown)),
//                   const SizedBox(height: 8),
//                   AuthTextField(
//                     controller: passwordController,
//                     hint: "Create your Password",
//                     icon: Icons.lock_outline,
//                     obscureText: obscurePassword,
//                     isPassword: true,
//                     onTogglePassword: () => setState(() => obscurePassword = !obscurePassword),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) return "Please enter a password";
//                       if (value.length < 8) return "Password must be at least 8 characters";
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   const Text("Confirm Password*", style: TextStyle(color: Colors.brown)),
//                   const SizedBox(height: 8),
//                   AuthTextField(
//                     controller: confirmPasswordController,
//                     hint: "Confirm password",
//                     icon: Icons.lock_outline,
//                     obscureText: obscureConfirmPassword,
//                     isPassword: true,
//                     onTogglePassword: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) return "Please confirm your password";
//                       if (value != passwordController.text) return "Passwords do not match";
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 30),
//                   AuthButton(
//                     text: "Sign Up",
//                     isLoading: isLoading,
//                     onPressed: signUp,
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Expanded(child: Divider(color: Colors.brown.withOpacity(0.3))),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         child: Text(
//                           "or continue with",
//                           style: TextStyle(color: Colors.brown.withOpacity(0.7), fontSize: 13),
//                         ),
//                       ),
//                       Expanded(child: Divider(color: Colors.brown.withOpacity(0.3))),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   GestureDetector(
//                     onTap: isGoogleLoading ? null : googleLogin,
//                     child: Container(
//                       width: double.infinity,
//                       height: 54,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(color: Colors.brown.withOpacity(0.2)),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: isGoogleLoading
//                           ? const Center(
//                               child: SizedBox(
//                                 height: 22,
//                                 width: 22,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.brown,
//                                 ),
//                               ),
//                             )
//                           : Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Image.asset(
//                                   "assets/images/google.png",
//                                   height: 24,
//                                   width: 24,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 const Text(
//                                   "Continue with Google",
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   Center(
//                     child: GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: const Text.rich(
//                         TextSpan(
//                           text: "Already have an account? ",
//                           style: TextStyle(color: Colors.black54),
//                           children: [
//                             TextSpan(
//                               text: "log in",
//                               style: TextStyle(
//                                 color: Colors.brown,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  late final SignupUseCase signupUseCase;
  late final AuthRemoteDataSource _dataSource;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  bool isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _dataSource = AuthRemoteDataSource();
    final repository = AuthRepositoryImpl(remoteDataSource: _dataSource);
    signupUseCase = SignupUseCase(repository);
  }

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final user = await signupUseCase(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.userId);
      await prefs.setString('name', user.name);
      await prefs.setString('role', user.role);

      if (!mounted) return;
      Navigator.pop(context, {
        'user_id': user.userId,
        'name': user.name,
        'role': user.role,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> googleLogin() async {
    setState(() => isGoogleLoading = true);
    try {
      final user = await _dataSource.googleLogin();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.userId);
      await prefs.setString('name', user.name);
      await prefs.setString('role', user.role);

      if (!mounted) return;
      Navigator.pop(context, {
        'user_id': user.userId,
        'name': user.name,
        'role': user.role,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => isGoogleLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
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
                  const Text("Your Name*", style: TextStyle(color: Colors.brown)),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: nameController,
                    hint: "Enter your name",
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Please enter your name";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text("Email*", style: TextStyle(color: Colors.brown)),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: emailController,
                    hint: "Enter your email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter your email";
                      if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text("Password*", style: TextStyle(color: Colors.brown)),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: passwordController,
                    hint: "Create your Password",
                    icon: Icons.lock_outline,
                    obscureText: obscurePassword,
                    isPassword: true,
                    onTogglePassword: () => setState(() => obscurePassword = !obscurePassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter a password";
                      if (value.length < 8) return "Password must be at least 8 characters";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text("Confirm Password*", style: TextStyle(color: Colors.brown)),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: confirmPasswordController,
                    hint: "Confirm password",
                    icon: Icons.lock_outline,
                    obscureText: obscureConfirmPassword,
                    isPassword: true,
                    onTogglePassword: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please confirm your password";
                      if (value != passwordController.text) return "Passwords do not match";
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  AuthButton(
                    text: "Sign Up",
                    isLoading: isLoading,
                    onPressed: signUp,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.brown.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "or continue with",
                          style: TextStyle(color: Colors.brown.withOpacity(0.7), fontSize: 13),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.brown.withOpacity(0.3))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: isGoogleLoading ? null : googleLogin,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.brown.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isGoogleLoading
                          ? const Center(
                              child: SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.brown,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/google.png",
                                  height: 24,
                                  width: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                        if (!mounted || result == null) return;
                        Navigator.pop(context, result);
                      },
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
}