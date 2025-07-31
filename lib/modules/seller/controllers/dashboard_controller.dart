import 'package:get/get.dart';

class SellerDashboardController extends GetxController {
  // Contoh variabel observable
  var sellerName = 'Seller Default'.obs;

  @override
  void onInit() {
    super.onInit();
    // Bisa load data awal di sini, misalnya dari Supabase
    print("SellerDashboardController initialized");
  }

  void logout() {
    // Implementasi logout nanti
    print("Seller logout");
  }
}
