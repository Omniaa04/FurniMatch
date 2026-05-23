import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';

class EditProfilePage extends StatefulWidget {
  final int userId;
  final String currentName;

  const EditProfilePage({
    super.key,
    required this.userId,
    required this.currentName,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  bool isSaving = false;
  String? nameError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
  }

 Future<void> saveName() async {
  print('=== saveName called ===');
  
  final name = nameController.text.trim();
  print('Name: $name');

  if (name.isEmpty) {
    setState(() => nameError = "Please enter your name");
    return;
  }

  setState(() {
    isSaving = true;
    nameError = null;
  });

  try {
    print('Step 1: Getting baseUrl...');
    final baseUrl = ApiConfig.baseUrl;
    print('Step 2: baseUrl = $baseUrl');

    final uri = Uri.parse('$baseUrl/user/update-name');
    print('Step 3: URI = $uri');

    final body = jsonEncode({'userId': widget.userId, 'name': name});
    print('Step 4: Body = $body');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    print('Step 5: Response status = ${response.statusCode}');
    print('Step 6: Response body = ${response.body}');

    if (!mounted) return;

    if (response.statusCode == 200) {
      Navigator.pop(context, name);
    } else {
      setState(() {
        nameError = 'Server error ${response.statusCode}: ${response.body}';
        isSaving = false;
      });
    }
  } catch (e, stack) {
    print('=== CRASH CAUGHT ===');
    print('Error: $e');
    print('Stack: $stack');

    if (!mounted) return;
    setState(() {
      nameError = e.toString();
      isSaving = false;
    });
  } finally {
    if (mounted && isSaving) {
      setState(() => isSaving = false);
    }
  }
}

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF8B5E3C);
    const bg = Color(0xFFF6F0E9);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2EC),
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: brown),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: brown,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: isSaving ? null : saveName,
                      icon: isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check, color: brown),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: brown,
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: bg,
                          child: Text(
                            widget.currentName.isNotEmpty ? widget.currentName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: brown,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Change Photo",
                        style: TextStyle(
                          color: brown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Name",
                  style: TextStyle(
                    color: brown,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: nameController,
                  onChanged: (_) {
                    if (nameError != null) {
                      setState(() {
                        nameError = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Enter your name",
                    hintStyle: const TextStyle(color: Colors.grey),
                    errorText: nameError,
                    errorStyle: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: brown, width: 1.5),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}