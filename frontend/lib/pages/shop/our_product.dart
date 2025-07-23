import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/controllers/favorite_controller.dart';
import 'package:flutter_web/controllers/product_controller.dart';
import 'package:flutter_web/models/cart_item.dart';
import 'package:flutter_web/pages/auth/auth_dialog.dart';
import 'package:flutter_web/pages/history/history.dart';
import 'package:flutter_web/pages/profile/profile_page.dart';
import 'package:flutter_web/pages/shop/product_dialog.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
// import '../../controller/cart_controller.dart';
// import '../../controller/auth_controller.dart';
// import '../../controller/product_controller.dart';
// import '../../controllers/page_controller.dart';
import '../../models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OurProduct extends GetView<ProductController> {
  OurProduct({super.key});

  final FavoriteController favC = Get.put(FavoriteController());
  final cartService = Get.find<CartService>();
  final authController= Get.find<AuthController>();

  // final favC = Get.find<FavoriteController>();
  // final ProductController productController = Get.put(ProductController());

  // final favC = Get.find<FavoriteController>();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600; // bisa kamu atur ambangnya
    final childAspectRatio = isLargeScreen ? 0.75 : 0.65;

    return LayoutBuilder(
      builder: (context, constraints) {
        // int crossAxisCount = (constraints.maxWidth ~/ 250).clamp(1, 4);
        int crossAxisCount = constraints.maxWidth < 600
      ? 2: constraints.maxWidth < 900 ? 3: 4;


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Our Products',
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.isLoading.value) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Loading products from database...',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
      
            if (controller.products.isEmpty) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No products available',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Database might be empty or connection failed',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => controller.refreshProducts(),
                        icon: Icon(Icons.refresh),
                        label: Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Showing ${controller.products.length} products',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return _productCard(product, cartService, authController);
                  },
                )
              ],
            );
          }),
        ],
      ),
    );
  },
);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 50),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Header
//           Text(
//             'Our Products',
//             style: GoogleFonts.poppins(
//               fontSize: 40,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
      
//           const SizedBox(height: 10),
      
//           // Products Grid
//           Obx(() {
//             if (controller.isLoading.value) {
//               return SizedBox(
//                 height: 300,
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         strokeWidth: 3,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         'Loading products from database...',
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
      
