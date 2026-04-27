import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:furnimatch/api_config.dart';
import 'package:furnimatch/shared/widgets/app_dialog.dart';

class AddProductPage extends StatefulWidget {
  final int storeId;

  const AddProductPage({
    super.key,
    this.storeId = 1,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  final List<String> appCategories = const [
    "Living room",
    "Bedroom",
    "Home office",
    "Kitchen",
    "Dining room",
  ];

  String? category;
  String? dimensionUnit;
  List<Color> selectedColors = [];
  Uint8List? productImageBytes;
  String? productImageName;
  bool isLoading = false;

  String colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2).toUpperCase()}';
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      final bytes = await result.readAsBytes();
      setState(() {
        productImageBytes = bytes;
        productImageName = result.name;
      });
    }
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (category == null || category!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose a category")),
      );
      return;
    }

    if (selectedColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one color")),
      );
      return;
    }

    if (productImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a product image")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/product/add'),
      );

      request.headers['ngrok-skip-browser-warning'] = 'true';
      request.fields['store_id'] = widget.storeId.toString();
      request.fields['name'] = nameController.text.trim();
      request.fields['description'] = descController.text.trim();
      request.fields['price'] = priceController.text.trim();
      request.fields['category'] = category!;
      request.fields['stock'] = stockController.text.trim().isEmpty
          ? '0'
          : stockController.text.trim();
      request.fields['colors'] =
          jsonEncode(selectedColors.map((c) => colorToHex(c)).toList());

      if (dimensionUnit != null && dimensionUnit!.isNotEmpty) {
        request.fields['dimension_unit'] = dimensionUnit!;
      }

      if (lengthController.text.trim().isNotEmpty) {
        request.fields['length'] = lengthController.text.trim();
      }

      if (heightController.text.trim().isNotEmpty) {
        request.fields['height'] = heightController.text.trim();
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          productImageBytes!,
          filename: productImageName ?? 'image.jpg',
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(responseBody);
      } catch (_) {}

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product added successfully!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ??
                  'Failed to add product (${response.statusCode})',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    lengthController.dispose();
    heightController.dispose();
    stockController.dispose();
    super.dispose();
  }

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
          children: [_productCard()],
        ),
      ),
    );
  }

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
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xfff9ece0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.brown),
                  image: productImageBytes != null
                      ? DecorationImage(
                          image: MemoryImage(productImageBytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: productImageBytes == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: Colors.brown,
                            size: 30,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Upload Photos",
                            style: TextStyle(
                              color: Colors.brown,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
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
            _textField("Description", descController, maxLines: 2),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _labeledField(
                    label: "Price",
                    hint: "0",
                    controller: priceController,
                    inputType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _labeledField(
                    label: "Stock",
                    hint: "0",
                    controller: stockController,
                    inputType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text("Category", style: TextStyle(color: Colors.brown)),
            const SizedBox(height: 6),
            _dropdown(
              hint: "Category",
              selectedValue: category,
              items: appCategories,
              onChanged: (v) => setState(() => category = v),
            ),
            const SizedBox(height: 16),
            const Text("Dimensions", style: TextStyle(color: Colors.brown)),
            const SizedBox(height: 6),
            _dropdown(
              hint: "Unit (cm / m)",
              selectedValue: dimensionUnit,
              items: const ["cm", "m"],
              onChanged: (v) => setState(() => dimensionUnit = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _textField("Length", lengthController)),
                const SizedBox(width: 12),
                Expanded(child: _textField("Height", heightController)),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Available Colors",
              style: TextStyle(color: Colors.brown),
            ),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...selectedColors.map(
                  (c) => Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 8),
                    width: 28,
                    height: 28,
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
                    padding: EdgeInsets.only(left: 4),
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
                onPressed: isLoading ? null : saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Save Product",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    String hint,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      validator: (value) {
        if ((value == null || value.trim().isEmpty) &&
            (hint == "Product Name" ||
                hint == "Description" ||
                hint == "Price" ||
                hint == "Stock Quantity")) {
          return "This field is required";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xfff8f8f8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.brown),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.brown),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.brown, width: 1.4),
        ),
      ),
    );
  }

  Widget _labeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.brown,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _textField(
          hint,
          controller,
          inputType: inputType,
        ),
      ],
    );
  }

  Widget _dropdown({
    required String hint,
    required String? selectedValue,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xfff8f8f8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(hint),
        items: items
            .map(
              (e) => DropdownMenuItem<String>(
                value: e,
                child: Text(e),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (value) {
          if (hint == "Category" && (value == null || value.isEmpty)) {
            return "Please choose a category";
          }
          return null;
        },
      ),
    );
  }

  void _showColorPicker() {
    Color pickerColor = Colors.brown;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppDialog.background,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          title: const Text(
            "Pick a Color",
            style: TextStyle(
              color: AppDialog.brown,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) => pickerColor = color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppDialog.muted,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDialog.red,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 34, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                setState(() => selectedColors.add(pickerColor));
                Navigator.pop(context);
              },
              child: const Text(
                "Add",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
