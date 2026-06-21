// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  int? userId;
  String? name;
  String? role;
  bool isLoading = true;

  bool get isLoggedIn => userId != null;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt('user_id');
    if (savedId != null) {
      userId = savedId;
      name = prefs.getString('name');
      role = prefs.getString('role');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> login({required int id, required String userName, required String userRole}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
    await prefs.setString('name', userName);
    await prefs.setString('role', userRole);
    userId = id;
    name = userName;
    role = userRole;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userId = null;
    name = null;
    role = null;
    notifyListeners();
  }
}