import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductController extends GetxController {
  final ProductService productService = ProductService();
  var products = <Product>[].obs;
  var featuredProducts = <Product>[].obs;
  var categories = <String>[].obs;
  var isLoading = false.obs;
  var isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    final result = await productService.fetchProducts();
    products.value = result;
    featuredProducts.value = result.take(8).toList();
    categories.value = result.map((p) => p.category ?? 'Uncategorized').toSet().toList();
    isLoading.value = false;
  }

  Future<void> searchProducts(String query) async {
    isSearching.value = true;
    final result = await productService.searchProducts(query);
    products.value = result;
    isSearching.value = false;
  }

  Future<void> migrateProducts() => productService.migrateStaticProductsToDatabase();

  Future<void> refreshProducts() async {
    print('🔄 Refreshing products...');
    await fetchProducts();
  }
}
