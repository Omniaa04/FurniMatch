import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:furnimatch/api_config.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductPage({
    super.key,
    required this.product,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  static const Color bgColor = Color(0xFFF6F0E9);
  static const Color darkBrown = Color(0xFF7D533D);
  static const Color cardColor = Color(0xFFFFFAF5);

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();
  final stockController = TextEditingController();
  final salePriceController = TextEditingController();

  bool isLoading = false;
  XFile? selectedImage;

  @override
  void initState() {
    super.initState();

    nameController.text = widget.product['name']?.toString() ?? '';
    descriptionController.text = widget.product['description']?.toString() ?? '';
    priceController.text = widget.product['price']?.toString() ?? '';
    categoryController.text = widget.product['category']?.toString() ?? '';
    stockController.text = widget.product['stock']?.toString() ?? '0';
    salePriceController.text = widget.product['sale_price']?.toString() ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    categoryController.dispose();
    stockController.dispose();
    salePriceController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => selectedImage = image);
    }
  }

  Future<void> updateProduct() async {
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        stockController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name, price and stock are required")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final productId = widget.product['id'];

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}/product/$productId/update'),
      );

      request.headers.addAll({
        "ngrok-skip-browser-warning": "true",
      });

      request.fields['name'] = nameController.text.trim();
      request.fields['description'] = descriptionController.text.trim();
      request.fields['price'] = priceController.text.trim();
      request.fields['category'] = categoryController.text.trim();
      request.fields['stock'] = stockController.text.trim();
      request.fields['sale_price'] = salePriceController.text.trim();

      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            selectedImage!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product updated successfully")),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Update failed")),
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

  Widget imagePreview() {
    final oldImage = widget.product['image_url']?.toString() ?? '';

    if (selectedImage != null) {
      if (kIsWeb) {
        return Image.network(
          selectedImage!.path,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 180,
        );
      }

      return Image.file(
        File(selectedImage!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180,
      );
    }

    if (oldImage.isNotEmpty) {
      return Image.network(
        oldImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180,
        headers: const {
          "ngrok-skip-browser-warning": "true",
        },
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_outlined,
          size: 60,
          color: darkBrown,
        ),
      );
    }

    return const Icon(
      Icons.image_outlined,
      size: 60,
      color: darkBrown,
    );
  }

  Widget inputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: darkBrown,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          cursorColor: darkBrown,
          decoration: InputDecoration(
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 18, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: darkBrown,
                  ),
                  const Text(
                    "Edit Product",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: darkBrown,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          color: cardColor,
                          child: imagePreview(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tap image to change it",
                      style: TextStyle(
                        color: darkBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),

                    inputField(label: "Product Name", controller: nameController),
                    inputField(
                      label: "Description",
                      controller: descriptionController,
                      maxLines: 3,
                    ),
                    inputField(
                      label: "Price",
                      controller: priceController,
                      keyboardType: TextInputType.number,
                    ),
                    inputField(label: "Category", controller: categoryController),
                    inputField(
                      label: "Stock",
                      controller: stockController,
                      keyboardType: TextInputType.number,
                    ),
                    inputField(
                      label: "Sale Price",
                      controller: salePriceController,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : updateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBrown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Save Changes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}