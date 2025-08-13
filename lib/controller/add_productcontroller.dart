// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:toko_online_getx/models/add_productmodel.dart';
import 'package:toko_online_getx/pages/product_view.dart';
import 'package:toko_online_getx/service/add_productservice.dart';

class AddProductController extends GetxController {
  final AddProductService _addProductService = Get.find<AddProductService>();


  // Rx<String?> imageUrl = Rx<String?>(null);

  // final nameController = TextEditingController();
  // final descriptionController = TextEditingController();
  // final priceController = TextEditingController();
  // final categoryController = TextEditingController();
  // final stockController = TextEditingController();

  final RxString name = ''.obs;
  final RxString description = ''.obs;
  final RxString price = ''.obs;
  final RxString category = ''.obs;
  final RxString stock = ''.obs;

  final RxBool isActive = true.obs;
  final RxString imageUrl = ''.obs;
  final RxBool isLoading = false.obs;

  AddProductmodel? productToEdit;

  bool get isEditMode => productToEdit != null;
  
  // bool get isEditMode => 
  //   (productToEdit != null) && 
  //   (productToEdit!.id != null) && 
  //   productToEdit!.id!.trim().isNotEmpty;



  

  @override
  void onInit() {
    super.onInit();
    print('✅ AddProductController onInit fired.');
    final args = Get.arguments;
    if (args != null && args is AddProductmodel) {
      print('✅ Arguments received in constructor for Edit Mode.');
      setProductToEdit(args);
    } else {
      print('❌ No arguments received in constructor. Starting Add Mode.');
      setProductToEdit(null);
    }
  }

  // Metode untuk mengisi form saat mode edit
  void setProductToEdit(AddProductmodel? product) {
    productToEdit = product;
    if (product != null) {
      print("🟢 Editing product with id: ${product.id}");
      // nameController.text = product.name;
      // descriptionController.text = product.description;
      // priceController.text = product.price.toString();
      // categoryController.text = product.category ?? '';
      // stockController.text = product.stock.toString();
      name.value = product.name;
      description.value = product.description;
      price.value = product.price.toString();
      category.value = product.category ?? '';
      stock.value = product.stock.toString();
      // isActive.value = product.isActive ?? true;
      isEditMode ? isActive.value = product.isActive ?? true :
      isActive.value = product.isActive ?? true;
      imageUrl.value = product.filePath;
    } else {
      // Reset form jika mode add
      // nameController.clear();
      // descriptionController.clear();
      // priceController.clear();
      // categoryController.clear();
      // stockController.clear();
      name.value = '';
      description.value = '';
      price.value = '';
      category.value = '';
      stock.value = '';
      // isActive.value = true; // Default to active when adding new product
      isEditMode ? isActive.value = false :
      isActive.value = true;
      imageUrl.value = '';
    }
  }


  Future<void> handleImageUpload() async {
    isLoading.value = true;
    String? uploadedUrl = await _addProductService.uploadImage();
    if (uploadedUrl != null) {
      imageUrl.value = uploadedUrl;
      Get.snackbar('Success', 'Image uploaded successfully!');
    } else {
      Get.snackbar('Error', 'Failed to upload image.');
    }
    isLoading.value = false;
  }

  // Future<void> addProduct(AddProductmodel product) async {
  //   await _addProductService.addProductToDatabase(product);
  // }

  // Future<void> saveProduct() async {


  //   // Tambahkan validasi di sini
  //   if (nameController.text.isEmpty || descriptionController.text.isEmpty || priceController.text.isEmpty || categoryController.text.isEmpty || stockController.text.isEmpty || imageUrl.isEmpty) {
  //     Get.snackbar('Error', 'Please fill all fields and upload an image.');
  //     return;
  //   }

  //   try {
  //     isLoading.value = true;
  //     final String? productId = isEditMode ? productToEdit?.id : null;
  //     final productData = AddProductmodel(
  //       id: productId,
  //       name: nameController.text,
  //       description: descriptionController.text,
  //       price: int.parse(priceController.text),
  //       category: categoryController.text,
  //       stock: int.parse(stockController.text),
  //       isActive: isActive.value,
  //       filePath: imageUrl.value,
  //     );

  //     if (isEditMode) {
  //       await _addProductService.updateProduct(productData);
  //       Get.back();
  //       Get.snackbar('Success', 'Product updated successfully!');
  //     } else {
  //       await _addProductService.addProductToDatabase(productData);
  //       Get.back();
  //       Get.snackbar('Success', 'Product added successfully!');
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'An unexpected error occurred: $e', backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> saveProduct() async {
    // Tambahkan validasi
    if (name.isEmpty || description.isEmpty || price.isEmpty || category.isEmpty || stock.isEmpty || imageUrl.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields and upload an image.');
      return;
    }

    try {
      isLoading.value = true;
      final String? productId = isEditMode ? productToEdit?.id : null;
      final productData = AddProductmodel(
        id: productId,
        name: name.value, // <-- Gunakan RxString di sini
        description: description.value, // <-- Gunakan RxString di sini
        price: int.parse(price.value), // <-- Gunakan RxString di sini
        category: category.value, // <-- Gunakan RxString di sini
        stock: int.parse(stock.value), // <-- Gunakan RxString di sini
        isActive: isActive.value,
        filePath: imageUrl.value,
      );

      if (isEditMode) {
        if (productId == null) {
          Get.snackbar('Error', 'Product ID is missing for update.');
          isLoading.value = false;
          return;
        }
        await _addProductService.updateProduct(productData);
        Get.offAllNamed(ProductView.TAG);
        Get.snackbar('Success', 'Product updated successfully!');
      } else {
        await _addProductService.addProductToDatabase(productData);
        Get.offAllNamed(ProductView.TAG);
        Get.snackbar('Success', 'Product added successfully!');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}


