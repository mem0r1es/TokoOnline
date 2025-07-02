import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/page_controller.dart';
import 'billing.dart';

class CartPages extends StatelessWidget {
  CartPages({super.key});

  final cartC = Get.put(CartController1());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: Product Table
          SizedBox(
            width: 817,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: _tableHeader(),
                ),
                // const Divider(height: 1),
                // List produk
                Obx(() => SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: cartC.cartItems.length,
                    itemBuilder: (_, i) {
                      final item = cartC.cartItems[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Product name + image
                            Row(
                              children: [
                                Image.asset(item.imagePath, width: 50, height: 50),
                                const SizedBox(width: 10),
                                Text(item.title),
                              ],
                            ),

                            Text('Rp ${_rupiah(item.price)}'),
                            Text('${item.quantity}'),
                            Text('Rp ${_rupiah(item.subtotal)}'),
                          ],
                        ),
                      );
                    },
                  ),
                )),

              ],
            ),
          ),

          const SizedBox(width: 30),

          // RIGHT: Ringkasan Belanja
          Container(
            width: 393,
            height: 390,
            color: const Color(0xFFF9F1E7),
            padding: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Cart Totals',
                    style: GoogleFonts.poppins(
                      fontSize: 32, 
                      fontWeight: FontWeight.w600, 
                      ),
                    ),
                    const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Obx(() {
                        final total = cartC.cartItems.fold(0, (sum, item) => sum + item.subtotal);
                        return Text(
                          'Rp ${_rupiah(total)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height:50),
                  Center(
                    child: Container(
                      width: 222,
                      height: 58.95,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: Colors.white,
                      ),
                      child: _billing('Check Out',() => Get.to(CheckoutPage()))
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() => Column(
    children: [
      Container(
        height: 60,
        padding: const EdgeInsets.all(20),
        color: const Color(0xFFF9F1E7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _text('Product'),
            _text('Price'),
            _text('Qty'),
            _text('Subtotal'),
          ],
        ),
      ),
      const Divider(height: 1),
    ],
  );

  Widget _text(String txt) => Text(
        txt,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      );

  Widget _billing(String text, [VoidCallback? onPressed]) {
    return SizedBox(
      width: 222,
      height: 58.95,
      child: TextButton(
        onPressed: onPressed, 
        child: _text(text),
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: const Color.fromARGB(255, 6, 5, 5),
            ),
          ),
        ),
      ),
    );
  }

  String _rupiah(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