//             if (controller.products.isEmpty) {
//               return SizedBox(
//                 height: 300,
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.inventory_2_outlined,
//                         size: 80,
//                         color: Colors.grey[400],
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         'No products available',
//                         style: GoogleFonts.poppins(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         'Database might be empty or connection failed',
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           color: Colors.grey[500],
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton.icon(
//                         onPressed: () => controller.refreshProducts(),
//                         icon: Icon(Icons.refresh),
//                         label: Text('Try Again'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.black,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
      
//             // Products grid
//             return Column(
//               children: [
//                 // Products count info
//                 Padding(
//                   padding: EdgeInsets.only(bottom: 20),
//                   child: Text(
//                     'Showing ${controller.products.length} products',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ),

//                 // Products grid
//                 LayoutBuilder(
//   builder: (context, constraints) {
//     int crossAxisCount = (constraints.maxWidth ~/ 250).clamp(1, 4); // Responsive columns

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       padding: const EdgeInsets.all(12),
//       itemCount: controller.products.length,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         crossAxisSpacing: 20,
//         mainAxisSpacing: 20,
//         childAspectRatio: 1.5, // adjust if card looks too tall/wide
//       ),
//       itemBuilder: (context, index) {
//         final product = controller.products[index];
//         return _productCard(product, cartService, authController);
//       },
//     );
//   },
// ),

//               ],
//             );
//           }),
//         ],
//       ),
//     );
  }

  Widget _productCard(
    Product product,
    CartService cartService,
    AuthController authController,
  ) {
    // Use database ID if available, fallback to title
    String productId = product.id ?? product.title;

    return SizedBox(
      width: 160,
      child: GestureDetector(
        onTap: (){
          Get.toNamed('${ProductDialog.TAG}?id=${product.id}');
          // Get.toNamed(ProductDialog.TAG, arguments: product);
          // Get.to(ProductDialog(product: product));
        },

        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Color(0xFFF8F4FF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: double.infinity,
                height: 120,
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: _buildProductImage(product),
                ),
              ),
        
              // Product Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name

                    SizedBox(
                      height: 36,
                      child: Text(
                        product.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 4),
                    
                    SizedBox(
                      height: 32,
                      child: Text(
                        product.storeName ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,                      
                      ),
                    ),
        
                    const SizedBox(height: 4),
        
                    // Price and Category
                    Text(
                      'Rp ${_rupiah(product.price)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[600],
                      ),
                    ),
        
                    // const SizedBox(height: 16),
        
                    // Action Buttons
                    // Row(
                    //   children: [
                    //     // Add to Cart Button
                    //     Expanded(
                    //       flex: 3,
                    //       child: Obx(() {
                    //         final cartItem = cartService.getItem(productId);
        
                    //         if (cartItem != null) {
                    //           // Sudah ada di cart ➔ Tampilkan tombol + -
                    //           return Row(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             mainAxisSize: MainAxisSize.min,
                    //             children: [
                    //               IconButton(
                    //                 onPressed: () => cartService.decreaseQuantity(productId),
                    //                 icon: Icon(Icons.remove_circle_outline),
                    //                 constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                    //               ),
                    //               Container(
                    //                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    //                 decoration: BoxDecoration(
                    //                   border: Border.all(color: Colors.grey[300]!),
                    //                   borderRadius: BorderRadius.circular(4),
                    //                 ),
                    //                 child: Text(
                    //                   '${cartItem.quantity}',
                    //                   style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                    //                 ),
                    //               ),
                    //               IconButton(
                    //                 onPressed: () {
                    //                   cartService.increaseQuantity(productId);
        
                    //                   final user = Supabase.instance.client.auth.currentUser;
                    //                   final email = user?.email;
        
                    //                   if (email != null) {
                    //                     cartService.saveCartToSupabase(email);
                    //                   }
                    //                 },
                    //                 icon: Icon(Icons.add_circle_outline),
                    //                 constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                    //               ),
                    //             ],
                    //           );
                    //         } else {
                    //           // Belum ada di cart ➔ Tampilkan tombol Add Cart
                    //           return ElevatedButton.icon(
                    //             onPressed: () => _handleAddToCart(product, productId, cartService, authController),
                    //             style: ElevatedButton.styleFrom(
                    //               backgroundColor: Colors.black,
                    //               foregroundColor: Colors.white,
                    //               padding: EdgeInsets.symmetric(vertical: 12),
                    //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    //             ),
                    //             icon: Icon(Icons.shopping_cart_outlined, size: 18),
                    //             label: Text(
                    //               'Add Cart',
                    //               style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                    //             ),
                    //           );
                    //         }
                    //       }),
                    //     ),
        
                    //     SizedBox(width: 8),
        
                    //     // Favorite Button
                    //     Obx(
                    //       () => Container(
                    //         decoration: BoxDecoration(
                    //           color: favC.isFavorite(product)
                    //               ? Colors.red[50]
                    //               : Colors.grey[100],
                    //           borderRadius: BorderRadius.circular(8),
                    //           border: Border.all(
                    //             color: favC.isFavorite(product)
                    //                 ? Colors.red
                    //                 : Colors.grey[300]!,
                    //           ),
                    //         ),
                    //         child: IconButton(
                    //           onPressed: () => _handleFavorite(product),
                    //           icon: Icon(
                    //             favC.isFavorite(product)
                    //                 ? Icons.favorite
                    //                 : Icons.favorite_border,
                    //             color: favC.isFavorite(product)
                    //                 ? Colors.red
                    //                 : Colors.grey[600],
                    //             size: 20,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.imagePath.startsWith('http')) {
      // Network image
      return Image.network(
        product.imagePath,
        fit: BoxFit.cover,
        width: 50,
        height: 100,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      // Asset image
      return Image.asset(
        product.imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          SizedBox(height: 8),
          Text(
            'Image not found',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showAuthDialog() {
    Get.dialog(AuthDialog());
  }

  void _handleAddToCart(
  Product product,
  String productId,
  CartService cartService,
  AuthController authController,
) async {
  final currentUser = authController.currentUser.value;

  if (currentUser == null || currentUser.email == null) {
    _showAuthDialog();
    Get.snackbar(
      "Login Required",
      "Please login first to add products to cart",
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      icon: Icon(Icons.login, color: Colors.white),
    );
    return;
  }

  if (product.stock != null && product.stock! <= 0) {
    Get.snackbar(
      "Out of Stock",
      "${product.title} is currently out of stock",
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      icon: Icon(Icons.inventory_2, color: Colors.white),
    );
    return;
  }

  // cartService.addItem(CartItem(
  //   id: productId,
  //   name: product.title,
  //   price: product.price.toDouble(),
  //   imageUrl: product.imagePath,
  // ));

  await cartService.saveCartToSupabase(currentUser.email!);
}

  void _handleFavorite(Product product) {
    favC.toggleFavorite(product);

    Get.snackbar(
      "Favorites",
      favC.isFavorite(product)
          ? "${product.title} added to favorites"
          : "${product.title} removed from favorites",
      backgroundColor: favC.isFavorite(product) ? Colors.red : Colors.grey,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
      icon: Icon(
        favC.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
        color: Colors.white,
      ),
    );
  }

  String _rupiah(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
}
