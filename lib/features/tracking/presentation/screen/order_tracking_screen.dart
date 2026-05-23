// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:furnimatch/api_config.dart';
// import '../../domain/order_tracking_model.dart';
// import '../widgets/order_items_list.dart';
// import '../widgets/tracking_stepper.dart';

// class OrderTrackingScreen extends StatelessWidget {
//   final String orderId;

//   const OrderTrackingScreen({
//     super.key,
//     this.orderId = '9038973',
//   });

// Future<Map<String, dynamic>> fetchTrackingData() async {
//   final url = Uri.parse('${ApiConfig.baseUrl}/tracking/$orderId');

//   final response = await http.get(url);

//   print('TRACKING URL: $url');
//   print('TRACKING STATUS: ${response.statusCode}');
//   print('TRACKING BODY: ${response.body}');

//   if (response.statusCode == 200) {
//     return jsonDecode(response.body);
//   } else {
//     throw Exception('Failed to load tracking data');
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'Tracking Order',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: fetchTrackingData(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: Color(0xFFD47222)),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Text(
//                   'Error: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ),
//             );
//           }

//           final data = snapshot.data!;

//           final String expectedDeliveryDate =
//               data['expectedDeliveryDate']?.toString() ?? '';

//           final String orderIdText = data['orderId']?.toString() ?? '';

//           final List trackingList = data['trackingSteps'] ?? [];

//           final List<TrackingStep> trackingSteps = trackingList.map((item) {
//             return TrackingStep(
//               title: item['title']?.toString() ?? '',
//               date: item['date']?.toString() ?? '',
//               isCompleted: item['isCompleted'] ?? false,
//             );
//           }).toList();

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const OrderItemsList(),
//                 const SizedBox(height: 25),

//                 _buildDetailsCard(
//                   children: [
//                     const Text(
//                       'Order details',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     _buildDetailRow(
//                       label: 'Expected delivery date',
//                       value: expectedDeliveryDate,
//                     ),
//                     const SizedBox(height: 5),
//                     _buildDetailRow(
//                       label: 'Order ID',
//                       value: orderIdText,
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 25),

//                 _buildDetailsCard(
//                   children: [
//                     const Text(
//                       'Order Status',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     TrackingStepper(steps: trackingSteps),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDetailsCard({required List<Widget> children}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: children,
//       ),
//     );
//   }

//   Widget _buildDetailRow({
//     required String label,
//     required String value,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(color: Colors.grey, fontSize: 14),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }
// }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import 'package:furnimatch/api_config.dart';
// import '../../domain/order_tracking_model.dart';
// import '../widgets/order_items_list.dart';
// import '../widgets/tracking_stepper.dart';

// class OrderTrackingScreen extends StatelessWidget {
//   final String orderId;

//   const OrderTrackingScreen({
//     super.key,
//     required this.orderId,
//   });

//   Future<Map<String, dynamic>> fetchTrackingData() async {
//     final url = Uri.parse('${ApiConfig.baseUrl}/tracking/$orderId');

//     final response = await http.get(
//   url,
//   headers: const {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//     'ngrok-skip-browser-warning': 'true',
//   },
// );

//     print('TRACKING URL: $url');
//     print('TRACKING STATUS: ${response.statusCode}');
//     print('TRACKING BODY: ${response.body}');

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to load tracking data');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'Tracking Order',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: fetchTrackingData(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: Color(0xFFD47222)),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Text(
//                   'Error: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ),
//             );
//           }

//           final data = snapshot.data!;

//           final String expectedDeliveryDate =
//               data['expectedDeliveryDate']?.toString() ?? '';

//           final String orderIdText = data['orderId']?.toString() ?? '';

//           final List trackingList = data['trackingSteps'] ?? [];

