import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import '../header_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class ProductInfoPage extends StatelessWidget {
  final CartService cartService = Get.find<CartService>();
  ProductInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Product Information",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding (
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (cartService.orderHistory.isEmpty) {
            return Center(
              child: Text(
                "No order history yet.",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: cartService.orderHistory.length,
            itemBuilder: (context, index) {
              final order = cartService.orderHistory[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('Order at ${order.timestamp}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: order.items
                        .map<Widget>((item) => _orderRow(
                              '${item.name} × ${item.quantity}',
                              'Rp ${_rupiah(item.totalPrice)}',
                            ))
                        .toList(),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      cartService.orderHistory.removeAt(index);
                    },
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _orderRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: isBold ? FontWeight.bold : FontWeight.w400)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _rupiah(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}