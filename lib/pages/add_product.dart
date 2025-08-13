// File: lib/pages/add_product.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toko_online_getx/controller/add_productcontroller.dart';
import 'package:toko_online_getx/models/add_productmodel.dart';

class AddProduct extends GetView<AddProductController> {
  static final String TAG = '/add-product';

  const AddProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('ADD/Update Product'),
        // Obx(() => Text(
        //   controller.isEditMode ? 'Edit Product' : 'Add Product',
        //   style: TextStyle(color: Colors.white),)),
        backgroundColor: Colors.blue,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _formInput('Product Name', initialValue: controller.name.value, onChanged: (value) => controller.name.value = value),
                const SizedBox(height: 16),
                _formInput('Description', initialValue: controller.description.value, onChanged: (value) => controller.description.value = value),
                const SizedBox(height: 16),
                _formInput('Price', initialValue: controller.price.value, onChanged: (value) => controller.price.value = value, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _formInput('Category', initialValue: controller.category.value, onChanged: (value) => controller.category.value = value),
                const SizedBox(height: 16),
                _formInput('Stock', initialValue: controller.stock.value, onChanged: (value) => controller.stock.value = value, keyboardType: TextInputType.number),
                const SizedBox(height: 16),

                if (controller.imageUrl.value.isNotEmpty)
                  Image.network(controller.imageUrl.value, width: 200, height: 200),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => controller.handleImageUpload(),
                      child: const Text('Upload Image'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => controller.saveProduct(),
                    child: Text(controller.isEditMode ? 'Update Product' : 'Submit Product'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
  Widget _formInput(String label, {String? initialValue, Function(String)? onChanged, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

//   Widget _formInput(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
//     return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//       const SizedBox(height: 8),
//       TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//       ),
//     ],
//   );
// }
}