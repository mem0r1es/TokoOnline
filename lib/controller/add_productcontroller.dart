import 'package:get/get.dart';
import 'package:toko_online_getx/models/add_productmodel.dart';
import 'package:toko_online_getx/service/add_productservice.dart';

class AddProductController extends GetxController {
  final AddProductService _addProductService = Get.find<AddProductService>();
  Rx<String?> imageUrl = Rx<String?>(null);

  Future<void> handleImageUpload() async {
    String? uploadedUrl = await _addProductService.uploadImage();
    if (uploadedUrl != null) {
      imageUrl.value = uploadedUrl;
    }
  }

  Future<void> addProduct(AddProductmodel product) async {
    await _addProductService.addProductToDatabase(product);
  }


  // Additional methods for handling form submission, validation, etc. can be added here.
}