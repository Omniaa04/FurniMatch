import 'package:flutter/material.dart';
import 'EditProfilePage.dart';
import 'AboutUs.dart'; 

const Color _primaryColor = Color(0xFF5D4037);
const Color _backgroundColor = Color(0xFFF7F4F0);
const Color _cardBackgroundColor = Color(0xFFFAF0E6);
const Color _buttonColor = Color(0xFFA1887F);
const Color _iconColorGold = Color(0xFFFDD835);

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const String profileImageUrl = 'assets/sample2.png';

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
              top: 50.0, left: 20.0, right: 20.0, bottom: 20.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _cardBackgroundColor,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: _primaryColor, size: 24),
                      onPressed: () {},
                    ),
                    Text(
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

                // Profile Info
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage(profileImageUrl),
                      backgroundColor: _buttonColor.withOpacity(0.5),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Rana Ahmed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        Text(
                          '@rana011ee',
                          style: TextStyle(
                            fontSize: 14,
                            color: _primaryColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfilePage()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _buttonColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Edit Profile',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                _buildSectionHeader(context, 'Profile'),
                _buildProfileItem(context, 'Points', Icons.star_border,
                    iconColor: _iconColorGold),
                _buildProfileItem(
                    context, 'My orders', Icons.shopping_bag_outlined),
                _buildProfileItem(
                    context, 'Payment Methods', Icons.payment_outlined),
                _buildProfileItem(
                    context, 'Our Policy', Icons.description_outlined),

                const SizedBox(height: 30),

                _buildSectionHeader(context, 'Setting'),
                _buildProfileItem(context, 'FAQ\'s', Icons.person_outline),
                _buildProfileItem(
                    context, 'Help Center', Icons.headset_mic_outlined),

               
                _buildProfileItem(
                  context,
                  'About Us',
                  Icons.groups_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutUsPage()),
                    );
                  },
                ),

                const SizedBox(height: 30),

                _buildSectionHeader(context, 'Log out'),
                _buildProfileItem(context, 'Log out', Icons.logout,
                    isLogout: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    String title,
    IconData icon, {
    Color iconColor = _primaryColor,
    bool isLogout = false,
    VoidCallback? onTap, // ✅ parameter جديد
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
            : const Icon(Icons.arrow_forward_ios,
                size: 16, color: _primaryColor),
        onTap: onTap ?? () => print('Tapped on $title'), // ✅ يستخدم onTap لو موجود
      ),
    );
  }
}