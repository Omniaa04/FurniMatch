import 'package:flutter/material.dart';
import '../../domain/order_tracking_model.dart'; 
import '../widgets/order_items_list.dart'; 
import '../widgets/tracking_stepper.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
   
    const String expectedDeliveryDate = '12 Jun 2025';
    const String orderId = '#9038973';
    const List<TrackingStep> trackingSteps = [
      TrackingStep(title: 'Order placed', date: '6 Jun 2025', isCompleted: true),
      TrackingStep(title: 'Order Dispatched', date: '8 Jun 2025', isCompleted: true),
      TrackingStep(title: 'Order in transit', date: '11 Jun 2025', isCompleted: false),
      TrackingStep(title: 'Order delivered', date: '12 Jun 2025', isCompleted: false),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Tracking Order',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OrderItemsList(),
            const SizedBox(height: 25),

            _buildDetailsCard(
              children: [
                const Text(
                  'Order details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  label: 'Expected delivery date', 
                  value: expectedDeliveryDate,
                ),
                const SizedBox(height: 5),
                _buildDetailRow(
                  label: 'Order ID', 
                  value: orderId,
                ),
              ],
            ),

            const SizedBox(height: 25),

            _buildDetailsCard(
              children: [
                const Text(
                  'Order Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 20),
                const TrackingStepper(steps: trackingSteps),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2), 
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}