import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class ProductInfoPage extends StatelessWidget {
  final CartService cartService = Get.find<CartService>();
  ProductInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Order History",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
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
            itemCount: cartService.orderHistory.length,
            itemBuilder: (context, index) {
              final order = cartService.orderHistory[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  tileColor: Colors.white,
                  title: Text('Order at ${order.timestamp}'),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    // ➔ Pindah ke detail page
                    Get.to(() => OrderDetailPage(order:order));
                  },
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class OrderDetailPage extends StatelessWidget {
  final OrderHistoryItem order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Order Details"),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ordered at: ${order.timestamp}", style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Contact Information",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              Text("Full Name: ${order.fullName}", style: GoogleFonts.poppins(fontSize: 14)),
              Text("Email: ${order.email}", style: GoogleFonts.poppins(fontSize: 14)),
              Text("Phone: ${order.phone}", style: GoogleFonts.poppins(fontSize: 14)),
              Text("Address: ${order.address}", style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Order Summary",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),

              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.name} × ${item.quantity}', style: GoogleFonts.poppins()),
                    Text('Rp ${_rupiah(item.totalPrice)}', style: GoogleFonts.poppins()),
                  ],
                ),
              )),
              const SizedBox(height: 10),

              Text(
                "Total Price: Rp ${_rupiah(order.items.fold(0.0, (sum, item) => sum + item.totalPrice))}",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
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
