// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:furnimatch/features/profile/presentation/pages/edit_profile_page.dart';
// import 'package:furnimatch/features/profile/presentation/pages/about_us_page.dart';
// import 'package:furnimatch/api_config.dart';

// const Color _primaryColor = Color(0xFF5D4037);
// const Color _backgroundColor = Color(0xFFF6F0E9);
// const Color _cardBackgroundColor = Color(0xFFFAF0E6);
// const Color _buttonColor = Color(0xFFA1887F);
// const Color _iconColorGold = Color(0xFFFDD835);

// class MyProfilePage extends StatefulWidget {
//   final int userId;
//   final String currentName;
//   final VoidCallback? onBackToHome;

//   const MyProfilePage({
//     super.key,
//     required this.userId,
//     required this.currentName,
//     this.onBackToHome,
//   });

//   @override
//   State<MyProfilePage> createState() => _MyProfilePageState();
// }

// class _MyProfilePageState extends State<MyProfilePage> {
//   String userName = '';
//   String userEmail = '';
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     userName = widget.currentName;
//     fetchProfile();
//   }

//   Future<void> fetchProfile() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${ApiConfig.baseUrl}/user/${widget.userId}'),
//         headers: {"ngrok-skip-browser-warning": "true"},
//       );

//       final data = jsonDecode(response.body);

//       if (data['success'] == true) {
//         setState(() {
//           userName = data['user']['name'] ?? widget.currentName;
//           userEmail = data['user']['email'] ?? '';
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }

//   String buildUserHandle(String name) {
//     return "@${name.toLowerCase().replaceAll(' ', '')}";
//   }

//   @override
//   Widget build(BuildContext context) {
//     const String profileImageUrl = 'assets/sample2.png';

