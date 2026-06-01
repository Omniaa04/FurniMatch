import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:furnimatch/api_config.dart';

class MyProfilePage extends StatefulWidget {
  final int userId;
  final String currentName;
  final VoidCallback? onBackToHome;
  final Function(String)? onNameUpdated;

  const MyProfilePage({
    super.key,
    required this.userId,
    required this.currentName,
    this.onBackToHome,
    this.onNameUpdated,
  });

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(); 

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

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final settings = data['settings'];

          setState(() {
            nameController.text = settings['userName'] ?? widget.currentName;
            emailController.text = settings['userEmail'] ?? '';
            phoneController.text = settings['userPhone'] ?? ''; 
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
      debugPrint('fetchProfile error: $e');
      if (mounted) setState(() => isLoading = false);
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
      if (!mounted) return;
      setState(() {
        selectedImageBytes = bytes;
      });
    }
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim(); 

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
      request.fields['userPhone'] = phone; 

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

      if (!mounted) return;

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(responseBody);

        if (data['success'] == true) {
          final settings = data['settings'];

          setState(() {
            profileImageUrl = settings['profileImagePath'];
            phoneController.text = settings['userPhone'] ?? phone; 
            isSaving = false;
          });

          widget.onNameUpdated?.call(settings['userName'] ?? name);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: mainBrown,
            ),
          );

          if (widget.onBackToHome != null) {
            widget.onBackToHome!();
          }
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
              content:
                  Text('Server error ${streamedResponse.statusCode}')),
        );
      }
    } catch (e, stack) {
      debugPrint('=== CRASH IN saveProfile ===');
      debugPrint('Error: $e');
      debugPrint('Stack: $stack');

      if (!mounted) return;
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
    emailController.dispose();
    phoneController.dispose(); 
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
                              () =>
                                  Navigator.pop(context, nameController.text),
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
                        prefixIcon: const Icon(Icons.alternate_email,
                            color: mainBrown),
                        filled: true,
                        fillColor: fieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                              const BorderSide(color: mainBrown, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                 
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        color: darkBrown,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9+\-\s()]'),
                        ),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: mainBrown),
                        hintText: 'e.g. +20 100 000 0000',
                        hintStyle:
                            TextStyle(color: accentBrown.withOpacity(0.6)),
                        filled: true,
                        fillColor: fieldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                              const BorderSide(color: mainBrown, width: 1.5),
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
                      controller: emailController,
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
                    const Text(
                      'Email cannot be changed',
                      style: TextStyle(
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