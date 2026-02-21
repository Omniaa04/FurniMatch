import 'package:flutter/material.dart';
import 'seller_dashboard_page.dart';

class SellerRegistrationPage extends StatefulWidget {
  const SellerRegistrationPage({super.key});

  @override
  State<SellerRegistrationPage> createState() => _SellerRegistrationPageState();
}

class _SellerRegistrationPageState extends State<SellerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? idFile;
  String? businessDoc;

  bool showErrors = false; // تظهر الرسائل بعد الضغط على Continue فقط

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

                      // ------------------ UPLOAD ID ------------------
                      _label("Upload ID / Passport*"),
                      _uploadField(
                        label: idFile ?? "Upload ID / Passport",
                        icon: Icons.credit_card_rounded,
                        onTap: () {
                          setState(() => idFile = "uploaded");
                        },
                      ),

                      if (showErrors && idFile == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            "Please upload your ID/Passport",
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // ------------------ UPLOAD BUSINESS DOC ------------------
                      _label("Business Registration Document*"),
                      _uploadField(
                        label: businessDoc ?? "Upload Business Document",
                        icon: Icons.description_outlined,
                        onTap: () {
                          setState(() => businessDoc = "uploaded");
                        },
                      ),

                      if (showErrors && businessDoc == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            "Please upload your registration document",
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),

                      const SizedBox(height: 30),

                      // ------------------ BUTTON ------------------
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
                            setState(() {
                              showErrors = true; // إظهار رسائل الرفع
                            });

                            final valid = _formKey.currentState!.validate();
                            final uploadsValid = idFile != null && businessDoc != null;

                            if (valid && uploadsValid) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SellerDashboardPage(),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Continue",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "By continuing, you agree to our Terms of services and Privacy policy",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
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

  // ------------------ WIDGETS ------------------

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(color: Colors.brown, fontSize: 16),
      ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
        ),
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
          border: Border.all(color: Colors.brown.withOpacity(0.4)),
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

