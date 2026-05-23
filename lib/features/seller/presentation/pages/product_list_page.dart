import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:furnimatch/api_config.dart';
import 'edit_product_page.dart';

class ProductListPage extends StatefulWidget {
  final int storeId;

  const ProductListPage({
    super.key,
    required this.storeId,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  bool isLoading = true;
  String selectedStockTab = "All";
  String searchText = "";

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/store/${widget.storeId}/products'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data['success'] == true) {
        setState(() {
          items = List<Map<String, dynamic>>.from(data['products']);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  int getStock(Map<String, dynamic> item) {
    final value = item['stock'] ?? 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String getPrice(Map<String, dynamic> item) {
    final value = item['sale_price'] ?? item['price'] ?? 0;
    return value.toString();
  }

  List<Map<String, dynamic>> get filteredItems {
    return items.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final stock = getStock(item);

      final matchesSearch = name.contains(searchText.toLowerCase());

      final matchesTab = selectedStockTab == "All"
          ? true
          : selectedStockTab == "In Stock"
              ? stock > 0
              : stock <= 0;

      return matchesSearch && matchesTab;
    }).toList();
  }

  Future<void> restockProduct(int productId, int newStock) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/product/$productId/restock'),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({"stock": newStock}),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stock updated successfully")),
        );
        fetchProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to update stock")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void showRestockSheet(Map<String, dynamic> item) {
    final controller = TextEditingController(
      text: getStock(item).toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xfff6eadf),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Restock Product",
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['name']?.toString() ?? '',
                style: const TextStyle(
                  color: Colors.brown,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                cursorColor: Colors.brown,
                decoration: InputDecoration(
                  hintText: "Enter new stock number",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    final newStock = int.tryParse(controller.text.trim());
                    if (newStock == null || newStock < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid number"),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(sheetContext);
                    restockProduct(item['id'], newStock);
                  },
                  child: const Text(
                    "Update Stock",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> deleteProduct(int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            "Deactivate Product?",
            style: TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "This product will be removed from your products list.",
            style: TextStyle(
              color: Colors.brown,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.brown),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                "Deactivate",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/product/delete/$productId'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product deactivated successfully")),
        );
        fetchProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Failed to deactivate product"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Product List",
          style: TextStyle(color: Colors.brown),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _mainTabs(context),
                  const SizedBox(height: 20),
                  _searchBox(),
                  const SizedBox(height: 14),
                  _stockTabs(),
                  const SizedBox(height: 18),
                  filteredItems.isEmpty
                      ? SizedBox(
                          height: 320,
                          child: _emptyState(),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _productCard(filteredItems[index]);
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _mainTabs(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xfff7efe8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: const BorderSide(color: Colors.transparent),
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 12,
            ),
          ),
          child: const Text(
            "Overview",
            style: TextStyle(color: Colors.brown),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 12,
            ),
          ),
          child: const Text(
            "Product List",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _searchBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfffff1e7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchText = value),
        cursorColor: Colors.brown,
        style: const TextStyle(
          color: Colors.brown,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.brown,
          ),
          hintText: "Search products",
          hintStyle: TextStyle(
            color: Colors.brown.withValues(alpha: 0.55),
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _stockTabs() {
    final tabs = ["All", "In Stock", "Out of Stock"];

    return Row(
      children: tabs.map((tab) {
        final selected = selectedStockTab == tab;

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ChoiceChip(
            label: Text(tab),
            selected: selected,
            showCheckmark: false,
            selectedColor: Colors.brown,
            backgroundColor: const Color(0xfff7efe8),
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.brown,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.transparent),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onSelected: (_) {
              setState(() => selectedStockTab = tab);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _productCard(Map<String, dynamic> item) {
    final stock = getStock(item);
    final inStock = stock > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfffff6ef),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          _productImage(item),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']?.toString() ?? 'No name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "EGP ${getPrice(item)}",
                  style: const TextStyle(
                    color: Colors.brown,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  inStock ? "In Stock" : "Out of Stock",
                  style: TextStyle(
                    color:
                        inStock ? Colors.green.shade700 : Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Stock: $stock",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _moreMenu(item),
        ],
      ),
    );
  }

  Widget _productImage(Map<String, dynamic> item) {
    final imageUrl = item['image_url']?.toString() ?? '';

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xffe8cdb8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                headers: const {"ngrok-skip-browser-warning": "true"},
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image,
                  color: Colors.brown,
                ),
              ),
            )
          : const Icon(
              Icons.image,
              color: Colors.brown,
            ),
    );
  }

  Widget _moreMenu(Map<String, dynamic> item) {
    return PopupMenuButton<String>(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      icon: const Icon(
        Icons.more_vert_rounded,
        color: Colors.brown,
      ),
      onSelected: (value) async {
        if (value == "edit") {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditProductPage(product: item),
            ),
          );
          if (updated == true) {
            fetchProducts();
          }
        } else if (value == "restock") {
          showRestockSheet(item);
        } else if (value == "deactivate") {
          deleteProduct(item['id']);
        }
      },
      itemBuilder: (context) => [
        _menuItem("edit", Icons.edit_outlined, "Edit"),
        _menuItem("restock", Icons.inventory_2_outlined, "Restock"),
        _menuItem("deactivate", Icons.power_settings_new_rounded, "Deactivate"),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.brown, size: 21),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.brown,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        "No products found",
        style: TextStyle(
          color: Colors.brown.withValues(alpha: 0.7),
          fontSize: 16,
        ),
      ),
    );
  }
}
