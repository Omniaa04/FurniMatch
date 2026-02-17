import 'package:flutter/material.dart';
import 'view_orders_page.dart';
import 'add_product_page.dart';
import 'product_analytics_page.dart';
import 'chat_page.dart';

/// ---------------- ORDER MODEL ----------------
class Order {
  String id;
  String customer;
  String status;
  String img;

  Order({
    required this.id,
    required this.customer,
    required this.status,
    required this.img,
  });
}

/// ---------------- DASHBOARD ----------------
class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {

  /// ORDERS LIST (STATE)
  final List<Order> orders = [
    Order(
      id: "#235",
      customer: "Ahmed Alaa",
      status: "Preparing",
      img: "assets/chair.png",
    ),
    Order(
      id: "#679",
      customer: "Rowan Alaa",
      status: "Out for delivery",
      img: "assets/table.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 26),
                decoration: BoxDecoration(
                  color: const Color(0xffe8cdb8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    Text("Seller Dashboard",
                        style: TextStyle(
                            color: Colors.brown,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("Total Sells",
                        style: TextStyle(color: Colors.brown)),
                    SizedBox(height: 6),
                    Text("20",
                        style: TextStyle(
                            color: Colors.brown,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// PRODUCT OVERVIEW
              const Text("Product Overview",
                  style: TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddProductPage()),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Add new Product",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ProductAnalyticsPage()),
                      );
                    },
                    icon: const Icon(Icons.menu, color: Colors.brown),
                    label: const Text("Product Analytics",
                        style: TextStyle(color: Colors.brown)),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              /// ORDER MANAGEMENT
              const Text("Order Management",
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),

              const SizedBox(height: 12),

              /// ORDERS
              ...orders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _orderCard(order),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: ElevatedButton(
//                   onPressed: () {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => ViewAllOrdersPage(
//         orders: orders.map((o) => {
//           "id": o.id,
//           "customer": o.customer,
//           "status": o.status,
//           "img": o.img,
//         }).toList(),
//       ),
//     ),
//   );
// },
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ViewAllOrdersPage(),
    ),
  );
},


                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22)),
                  ),
                  child: const Text("View All Orders",
                      style: TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(height: 28),

              /// CUSTOMER CHATS
              const Text("Customer Chats",
                  style: TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),

              const SizedBox(height: 12),

              _chatCard("Rowan Alaa", "assets/sample2.png", context),
              const SizedBox(height: 12),
              _chatCard("Alaa Moustafa", "assets/sample3.png", context),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- ORDER CARD ----------------
  Widget _orderCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  image: AssetImage(order.img), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("order ${order.id}",
                    style: const TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text("Customer: ${order.customer}"),
                const SizedBox(height: 5),
                Text("Status: ${order.status}",
                    style: const TextStyle(color: Colors.brown)),
              ],
            ),
          ),

          /// STATUS MENU
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.brown),
            onSelected: (value) {
              if (order.status == "Shipped") return;
              setState(() => order.status = value);
            },
            itemBuilder: (_) {
              if (order.status == "Shipped") {
                return const [
                  PopupMenuItem(
                    enabled: false,
                    child: Text("Already Shipped"),
                  ),
                ];
              }
              return const [
                PopupMenuItem(value: "Preparing", child: Text("Preparing")),
                PopupMenuItem(
                    value: "Out for delivery",
                    child: Text("Out for delivery")),
                PopupMenuItem(value: "Shipped", child: Text("Shipped")),
                PopupMenuItem(value: "Canceled", child: Text("Canceled")),
              ];
            },
          ),
        ],
      ),
    );
  }

  /// ---------------- CHAT CARD ----------------
  Widget _chatCard(String name, String img, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ChatPage(customerName: name)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundImage: AssetImage(img)),
            const SizedBox(width: 12),
            Text("Customer: $name",
                style: const TextStyle(
                    color: Colors.brown, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
