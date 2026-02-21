// import 'package:flutter/material.dart';

// class ViewAllOrdersPage extends StatelessWidget {
//   const ViewAllOrdersPage({super.key});

//   List<Map<String, String>> orders() {
//     return [
//       {"id":"#235","customer":"Ahmed Alaa","status":"Shipped","img":"assets/chair.png"},
//       {"id":"#679","customer":"Rowan Alaa","status":"Shipped","img":"assets/table.png"},
//       {"id":"#900","customer":"Lina","status":"Preparing","img":"assets/1.png"},
//       {"id":"#1890","customer":"Omnia","status":"Preparing","img":"assets/2.png"},
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final list = orders();
//     return Scaffold(
//       backgroundColor: const Color(0xfff6eadf),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text("All Orders", style: TextStyle(color: Colors.brown)),
//         leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.brown), onPressed: () => Navigator.pop(context)),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView.separated(
//           itemCount: list.length,
//           separatorBuilder: (_,__) => const SizedBox(height: 12),
//           itemBuilder: (context, index) {
//             final o = list[index];
//             return Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
//               child: Row(
//                 children: [
//                   Container(width: 64, height: 64, decoration: BoxDecoration(image: DecorationImage(image: AssetImage(o["img"]!), fit: BoxFit.cover), borderRadius: BorderRadius.circular(8))),
//                   const SizedBox(width: 12),
//                   Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text("order ${o["id"]}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
//                     const SizedBox(height: 6),
//                     Text("Customer: ${o["customer"]}", style: const TextStyle(color: Colors.black87)),
//                   ])),
//                   Text("${o["status"]}", style: const TextStyle(color: Colors.brown)),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ViewAllOrdersPage extends StatefulWidget {
  const ViewAllOrdersPage({super.key});

  @override
  State<ViewAllOrdersPage> createState() => _ViewAllOrdersPageState();
}

class _ViewAllOrdersPageState extends State<ViewAllOrdersPage> {
  List<Map<String, String>> orders = [
    {"id":"#235","customer":"Ahmed Alaa","status":"Shipped","img":"assets/chair.png"},
    {"id":"#679","customer":"Rowan Alaa","status":"Preparing","img":"assets/table.png"},
    {"id":"#900","customer":"Lina","status":"Preparing","img":"assets/1.png"},
    {"id":"#1890","customer":"Omnia","status":"Out for delivery","img":"assets/2.png"},
  ];

  void _changeStatus(int index, String newStatus) {
    final currentStatus = orders[index]["status"];

    if (currentStatus == "Shipped") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order already shipped"),
          backgroundColor: Colors.brown,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      orders[index]["status"] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("All Orders", style: TextStyle(color: Colors.brown)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final o = orders[index];

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
                ],
              ),
              child: Row(
                children: [
                  // Image
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(o["img"]!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Order info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "order ${o["id"]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Customer: ${o["customer"]}",
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Status: ${o["status"]}",
                          style: const TextStyle(color: Colors.brown),
                        ),
                      ],
                    ),
                  ),

                  // 3 dots menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.brown),
                    onSelected: (value) {
                      _changeStatus(index, value);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "Preparing",
                        child: Text("Preparing"),
                      ),
                      PopupMenuItem(
                        value: "Out for delivery",
                        child: Text("Out for delivery"),
                      ),
                      PopupMenuItem(
                        value: "Shipped",
                        child: Text("Shipped"),
                      ),
                      PopupMenuItem(
                        value: "Cancelled",
                        child: Text("Cancelled"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

