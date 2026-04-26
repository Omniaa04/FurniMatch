import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:furnimatch/features/profile/pages/edit_profile_page.dart';
import 'package:furnimatch/features/profile/pages/about_us_page.dart';
import 'package:furnimatch/api_config.dart';

const Color _primaryColor = Color(0xFF5D4037);
const Color _backgroundColor = Color(0xFFF6F0E9);
const Color _cardBackgroundColor = Color(0xFFFAF0E6);
const Color _buttonColor = Color(0xFFA1887F);
const Color _iconColorGold = Color(0xFFFDD835);

class MyProfilePage extends StatefulWidget {
  final int userId;
  final String currentName;

  const MyProfilePage({
    super.key,
    required this.userId,
    required this.currentName,
  });

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  String userName = '';
  String userEmail = '';
  bool isLoading = true;
  int _currentIndex = 5;

  @override
  void initState() {
    super.initState();
    userName = widget.currentName;
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/${widget.userId}'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          userName = data['user']['name'] ?? widget.currentName;
          userEmail = data['user']['email'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String buildUserHandle(String name) {
    return "@${name.toLowerCase().replaceAll(' ', '')}";
  }

  void _onBottomNavTap(int index) {
  setState(() {
    _currentIndex = index;
  });

  if (index == 0) {
    Navigator.pop(context, userName);
    return;
  }

  if (index == 1) {
    Navigator.pop(context, userName);
    return;
  }

  if (index == 5) {
    return;
  }
}

  @override
  Widget build(BuildContext context) {
    const String profileImageUrl = 'assets/sample2.png';

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: _cardBackgroundColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: _primaryColor,
                              size: 24,
                            ),
                            onPressed: () => Navigator.pop(context, userName),
                          ),
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),

                      const SizedBox(height: 30),

                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: const AssetImage(profileImageUrl),
                            backgroundColor: _buttonColor.withOpacity(0.5),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor,
                                  ),
                                ),
                                Text(
                                  buildUserHandle(userName),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _primaryColor.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final updatedName = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfilePage(
                                          userId: widget.userId,
                                          currentName: userName,
                                        ),
                                      ),
                                    );

                                    if (updatedName != null &&
                                        updatedName is String) {
                                      setState(() {
                                        userName = updatedName;
                                      });
                                      Navigator.pop(context, updatedName);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _buttonColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      _buildSectionHeader('Profile'),
                      _buildProfileItem(
                        'Points',
                        Icons.star_border,
                        iconColor: _iconColorGold,
                      ),
                      _buildProfileItem(
                        'My orders',
                        Icons.shopping_bag_outlined,
                      ),
                      _buildProfileItem(
                        'Payment Methods',
                        Icons.payment_outlined,
                      ),
                      _buildProfileItem(
                        'Our Policy',
                        Icons.description_outlined,
                      ),

                      const SizedBox(height: 30),

                      _buildSectionHeader('Setting'),
                      _buildProfileItem("FAQ's", Icons.person_outline),
                      _buildProfileItem(
                        'Help Center',
                        Icons.headset_mic_outlined,
                      ),
                      _buildProfileItem(
                        'About Us',
                        Icons.groups_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutUsPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      _buildSectionHeader('Log out'),
                      _buildProfileItem(
                        'Log out',
                        Icons.logout,
                        isLogout: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: _onBottomNavTap,
  type: BottomNavigationBarType.fixed,
  backgroundColor: Colors.white,
  elevation: 8,
  selectedItemColor: const Color(0xFFEBA46E),
  unselectedItemColor: Colors.grey,
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_filled),
      label: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_outlined),
      label: "Inbox",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications_none),
      label: "Notifications",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.view_in_ar),
      label: "3D model",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart_outlined),
      label: "Cart",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      label: "Profile",
    ),
  ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    String title,
    IconData icon, {
    Color iconColor = _primaryColor,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _buttonColor.withOpacity(0.5), width: 0.5),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(color: isLogout ? Colors.red : _primaryColor),
        ),
        trailing: isLogout
            ? null
            : const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _primaryColor,
              ),
        onTap: onTap ?? () {},
      ),
    );
  }
}