import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xFF5D4037); 
const Color _cardBackgroundColor = Color(0xFFFAF0E6); 
const Color _buttonColor = Color(0xFFA1887F); 

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const String profileImageUrl = 'assets/sample2.png'; 

    return Scaffold(
      backgroundColor: _cardBackgroundColor,
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 25.0, right: 25.0),
          child: Column(
            children: <Widget>[
             
              _buildAppBar(context),
              const SizedBox(height: 30),
              _buildProfileImageArea(profileImageUrl),
              const SizedBox(height: 50),

            
              _buildInputField(label: 'First Name', initialValue: 'Rana'),
              const SizedBox(height: 20),
              _buildInputField(label: 'Second Name', initialValue: 'Ahmed'),
              const SizedBox(height: 20),
              _buildInputField(label: 'Username', initialValue: '@rana011ee'),
              
              
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
     
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  
  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
       
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        
        Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
      ],
    );
  }


  Widget _buildProfileImageArea(String imageUrl) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage(imageUrl), 
          backgroundColor: _buttonColor.withOpacity(0.5),
        ),
        const SizedBox(height: 10),
        Text(
          'Change Photo',
          style: TextStyle(
            color: _primaryColor.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  
  Widget _buildInputField({required String label, required String initialValue}) {
    
    return Stack(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: _primaryColor, 
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
          child: TextFormField(
            initialValue: initialValue,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            cursorColor: Colors.white,
          ),
        ),
       
        Positioned(
          top: 5,
          left: 15,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _cardBackgroundColor, 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavBarItem(Icons.home_outlined, 'Home', false),
          _buildNavBarItem(Icons.favorite_border, 'Favorites', false),
          _buildNavBarItem(Icons.notifications_none, 'Notifications', false),
          _buildNavBarItem(Icons.card_giftcard, '3D model', false), 
          _buildNavBarItem(Icons.shopping_cart_outlined, 'Cart', false),
          _buildNavBarItem(Icons.person, 'Profile', true), 
        ],
      ),
    );
  }

 
  Widget _buildNavBarItem(IconData icon, String label, bool isActive) {
    Color color = isActive ? _primaryColor : _buttonColor.withOpacity(0.7);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}