import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:furnimatch/api_config.dart';

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
  bool grid = false;
  bool isLoading = true;
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
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
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
          "Products",
          style: TextStyle(color: Colors.brown),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon:
                Icon(grid ? Icons.list : Icons.grid_view, color: Colors.brown),
            onPressed: () => setState(() => grid = !grid),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            )
          : items.isEmpty
              ? const Center(
                  child: Text(
                    "No products yet",
                    style: TextStyle(color: Colors.brown),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: grid ? _gridView() : _listView(),
                ),
    );
  }

  Widget _listView() {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xfffff6ef),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xffe8cdb8),
                ),
                child: item['image_url'] != null &&
                        item['image_url'].toString().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['image_url'],
                          fit: BoxFit.cover,
                          headers: const {
                            "ngrok-skip-browser-warning": "true",
                          },
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, color: Colors.brown),
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.brown),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
              Text(
                "\$${item['price']}",
                style: const TextStyle(color: Colors.brown),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _gridView() {
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item['image_url'] != null &&
                          item['image_url'].toString().isNotEmpty
                      ? Image.network(
                          item['image_url'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          headers: const {
                            "ngrok-skip-browser-warning": "true",
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xffe8cdb8),
                            child: const Icon(Icons.image, color: Colors.brown),
                          ),
                        )
                      : Container(
                          color: const Color(0xffe8cdb8),
                          child: const Icon(Icons.image, color: Colors.brown),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['name'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                "\$${item['price']}",
                style: const TextStyle(color: Colors.brown),
              ),
            ],
          ),
        );
      },
    );
  }
}
