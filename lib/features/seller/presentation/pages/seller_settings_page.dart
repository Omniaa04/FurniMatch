// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:furnimatch/api_config.dart';

// class SellerSettingsPage extends StatefulWidget {
//   final int sellerId;
//   final int storeId;

//   const SellerSettingsPage({
//     super.key,
//     required this.sellerId,
//     required this.storeId,
//   });

//   @override
//   State<SellerSettingsPage> createState() => _SellerSettingsPageState();
// }

// class _SellerSettingsPageState extends State<SellerSettingsPage> {
//   final Color brown = const Color(0xFF875A42);
//   final Color background = const Color(0xFFF6F0E9);

//   final TextEditingController sellerNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController storeNameController = TextEditingController();
//   final TextEditingController ownerNameController = TextEditingController();
//   final TextEditingController storeAddressController = TextEditingController();

//   bool isLoading = true;
//   bool isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     loadSettings();
//   }

//   Future<void> loadSettings() async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//           '${ApiConfig.baseUrl}/seller/settings/${widget.sellerId}/${widget.storeId}',
//         ),
//         headers: {"ngrok-skip-browser-warning": "true"},
//       );

//       final data = jsonDecode(response.body);

//       if (!mounted) return;

//       if (response.statusCode == 200 && data["success"] == true) {
//         sellerNameController.text = data["profile"]["name"] ?? "";
//         emailController.text = data["profile"]["email"] ?? "";
//         storeNameController.text = data["store"]["store_name"] ?? "";
//         ownerNameController.text = data["store"]["owner_name"] ?? "";
//         storeAddressController.text = data["store"]["business_address"] ?? "";
//       } else {
//         _showMessage(data["message"] ?? "Failed to load settings");
//       }
//     } catch (e) {
//       if (!mounted) return;
//       _showMessage("Server error: $e");
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   Future<void> saveSettings() async {
//     if (sellerNameController.text.trim().isEmpty ||
//         emailController.text.trim().isEmpty ||
//         storeNameController.text.trim().isEmpty ||
//         ownerNameController.text.trim().isEmpty ||
//         storeAddressController.text.trim().isEmpty) {
//       _showMessage("Please fill all fields");
//       return;
//     }

//     setState(() => isSaving = true);

//     try {
//       final profileResponse = await http.put(
//         Uri.parse(
//           '${ApiConfig.baseUrl}/seller/settings/profile/${widget.sellerId}',
//         ),
//         headers: {
//           "Content-Type": "application/json",
//           "ngrok-skip-browser-warning": "true",
//         },
//         body: jsonEncode({
//           "name": sellerNameController.text.trim(),
//           "email": emailController.text.trim(),
//         }),
//       );

//       final profileData = jsonDecode(profileResponse.body);

//       if (profileResponse.statusCode != 200 || profileData["success"] != true) {
//         _showMessage(profileData["message"] ?? "Profile update failed");
//         return;
//       }

//       final storeResponse = await http.put(
//         Uri.parse(
//           '${ApiConfig.baseUrl}/seller/settings/store/${widget.sellerId}/${widget.storeId}',
//         ),
//         headers: {
//           "Content-Type": "application/json",
//           "ngrok-skip-browser-warning": "true",
//         },
//         body: jsonEncode({
//           "store_name": storeNameController.text.trim(),
//           "owner_name": ownerNameController.text.trim(),
//           "business_address": storeAddressController.text.trim(),
//         }),
//       );

//       final storeData = jsonDecode(storeResponse.body);

//       if (storeResponse.statusCode == 200 && storeData["success"] == true) {
//         _showMessage("Settings saved successfully");
//         if (mounted)
//           Navigator.pop(
//               context, ownerNameController.text.trim()); // أضيفي السطر ده
//       } else {
//         _showMessage(storeData["message"] ?? "Store update failed");
//       }
//     } catch (e) {
//       _showMessage("Server error: $e");
//     } finally {
//       if (mounted) {
//         setState(() => isSaving = false);
//       }
//     }
//   }

//   Future<void> showChangePasswordDialog() async {
//     final oldPasswordController = TextEditingController();
//     final newPasswordController = TextEditingController();
//     final confirmPasswordController = TextEditingController();

//     await showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: background,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Text(
//             "Change Password",
//             style: TextStyle(color: brown, fontWeight: FontWeight.bold),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _passwordField("Old Password", oldPasswordController),
//               const SizedBox(height: 12),
//               _passwordField("New Password", newPasswordController),
//               const SizedBox(height: 12),
//               _passwordField("Confirm Password", confirmPasswordController),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: brown),
//               onPressed: () async {
//                 final oldPass = oldPasswordController.text.trim();
//                 final newPass = newPasswordController.text.trim();
//                 final confirmPass = confirmPasswordController.text.trim();

//                 if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
//                   _showMessage("Please fill all password fields");
//                   return;
//                 }
//                 if (newPass != confirmPass) {
//                   _showMessage("Passwords do not match");
//                   return;
//                 }
//                 if (newPass.length < 8) {
//                   _showMessage("Password must be at least 8 characters");
//                   return;
//                 }

//                 Navigator.pop(dialogContext); // اقفلي الـ dialog الأول

//                 try {
//                   final response = await http.post(
//                     Uri.parse(
//                       '${ApiConfig.baseUrl}/seller/settings/security/${widget.sellerId}',
//                     ),
//                     headers: {
//                       "Content-Type": "application/json",
//                       "ngrok-skip-browser-warning": "true",
//                     },
//                     body: jsonEncode({
//                       "old_password": oldPass,
//                       "new_password": newPass,
//                     }),
//                   );

//                   final data = jsonDecode(response.body);

//                   if (!mounted) return;

//                   if (response.statusCode == 200 && data["success"] == true) {
//                     _showMessage("Password changed successfully");
//                   } else {
//                     _showMessage(data["message"] ?? "Password change failed");
//                   }
//                 } catch (e) {
//                   if (!mounted) return;
//                   _showMessage("Server error: $e");
//                 }
//               },
//               child: const Text(
//                 "Save",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     oldPasswordController.dispose();
//     newPasswordController.dispose();
//     confirmPasswordController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         backgroundColor: brown,
//         elevation: 0,
//         title: const Text(
//           "Settings",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator(color: brown))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(18),
//               child: Column(
//                 children: [
//                   _sectionTitle("Profile Settings"),
//                   _card([
//                     _textField(
//                       "Email",
//                       emailController,
//                       Icons.email,
//                     ),
//                   ]),
//                   const SizedBox(height: 20),
//                   _sectionTitle("Store Settings"),
//                   _card([
//                     _textField(
//                       "Store Name",
//                       storeNameController,
//                       Icons.store,
//                     ),
//                     _textField(
//                       "Owner Name",
//                       ownerNameController,
//                       Icons.badge,
//                     ),
//                     _textField(
//                       "Store Address",
//                       storeAddressController,
//                       Icons.location_on,
//                     ),
//                   ]),
//                   const SizedBox(height: 20),
//                   _sectionTitle("Security"),
//                   _card([
//                     ListTile(
//                       leading: Icon(Icons.lock, color: brown),
//                       title: Text(
//                         "Change Password",
//                         style: TextStyle(
//                           color: brown,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       trailing: Icon(
//                         Icons.arrow_forward_ios,
//                         color: brown,
//                         size: 18,
//                       ),
//                       onTap: showChangePasswordDialog,
//                     ),
//                   ]),
//                   const SizedBox(height: 25),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 52,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: brown,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                       ),
//                       onPressed: isSaving ? null : saveSettings,
//                       child: isSaving
//                           ? const CircularProgressIndicator(
//                               color: Colors.white,
//                             )
//                           : const Text(
//                               "Save Changes",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 10),
//         child: Text(
//           title,
//           style: TextStyle(
//             color: brown,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _card(List<Widget> children) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(children: children),
//     );
//   }

//   Widget _textField(
//     String label,
//     TextEditingController controller,
//     IconData icon,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, color: brown),
//           labelText: label,
//           labelStyle: TextStyle(color: brown),
//           filled: true,
//           fillColor: background,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _passwordField(
//     String label,
//     TextEditingController controller,
//   ) {
//     return TextField(
//       controller: controller,
//       obscureText: true,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: brown),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//       ),
//     );
//   }

//   void _showMessage(String message) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   @override
//   void dispose() {
//     sellerNameController.dispose();
//     emailController.dispose();
//     storeNameController.dispose();
//     ownerNameController.dispose();
//     storeAddressController.dispose();
//     super.dispose();
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';

class SellerSettingsPage extends StatefulWidget {
  final int sellerId;
  final int storeId;

  const SellerSettingsPage({
    super.key,
    required this.sellerId,
    required this.storeId,
  });

  @override
  State<SellerSettingsPage> createState() => _SellerSettingsPageState();
}

class _SellerSettingsPageState extends State<SellerSettingsPage> {
  final Color brown = const Color(0xFF875A42);
  final Color background = const Color(0xFFF6F0E9);

  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController storeAddressController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/seller/settings/${widget.sellerId}/${widget.storeId}',
        ),
         headers: {
        "ngrok-skip-browser-warning": "true",  // Add this
        "Content-Type": "application/json",     // Add this
      },
       
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data["success"] == true) {
        sellerNameController.text = data["profile"]["name"] ?? "";
        emailController.text = data["profile"]["email"] ?? "";
        storeNameController.text = data["store"]["store_name"] ?? "";
        ownerNameController.text = data["store"]["owner_name"] ?? "";
        storeAddressController.text = data["store"]["business_address"] ?? "";
      } else {
        _showMessage(data["message"] ?? "Failed to load settings");
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage("Server error: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> saveSettings() async {
    if (sellerNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        storeNameController.text.trim().isEmpty ||
        ownerNameController.text.trim().isEmpty ||
        storeAddressController.text.trim().isEmpty) {
      _showMessage("Please fill all fields");
      return;
    }

    setState(() => isSaving = true);

    try {
      final profileResponse = await http.put(
        Uri.parse(
          '${ApiConfig.baseUrl}/seller/settings/profile/${widget.sellerId}',
        ),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "name": sellerNameController.text.trim(),
          "email": emailController.text.trim(),
        }),
      );

      final profileData = jsonDecode(profileResponse.body);

      if (profileResponse.statusCode != 200 || profileData["success"] != true) {
        _showMessage(profileData["message"] ?? "Profile update failed");
        return;
      }

      final storeResponse = await http.put(
        Uri.parse(
          '${ApiConfig.baseUrl}/seller/settings/store/${widget.sellerId}/${widget.storeId}',
        ),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "store_name": storeNameController.text.trim(),
          "owner_name": ownerNameController.text.trim(),
          "business_address": storeAddressController.text.trim(),
        }),
      );

      final storeData = jsonDecode(storeResponse.body);

      if (storeResponse.statusCode == 200 && storeData["success"] == true) {
        _showMessage("Settings saved successfully");
        if (mounted) Navigator.pop(context, storeNameController.text.trim());
      } else {
        _showMessage(storeData["message"] ?? "Store update failed");
      }
    } catch (e) {
      _showMessage("Server error: $e");
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> showChangePasswordDialog() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Change Password",
            style: TextStyle(color: brown, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _passwordField("Old Password", oldPasswordController),
              const SizedBox(height: 12),
              _passwordField("New Password", newPasswordController),
              const SizedBox(height: 12),
              _passwordField("Confirm Password", confirmPasswordController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: brown),
              onPressed: () async {
                final oldPass = oldPasswordController.text.trim();
                final newPass = newPasswordController.text.trim();
                final confirmPass = confirmPasswordController.text.trim();

                if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                  _showMessage("Please fill all password fields");
                  return;
                }
                if (newPass != confirmPass) {
                  _showMessage("Passwords do not match");
                  return;
                }
                if (newPass.length < 8) {
                  _showMessage("Password must be at least 8 characters");
                  return;
                }

                Navigator.pop(dialogContext);

                try {
                  final response = await http.post(
                    Uri.parse(
                      '${ApiConfig.baseUrl}/seller/settings/security/${widget.sellerId}',
                    ),
                    headers: {
                      "Content-Type": "application/json",
                      "ngrok-skip-browser-warning": "true",
                    },
                    body: jsonEncode({
                      "old_password": oldPass,
                      "new_password": newPass,
                    }),
                  );

                  final data = jsonDecode(response.body);

                  if (!mounted) return;

                  if (response.statusCode == 200 && data["success"] == true) {
                    _showMessage("Password changed successfully");
                  } else {
                    _showMessage(data["message"] ?? "Password change failed");
                  }
                } catch (e) {
                  if (!mounted) return;
                  _showMessage("Server error: $e");
                }
              },
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: brown,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: brown))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _sectionTitle("Profile Settings"),
                  _card([
                    _textField("Email", emailController, Icons.email),
                  ]),
                  const SizedBox(height: 20),
                  _sectionTitle("Store Settings"),
                  _card([
                    _textField("Store Name", storeNameController, Icons.store),
                    _textField("Owner Name", ownerNameController, Icons.badge),
                    _textField("Store Address", storeAddressController, Icons.location_on),
                  ]),
                  const SizedBox(height: 20),
                  _sectionTitle("Security"),
                  _card([
                    ListTile(
                      leading: Icon(Icons.lock, color: brown),
                      title: Text(
                        "Change Password",
                        style: TextStyle(color: brown, fontWeight: FontWeight.w600),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: brown, size: 18),
                      onTap: showChangePasswordDialog,
                    ),
                  ]),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: isSaving ? null : saveSettings,
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: TextStyle(color: brown, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _textField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: brown),
          labelText: label,
          labelStyle: TextStyle(color: brown),
          filled: true,
          fillColor: background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: brown),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    sellerNameController.dispose();
    emailController.dispose();
    storeNameController.dispose();
    ownerNameController.dispose();
    storeAddressController.dispose();
    super.dispose();
  }
}