import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/cart_controller.dart';
// import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:flutter_web/models/cart_item.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../controller/cart_controller.dart';
import 'checkout_page.dart';

// class CartPages extends StatelessWidget {
//   const CartPages({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Gunakan CartService yang baru
//     // final CartController = Get.find<CartController>();
//     final cartController = Get.find<CartController>();
//     final cartService = Get.find<CartService>();

//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Obx(() {
//         if (cartService.isEmpty) {
//           return _buildEmptyCart();
//         } else {
//           return _buildCartWithItems(cartService);
//         }
//       }),
//     );
//   }

//   Widget _buildEmptyCart() {
//     return SizedBox(
//       width: MediaQuery.of(Get.context!).size.width - 100,
//       height: 400,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.shopping_cart_outlined,
//               size: 100,
//               color: Colors.grey[400],
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Your cart is empty',
//               style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[600],
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Add some products to get started!',
//               style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[500]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Widget _buildCartWithItems(CartService cartService) {
//   //   return Row(
//     //   crossAxisAlignment: CrossAxisAlignment.start,
//     //   children: [
//     //     // LEFT: Product Table
//     //     SizedBox(
//     //       width: 817,
//     //       child: Column(
//     //         children: [
//     //           Padding(
//     //             padding: const EdgeInsets.only(left: 8.0),
//     //             child: _tableHeader(),
//     //           ),
//     //           // List produk dari CartService
//     //           SizedBox(
//     //             height: 300,
//     //             child: ListView.builder(
//     //               itemCount: cartService.cartItems.length,
//     //               itemBuilder: (_, i) {
//     //                 final item = cartService.cartItems[i];
                    
//     //                 return Padding(
//     //                   padding: const EdgeInsets.symmetric(
//     //                     vertical: 10,
//     //                     horizontal: 20,
//     //                   ),
//     //                   child: Row(
//     //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     //                     children: [
//     //                       // Product name + image
//     //                       Expanded(
//     //                         flex: 2,
//     //                         child: Row(
//     //                           children: [
//     //                             SizedBox(
//     //                               width: 50,
//     //                               height: 50,
//     //                               child: item.imageUrl.startsWith('http')
//     //                                   ? Image.network(
//     //                                       item.imageUrl,
//     //                                       fit: BoxFit.cover,
//     //                                       errorBuilder:
//     //                                           (context, error, stackTrace) {
//     //                                             return Icon(
//     //                                               Icons.image_not_supported,
//     //                                               color: Colors.grey,
//     //                                             );
//     //                                           },
//     //                                     )
//     //                                   : Image.asset(
//     //                                       item.imageUrl,
//     //                                       fit: BoxFit.cover,
//     //                                       errorBuilder:
//     //                                           (context, error, stackTrace) {
//     //                                             return Icon(
//     //                                               Icons.image_not_supported,
//     //                                               color: Colors.grey,
//     //                                             );
//     //                                           },
//     //                                     ),
//     //                             ),
//     //                             const SizedBox(width: 10),
//     //                             Expanded(
//     //                               child: Text(
//     //                                 item.name,
//     //                                 style: GoogleFonts.poppins(fontSize: 14),
//     //                                 overflow: TextOverflow.ellipsis,
//     //                               ),
//     //                             ),
//     //                           ],
//     //                         ),
//     //                       ),

//     //                       // Price
//     //                       Expanded(
//     //                         flex: 1,
//     //                         child: Text(
//     //                           'Rp ${_formatPrice(item.price)}',
//     //                           style: GoogleFonts.poppins(fontSize: 14),
//     //                           textAlign: TextAlign.center,
//     //                         ),
//     //                       ),

