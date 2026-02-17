import 'package:flutter/material.dart';
import 'product_list_page.dart';
// import 'view_orders_page.dart';

class ProductAnalyticsPage extends StatelessWidget {
  const ProductAnalyticsPage({super.key});


  List<Map<String, dynamic>> topProducts() {
    return [
      {"title": "Cloud Sofa", "price": "\$12,000", "img": "assets/sofa.png"},
      {"title": "Cloud Sofa", "price": "\$12,000", "img": "assets/1.png"},
      {"title": "Cloud Sofa", "price": "\$12,000", "img": "assets/2.png"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final products = topProducts();
    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Product Analytics", style: TextStyle(color: Colors.brown)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

           
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  ),
                  child: const Text("Overview", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListPage()));
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xfff7efe8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(color: Colors.transparent),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text("Product List", style: TextStyle(color: Colors.brown)),
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
                children: const [
                  Text("Sales Overview", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                  Text("\$12,000", style: TextStyle(color: Colors.brown)),
                ],
              ),
            ),

            const SizedBox(height: 14),

          
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Views Over Time", style: TextStyle(color: Colors.brown, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Expanded(child: _SimpleLineChart()),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text("Top Performing Products", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
            const SizedBox(height: 12),

            // Top Products List (cards)
            Column(
              children: products.map((p) => _productCard(context, p)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(BuildContext context, Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfffff6ef),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(image: AssetImage(p["img"]), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p["title"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                const SizedBox(height: 6),
                const Text("Last Message: discount on this table?", style: TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 4),
                const Text("Time: 5 min ago", style: TextStyle(color: Colors.black45, fontSize: 11)),
              ],
            ),
          ),
          Text(p["price"], style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}


class _SimpleLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.brown
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final paintGrid = Paint()..color = Colors.brown.withOpacity(0.12);
    final w = size.width;
    final h = size.height;
    // draw simple grid lines
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(Offset(0, h * i / 4), Offset(w, h * i / 4), paintGrid);
    }
    // sample points
    final points = [
      Offset(w * 0.05, h * 0.7),
      Offset(w * 0.2, h * 0.6),
      Offset(w * 0.35, h * 0.65),
      Offset(w * 0.5, h * 0.5),
      Offset(w * 0.65, h * 0.55),
      Offset(w * 0.8, h * 0.35),
      Offset(w * 0.95, h * 0.3),
    ];
    // draw path
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var p in points) path.lineTo(p.dx, p.dy);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
