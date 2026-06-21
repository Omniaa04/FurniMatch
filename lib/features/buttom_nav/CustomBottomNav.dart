import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  final int cartCount;
  final int inboxCount;
  final int notifCount; //  one clean parameter

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
    this.inboxCount = 0,
    this.notifCount = 0, //  clean
  });

  Widget _iconWithBadge({
    required IconData icon,
    required int count,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 9 ? '9+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconSize: 22,
        selectedFontSize: 9.5,
        unselectedFontSize: 9.5,
        selectedItemColor: const Color(0xFFEBA46E),
        unselectedItemColor: Colors.grey,
        onTap: onTap,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: _iconWithBadge(
              icon: Icons.chat_outlined,
              count: inboxCount,
            ),
            label: "Inbox",
          ),
          BottomNavigationBarItem(
            icon: _iconWithBadge(
              icon: Icons.notifications_none,
              count: notifCount, //  use notifCount
            ),
            label: "Notification",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: "3D",
          ),
          BottomNavigationBarItem(
            icon: _iconWithBadge(
              icon: Icons.shopping_cart_outlined,
              count: cartCount,
            ),
            label: "Cart",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}