//     //                       // Quantity dengan kontrol
//     //                       Expanded(
//     //                         flex: 1,
//     //                         child: Row(
//     //                           mainAxisAlignment: MainAxisAlignment.center,
//     //                           mainAxisSize: MainAxisSize.min,
//     //                           children: [
//     //                             IconButton(
//     //                               onPressed: () =>
//     //                                   cartService.decreaseQuantity(item.id),
//     //                               icon: Icon(
//     //                                 Icons.remove_circle_outline,
//     //                                 size: 20,
//     //                               ),
//     //                               constraints: BoxConstraints(
//     //                                 minWidth: 24,
//     //                                 minHeight: 24,
//     //                               ),
//     //                             ),
//     //                             Container(
//     //                               padding: EdgeInsets.symmetric(
//     //                                 horizontal: 8,
//     //                                 vertical: 4,
//     //                               ),
//     //                               decoration: BoxDecoration(
//     //                                 border: Border.all(
//     //                                   color: Colors.grey[300]!,
//     //                                 ),
//     //                                 borderRadius: BorderRadius.circular(4),
//     //                               ),
//     //                               child: Text(
//     //                                 '${item.quantity}',
//     //                                 style: GoogleFonts.poppins(
//     //                                   fontSize: 14,
//     //                                   fontWeight: FontWeight.w600,
//     //                                 ),
//     //                               ),
//     //                             ),
//     //                             IconButton(
//     //                               onPressed: () =>
//     //                                   cartService.increaseQuantity(item.id),
//     //                               icon: Icon(
//     //                                 Icons.add_circle_outline,
//     //                                 size: 20,
//     //                               ),
//     //                               constraints: BoxConstraints(
//     //                                 minWidth: 24,
//     //                                 minHeight: 24,
//     //                               ),
//     //                             ),
//     //                           ],
//     //                         ),
//     //                       ),

//     //                       // Subtotal
//     //                       Expanded(
//     //                         flex: 1,
//     //                         child: Text(
//     //                           'Rp ${_formatPrice(item.totalPrice)}',
//     //                           style: GoogleFonts.poppins(
//     //                             fontSize: 14,
//     //                             fontWeight: FontWeight.w600,
//     //                           ),
//     //                           textAlign: TextAlign.center,
//     //                         ),
//     //                       ),

//     //                       // Remove button
//     //                       IconButton(
//     //                         onPressed: () =>
//     //                             _showRemoveConfirmation(item, cartService),
//     //                         icon: Icon(
//     //                           Icons.delete_outline,
//     //                           color: Colors.red,
//     //                           size: 20,
//     //                         ),
//     //                       ),
//     //                     ],
//     //                   ),
//     //                 );
//     //               },
//     //             ),
//     //           ),
//     //         ],
//     //       ),
//     //     ),

//     //     const SizedBox(width: 30),

//     //     // RIGHT: Ringkasan Belanja
//     //     Container(
//     //       width: 393,
//     //       height: 400,
//     //       color: const Color(0xFFF9F1E7),
//     //       padding: const EdgeInsets.all(24),
//     //       child: SingleChildScrollView(
//     //         child: Padding(
//     //           padding: const EdgeInsets.all(8.0),
//     //           child: Column(
//     //             mainAxisSize: MainAxisSize.min,
//     //             mainAxisAlignment: MainAxisAlignment.start,
//     //             children: [
//     //               Text(
//     //                 'Cart Totals',
//     //                 style: GoogleFonts.poppins(
//     //                   fontSize: 32,
//     //                   fontWeight: FontWeight.w600,
//     //                 ),
//     //               ),
//     //               const SizedBox(height: 20),
            
//     //               // Subtotal
//     //               Row(
//     //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     //                 children: [
//     //                   Text(
//     //                     'Subtotal',
//     //                     style: GoogleFonts.poppins(
//     //                       fontSize: 16,
//     //                       fontWeight: FontWeight.w500,
//     //                     ),
//     //                   ),
//     //                   Obx(
//     //                     () => Text(
//     //                       'Rp ${_formatPrice(cartService.totalPrice)}',
//     //                       style: GoogleFonts.poppins(
//     //                         fontSize: 16,
//     //                         fontWeight: FontWeight.w500,
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
            
//     //               const SizedBox(height: 10),
            
