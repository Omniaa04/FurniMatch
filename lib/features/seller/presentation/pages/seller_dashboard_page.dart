import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:furnimatch/api_config.dart';
import 'package:furnimatch/features/buttom_nav/main_shell.dart';
import 'package:furnimatch/features/profile/presentation/pages/about_us_page.dart';
import 'package:furnimatch/features/seller/presentation/pages/add_product_page.dart';
import 'package:furnimatch/features/seller/presentation/pages/product_analytics_page.dart';
import 'package:furnimatch/features/seller/presentation/pages/seller_chat_details_page.dart';
import 'package:furnimatch/features/seller/presentation/pages/view_orders_page.dart';
import 'package:furnimatch/shared/widgets/app_dialog.dart';

class SellerDashboardPage extends StatefulWidget {
  final int storeId;
  final int sellerId;
  final String? sellerName;

  const SellerDashboardPage({
    super.key,
    this.storeId = 0,
    this.sellerId = 0,
    this.sellerName,
  });

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> chats = [];

  bool isLoadingOrders = true;
  bool isLoadingProducts = true;
  bool isLoadingChats = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      fetchProducts(),
      fetchOrders(),
      fetchChats(),
    ]);
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/store/${widget.storeId}/products'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        products = data['success'] == true
            ? List<Map<String, dynamic>>.from(data['products'] ?? [])
            : [];
        isLoadingProducts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingProducts = false);
    }
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/store/${widget.storeId}/orders'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        orders = data['success'] == true
            ? List<Map<String, dynamic>>.from(data['orders'] ?? [])
            : [];
        isLoadingOrders = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingOrders = false);
    }
  }

  Future<void> fetchChats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/store/${widget.storeId}/chats'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        chats = data['success'] == true
            ? List<Map<String, dynamic>>.from(data['chats'] ?? [])
            : [];
        isLoadingChats = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingChats = false);
    }
  }

  Future<void> updateOrderStatus(
      Map<String, dynamic> order, String newStatus) async {
    if (order['status'] == 'Shipped') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order already shipped")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/order/update-status'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'order_id': order['id'],
          'status': newStatus,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        await fetchOrders();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order status updated")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> deleteProduct(int productId) async {
    final confirm = await AppDialog.confirm(
      context: context,
      title: 'Delete Product',
      message: 'Are you sure you want to delete this product?',
      icon: Icons.delete_outline,
      cancelText: 'Cancel',
      confirmText: 'Delete',
    );

    if (confirm != true) return;

    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/product/delete/$productId'),
      headers: {'ngrok-skip-browser-warning': 'true'},
    );

    await fetchProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product deleted")),
    );
  }

  Future<bool> setProductSale({
    required int productId,
    required double? salePrice,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/product/set-sale'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'product_id': productId,
          'sale_price': salePrice,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['success'] != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Could not set sale')),
          );
        }
        return false;
      }

      if (mounted) {
        setState(() {
          final index = products.indexWhere(
            (product) => product['id'].toString() == productId.toString(),
          );
          if (index != -1) {
            products[index] = {
              ...products[index],
              'sale_price': salePrice,
            };
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              salePrice == null
                  ? 'Sale removed successfully'
                  : 'Sale price set successfully',
            ),
          ),
        );
      }

      await fetchProducts();
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      return false;
    }
  }

  Future<void> showSaleDialog(Map<String, dynamic> product) async {
    final productId = int.tryParse('${product['id']}');
    if (productId == null) return;

    final currentSale = product['sale_price'];
    final hasSale = _hasSalePrice(product);
    final saleController = TextEditingController(
      text: hasSale ? currentSale.toString() : '',
    );
    var isSaving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            backgroundColor: AppDialog.background,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            titlePadding: const EdgeInsets.fromLTRB(28, 26, 28, 12),
            contentPadding: const EdgeInsets.fromLTRB(28, 0, 28, 18),
            actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
            title: Text(
              (product['name']?.toString() ?? 'Product').toLowerCase(),
              style: const TextStyle(
                color: AppDialog.brown,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Price: \$${_formatPrice(product['price'])}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppDialog.brown,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasSale
                      ? 'Current Sale: \$${_formatPrice(currentSale)}'
                      : 'Current Sale: No sale',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF56B37F),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: saleController,
                  enabled: !isSaving,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  cursorColor: AppDialog.brown,
                  style: const TextStyle(color: AppDialog.brown, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter sale price',
                    hintStyle: const TextStyle(
                      color: Color(0xFF6F625D),
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFB8B1AA),
                        width: 1.6,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppDialog.brown,
                        width: 1.8,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFB8B1AA),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: isSaving
                            ? null
                            : () {
                                Navigator.pop(dialogContext);
                                deleteProduct(productId);
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: AppDialog.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFF9FC9D9),
                          size: 18,
                        ),
                        label: const Text(
                          "Delete",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: isSaving
                            ? null
                            : () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          foregroundColor: AppDialog.muted,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (hasSale) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  setDialogState(() => isSaving = true);
                                  final removed = await setProductSale(
                                    productId: productId,
                                    salePrice: null,
                                  );

                                  if (!dialogContext.mounted) return;
                                  setDialogState(() => isSaving = false);
                                  if (removed) Navigator.pop(dialogContext);
                                },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFEBA46E),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            "Remove Sale",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                final saleText = saleController.text
                                    .trim()
                                    .replaceAll(',', '.');
                                final salePrice = double.tryParse(saleText);
                                if (salePrice == null || salePrice <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Enter a valid sale price'),
                                    ),
                                  );
                                  return;
                                }

                                setDialogState(() => isSaving = true);
                                final saved = await setProductSale(
                                  productId: productId,
                                  salePrice: salePrice,
                                );

                                if (!dialogContext.mounted) return;
                                setDialogState(() => isSaving = false);
                                if (saved) Navigator.pop(dialogContext);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppDialog.brown,
                          disabledBackgroundColor:
                              AppDialog.brown.withValues(alpha: 0.5),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Set Sale",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _hasSalePrice(Map<String, dynamic> product) {
    final salePrice = product['sale_price'];
    if (salePrice == null) return false;
    final value = double.tryParse(salePrice.toString());
    return value != null && value > 0;
  }

  String _formatPrice(dynamic price) {
    final value = double.tryParse(price?.toString() ?? '');
    if (value == null) return '${price ?? ''}';
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  Future<void> showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFF6F0E9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFFF5A5F), size: 28),
            SizedBox(width: 12),
            Text(
              "Log out",
              style: TextStyle(
                color: Color(0xFF7D533D),
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to log out?\nWe’ll miss you ❤️",
          style: TextStyle(
            color: Color(0xFF7D533D),
            fontSize: 16,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text(
              "No",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5A5F),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Yes",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF6F0E9);
    const brown = Color(0xFF7D533D);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: Drawer(
        child: Container(
          color: bgColor,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 55, 20, 24),
                decoration: const BoxDecoration(
                  color: brown,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.store, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.sellerName ?? 'Seller',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Welcome to your dashboard',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.groups_outlined, color: brown),
                title: const Text('About Us', style: TextStyle(color: brown)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutUsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: brown),
                title: const Text('Settings', style: TextStyle(color: brown)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: brown),
                title: const Text('Help', style: TextStyle(color: brown)),
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: showLogoutDialog,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: brown),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8CDB8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Seller Dashboard',
                      style: TextStyle(
                        color: brown,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${orders.length} total orders',
                      style: const TextStyle(color: brown),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddProductPage(storeId: widget.storeId),
                          ),
                        );
                        fetchProducts();
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add Product',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: brown),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductAnalyticsPage(storeId: widget.storeId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart, color: brown),
                      label: const Text(
                        'Analytics',
                        style: TextStyle(color: brown),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle('My Products'),
              const SizedBox(height: 8),
              isLoadingProducts
                  ? const Center(child: CircularProgressIndicator(color: brown))
                  : products.isEmpty
                      ? const Text('No products yet')
                      : SizedBox(
                          height: 210,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: products.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, index) {
                              final product = products[index];
                              final hasSale = _hasSalePrice(product);
                              return InkWell(
                                onTap: () => showSaleDialog(product),
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                          child: product['image_url'] != null
                                              ? Image.network(
                                                  product['image_url'],
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  headers: const {
                                                    'ngrok-skip-browser-warning':
                                                        'true',
                                                  },
                                                )
                                              : Container(
                                                  color:
                                                      const Color(0xFFE8CDB8)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['name'] ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: brown,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (hasSale) ...[
                                              Text(
                                                '\$${_formatPrice(product['price'])}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  decorationThickness: 2,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                '\$${_formatPrice(product['sale_price'])}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppDialog.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ] else
                                              Text(
                                                '\$${_formatPrice(product['price'])}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: brown,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
              const SizedBox(height: 24),
              _sectionTitle('Order Management'),
              const SizedBox(height: 8),
              isLoadingOrders
                  ? const Center(child: CircularProgressIndicator(color: brown))
                  : orders.isEmpty
                      ? const Text('No orders yet')
                      : Column(
                          children: orders
                              .take(3)
                              .map((order) => _orderCard(order))
                              .toList(),
                        ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ViewAllOrdersPage(storeId: widget.storeId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: brown),
                  child: const Text(
                    'View All Orders',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Customer Chats'),
              const SizedBox(height: 8),
              isLoadingChats
                  ? const Center(child: CircularProgressIndicator(color: brown))
                  : chats.isEmpty
                      ? const Text('No chats yet')
                      : Column(
                          children: chats
                              .map(
                                (chat) => ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  tileColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFE8CDB8),
                                    child: Icon(Icons.person, color: brown),
                                  ),
                                  title: Text(
                                    'Customer: ${chat['name']}',
                                    style: const TextStyle(color: brown),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SellerChatDetailsPage(
                                          customerName: chat['name'],
                                          customerId: chat['user_id'],
                                          storeId: widget.storeId,
                                          sellerUserId: widget.sellerId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                              .toList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF7D533D),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    const brown = Color(0xFF7D533D);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order['id']}',
                  style: const TextStyle(
                      color: brown, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Customer: ${order['customer_name']}'),
                Text('Status: ${order['status']}'),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => updateOrderStatus(order, value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Preparing', child: Text('Preparing')),
              PopupMenuItem(
                value: 'Out for delivery',
                child: Text('Out for delivery'),
              ),
              PopupMenuItem(value: 'Shipped', child: Text('Shipped')),
              PopupMenuItem(value: 'Cancelled', child: Text('Cancelled')),
            ],
          ),
        ],
      ),
    );
  }
}
