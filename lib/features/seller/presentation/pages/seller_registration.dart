import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:furnimatch/api_config.dart';
import 'package:furnimatch/features/seller/presentation/pages/seller_dashboard_page.dart';
import 'package:furnimatch/features/seller/presentation/pages/seller_login_page.dart';

class SellerRegistrationPage extends StatefulWidget {
  final int userId;

  const SellerRegistrationPage({super.key, this.userId = 0});

  @override
  State<SellerRegistrationPage> createState() => _SellerRegistrationPageState();
}

class _SellerRegistrationPageState extends State<SellerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  Uint8List? idFileBytes;
  String? idFileName;
  Uint8List? businessDocBytes;
  String? businessDocName;
  bool showErrors = false;
  bool isLoading = false;

  Future<void> registerSeller() async {
    setState(() => isLoading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/seller/register'),
      );

      request.fields['store_name'] = storeNameController.text;
      request.fields['owner_name'] = ownerNameController.text;
      request.fields['business_address'] = addressController.text;
      request.fields['email'] = emailController.text;
      request.fields['password'] = passwordController.text;

      if (idFileBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'id_file',
          idFileBytes!,
          filename: idFileName ?? 'id.jpg',
        ));
      }

      if (businessDocBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'business_doc',
          businessDocBytes!,
          filename: businessDocName ?? 'business.jpg',
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (!mounted) return;

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SellerDashboardPage(
              storeId: data['store_id'],
              sellerId: data['user_id'],
              sellerName: storeNameController.text,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
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
                    "Seller Registration",
                    style: TextStyle(
                      color: Colors.brown,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _label("Store name*"),
                      _textField(
                        controller: storeNameController,
                        icon: Icons.storefront_outlined,
                        hint: "Enter store name",
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Store name is required.";
                          }
                          if (v.length < 3) {
                            return "Store name must be at least 3 characters.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _label("Owner name*"),
                      _textField(
                        controller: ownerNameController,
                        icon: Icons.person_outline,
                        hint: "Enter owner name",
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Owner name is required.";
                          }
                          if (!RegExp(r"^[A-Za-z ]+$").hasMatch(v)) {
                            return "Name must contain only letters.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _label("Business Address*"),
                      _textField(
                        controller: addressController,
                        icon: Icons.location_on_outlined,
                        hint: "Enter business address",
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Business address is required.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _label("Email*"),
                      _textField(
                        controller: emailController,
                        icon: Icons.email_outlined,
                        hint: "Enter your email",
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Email is required.";
                          }
                          if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                              .hasMatch(v)) {
                            return "Enter a valid email.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _label("Password*"),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Password is required.";
                          }
                          if (v.length < 8) {
                            return "Password must be at least 8 characters.";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.brown),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.brown,
                            ),
                            onPressed: () => setState(
                              () => obscurePassword = !obscurePassword,
                            ),
                          ),
                          hintText: "Create password",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _label("Upload ID / Passport*"),
                      _uploadField(
                        label: idFileName ?? "Upload ID / Passport",
                        icon: Icons.credit_card_rounded,
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                            withData: true,
                          );
                          if (result != null) {
                            setState(() {
                              idFileBytes = result.files.single.bytes;
                              idFileName = result.files.single.name;
                            });
                          }
                        },
                      ),
                      if (showErrors && idFileBytes == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            "Please upload your ID/Passport",
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      const SizedBox(height: 20),
                      _label("Business Registration Document*"),
                      _uploadField(
                        label: businessDocName ?? "Upload Business Document",
                        icon: Icons.description_outlined,
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                            withData: true,
                          );
                          if (result != null) {
                            setState(() {
                              businessDocBytes = result.files.single.bytes;
                              businessDocName = result.files.single.name;
                            });
                          }
                        },
                      ),
                      if (showErrors && businessDocBytes == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            "Please upload your registration document",
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      const SizedBox(height: 30),
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
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() => showErrors = true);
                                  final valid =
                                      _formKey.currentState!.validate();
                                  final uploadsValid = idFileBytes != null &&
                                      businessDocBytes != null;
                                  if (valid && uploadsValid) {
                                    registerSeller();
                                  }
                                },
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "Continue",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SellerLoginPage(),
                            ),
                          );
                          if (!mounted) {
                            return;
                          }
                          if (result != null) {
                            navigator.pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => SellerDashboardPage(
                                  storeId: result['store_id'],
                                  sellerId: result['user_id'],
                                  sellerName: result['name'],
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.black54),
                            children: [
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  color: Colors.brown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child:
          Text(text, style: const TextStyle(color: Colors.brown, fontSize: 16)),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.brown),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }

  Widget _uploadField({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.brown.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.brown),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
            const Icon(Icons.add, color: Colors.brown),
          ],
        ),
      ),
    );
  }
}