//           final List<TrackingStep> trackingSteps = trackingList.map((item) {
//             return TrackingStep(
//               title: item['title']?.toString() ?? '',
//               date: item['date']?.toString() ?? '',
//               isCompleted: item['isCompleted'] ?? false,
//             );
//           }).toList();

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 OrderItemsList(
//   items: List<Map<String, dynamic>>.from(data['items'] ?? []),
// ),
//                 const SizedBox(height: 25),

//                 _buildDetailsCard(
//                   children: [
//                     const Text(
//                       'Order details',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     _buildDetailRow(
//                       label: 'Expected delivery date',
//                       value: expectedDeliveryDate,
//                     ),
//                     const SizedBox(height: 5),
//                     _buildDetailRow(
//                       label: 'Order ID',
//                       value: orderIdText,
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 25),

//                 _buildDetailsCard(
//                   children: [
//                     const Text(
//                       'Order Status',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     TrackingStepper(steps: trackingSteps),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDetailsCard({required List<Widget> children}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: children,
//       ),
//     );
//   }

//   Widget _buildDetailRow({
//     required String label,
//     required String value,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(color: Colors.grey, fontSize: 14),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:furnimatch/api_config.dart';
import 'package:furnimatch/features/buttom_nav/CustomBottomNav.dart';
import 'package:furnimatch/features/buttom_nav/main_shell.dart';
import 'package:furnimatch/providers/cart_provider.dart';

import '../../domain/order_tracking_model.dart';
import '../widgets/order_items_list.dart';
import '../widgets/tracking_stepper.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final int? userId;
  final String? userName;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    this.userId,
    this.userName,
  });

  static const Color darkBrown = Color(0xFF7D533D);
  static const Color bgColor = Color(0xFFF6F0E9);

  void goToHome(BuildContext context) {
    MainShell.openTab(
      context,
      index: 0,
      userId: userId,
      userName: userName,
    );
  }

  void goToTab(BuildContext context, int index) {
    MainShell.openTab(
      context,
      index: index,
      userId: userId,
      userName: userName,
    );
  }

  Future<Map<String, dynamic>> fetchTrackingData() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/tracking/$orderId');

    final response = await http.get(
      url,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    print('TRACKING URL: $url');
    print('TRACKING STATUS: ${response.statusCode}');
    print('TRACKING BODY: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load tracking data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: darkBrown, size: 22),
          onPressed: () => goToHome(context),
        ),
        titleSpacing: 0,
        centerTitle: false,
        title: const Text(
          'Tracking Order',
          style: TextStyle(
            color: darkBrown,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchTrackingData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: darkBrown),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final data = snapshot.data!;

          final String expectedDeliveryDate =
              data['expectedDeliveryDate']?.toString() ?? '';

          final String orderIdText = data['orderId']?.toString() ?? '';

          final List trackingList = data['trackingSteps'] ?? [];

          final List<TrackingStep> trackingSteps = trackingList.map((item) {
            return TrackingStep(
              title: item['title']?.toString() ?? '',
              date: item['date']?.toString() ?? '',
              isCompleted: item['isCompleted'] ?? false,
            );
          }).toList();

          final List<Map<String, dynamic>> items =
              List<Map<String, dynamic>>.from(data['items'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderItemsList(items: items),
                const SizedBox(height: 22),

                _buildDetailsCard(
                  children: [
                    const Text(
                      'Order details',
                      style: TextStyle(
                        color: darkBrown,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      label: 'Expected delivery date',
                      value: expectedDeliveryDate,
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      label: 'Order ID',
                      value: orderIdText,
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _buildDetailsCard(
                  children: [
                    const Text(
                      'Order Status',
                      style: TextStyle(
                        color: darkBrown,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TrackingStepper(steps: trackingSteps),
                  ],
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return CustomBottomNav(
            currentIndex: 0,
            cartCount: cartProvider.cartCount,
            inboxCount: 0,
            notifCount: 0,
            onTap: (index) => goToTab(context, index),
          );
        },
      ),
    );
  }

  Widget _buildDetailsCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: darkBrown.withOpacity(0.55),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: const TextStyle(
            color: darkBrown,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}