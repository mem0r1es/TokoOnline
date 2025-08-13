import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsController extends GetxController {
  final supabase = Supabase.instance.client;

  // TextEditingController for search
  final TextEditingController searchController = TextEditingController();

  var allProducts = <Map<String, dynamic>>[].obs;
  var filteredProducts = <Map<String, dynamic>>[].obs;

  var searchQuery = ''.obs;
  var selectedCategory = ''.obs;
  var selectedStatus = ''.obs;
  var isLoading = false.obs;

  // Category list untuk dropdown
  final RxList<String> categoryList = <String>[
    'all',
    'Electronics',
    'Fashion',
    'Food & Beverage',
    'Health & Beauty',
    'Sports',
    'Books',
    'Home & Garden',
    'Toys',
    'Automotive',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    
    // Add listener untuk search
    searchController.addListener(() {
      searchProducts(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('products_with_seller')
          .select('*')
          .order('created_at', ascending: false) as List;

      final products = response
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      allProducts.assignAll(products);
      filteredProducts.assignAll(products);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat produk: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applyFilters();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category.trim();
    _applyFilters();
  }

  void filterByStatus(String status) {
    selectedStatus.value = status.trim();
    _applyFilters();
  }

  void _applyFilters() {
    filteredProducts.value = allProducts.where((product) {
      final name = (product['name'] ?? '').toString().toLowerCase();
      final category = (product['category'] ?? '').toString().toLowerCase();
      final isActive = product['is_active'] ?? true;

      final matchesSearch =
          searchQuery.value.isEmpty || name.contains(searchQuery.value);
      
      final matchesCategory = selectedCategory.value.isEmpty ||
          selectedCategory.value == 'all' ||
          category == selectedCategory.value.toLowerCase();
      
      bool matchesStatus = true;
      if (selectedStatus.value.isNotEmpty && selectedStatus.value != 'all') {
        if (selectedStatus.value == 'active') {
          matchesStatus = isActive == true;
        } else if (selectedStatus.value == 'inactive') {
          matchesStatus = isActive == false;
        }
      }

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  void viewProductDetail(Map<String, dynamic> product) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Produk',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display product image if available
                      if (product['image_url'] != null && product['image_url'].toString().isNotEmpty)
                        Container(
                          height: 200,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product['image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      _buildDetailRow('ID', product['id']),
                      _buildDetailRow('Nama Produk', product['name']),
                      _buildDetailRow('Kategori', product['category']),
                      _buildDetailRow('Harga', 'Rp ${_formatPrice(product['price'])}'),
                      _buildDetailRow('Stok', product['stock_quantity']?.toString()),
                      _buildDetailRow('Status', product['is_active'] == true ? 'Aktif' : 'Tidak Aktif'),
                      _buildDetailRow('Nama Toko', product['seller_store_name']),
                      _buildDetailRow('Seller ID', product['seller_id']),
                      _buildDetailRow('Dibuat', _formatDateTime(product['created_at'])),
                      const SizedBox(height: 12),
                      const Text(
                        'Deskripsi:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          product['description']?.toString() ?? 'Tidak ada deskripsi',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? '-')),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '-';
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateTime;
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    try {
      final numPrice = double.parse(price.toString());
      return numPrice.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (_) {
      return price.toString();
    }
  }
}