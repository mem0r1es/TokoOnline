import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersController extends GetxController {
  final supabase = Supabase.instance.client;

  // TextEditingController for search
  final TextEditingController searchController = TextEditingController();

  var allOrders = <Map<String, dynamic>>[].obs;
  var filteredOrders = <Map<String, dynamic>>[].obs;

  var searchQuery = ''.obs;
  var selectedStatus = ''.obs;
  var selectedPaymentMethod = ''.obs;
  var isLoading = false.obs;

  // Status list untuk dropdown
  final RxList<String> statusList = <String>[
    'all',
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'refunded',
  ].obs;

  // Payment method list untuk dropdown
  final RxList<String> paymentMethodList = <String>[
    'all',
    'credit_card',
    'bank_transfer',
    'e_wallet',
    'cod',
    'virtual_account',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    
    // Add listener untuk search
    searchController.addListener(() {
      searchOrders(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('order_history')
          .select('*')
          .order('created_at', ascending: false) as List;

      final orders = response
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      allOrders.assignAll(orders);
      filteredOrders.assignAll(orders);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat orders: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchOrders(String query) {
    searchQuery.value = query.trim().toLowerCase();
    _applyFilters();
  }

  void filterByStatus(String status) {
    selectedStatus.value = status.trim();
    _applyFilters();
  }

  void filterByPaymentMethod(String paymentMethod) {
    selectedPaymentMethod.value = paymentMethod.trim();
    _applyFilters();
  }

  void _applyFilters() {
    filteredOrders.value = allOrders.where((order) {
      final fullName = (order['full_name'] ?? '').toString().toLowerCase();
      final email = (order['email'] ?? '').toString().toLowerCase();
      final orderId = (order['order_id'] ?? '').toString().toLowerCase();
      final status = (order['status'] ?? '').toString().toLowerCase();
      final paymentMethod = (order['payment_method'] ?? '').toString().toLowerCase();

      final matchesSearch = searchQuery.value.isEmpty || 
          fullName.contains(searchQuery.value) ||
          email.contains(searchQuery.value) ||
          orderId.contains(searchQuery.value);
      
      final matchesStatus = selectedStatus.value.isEmpty ||
          selectedStatus.value == 'all' ||
          status == selectedStatus.value.toLowerCase();
      
      final matchesPaymentMethod = selectedPaymentMethod.value.isEmpty ||
          selectedPaymentMethod.value == 'all' ||
          paymentMethod == selectedPaymentMethod.value.toLowerCase();

      return matchesSearch && matchesStatus && matchesPaymentMethod;
    }).toList();
  }

  void viewOrderDetail(Map<String, dynamic> order) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 600,
          height: MediaQuery.of(Get.context!).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Order',
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Information
                      _buildSectionTitle('Order Information'),
                      _buildDetailRow('Order ID', order['order_id']),
                      _buildDetailRow('Status', order['status']),
                      _buildDetailRow('Timestamp', _formatDateTime(order['timestamp'])),
                      _buildDetailRow('Created At', _formatDateTime(order['created_at'])),
                      _buildDetailRow('Updated At', _formatDateTime(order['updated_at'])),
                      _buildDetailRow('Estimated Arrival', _formatDateTime(order['estimated_arrival'])),
                      
                      const SizedBox(height: 20),
                      
                      // Customer Information
                      _buildSectionTitle('Customer Information'),
                      _buildDetailRow('Full Name', order['full_name']),
                      _buildDetailRow('Email', order['email']),
                      _buildDetailRow('Phone', order['phone']),
                      _buildDetailRow('Address', order['address']),
                      
                      const SizedBox(height: 20),
                      
                      // Payment & Shipping Information
                      _buildSectionTitle('Payment & Shipping'),
                      _buildDetailRow('Payment Method', _formatPaymentMethod(order['payment_method'])),
                      _buildDetailRow('Seller', order['seller']),
                      _buildDetailRow('Cargo Name', order['cargo_name']),
                      _buildDetailRow('Cargo ID', order['cargo_id']),
                      
                      const SizedBox(height: 20),
                      
                      // Product Information
                      _buildSectionTitle('Product Information'),
                      _buildDetailRow('Items', order['items']),
                      _buildDetailRow('Item Quantity', order['item_quantity']?.toString()),
                      _buildDetailRow('Total Products', order['total_produk']?.toString()),
                      
                      // Display product image if available
                      if (order['imageUrl'] != null && order['imageUrl'].toString().isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            const Text(
                              'Product Image:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  order['imageUrl'],
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
                          ],
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Price Information
                      _buildSectionTitle('Price Information'),
                      _buildDetailRow('Total Price', 'Rp ${_formatPrice(order['total_price'])}'),
                      _buildDetailRow('Shipping Cost (Ongkir)', 'Rp ${_formatPrice(order['ongkir'])}'),
                      _buildDetailRow('Total Payment', 'Rp ${_formatPrice(order['total_bayar'])}'),
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

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
          fontSize: 16,
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
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(fontSize: 14),
            ),
          ),
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

  String _formatPaymentMethod(String? method) {
    if (method == null) return '-';
    switch (method.toLowerCase()) {
      case 'credit_card':
        return 'Credit Card';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'e_wallet':
        return 'E-Wallet';
      case 'cod':
        return 'Cash on Delivery';
      case 'virtual_account':
        return 'Virtual Account';
      default:
        return method;
    }
  }

  String formatStatusText(String? status) {
    if (status == null) return '-';
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}