
import 'package:flutter/material.dart';
import 'package:flutter_web/models/product_model.dart';
import 'package:flutter_web/pages/search/search_page.dart';
import 'package:flutter_web/services/product_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchController extends GetxController {
  final TextEditingController searchInputController = TextEditingController();
  // var query = ''.obs;
  // var results = <Product>[].obs;

  var currentQuery = ''.obs;
  var searchResults = <Product>[].obs;

  // Method untuk melakukan pencarian
  Future<void> performSearch(String query) async {
    // Perbarui currentQuery agar UI bisa bereaksi jika diperlukan
    currentQuery.value = query;
    searchResults.clear(); // Bersihkan hasil sebelumnya

    if (query.trim().isEmpty) {
      // Jika query kosong, jangan lakukan pencarian, mungkin tampilkan pesan
      return;
    }

    try {
      print('🔍 SEARCH CONTROLLER: Starting search for "$query"');

      // Dapatkan ProductService. Pastikan sudah diinisialisasi di GetX binding.
      final ProductService productService = Get.find<ProductService>();
      final List<Product> foundProducts = await productService.searchProducts(query);

      searchResults.value = foundProducts; // Update hasil pencarian

      print('SEARCH CONTROLLER: Found ${foundProducts.length} results');
      for (var product in foundProducts) {
        print('    - ${product.title} (${product.category})');
      }

      // Navigasi ke halaman hasil pencarian jika ada hasil
      if (foundProducts.isNotEmpty) {
        Get.toNamed(
          SearchResultPage.TAG,
          arguments: {
            'query': query,
            'results': foundProducts,
          },
        );
      } else {
        // Tampilkan dialog jika tidak ada hasil
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'No Results Found',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No products found for "$query"',
                  style: GoogleFonts.poppins(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      print('SEARCH CONTROLLER ERROR: $e');
      Get.snackbar(
        'Search Error',
        'Failed to search products: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    void clearSearchInput (){
      searchInputController.clear();
    }
  }
  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }


  

  // void setResults(String q, List<Product> r) {
  //   query.value = q;
  //   results.value = r;
  // }

  // void clear() {
  //   query.value = '';
  //   results.clear();
  // }

  
}


