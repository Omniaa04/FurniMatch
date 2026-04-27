import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:furnimatch/api_config.dart';
import 'package:furnimatch/features/seller/presentation/pages/product_list_page.dart';

class ProductAnalyticsPage extends StatefulWidget {
  final int storeId;

  const ProductAnalyticsPage({
    super.key,
    required this.storeId,
  });

  @override
  State<ProductAnalyticsPage> createState() => _ProductAnalyticsPageState();
}

class _ProductAnalyticsPageState extends State<ProductAnalyticsPage> {
  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic> summary = {};
  List<Map<String, dynamic>> topProducts = [];
  List<Map<String, dynamic>> salesOverTime = [];

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/store/${widget.storeId}/analytics'),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          summary = Map<String, dynamic>.from(data['summary'] ?? {});
          topProducts =
              List<Map<String, dynamic>>.from(data['top_products'] ?? []);
          salesOverTime =
              List<Map<String, dynamic>>.from(data['sales_over_time'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Failed to load analytics';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error loading analytics: $e';
        isLoading = false;
      });
    }
  }

  String formatPrice(dynamic value) {
    if (value == null) return "\$0";
    if (value is int) return "\$$value";
    if (value is double) {
      if (value == value.roundToDouble()) {
        return "\$${value.toInt()}";
      }
      return "\$${value.toStringAsFixed(2)}";
    }
    return "\$$value";
  }

  @override
  Widget build(BuildContext context) {
    final totalRevenue = summary['total_revenue'] ?? 0;
    final totalProducts = summary['total_products'] ?? 0;
    final totalOrders = summary['total_orders'] ?? 0;
    final totalUnitsSold = summary['total_units_sold'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Product Analytics",
          style: TextStyle(color: Colors.brown),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: fetchAnalytics,
            icon: const Icon(Icons.refresh, color: Colors.brown),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.brown, fontSize: 16),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Overview",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductListPage(storeId: widget.storeId),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xfff7efe8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(color: Colors.transparent),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Product List",
                              style: TextStyle(color: Colors.brown),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xfffff1e7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Sales Overview",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            Text(
                              formatPrice(totalRevenue),
                              style: const TextStyle(color: Colors.brown),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              title: "Products",
                              value: "$totalProducts",
                              icon: Icons.inventory_2_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _summaryCard(
                              title: "Orders",
                              value: "$totalOrders",
                              icon: Icons.receipt_long_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              title: "Units Sold",
                              value: "$totalUnitsSold",
                              icon: Icons.shopping_bag_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _summaryCard(
                              title: "Revenue",
                              value: formatPrice(totalRevenue),
                              icon: Icons.attach_money_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        height: 190,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Sales Over Time",
                              style: TextStyle(
                                color: Colors.brown,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: salesOverTime.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "No sales data yet",
                                        style: TextStyle(color: Colors.brown),
                                      ),
                                    )
                                  : _SimpleLineChart(points: salesOverTime),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "Top Performing Products",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (topProducts.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "No products performance data yet",
                              style: TextStyle(color: Colors.brown),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: topProducts
                              .map((product) => _productCard(product))
                              .toList(),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.brown),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xffe8cdb8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: product["image_url"] != null &&
                    product["image_url"].toString().isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product["image_url"],
                      fit: BoxFit.cover,
                      headers: const {"ngrok-skip-browser-warning": "true"},
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, color: Colors.brown);
                      },
                    ),
                  )
                : const Icon(Icons.image, color: Colors.brown),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product["name"] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Sold: ${product["orders_count"] ?? 0} time(s)",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Revenue: ${formatPrice(product["revenue"])}",
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatPrice(product["price"]),
            style: const TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> points;

  const _SimpleLineChart({required this.points});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(points),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> points;

  _LineChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.brown
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;

    final paintGrid = Paint()
      ..color = Colors.brown.withValues(alpha: 0.12)
      ..strokeWidth = 1;

    const textStyle = TextStyle(
      color: Colors.brown,
      fontSize: 10,
    );

    final width = size.width;
    final height = size.height;

    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(0, height * i / 4),
        Offset(width, height * i / 4),
        paintGrid,
      );
    }

    if (points.isEmpty) return;

    double maxValue = 1;
    for (final point in points) {
      final value = (point['orders'] ?? 0).toDouble();
      if (value > maxValue) maxValue = value;
    }

    final dxStep = points.length == 1 ? width / 2 : width / (points.length - 1);

    final offsets = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final value = (points[i]['orders'] ?? 0).toDouble();
      final x = dxStep * i;
      final y = height - ((value / maxValue) * (height - 20)) - 10;
      offsets.add(Offset(x, y));
    }

    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
    }
    canvas.drawPath(path, paintLine);

    for (int i = 0; i < offsets.length; i++) {
      canvas.drawCircle(offsets[i], 3.5, pointPaint);

      final label = points[i]['label']?.toString() ?? '';
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(offsets[i].dx - textPainter.width / 2, height - 14),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
