import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/address_controller.dart';
// import 'package:flutter_web/controller/auth_controller.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/controllers/cargo_controller.dart';
import 'package:flutter_web/controllers/checkout_controller.dart';
import 'package:flutter_web/extensions/extension.dart';
import 'package:flutter_web/models/cart_item.dart';
// import 'package:flutter_web/controller/cart_controller.dart';
// import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:flutter_web/models/order_history_item.dart';
import 'package:flutter_web/pages/pengiriman/cargo.dart';
import 'package:flutter_web/pages/profile/address_page.dart';
import 'package:flutter_web/pages/shoppingcart/after_checkout.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:flutter_web/services/checkout_service.dart';
// import 'package:flutter_web/widgets/header_bar.dart';
import 'package:flutter_web/pages/history/history.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// import '../../controller/page_controller.dart'; 
// import '../../controller/cart_controller.dart';

class CheckoutPage extends GetView<CheckoutController> {
  final CartItem? singleItem;

  CheckoutPage({super.key, this.singleItem});
  // CheckoutPage({super.key});

  // final CartController cartController = Get.find<CartController>();
  final CartService cartService = Get.find<CartService>();
  final CheckoutController checkoutController = Get.find();
  final addressController = Get.find<AddressController>();
  final cargoController = Get.find<CargoController>();

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final itemsToCheckout = singleItem != null
        ? [singleItem!] // Kalau dari "Beli Sekarang", 1 produk aja
        : cartService.cartItems; // Kalau dari keranjang, ambil semua

    final totalPrice = itemsToCheckout.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final groupedItems = <String, List<CartItem>>{};
    for (final item in itemsToCheckout) {
      final seller = item.seller ?? 'Toko Tidak Diketahui';
      groupedItems.putIfAbsent(seller, () => []).add(item);
    }

    // Fungsi untuk menghitung estimasi tiba berdasarkan kategori cargo
DateTime calculateEstimasiTiba(String kategori) {
  final key = kategori.trim();

  switch (key) {
    case 'Same Day':
      return DateTime.now().add(Duration(hours: 6));
    case 'Instant':
      return DateTime.now().add(Duration(days: 1));
    case 'Reguler':
      return DateTime.now().add(Duration(days: 3));
    case 'Hemat Kargo':
      return DateTime.now().add(Duration(days: 5));
    default:
      print('⚠️ Kategori cargo tidak dikenali: $kategori');
      return DateTime.now().add(Duration(days: 4));
  }
}


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
        title: Text("Checkout Page",
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w600)),
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
          final ongkir = cargoController.selectedCargo.value?.harga ?? 0;
          final totalBayar = totalPrice + ongkir;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _title("Shipping Address"),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 243, 229, 242)
                              .withOpacity(0.9),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          alignment: Alignment.centerRight,
                        ),
                        onPressed: () {
                          Get.toNamed(AddressPage.TAG);
                        },
                        child: Text(
                          "Manage Addresses",
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.purple[20],
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  tileColor: Colors.purple[50],
                  subtitle: address != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(Icons.location_on, size: 18, color: Colors.purple),
                                      ),
                                      const WidgetSpan(child: SizedBox(width: 4)),
                                      TextSpan(
                                        text: address.fullName ?? '',
                                        style: context.titleMedium
                                      ),
                                      TextSpan(
                                        text: ' | ${address.phone ?? ''}',
                                        style: GoogleFonts.montserrat(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey.shade600,
                                        ), 
                                      )
                                    ]),
                                  ),
                                )
                              ],
                            ),
                            Text(
                                '${address.address ?? ''}, ${address.kecamatan ?? ''}, ${address.kota ?? ''}, ${address.provinsi ?? ''}, ${address.kodepos ?? ''}'),
                          ],
                        )
                      : Text(
                          "No address selected",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.red),
                        ),
                ),
                const SizedBox(height: 10),

              // ✅ RINGKASAN PRODUK + TOTAL
              ...groupedItems.entries.map((entry) {
                final seller = entry.key;
                final sellerItems = entry.value;

                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    )
                  ),
                  tileColor: Colors.purple[50],
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _title(seller),
                      const SizedBox(height: 10),
                      ...sellerItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _orderRow(
                                  '${item.name}  × ${item.quantity}',
                                  'Rp ${_rupiah(item.price)}',
                                  'Rp ${_rupiah(item.totalPrice)}',
                                  // '× ${item.quantity}'
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                    ],
                  ),
                );
              }),
              const SizedBox(height:1),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                tileColor: Colors.purple[50],
