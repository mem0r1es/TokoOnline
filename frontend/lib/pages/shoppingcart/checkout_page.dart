// Final Revised CheckoutPage with preserved commented code and fixed body layout
import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/address_controller.dart';
// import 'package:flutter_web/controller/auth_controller.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/models/cart_item.dart';
import 'package:flutter_web/models/info_user.dart';
// import 'package:flutter_web/controller/cart_controller.dart';
// import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:flutter_web/models/order_history_item.dart';
import 'package:flutter_web/pages/profile/address_page.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:flutter_web/services/checkout_service.dart';
import 'package:flutter_web/widgets/address_list_widget.dart';
// import 'package:flutter_web/widgets/header_bar.dart';
import 'package:flutter_web/pages/history/history.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../../controller/page_controller.dart'; 
// import '../../controller/cart_controller.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // final CartController cartController = Get.find<CartController>();
  final CartService cartService = Get.find<CartService>();
  // final _firstNameController = TextEditingController();
  // final _lastNameController = TextEditingController();
  // final _emailController = TextEditingController();
  // final _phoneController = TextEditingController();
  // final _addressController = TextEditingController();
  // final authController = Get.find<AuthController>();
  // final userId = AuthService.getUserId();

  String? _selectedAddressId;
  InfoUser? _selectedAddressUser;
  String? _selectedPayment = 'Direct bank transfer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x0fffffff),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Checkout Page", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Get.to(() => ProductInfoPage()); // Pindah ke halaman order history
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: Shipping Address and Manage Addresses
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top : 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _title("Shipping Address"),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(() => AddressPage());  // Kalau mau tambah/ganti alamat ➔ buka halaman AddressPage
                        },
                        child: Text("Manage Addresses"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: AddressListWidget(
                      selectedAddressId: _selectedAddressId,
                      onAddressSelected: (id) {
                        setState(() {
                          _selectedAddressId = id;
                          _selectedAddressUser = Get.find<AddressController>().addresses.firstWhereOrNull((a) => a.id == id);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title("Product"),
                    const SizedBox(height: 10),
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
                    _title("Payment"),
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
                      onPressed: () async {
                        Get.find<AuthController>();
                        final checkoutService = Get.find<CheckoutService>();
                        if (_selectedAddressUser == null) {
                          Get.snackbar("Error", "Please select an address first.");
                          return;
                        }
                        final order = OrderHistoryItem(
                          timestamp: DateTime.now(),
                          items: List<CartItem>.from(cartService.cartItems),
                          infoUser: [_selectedAddressUser!],
                          paymentMethod: _selectedPayment ?? 'Cash on Delivery',
                        );
                        cartService.orderHistory.add(order);
                        await checkoutService.saveOrderToSupabase(order, _selectedPayment!);
                        await cartService.clearCartFromSupabase('userEmail');
                        cartService.clearCart();
                        Get.to(() => ProductInfoPage());
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
    );
  }

  Widget _title(String text) => Text(
        text,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
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
        Radio<String>(
          value: label,
          groupValue: _selectedPayment,
          onChanged: (String? value) {
            setState(() {
              _selectedPayment = value;
            });
          },
        ),
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
