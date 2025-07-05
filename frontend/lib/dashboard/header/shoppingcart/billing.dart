import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:flutter_web/dashboard/header/header_bar.dart';
import 'package:flutter_web/dashboard/header/shoppingcart/history.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/page_controller.dart'; 
import '../../../controllers/cart_controller.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartService cartService = Get.find<CartService>();

  String? _selectedPayment = 'Direct bank transfer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x0fffffff),
      body: Column(
        children: [
          const HeaderPages(), // Tetap di atas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT: Billing Form
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _title("Billing details"),
                          const SizedBox(height: 20),
                          _formRow("First Name", "Last Name"),
                          const SizedBox(height: 16),
                          _formInput("Company Name (Optional)"),
                          const SizedBox(height: 16),
                          _formInput("Country / Region"),
                          const SizedBox(height: 16),
                          _formInput("Street Address"),
                          const SizedBox(height: 16),
                          _formInput("Town / City"),
                          const SizedBox(height: 16),
                          _formInput("Province"),
                          const SizedBox(height: 16),
                          _formInput("ZIP Code"),
                          const SizedBox(height: 16),
                          _formInput("Phone"),
                          const SizedBox(height: 16),
                          _formInput("Email Address"),
                          const SizedBox(height: 16),
                          _formInput("Additional Information"),
                        ],
                      ),
                    ),

                    const SizedBox(width: 50),

                    // RIGHT: Cart Summary
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Obx(() {
                          // final total = cartC.cartItems.fold(0, (sum, item) => sum + item.subtotal);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _title("Product"),
                              const SizedBox(height: 10),

                              // Produk dalam cart
                              ...cartService.cartItems.map((item) => _orderRow(
                                    '${item.name} × ${item.quantity}',
                                    'Rp ${_rupiah(item.totalPrice)}',
                                  )),

                              const Divider(),
                              _orderRow("Subtotal", 'Rp ${_rupiah(cartService.totalPrice)}'),
                              const SizedBox(height: 8),
                              _orderRow(
                                "Total",
                                'Rp ${_rupiah(cartService.totalPrice)}',
                                isBold: true,
                                color: Colors.orange[800],
                              ),
                              const SizedBox(height: 20),
                              _title("Payment Methods"),
                              const SizedBox(height: 10),
                              _radioOption("Direct bank transfer"),
                              _radioOption("Cash on delivery"),
                              const SizedBox(height: 10),
                              Text(
                                "Your personal data will be used to support your experience...",
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Get.to(() => const HistoryPage());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                                ),
                                child: Text("Place Order", style: GoogleFonts.poppins(fontSize: 16)),
                              )
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String text) => Text(
        text,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
      );

  Widget _formInput(String label) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ],
      );

  Widget _formRow(String leftLabel, String rightLabel) => Row(
        children: [
          Expanded(child: _formInput(leftLabel)),
          const SizedBox(width: 16),
          Expanded(child: _formInput(rightLabel)),
        ],
      );

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

  Widget _radioOption(String label) {
    return Row(
      children: [
        Radio <String>(
          value: label, 
          groupValue: _selectedPayment, 
          onChanged: (String? value) {
            setState(() {
              _selectedPayment = value;
            });
          }),
        Text(label, style: GoogleFonts.poppins(fontSize: 14)),
      ],
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