import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/address_controller.dart';
// import 'package:flutter_web/controller/auth_controller.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/controllers/checkout_controller.dart';
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

class CheckoutPage extends GetView<CheckoutController> {
  CheckoutPage({super.key});

  // final CartController cartController = Get.find<CartController>();
  final CartService cartService = Get.find<CartService>();
  final CheckoutController checkoutController = Get.find();
  final addressController = Get.find<AddressController>();

  // final _firstNameController = TextEditingController();
  // final _lastNameController = TextEditingController();
  // final _emailController = TextEditingController();
  // final _phoneController = TextEditingController();
  // final _addressController = TextEditingController();
  // final authController = Get.find<AuthController>();
  // final userId = AuthService.getUserId();


  // String? _selectedAddressId;
  // InfoUser? _selectedAddressUser;
  // String? _selectedPayment = 'Direct bank transfer';

//   @override
//   void initState() {
//   super.initState();
//   // final userEmail = authController.getUserEmail()?? '';
//   _emailController.text = authController.getUserEmail() ?? '';
// }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
      title: Text("Checkout Page", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            Get.toNamed(ProductInfoPage.TAG);
          },
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        final address = addressController.selectedAddressUser.value;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _title("Shipping Address"),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),),
                    onPressed: () {
                      Get.toNamed(AddressPage.TAG);
                    },
                    child: Text(
                      "Manage Addresses",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                      color: Colors.purple[20],
                      fontWeight: FontWeight.bold
                    )
                      ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
          
              // ✅ Menampilkan 1 default address
              if (address != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        'Fullname: ${address.fullName ?? 'Unknown'}',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phone: ${address.phone ?? 'Unknown'}',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Address: ${address.address ?? 'Unknown'}',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              else
                Text("No address selected", style: GoogleFonts.poppins(fontSize: 14, color: Colors.red)),
          
              const SizedBox(height: 20),
          
              // ✅ RINGKASAN PRODUK + TOTAL
              Container(
                margin: const EdgeInsets.only(top: 20),
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title("Product"),
                    const SizedBox(height: 10),
                    ...cartService.cartItems.map((item) => _orderRow(
                          '${item.name} × ${item.quantity}',
                          'Rp ${_rupiah(item.totalPrice)}',
                        )),
                    const Divider(),
                    // _orderRow("Subtotal", 'Rp ${_rupiah(cartService.totalPrice)}'),
                    // const SizedBox(height: 8),
                    _orderRow(
                      "Total",
                      'Rp ${_rupiah(cartService.totalPrice)}',
                      isBold: true,
                      color: Colors.purple[800],
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
                        final authController = Get.find<AuthController>();
                        final cartService = Get.find<CartService>();
                        final checkoutService = Get.find<CheckoutService>();
                        final userEmail = authController.getUserEmail() ?? '';
                        final addressController = Get.find<AddressController>();
              
                        if (addressController.selectedAddressUser.value == null) {
                          Get.snackbar("Error", "Please select an address first.");
                          return;
                        }
              
                        final order = OrderHistoryItem(
                          timestamp: DateTime.now(),
                          items: List<CartItem>.from(cartService.cartItems),
                          infoUser: [addressController.selectedAddressUser.value!],
                          paymentMethod: controller.selectedPayment.value, id: '',
                        );
              
                        cartService.orderHistory.add(order);
                        await checkoutService.saveOrderToSupabase(order, controller.selectedPayment.value);
                        await Get.find<CartService>().clearCartFromSupabase(userEmail);
                        cartService.clearCart();
              
                        Get.toNamed(ProductInfoPage.TAG);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 248, 243, 243),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      ),
                      child: Text("Place Order", style: GoogleFonts.poppins(fontSize: 16)),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    ),
  );
}


  Widget _title(String text) => Text(
        text,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
      );

  // Widget _formInput(String label, {TextEditingController? controller, bool readOnly = false}) => Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(label, style: GoogleFonts.poppins(fontSize: 14)),
  //         const SizedBox(height: 8),
  //         TextFormField(
  //           controller: controller,
  //           readOnly: readOnly,
  //           decoration: InputDecoration(
  //             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //             fillColor: readOnly ? Colors.grey[200] : Colors.white,
  //             filled: true,
  //           ),
  //         ),
  //       ],
  //     );

  // Widget _formRow(String leftLabel, String rightLabel) => Row(
  //       children: [
  //         Expanded(child: _formInput(leftLabel, controller: _firstNameController)),
  //         const SizedBox(width: 16),
  //         Expanded(child: _formInput(rightLabel, controller: _lastNameController)),
  //       ],
  //     );

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
    return Obx(() => Row(
      children: [
        Radio <String>(
          value: label, 
          groupValue: controller.selectedPayment.value, 
          onChanged: (value) {
            // setState(() {
              // _selectedPayment = value;
              if (value != null) controller.selectedPayment.value = value;
            // });
          }),
        Text(label, style: GoogleFonts.poppins(fontSize: 14)),
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
