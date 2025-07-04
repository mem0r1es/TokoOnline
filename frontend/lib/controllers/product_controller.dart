import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../dashboard/header/shop/product_model.dart';

class ProductService extends GetxController {
  final supabase = Supabase.instance.client;

  // Observable lists
  var products = <Product>[].obs;
  var featuredProducts = <Product>[].obs;
  var categories = <String>[].obs;

  // Loading states
  var isLoading = false.obs;
  var isSearching = false.obs;

  // Static fallback products
  final List<Product> staticProducts = [
    Product(
      id: 'static-1',
      title: 'Syltherine',
      imagePath: 'assets/product1.png',
      description: 'Stylish cafe chair',
      price: 2500000,
      category: 'furniture',
      stock: 50,
    ),
    Product(
      id: 'static-2',
      title: 'Product 2',
      imagePath: 'assets/product2.png',
      description: 'Elegant dining table',
      price: 3000000,
      category: 'furniture',
      stock: 25,
    ),
    Product(
      id: 'static-3',
      title: 'Product 3',
      imagePath: 'assets/product3.png',
      description: 'Comfortable sofa',
      price: 4500000,
      category: 'furniture',
      stock: 15,
    ),
    Product(
      id: 'static-4',
      title: 'Product 4',
      imagePath: 'assets/product4.png',
      description: 'Modern bookshelf',
      price: 1800000,
      category: 'furniture',
      stock: 30,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  // UPDATED METHOD - STEP 2
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      print('🔍 STEP: Starting fetchProducts...');

      // Check total products (including inactive)
      final totalCountResponse = await supabase.from('products').select('id');
      print('📊 TOTAL products in DB (all): ${totalCountResponse.length}');

      // Check active products
      final response = await supabase
          .from('products')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      print('📊 ACTIVE products in DB: ${response.length}');

      // Check for inactive products
      final inactiveCountResponse = await supabase
          .from('products')
          .select('id')
          .eq('is_active', false);
      print('📊 INACTIVE products in DB: ${inactiveCountResponse.length}');

      // Show all product names for debug
      print('📋 ACTIVE PRODUCT LIST:');
      for (var item in response) {
        print(
          '   - ${item['name']} (${item['category']}) - Active: ${item['is_active']} - Stock: ${item['stock']}',
        );
      }

      List<Product> databaseProducts = response
          .map((data) => Product.fromDatabase(data))
          .toList();

      if (databaseProducts.isNotEmpty) {
        products.value = databaseProducts;
        print('✅ USING DATABASE products: ${databaseProducts.length} items');
      } else {
        products.value = staticProducts;
        print(
          '⚠️ DATABASE EMPTY - using STATIC fallback: ${staticProducts.length} items',
        );
      }

      // Set featured products (first 8)
      featuredProducts.value = products.take(8).toList();

      // Extract unique categories
      categories.value = products
          .map((p) => p.category ?? 'Uncategorized')
          .toSet()
          .toList();

      print('🏁 FINAL SUMMARY:');
      print('   - Total products loaded: ${products.length}');
      print('   - Featured products: ${featuredProducts.length}');
      print('   - Categories: ${categories.join(', ')}');
    } catch (e) {
      print('❌ ERROR fetching products: $e');
      print('❌ Error type: ${e.runtimeType}');

      // Use static products as fallback on error
      products.value = staticProducts;
      featuredProducts.value = staticProducts;

      Get.snackbar(
        'Warning',
        'Database connection failed. Using sample products.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
      print('🏁 fetchProducts completed');
    }
  }

  // UPDATED SEARCH METHOD - STEP 3
  Future<List<Product>> searchProducts(String query) async {
    if (query.trim().isEmpty) return products.toList();

    try {
      isSearching.value = true;
      print('🔍 SEARCHING for: "$query"');
      print('🔍 Searching in ${products.length} total products');

      // Local search first (from loaded products)
      List<Product> localResults = products
          .where(
            (product) =>
                product.title.toLowerCase().contains(query.toLowerCase()) ||
                product.description.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                (product.category?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();

      print('📊 Local search results: ${localResults.length}');
      for (var product in localResults) {
        print('   - Found: ${product.title} (${product.category})');
      }

      if (localResults.isNotEmpty) {
        return localResults;
      }

      // If local search empty, try database search
      print('🔍 Local search empty, trying database search...');

      final response = await supabase
          .from('products')
          .select('*')
          .eq('is_active', true)
          .or(
            'name.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%',
          )
          .order('name');

      final searchResults = response
          .map((data) => Product.fromDatabase(data))
          .toList();

      print('📊 Database search results: ${searchResults.length}');
      for (var product in searchResults) {
        print('   - Found in DB: ${product.title} (${product.category})');
      }

      return searchResults;
    } catch (e) {
      print('❌ Search error: $e');
      return [];
    } finally {
      isSearching.value = false;
    }
  }

  // Method untuk migrate static products ke database
  Future<void> migrateStaticProductsToDatabase() async {
    try {
      print('🔄 Migrating static products to database...');

      // Check if products already exist
      final existingProducts = await supabase
          .from('products')
          .select('name')
          .eq('is_active', true);

      if (existingProducts.isNotEmpty) {
        Get.snackbar(
          'Info',
          'Products already exist in database! (${existingProducts.length} found)',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Insert static products
      final productsToInsert = staticProducts
          .map((product) => product.toDatabase())
          .toList();

      await supabase.from('products').insert(productsToInsert);

      Get.snackbar(
        'Success',
        'Products successfully migrated to database!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      // Refresh products from database
      await fetchProducts();
    } catch (e) {
      print('❌ Migration error: $e');
      Get.snackbar(
        'Error',
        'Migration failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Refresh products
  Future<void> refreshProducts() async {
    print('🔄 Refreshing products...');
    await fetchProducts();
  }

  // Debug method
  void printProductsInfo() {
    print('=== PRODUCTS INFO ===');
    print('Total products: ${products.length}');
    print('Categories: ${categories.join(', ')}');
    print('Featured products: ${featuredProducts.length}');
    print('Loading: ${isLoading.value}');
    print('Searching: ${isSearching.value}');

    for (var product in products.take(3)) {
      print('- ${product.title}: Rp ${product.price}');
    }
    print('=====================');
  }

  // NEW: Test connection method
  Future<void> testConnection() async {
    try {
      print('🧪 TESTING: Supabase connection...');

      final response = await supabase.from('products').select('count').limit(1);

      print('✅ TESTING: Connection OK! Response: $response');
    } catch (e) {
      print('❌ TESTING: Connection FAILED! Error: $e');
    }
  }
}
