
import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/scroll_controller.dart';
import 'package:flutter_web/models/order_history_item.dart';
import 'package:flutter_web/pages/history/order_tile.dart';
import 'package:flutter_web/pages/homepage/home_page.dart';
import 'package:flutter_web/controllers/address_controller.dart';
import 'package:flutter_web/models/info_user.dart';
// import 'package:flutter_web/controller/cart_controller.dart';
// import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:flutter_web/models/order_history_item.dart';
import 'package:flutter_web/services/checkout_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'package:intl/intl.dart';

class ProductInfoPage extends StatefulWidget {
  static const TAG = '/productinfo';

  const ProductInfoPage({super.key});

  @override
  State<ProductInfoPage> createState() => _ProductInfoPageState();
}

class _ProductInfoPageState extends State<ProductInfoPage> {
  final CheckoutService checkoutService = Get.find<CheckoutService>();

  @override
  void initState() {
    super.initState();
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email != null) {
      checkoutService.loadOrderHistoryFromSupabase(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = Get.find<CustomScrollController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            scrollController.selectedIndex.value = 2;
            Get.offAllNamed(HomePage.TAG);
          },
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Order History",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Obx(() {
          if (checkoutService.orderHistory.isEmpty) {
            return Center(
              child: Text(
                "No order history yet.",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            controller: scrollController.scrollController,
            itemCount: checkoutService.orderHistory.length,
            itemBuilder: (context, index) {
              
              final order = checkoutService.orderHistory[index];
              DateFormat('dd MMM yyyy • HH:mm').format(order.timestamp);

              return Column(
                children: [
                  OrderTile(order: order),
                  // const SizedBox(height: 15),
                  const Divider(
                    color: Colors.white,
                  ),
                  // const SizedBox(height: 2),
                ],
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

  OrderDetailPage({super.key, required this.order});

  final addressController = Get.find<AddressController>();
  final checkoutService = Get.find<CheckoutService>();

  @override
  Widget build(BuildContext context) {
    final info = order.infoUser.isNotEmpty ? order.infoUser.first : InfoUser(provinsiId: '', kecamatanId: '', kotaId: '');

    final formattedTime = DateFormat('dd MMM yyyy • HH:mm').format(order.timestamp);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Order Details", style: GoogleFonts.poppins()),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ordered at $formattedTime', style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 16),

              _sectionTitle("Contact Information"),
              Text("Full Name: ${info.fullName}", style: GoogleFonts.poppins(fontSize: 14)),
              Text("Email: ${info.email}", style: GoogleFonts.poppins(fontSize: 14)),
              Text("Phone: ${info.phone}", style: GoogleFonts.poppins(fontSize: 14)),
              Text("Address: ${info.address}", style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 20),

              _sectionTitle("Order Summary"),
              const SizedBox(height: 10),

              _orderSummarySection(),
              const SizedBox(height: 10),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Price:",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text("Rp ${_rupiah(order.items.fold(0.0, (sum, item) => sum + item.totalPrice))}")
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Payment Method: ${order.paymentMethod}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _orderSummarySection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ...order.items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${item.name} × ${item.quantity}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
              Text(
                'Rp ${_rupiah(item.totalPrice)}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
        );
      }),
    ],
  );
}

  String _rupiah(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}