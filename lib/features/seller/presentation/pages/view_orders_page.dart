import 'package:flutter/material.dart';

import 'package:furnimatch/features/seller/presentation/controllers/view_orders_controller.dart';

class ViewAllOrdersPage extends StatefulWidget {
  final int storeId;

  const ViewAllOrdersPage({
    super.key,
    required this.storeId,
  });

  @override
  State<ViewAllOrdersPage> createState() => _ViewAllOrdersPageState();
}

class _ViewAllOrdersPageState extends State<ViewAllOrdersPage> {
  final controller = ViewOrdersController();
  final statuses = const [
  'Preparing',
  'Shipped',
  'Out for delivery',
  'Delivered',
  'Cancelled',
];
  @override
  void initState() {
    super.initState();
    controller.loadOrders(widget.storeId);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(Map<String, dynamic> order, String status) async {
    final result = await controller.updateOrderStatus(
      orderId: order['id'],
      status: status,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Done')),
    );

    if (result['ok'] == true) {
      controller.loadOrders(widget.storeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF6F0E9);
    const brown = Color(0xFF7D533D);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: brown),
            title: const Text('All Orders', style: TextStyle(color: brown)),
            actions: [
              IconButton(
                onPressed: () => controller.loadOrders(widget.storeId),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator(color: brown))
              : controller.orders.isEmpty
                  ? const Center(
                      child: Text(
                        'No orders yet',
                        style: TextStyle(color: brown),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final order = controller.orders[index];
                        final imageUrl = order['image_url']?.toString();

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        width: 74,
                                        height: 74,
                                        fit: BoxFit.cover,
                                        headers: const {
                                          'ngrok-skip-browser-warning': 'true',
                                        },
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 74,
                                          height: 74,
                                          color: const Color(0xFFE8CDB8),
                                          child: const Icon(Icons.image),
                                        ),
                                      )
                                    : Container(
                                        width: 74,
                                        height: 74,
                                        color: const Color(0xFFE8CDB8),
                                        child: const Icon(Icons.image),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${order['id']}',
                                      style: const TextStyle(
                                        color: brown,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order['product_name']?.toString() ??
                                          'Product',
                                      style: const TextStyle(
                                        color: brown,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Customer: ${order['customer_name']}'),
                                    const SizedBox(height: 4),
                                    Text('Status: ${order['status']}'),
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      value:
                                          statuses.contains(order['status'])
                                              ? order['status']
                                              : statuses.first,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor: const Color(0xFFF6F0E9),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      items: statuses
                                          .map(
                                            (status) => DropdownMenuItem(
                                              value: status,
                                              child: Text(status),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          _changeStatus(order, value);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
