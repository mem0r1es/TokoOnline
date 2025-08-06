
import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/scroll_controller.dart';
import 'package:flutter_web/pages/history/order_tile.dart';
import 'package:flutter_web/pages/homepage/home_page.dart';
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
              final formattedTime = DateFormat('dd MMM yyyy • HH:mm').format(order.timestamp);

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