//     //               // Total Items
//     //               Row(
//     //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     //                 children: [
//     //                   Text(
//     //                     'Items',
//     //                     style: GoogleFonts.poppins(
//     //                       fontSize: 16,
//     //                       fontWeight: FontWeight.w500,
//     //                     ),
//     //                   ),
//     //                   Obx(
//     //                     () => Text(
//     //                       '${cartService.itemCount}',
//     //                       style: GoogleFonts.poppins(
//     //                         fontSize: 16,
//     //                         fontWeight: FontWeight.w500,
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
            
//     //               const SizedBox(height: 20),
//     //               Divider(thickness: 1),
//     //               const SizedBox(height: 10),
            
//     //               // Total
//     //               Row(
//     //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     //                 children: [
//     //                   Text(
//     //                     'Total',
//     //                     style: GoogleFonts.poppins(
//     //                       fontSize: 18,
//     //                       fontWeight: FontWeight.w600,
//     //                     ),
//     //                   ),
//     //                   Obx(
//     //                     () => Text(
//     //                       'Rp ${_formatPrice(cartService.totalPrice)}',
//     //                       style: GoogleFonts.poppins(
//     //                         fontSize: 18,
//     //                         fontWeight: FontWeight.w600,
//     //                         color: Colors.green[600],
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ],
//     //               ),
            
//     //               const SizedBox(height: 30),
            
//     //               // Checkout Button
//     //               Center(
//     //                 child: Container(
//     //                   width: 222,
//     //                   height: 58.95,
//     //                   decoration: BoxDecoration(
//     //                     borderRadius: BorderRadius.all(Radius.circular(15)),
//     //                     color: Colors.white,
//     //                   ),
//     //                   child: _billing(
//     //                     'Check Out',
//     //                     () => _handleCheckout(cartService),
//     //                   ),
//     //                 ),
//     //               ),
            
//     //               const SizedBox(height: 15),
            
//     //               // Clear Cart Button
//     //               Center(
//     //                 child: SizedBox(
//     //                   width: 222,
//     //                   height: 45,
//     //                   child: OutlinedButton(
//     //                     onPressed: () => _showClearCartConfirmation(cartService),
//     //                     style: OutlinedButton.styleFrom(
//     //                       side: BorderSide(color: Colors.red),
//     //                       shape: RoundedRectangleBorder(
//     //                         borderRadius: BorderRadius.circular(15),
//     //                       ),
//     //                     ),
//     //                     child: Text(
//     //                       'Clear Cart',
//     //                       style: GoogleFonts.poppins(
//     //                         fontSize: 16,
//     //                         fontWeight: FontWeight.w500,
//     //                         color: Colors.red,
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 ),
//     //               ),
//     //             ],
//     //           ),
//     //         ),
//     //       ),
//     //     ),
//     //   ],
//     // );
//   // }

//   Widget _tableHeader() => Column(
//     children: [
//       Container(
//         height: 60,
//         padding: const EdgeInsets.all(20),
//         color: const Color(0xFFF9F1E7),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(flex: 2, child: _text('Product')),
//             Expanded(flex: 1, child: _text('Price')),
//             Expanded(flex: 1, child: _text('Qty')),
//             Expanded(flex: 1, child: _text('Subtotal')),
//             SizedBox(width: 48), // Space for delete button
//           ],
//         ),
//       ),
//       const Divider(height: 1),
//     ],
//   );

//   Widget _text(String txt) => Text(
//     txt,
//     style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
//     textAlign: TextAlign.center,
//   );

//   Widget _billing(String text, [VoidCallback? onPressed]) {
//     return SizedBox(
//       width: 222,
//       height: 58.95,
//       child: TextButton(
//         onPressed: onPressed,
//         style: ButtonStyle(
//           textStyle: WidgetStateProperty.all(
//             GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.w400,
//               color: const Color.fromARGB(255, 6, 5, 5),
//             ),
//           ),
//         ),
//         child: _text(text),
//       ),
//     );
//   }

