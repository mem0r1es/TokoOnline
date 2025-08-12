import 'package:flutter/material.dart';
import 'package:flutter_web/models/cart_item.dart';
// import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../controller/cart_controller.dart';
import 'checkout_page.dart';

class CartPages extends StatelessWidget {
  static const TAG = '/shoppingcart';
  final cartService = Get.find<CartService>();
  final user = Supabase.instance.client.auth.currentUser;

  CartPages({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Keranjang Belanja',
        style: GoogleFonts.poppins(
          fontSize: 20,
          color: Colors.purple[20],
          fontWeight: FontWeight.w400
        )
      ),
        backgroundColor: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
      ),
      backgroundColor: Colors.white, // AppBar is handled by ShoppingCart
      body: Obx(() {
        if (cartService.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 100,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 20),
                Text(
                  'Keranjang masih kosong',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tambahkan beberapa produk untuk memulai!',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        final groupedItems = <String, List<CartItem>>{};
        for (final item in cartService.cartItems) {
          final seller = item.seller;
          groupedItems.putIfAbsent(seller, () => []).add(item);
        }

        return ListView(
        padding: const EdgeInsets.all(16),
        children: groupedItems.entries.map((entry) {
          final seller = entry.key;
          final items = entry.value;

          return Card(
            color: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[500]),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Text(
                                    'Rp ${_formatPrice(item.price)}',
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          cartService.decreaseQuantity(item.id);
                                          if (user?.email != null) {
                                            cartService.saveCartToSupabase(user!.email!);
                                          }
                                        },
                                      ),
                                      Text('${item.quantity}', style: GoogleFonts.poppins(fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          cartService.increaseQuantity(item.id);
                                          cartService.saveCartToSupabase(user!.email!);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: Text('Hapus Item'),
                                    content: Text('Hapus ${item.name} dari keranjang?'),
                                    actions: [
                                      TextButton(onPressed: () => Get.back(), child: Text('Batal')),
                                      ElevatedButton(
                                        onPressed: () {
                                          cartService.removeItem(item.id);
                                          if (user?.email != null) {
                                            cartService.saveCartToSupabase(user!.email!);
                                          }
                                          Get.back();
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: Text('Hapus', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );

        // return ListView.builder(
        //   padding: const EdgeInsets.all(16),
        //   itemCount: cartService.cartItems.length,
        //   itemBuilder: (context, index) {
        //     final item = cartService.cartItems[index];
        //     return Card(
        //       color: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
        //       margin: const EdgeInsets.symmetric(vertical: 8.0),
        //       child: Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: Column(
        //           children: [
        //             Text(
        //               '${item.seller}',
        //             ),
        //             Row(
        //               children: [
        //                 SizedBox(
        //                   width: 80,
        //                   height: 80,
        //                   child: Image.network(
        //                     item.imageUrl, 
        //                     width: 80, 
        //                     height: 80, 
        //                     fit: BoxFit.cover,
        //                     errorBuilder: (context, error, stackTrace){
        //                       return Container(
        //                         color: Colors.grey[200], // Background color for placeholder
        //                         child: Icon(
        //                           Icons.image_not_supported, // A generic image placeholder icon
        //                           size: 50,
        //                           color: Colors.grey[500],
        //                         ),
        //                       );
        //                     },
        //                     )),
        //                 const SizedBox(width: 16),
        //                 Expanded(
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       Text(
        //                         item.name,
        //                         style: GoogleFonts.poppins(
        //                             fontSize: 16, fontWeight: FontWeight.w500),
        //                       ),
        //                       Text(
        //                         'Rp ${_formatPrice(item.price)}',
        //                         style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
        //                       ),
        //                       Row(
        //                         mainAxisAlignment: MainAxisAlignment.end,
        //                         children: [
        //                           IconButton(
        //                             icon: const Icon(Icons.remove),
        //                             onPressed: () {
        //                               cartService.decreaseQuantity(item.id);
        //                               if (user?.email != null) {
        //                                 cartService.saveCartToSupabase(user!.email!);
        //                               }
        //                             },
        //                           ),
        //                           Text('${item.quantity}', style: GoogleFonts.poppins(fontSize: 16)),
        //                           IconButton(
        //                             icon: const Icon(Icons.add),
        //                             onPressed: () {
        //                               cartService.increaseQuantity(item.id);
        //                               cartService.saveCartToSupabase(user!.email!);
        //                             },
        //                           ),
        //                         ],
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //                 IconButton(
        //                   icon: const Icon(Icons.delete_outline, color: Colors.red),
        //                   onPressed: () {
        //                     Get.dialog(
        //                       AlertDialog(
        //                         title: Text('Hapus Item'),
        //                         content: Text('Hapus ${item.name} dari keranjang?'),
        //                         actions: [
        //                           TextButton(onPressed: () => Get.back(), child: Text('Batal')),
        //                           ElevatedButton(
        //                             onPressed: () {
        //                               cartService.removeItem(item.id);
        //                               if (user?.email != null) {
        //                                 cartService.saveCartToSupabase(user!.email!);
        //                               }
        //                               Get.back();
        //                             },
        //                             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        //                             child: Text('Hapus', style: TextStyle(color: Colors.white)),
        //                           ),
        //                         ],
        //                       ),
        //                     );
        //                   },
        //                 ),
        //               ],
        //             ),
        //           ],
        //         ),
        //       ),
        //     );
        //   },
        // );
      }),
      bottomNavigationBar: Obx(() => Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: Rp ${_formatPrice(cartService.totalPrice)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[20]),
                  onPressed: cartService.isEmpty
                      ? null
                      : () {
                          Get.to(() => CheckoutPage());
                        },
                  child: Text(
                    'Checkout', 
                    style: GoogleFonts.poppins(
                      color: Colors.purple[20],
                      fontWeight: FontWeight.bold
                    )
                    ),
                ),
              ],
            ),
          )),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}