//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: _primaryColor),
//             )
//           : SafeArea(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
//                 child: Container(
//                   padding: const EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: _cardBackgroundColor,
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           IconButton(
//                             icon: const Icon(
//                               Icons.arrow_back,
//                               color: _primaryColor,
//                               size: 24,
//                             ),
//                             onPressed: widget.onBackToHome ??
//                                 () => Navigator.pop(context, userName),
//                           ),
//                           const Text(
//                             'My Profile',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: _primaryColor,
//                             ),
//                           ),
//                           const SizedBox(width: 48),
//                         ],
//                       ),
//                       const SizedBox(height: 30),
//                       Row(
//                         children: <Widget>[
//                           CircleAvatar(
//                             radius: 35,
//                             backgroundImage: const AssetImage(profileImageUrl),
//                             backgroundColor: _buttonColor.withOpacity(0.5),
//                           ),
//                           const SizedBox(width: 15),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 Text(
//                                   userName,
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: _primaryColor,
//                                   ),
//                                 ),
//                                 Text(
//                                   buildUserHandle(userName),
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: _primaryColor.withOpacity(0.7),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 InkWell(
//                                   onTap: () async {
//                                     final updatedName = await Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => EditProfilePage(
//                                           userId: widget.userId,
//                                           currentName: userName,
//                                         ),
//                                       ),
//                                     );

//                                     if (updatedName != null &&
//                                         updatedName is String) {
//                                       setState(() {
//                                         userName = updatedName;
//                                       });
//                                       Navigator.pop(context, updatedName);
//                                     }
//                                   },
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 10,
//                                       vertical: 5,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: _buttonColor,
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: const Text(
//                                       'Edit Profile',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 30),
//                       _buildSectionHeader('Profile'),
//                       _buildProfileItem(
//                         'Points',
//                         Icons.star_border,
//                         iconColor: _iconColorGold,
//                       ),
//                       _buildProfileItem(
//                         'My orders',
//                         Icons.shopping_bag_outlined,
//                       ),
//                       _buildProfileItem(
//                         'Payment Methods',
//                         Icons.payment_outlined,
//                       ),
//                       _buildProfileItem(
//                         'Our Policy',
//                         Icons.description_outlined,
//                       ),
//                       const SizedBox(height: 30),
//                       _buildSectionHeader('Setting'),
//                       _buildProfileItem("FAQ's", Icons.person_outline),
//                       _buildProfileItem(
//                         'Help Center',
//                         Icons.headset_mic_outlined,
//                       ),
//                       _buildProfileItem(
//                         'About Us',
//                         Icons.groups_outlined,
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const AboutUsPage(),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 30),
//                       _buildSectionHeader('Log out'),
//                       _buildProfileItem(
//                         'Log out',
//                         Icons.logout,
//                         isLogout: true,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10.0),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: _primaryColor,
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileItem(
//     String title,
//     IconData icon, {
//     Color iconColor = _primaryColor,
//     bool isLogout = false,
//     VoidCallback? onTap,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _buttonColor.withOpacity(0.5), width: 0.5),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
//         leading: Icon(icon, color: iconColor),
//         title: Text(
//           title,
//           style: TextStyle(color: isLogout ? Colors.red : _primaryColor),
//         ),
//         trailing: isLogout
//             ? null
//             : const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: _primaryColor,
//               ),
//         onTap: onTap ?? () {},
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:furnimatch/api_config.dart';

class MyProfilePage extends StatefulWidget {
  final int userId;
  final String currentName;
  final VoidCallback? onBackToHome;

  const MyProfilePage({
    super.key,
    required this.userId,
    required this.currentName,
    this.onBackToHome,
  });

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final TextEditingController nameController = TextEditingController();

  String userEmail = '';
  String? profileImageUrl;
  bool isLoading = true;
  bool isSaving = false;
  Uint8List? selectedImageBytes;

  static const Color darkBrown = Color(0xFF7D533D);
  static const Color mainBrown = Color(0xFF7D533D);
  static const Color background = Color(0xFFF6F0E9);
  static const Color accentBrown = Color(0xFFAD8B73);
  static const Color fieldColor = Color(0xFFEFE9E2);

  @override
  void initState() {
    super.initState();
    nameController.text = widget.currentName;
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/settings/${widget.userId}'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final settings = data['settings'];

          setState(() {
            nameController.text = settings['userName'] ?? widget.currentName;
            userEmail = settings['userEmail'] ?? '';
            profileImageUrl = settings['profileImagePath'];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickProfileImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 500,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        selectedImageBytes = bytes;
      });
    }
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/settings/${widget.userId}');
      final request = http.MultipartRequest('PUT', uri);

      request.headers['ngrok-skip-browser-warning'] = 'true';
      request.fields['userName'] = name;

      if (selectedImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            selectedImageBytes!,
            filename: 'profile_${widget.userId}.jpg',
          ),
        );
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(responseBody);

        if (data['success'] == true) {
          final settings = data['settings'];

          setState(() {
            profileImageUrl = settings['profileImagePath'];
            isSaving = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: mainBrown,
            ),
          );

          Navigator.pop(context, name);
        } else {
          setState(() => isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to save')),
          );
        }
      } else {
        setState(() => isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error ${streamedResponse.statusCode}'),
          ),
        );
      }
    } catch (e) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  ImageProvider? getProfileImage() {
    if (selectedImageBytes != null) {
      return MemoryImage(selectedImageBytes!);
    }

    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return NetworkImage(profileImageUrl!);
    }

    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = getProfileImage();

    return Scaffold(
      backgroundColor: background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: mainBrown))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: widget.onBackToHome ??
                              () => Navigator.pop(context, nameController.text),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: darkBrown,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: darkBrown,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: pickProfileImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 135,
                                  height: 135,
                                  decoration: BoxDecoration(
                                    color: accentBrown,
                                    borderRadius: BorderRadius.circular(34),
                                    image: imageProvider != null
                                        ? DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: imageProvider == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 58,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: mainBrown,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: background,
                                        width: 3,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tap to change photo',
                            style: TextStyle(
                              color: accentBrown,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Text(
                      'Username',
                      style: TextStyle(
                        color: darkBrown,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.alternate_email, color: mainBrown),
                        filled: true,
                        fillColor: fieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Email',
                      style: TextStyle(
                        color: darkBrown,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      enabled: false,
                      controller: TextEditingController(text: userEmail),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: mainBrown,
                        ),
                        suffixIcon: const Icon(
                          Icons.lock_outline,
                          color: accentBrown,
                        ),
                        filled: true,
                        fillColor: fieldColor,
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email cannot be changed',
                      style: const TextStyle(
                        color: accentBrown,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainBrown,
                          disabledBackgroundColor: accentBrown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