//   void _showRemoveConfirmation(CartItem item, CartService cartService) {
//     Get.dialog(
//       AlertDialog(
//         title: Text('Remove Item'),
//         content: Text('Remove ${item.name} from your cart?'),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               cartService.removeItem(item.id);
//               Get.back();
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: Text('Remove', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showClearCartConfirmation(CartService cartService) {
//     Get.dialog(
//       AlertDialog(
//         title: Text('Clear Cart'),
//         content: Text('Are you sure you want to remove all items from cart?'),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               cartService.clearCart();
//               Get.back();
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: Text('Clear All', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleCheckout(CartService cartService) {
//     if (cartService.isEmpty) {
//       Get.snackbar(
//         'Cart Empty',
//         'Add some items before checkout',
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     // Bisa navigate ke billing page atau checkout process
//     Get.to(CheckoutPage());
//   }

//   String _formatPrice(double price) {
//     return price
//         .toStringAsFixed(0)
//         .replaceAllMapped(
//           RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (m) => '${m[1]}.',
//         );
//   }
// }

// class CartPageFromSupabase extends StatefulWidget {
//   const CartPageFromSupabase({Key? key}) : super(key: key);

//   @override
//   State<CartPageFromSupabase> createState() => _CartPageFromSupabaseState();
// }

// class _CartPageFromSupabaseState extends State<CartPageFromSupabase> {
//   final cartService = Get.find<CartService>();
//   late final user;
//   String? email;

  

//   // Future<void> _loadCart() async {
//   //   if (user != null && user.email!= null) {
//   //     final result = await cartService.loadCartFromSupabase(user.email!);
//   //     cartService.cartItems.assignAll(
//   //       result.map((historyItem) => CartItem(
//   //         id: historyItem.productId, 
//   //         name: historyItem.name, 
//   //         price: historyItem.price, 
//   //         imageUrl: historyItem.imageUrl, 
//   //         quantity: historyItem.quantity,
//   //       )).toList()
//   //     );
//   //   }
//   // }

//   @override
//   void initState() {
//     super.initState();
//     user = Supabase.instance.client.auth.currentUser;
//     email = user?.email;
//     if (email != null) {
//       // cartService.loadCartFromLocalStorage(email!);
//       cartService.loadCartFromSupabase(email!);
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Your Cart')),
//       body: Obx(() {
//         if (cartService.isEmpty) {
//           return Center(child: Text('Cart is Empty'));
//         } else {
//           return ListView.builder(
//             itemCount: cartService.cartItems.length,
//             itemBuilder: (_, i) {
//               final item = cartService.cartItems[i];
//               return ListTile(
//                 leading: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
//                 title: Text(item.name),
//                 subtitle: Text('Rp ${_formatPrice(item.price)}'),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.remove),
//                       onPressed: () {
//                         cartService.decreaseQuantity(item.id);
//                         if (user?.email != null) {
//                           cartService.saveCartToSupabase(user!.email!);
//                         }
//                       },
//                     ),
//                     Text('${item.quantity}'),
//                     IconButton(
//                       icon: Icon(Icons.add),
//                       onPressed: () {
//                         cartService.increaseQuantity(item.id);
//                         cartService.saveCartToSupabase(user!.email!);
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         }
//       }),
//       bottomNavigationBar: Obx(() => Container(
//         padding: EdgeInsets.all(16),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('Total: Rp ${_formatPrice(cartService.totalPrice)}',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             ElevatedButton(
//               onPressed: cartService.isEmpty ? null : () {
//                 Get.to(CheckoutPage());
//               },
//               child: Text('Checkout'),
//             )
//           ],
//         ),
//       )),
//     );
//   }

//   String _formatPrice(double price) {
//     return price
//       .toStringAsFixed(0)
//       .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
//   }
// }

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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cartService.cartItems.length,
          itemBuilder: (context, index) {
            final item = cartService.cartItems[index];
            return Card(
              color: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.network(
                        item.imageUrl, 
                        width: 80, 
                        height: 80, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace){
                          return Container(
                            color: Colors.grey[200], // Background color for placeholder
                            child: Icon(
                              Icons.image_not_supported, // A generic image placeholder icon
                              size: 50,
                              color: Colors.grey[500],
                            ),
                          );
                        },
                        )),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
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
              ),
            );
          },
        );
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