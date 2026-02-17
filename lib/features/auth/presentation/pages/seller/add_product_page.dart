
import 'package:flutter/material.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  // Dropdowns (w/o validation errors)
  String? category;
  String? subCategory;
  String? dimensionUnit;

  List<Color> selectedColors = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add New Product",
          style: TextStyle(
            color: Colors.brown,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _productCard(),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------
  Widget _productCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xfff2d8be),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _uploadBox("Upload Photos", Icons.image_outlined),
                _uploadBox("Upload 3D Model", Icons.view_in_ar),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Details Product",
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 12),

            _textField("Product Name", nameController),
            const SizedBox(height: 12),

            _textField("Description", descController),
            const SizedBox(height: 12),

            _textField("Price", priceController, inputType: TextInputType.number),
            const SizedBox(height: 12),

            const Text("Category", style: TextStyle(color: Colors.brown)),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: _dropdown(
                    hint: "Category",
                    value: category,
                    items: ["Furniture", "Chairs", "Tables"],
                    onChanged: (v) => setState(() => category = v),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _dropdown(
                    hint: "Sub-Category",
                    value: subCategory,
                    items: ["Modern", "Classic", "Wood"],
                    onChanged: (v) => setState(() => subCategory = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            
            const Text("Dimensions", style: TextStyle(color: Colors.brown)),
const SizedBox(height: 6),

_dropdown(
  hint: "Unit (cm / m)",
  value: dimensionUnit,
  items: ["cm", "m"],
  onChanged: (v) => setState(() => dimensionUnit = v),
),

const SizedBox(height: 12),

Row(
  children: [
    Expanded(
      child: _textField("Length", lengthController),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _textField("Height", heightController),
    ),
  ],
),


            const SizedBox(height: 16),

            const Text("Available Colors", style: TextStyle(color: Colors.brown)),
            const SizedBox(height: 8),

            Wrap(
              children: [
                ...selectedColors.map(
                      (c) => Container(
                    margin: const EdgeInsets.all(4),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showColorPicker,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "+ Add Color",
                      style: TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Text("Save Product", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------
  Widget _uploadBox(String text, IconData icon) {
    return Container(
      width: 130,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xfff9ece0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.brown, size: 30),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.brown, fontSize: 14)),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  Widget _textField(String hint, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      validator: (v) => (v == null || v.trim().isEmpty) ? "Required field" : null,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // --------------------------------------------------------
  Widget _dropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint),
        decoration: const InputDecoration(border: InputBorder.none),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        // No validator → No red text
      ),
    );
  }

  // --------------------------------------------------------
  // COLOR PICKER DIALOG
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pick a Color"),
          content: SizedBox(
            width: double.maxFinite,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Colors.primaries.take(18).map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColors.add(color);
                    });
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: color,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------
  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product Saved Successfully")),
      );
    }
  }
}


