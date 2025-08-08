import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:toko_online_getx/controller/add_productcontroller.dart';
import 'package:toko_online_getx/extensions/extension.dart';
import 'package:toko_online_getx/models/add_productmodel.dart';

class AddProduct extends StatefulWidget {
  final AddProductController controller = Get.find<AddProductController>();
  final AddProductmodel? product;

  AddProduct({super.key, this.product});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _namecontroller = TextEditingController();
  final _descriptioncontroller = TextEditingController();
  final _pricecontroller = TextEditingController();
  final _categorycontroller = TextEditingController();
  final _stockcontroller = TextEditingController();
  final _isActivecontroller = TextEditingController();
  final _imagecontroller = TextEditingController();

  bool get isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    
    if (widget.product != null) {
      _namecontroller.text = widget.product!.name;
      _descriptioncontroller.text = widget.product!.description;
      _pricecontroller.text = widget.product!.price.toString();
      _categorycontroller.text = widget.product!.category!;
      _stockcontroller.text = widget.product!.stock.toString();
      _isActivecontroller.text = widget.product!.isActive.toString();
      _imagecontroller.text = widget.product!.filePath ?? '';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formInput('Product Name', controller: _namecontroller),
              const SizedBox(height: 16),
              _formInput('Description', controller: _descriptioncontroller),
              const SizedBox(height: 16),
              _formInput('Price', controller: _pricecontroller),
              const SizedBox(height: 16),
              _formInput('Category', controller: _categorycontroller),
              const SizedBox(height: 16),
              _formInput('Stock', controller: _stockcontroller),
              const SizedBox(height: 16),
              Text('Image URL', style: context.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Obx((){
                    if (widget.controller.imageUrl.value != null) {
                      return Image.network(widget.controller.imageUrl.value!, width: 200, height: 200);
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (){
                      widget.controller.handleImageUpload();
                    }, 
                    child: Text('Upload Image')),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => _saveProduct(), 
                  child: Text('Submit Product'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _formInput(String label, {TextEditingController? controller, bool readOnly = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          fillColor: readOnly ? Colors.grey[200] : Colors.white,
          filled: true,
        ),
      ),
    ],
  );

  Future<void> _saveProduct() async {
  // 1. Validasi input yang lebih baik dan terpusat
  if (_namecontroller.text.isEmpty ||
      _descriptioncontroller.text.isEmpty ||
      _pricecontroller.text.isEmpty ||
      _categorycontroller.text.isEmpty ||
      _stockcontroller.text.isEmpty ||
      widget.controller.imageUrl.value == null) // Periksa URL gambar
  {
    Get.snackbar(
      'Error',
      'Please fill all fields and upload an image', // Pesan error lebih jelas
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  // Ambil nilai dari controller
  final String name = _namecontroller.text;
  final String description = _descriptioncontroller.text;
  final int? price = int.tryParse(_pricecontroller.text);
  final String category = _categorycontroller.text;
  final int? stock = int.tryParse(_stockcontroller.text);

  // 2. Tambahkan validasi untuk nilai numerik
  if (price == null || stock == null) {
    Get.snackbar(
      'Error',
      'Price and stock must be valid numbers',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }
  
  // 3. Pastikan `filePath` tersedia
  final String? imageUrl = widget.controller.imageUrl.value;
  if (imageUrl == null) {
      Get.snackbar(
      'Error',
      'Please upload an image before saving.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  // 4. Buat objek AddProductmodel
  final product = AddProductmodel(
      name: name,
      description: description,
      price: price,
      category: category,
      stock: stock,
      isActive: true,
      filePath: imageUrl,
      // Jika Anda perlu sellerId, pastikan juga sudah di-handle
      // sellerId: widget.controller.sellerId, 
    );

    // 5. Panggil metode controller dengan logika yang sesuai
    if (isEditMode) {
      // Pastikan ID produk tersedia saat mode edit
      if (widget.product?.id == null) {
        Get.snackbar('Error', 'Product ID is missing for update operation.');
        return;
      }
      // await widget.controller.updateProduct(widget.product!.id!, product);
    } else {
      await widget.controller.addProduct(product);
    }
    
    Get.back();
  }
}