<<<<<<< Updated upstream
                title: Text(
                  'Opsi Pengiriman',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
=======
                title: _title('Opsi Pengiriman'),
>>>>>>> Stashed changes
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Get.toNamed(CargoPage.TAG);
                  },
              ),
              if (cargoController.selectedCategory.value.isNotEmpty == true)
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                tileColor: Colors.purple[50],
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cargoController.selectedCargoName.value.isNotEmpty == true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${cargoController.selectedCategory.value} (${cargoController.selectedCargoName.value})',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            Text(
<<<<<<< Updated upstream
                              'Rp ${_rupiah((ongkir ?? 0).toDouble())}',
                              style: context.labelLarge,
=======
                              'Rp${_rupiah((ongkir ?? 0).toDouble())}',
>>>>>>> Stashed changes
                            ),
                          ],
                        ),
                        if (cargoController.selectedCategory.value.isNotEmpty == true)
                        Text(
                          'Estimasi tiba: ${DateFormat('dd MMM yyyy').format(
                            calculateEstimasiTiba(cargoController.selectedCategory.value)
                          )}',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
              ),
              const SizedBox(height: 1),
              ListTile(
                tileColor: Colors.purple[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  )
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ${itemsToCheckout.length} Produk:',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
<<<<<<< Updated upstream
                      'Rp ${_rupiah(totalBayar)}',
=======
                      '${_rupiah(totalBayar)}',
>>>>>>> Stashed changes
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              //Payment
              Container(
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(15),
                  ),
                  tileColor: Colors.purple[50],
                  title: 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                      ],
                    ),
                 ),
              ),
              const SizedBox(height: 10),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(15),
                ),
                tileColor: Colors.purple[50],
                title: Text(
                  'Rincian Pembayaran',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal Pesanan',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Rp${_rupiah(totalPrice)}'
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal Pengiriman',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Rp${_rupiah((ongkir ?? 0).toDouble())}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
  ),
    ),
  bottomNavigationBar: Obx(() {
  final ongkir = cargoController.selectedCargo.value?.harga ?? 0;
  final totalBayar = totalPrice + ongkir;
    
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Total',
            style: TextStyle(
              fontWeight: FontWeight.w400, 
              fontSize: 16, 
              color: Colors.black,
              )),
          const SizedBox(width: 5,),
          Text('Rp ${_rupiah(totalPrice + ongkir)}',
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 16, 
              color: Colors.purple[800],
              )),
          const SizedBox(width: 20,),
          ElevatedButton(
            onPressed: () async {
              final authController = Get.find<AuthController>();
              final cartService = Get.find<CartService>();
              final checkoutService = Get.find<CheckoutService>();
              final userEmail = authController.getUserEmail() ?? '';
              final addressController = Get.find<AddressController>();
              final itemsToCheckout = singleItem != null ? [singleItem!] : cartService.cartItems;

              print('🟠 itemsToCheckout length: ${itemsToCheckout.length}');
              for (var item in itemsToCheckout) {
                print('🛒 ${item.name} x ${item.quantity}');
              }

              if (addressController.selectedAddressUser.value == null) {
                Get.snackbar("Error", "Please select an address first.");
                return;
              }

              if(cargoController.selectedCargo.value == null) {
                Get.snackbar('Error', "Silakan dipilih opsi pengiriman.");
                return;
              }

              final order = OrderHistoryItem(
                id: '',
                timestamp: DateTime.now(),
                items: List<CartItem>.from(itemsToCheckout),
                infoUser: [addressController.selectedAddressUser.value!],
                paymentMethod: controller.selectedPayment.value,
                cargoCategory: cargoController.selectedCargo.value!.kategoriId.toString(),
                cargoName: cargoController.selectedCargo.value!.name,
                estimatedArrival: calculateEstimasiTiba(controller.selectedCategory.value),
                status: 'Pesanan Diterima',
                ongkir: (cargoController.selectedCargo.value?.harga ?? 0).toDouble(),
                totalBayar: ((itemsToCheckout.fold(0.0, (sum, item) => sum + item.totalPrice)) +
                            (cargoController.selectedCargo.value?.harga ?? 0))
                    .toInt(),
              );


              cartService.orderHistory.add(order);

              await checkoutService.saveOrderToSupabase(
                order, 
                controller.selectedPayment.value, 
                cargoController.selectedCargo.value!
              );

              if (singleItem == null) {
                await cartService.clearCartFromSupabase(userEmail);
                cartService.clearCart();
              }

              // Get.toNamed(ProductInfoPage.TAG);
              Get.toNamed(AfterCheckout.TAG, arguments: {
                'totalBayar' : totalBayar,
              });
            },
            child: Text("Place Order", style: GoogleFonts.poppins(fontSize: 16)),
          ),
        ],
      ),
    );
  }
));
}


  Widget _title(String text) => Text(
        text,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
      );

  Widget _orderRow(String label, String value, String value1, {bool isBold = false, Color? color}) {
    return SizedBox(
      height: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
                fontSize: 15,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
                  color: color,
                  fontSize: 14,
                ),
              ),
              Text(
                value1,
                style: GoogleFonts.poppins(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
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