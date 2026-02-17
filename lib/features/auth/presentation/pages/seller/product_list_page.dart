import 'package:flutter/material.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  bool grid = false;

  final List<Map<String, dynamic>> items = List.generate(8, (i) => {
    "id": "p$i",
    "title": "Product ${i+1}",
    "price": "\$${(i+1)*120}",
    "img": "assets/sofa.png",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Products", style: TextStyle(color: Colors.brown)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.brown), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: Icon(grid ? Icons.list : Icons.grid_view, color: Colors.brown),
            onPressed: () => setState(() => grid = !grid),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: grid ? _gridView() : _listView(),
      ),
    );
  }

  Widget _listView() {
    return ListView.separated(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final it = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xfffff6ef),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
          ),
          child: Row(
            children: [
              Container(width: 64, height: 64, decoration: BoxDecoration(image: DecorationImage(image: AssetImage(it["img"]), fit: BoxFit.cover), borderRadius: BorderRadius.circular(8))),
              const SizedBox(width: 12),
              Expanded(child: Text(it["title"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown))),
              Text(it["price"], style: const TextStyle(color: Colors.brown)),
            ],
          ),
        );
      },
    );
  }

  Widget _gridView() {
    return GridView.builder(
      itemCount: items.length,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemBuilder: (context, index) {
        final it = items[index];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage(it["img"]), fit: BoxFit.cover), borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 8),
              Text(it["title"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(height: 4),
              Text(it["price"], style: const TextStyle(color: Colors.brown)),
            ],
          ),
        );
      },
    );
  }
}
