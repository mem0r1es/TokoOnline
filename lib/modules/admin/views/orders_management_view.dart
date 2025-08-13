import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toko_online_getx/modules/admin/controllers/orders_controller.dart';

class OrdersManagementView extends StatelessWidget {
  OrdersManagementView({Key? key}) : super(key: key);

  final OrdersController controller = Get.put(OrdersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Orders Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Statistics display
                Obx(() => Row(
                  children: [
                    _buildStatCard(
                      'Total Orders',
                      controller.filteredOrders.length.toString(),
                      Icons.shopping_cart_outlined,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Total Revenue',
                      'Rp ${_formatPrice(_calculateTotalRevenue())}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ],
                )),
              ],
            ),
            const SizedBox(height: 24),

            // Search & Filter
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextField(
                            controller: controller.searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by customer name, email, or order ID...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            onChanged: (value) => controller.searchOrders(value),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Obx(() => DropdownButtonFormField<String>(
                            value: controller.selectedStatus.value.isEmpty 
                                ? 'all' 
                                : controller.selectedStatus.value,
                            decoration: InputDecoration(
                              labelText: 'Filter by Status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: controller.statusList
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status == 'all' ? 'All Status' : _formatStatusText(status)),
                                    ))
                                .toList(),
                            onChanged: (value) => controller.filterByStatus(value ?? ''),
                          )),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Obx(() => DropdownButtonFormField<String>(
                            value: controller.selectedPaymentMethod.value.isEmpty 
                                ? 'all' 
                                : controller.selectedPaymentMethod.value,
                            decoration: InputDecoration(
                              labelText: 'Filter by Payment',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: controller.paymentMethodList
                                .map((method) => DropdownMenuItem(
                                      value: method,
                                      child: Text(method == 'all' ? 'All Payments' : _formatPaymentMethod(method)),
                                    ))
                                .toList(),
                            onChanged: (value) => controller.filterByPaymentMethod(value ?? ''),
                          )),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () => controller.loadOrders(),
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh',
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Table
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading orders...'),
                        ],
                      ),
                    );
                  }

                  if (controller.filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders found',
                            style: TextStyle(
                              color: Colors.grey[600], 
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filter criteria',
                            style: TextStyle(
                              color: Colors.grey[500], 
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Table Header with info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Showing ${controller.filteredOrders.length} order(s)',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      // Table Content
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              columnSpacing: 24,
                              horizontalMargin: 16,
                              columns: const [
                                DataColumn(label: Text('#')),
                                DataColumn(label: Text('Order ID')),
                                DataColumn(label: Text('Customer')),
                                DataColumn(label: Text('Items')),
                                DataColumn(label: Text('Total Amount')),
                                DataColumn(label: Text('Payment Method')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Seller')),
                                DataColumn(label: Text('Created')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: controller.filteredOrders.asMap().entries.map((entry) {
                                int index = entry.key;
                                var order = entry.value;

                                return DataRow(
                                  color: MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (states.contains(MaterialState.hovered)) {
                                        return Colors.grey[100];
                                      }
                                      return null;
                                    },
                                  ),
                                  cells: [
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8, 
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: Colors.blue[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        order['order_id']?.toString() ?? '-',
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 150,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              order['full_name'] ?? '-',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              order['email'] ?? '-',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${order['item_quantity'] ?? 0} items',
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            order['items']?.toString() ?? '-',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        'Rp ${_formatPrice(order['total_bayar'])}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _formatPaymentMethod(order['payment_method']),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    DataCell(_buildStatusChip(order['status'])),
                                    DataCell(
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          order['seller'] ?? '-',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(_formatDate(order['created_at']))),
                                    DataCell(_buildActionButtons(order)),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    final color = controller.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        controller.formatStatusText(status),
        style: TextStyle(
          fontSize: 12,
          color: color.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Only view action is allowed for admin
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 18),
          onPressed: () => controller.viewOrderDetail(order),
          color: Colors.blue,
          tooltip: 'View Details',
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
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

  String _formatStatusText(String? status) {
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

  double _calculateTotalRevenue() {
    double total = 0;
    for (var order in controller.filteredOrders) {
      final totalBayar = order['total_bayar'];
      if (totalBayar != null) {
        try {
          total += double.parse(totalBayar.toString());
        } catch (e) {
          // Skip invalid values
        }
      }
    }
    return total;
  }
}