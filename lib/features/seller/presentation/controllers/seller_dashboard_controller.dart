import 'package:flutter/foundation.dart';
import 'package:furnimatch/features/seller/data/services/seller_api_service.dart';

class SellerDashboardController extends ChangeNotifier {
  final SellerApiService api;

  SellerDashboardController(this.api);

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> chats = [];

  bool isLoadingProducts = false;
  bool isLoadingOrders = false;
  bool isLoadingChats = false;

  Future<void> loadProducts(int storeId) async {
    isLoadingProducts = true;
    notifyListeners();
    products = await api.getProducts(storeId);
    isLoadingProducts = false;
    notifyListeners();
  }

  Future<void> loadOrders(int storeId) async {
    isLoadingOrders = true;
    notifyListeners();
    orders = await api.getOrders(storeId);
    isLoadingOrders = false;
    notifyListeners();
  }

  Future<void> loadChats(int storeId) async {
    isLoadingChats = true;
    notifyListeners();
    chats = await api.getChats(storeId);
    isLoadingChats = false;
    notifyListeners();
  }
}
