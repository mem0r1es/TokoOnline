// modules/seller/views/order_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_online_getx/modules/seller/controllers/dashboard_controller.dart';
import 'package:toko_online_getx/modules/seller/widgets/sidebar_seller.dart';
import 'package:toko_online_getx/widgets/seller_top_bar.dart';
import 'package:intl/intl.dart';

class OrderPage extends GetView<SellerDashboardController> {
  static const String TAG = '/order-page';
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SidebarSeller(),
          Expanded(
            child: Column(
              children: [
                const SellerTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Obx(() => Text(
                                'Menampilkan ${controller.totalOrders.value} pesanan',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              )),
                        ),
                        Expanded(
                          child: Obx(() {
                            if (controller.isLoadingOrders.value) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (controller.orders.isEmpty) {
                              return const Center(
                                child: Text('Tidak ada pesanan ditemukan.',
                                    style: TextStyle(fontSize: 16)),
                              );
                            }
                            return RefreshIndicator(
                              onRefresh: () async => controller.refreshDashboard(),
                              child: ListView.builder(
                                itemCount: controller.orders.length,
                                itemBuilder: (context, index) {
                                  final order = controller.orders[index];
                                  return Card(
                                    elevation: 1,
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: ListTile(
                                      leading: Image.network(
                                        order['product_image'] ?? '',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image, size: 50),
                                      ),
                                      title: Text(order['product_name'] ?? 'Nama Produk Tidak Diketahui',
                                          style: const TextStyle(fontSize: 16)),
                                      subtitle: Text(
                                          'Status: ${order['status'] ?? 'Menunggu Konfirmasi'}'),
                                      onTap: () => _showOrderDetailDialog(context, order),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailDialog(BuildContext context, Map<String, dynamic> order) {
    String selectedStatus = order['status'] ?? 'menunggu konfirmasi';
    DateTime? estimatedArrival = order['estimated_arrival'] != null
        ? DateTime.parse(order['estimated_arrival'])
        : null;

    final estimatedArrivalController = TextEditingController(
      text: estimatedArrival != null ? DateFormat('dd-MM-yyyy').format(estimatedArrival) : ''
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Detail Pesanan'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Image.network(
                        order['product_image'] ?? '',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 150),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Nama Produk', order['product_name']),
                    _buildDetailRow('Jumlah', order['quantity'].toString()),
                    _buildDetailRow('Nama Pembeli', order['full_name']),
                    _buildDetailRow('Alamat Pengiriman', order['address']),
                    _buildDetailRow('Metode Pembayaran', order['payment_method']),
                    _buildDetailRow('Kurir', order['cargo_name']),
                    _buildDetailRow('Ongkir', _rupiah(order['ongkir'] ?? 0)),
                    _buildDetailRow('Total Produk', _rupiah(order['total_produk'] ?? 0)),
                    _buildDetailRow('Total Bayar', _rupiah(order['total_bayar'] ?? 0)),
                    _buildDetailRow('Status Saat Ini', selectedStatus),
                    const SizedBox(height: 16),
                    const Text('Ubah Status Pesanan:', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: selectedStatus,
                      items: <String>['menunggu konfirmasi', 'diproses', 'dikirim', 'tiba', 'dibatalkan']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.capitalizeFirst ?? value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        if (newValue != null) {
                          setState(() {
                            selectedStatus = newValue;
                          });
                          await controller.updateOrderStatus(order['order_id'], newValue, estimatedArrival: estimatedArrival);
                          Navigator.of(context).pop(); // Tutup dialog setelah update selesai
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Ubah Estimasi Tiba:', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: estimatedArrivalController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: estimatedArrival ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            estimatedArrival = pickedDate;
                            estimatedArrivalController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                          });
                          await controller.updateOrderStatus(order['order_id'], selectedStatus, estimatedArrival: pickedDate);
                          Navigator.of(context).pop();
                        }
                      },
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value?.toString() ?? '-')),
        ],
      ),
    );
  }

  String _rupiah(num n) => NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(n);
}
