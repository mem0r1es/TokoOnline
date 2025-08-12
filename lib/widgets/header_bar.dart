import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_web/controllers/address_controller.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:flutter_web/controllers/checkout_controller.dart';
import 'package:flutter_web/extensions/extension.dart';
import 'package:flutter_web/controllers/favorite_controller.dart';
import 'package:flutter_web/pages/shoppingcart/cart.dart';
import 'package:flutter_web/services/scroll_controller_manager.dart';
// Periksa nama kelas AboutPage
// Periksa nama kelas ContactPage
// Ini ProductInfoPage?
import 'package:flutter_web/pages/history/history.dart'; // Ini ProductInfoPage?
import 'package:flutter_web/pages/profile/profile_page.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:flutter_web/services/checkout_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../pages/shop/shops.dart';
import '../pages/auth/auth_dialog.dart';

// Tambahkan import untuk SearchController yang baru
import 'package:flutter_web/controllers/search_controller.dart'; // Pastikan path ini benar


class HeaderPages extends GetView<ScrollControllerManager> { // Tetap gunakan ScrollControllerManager jika ini memang controller utama untuk header
  const HeaderPages({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final CartService cartService = Get.find();
    // final ProductService productService = Get.find(); // Tidak perlu lagi di sini, pindah ke SearchController
    final AddressController addressController = Get.find();
    final CheckoutService checkoutService = Get.find();
    final CartController cartController = Get.find();
    final CheckoutController checkoutController = Get.find();

    // Dapatkan instance SearchController
    final SearchController searchController = Get.find<SearchController>();


    return Container(
      width: double.infinity,
      color: Colors.purple[40],
      padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 29),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Logo dan Teks (diuncomment jika ingin ditampilkan)
          // Row(
          //   children: [
          //     Image.asset(
          //       'headers/MeubelHouse_Logos-05.png', // Pastikan path ini benar
          //       width: 50,
          //       height: 32,
          //     ),
          //     const SizedBox(width: 5),
          //     Text(
          //       'Toko Online',
          //       style: GoogleFonts.montserrat(
          //         fontSize: 34,
          //         color: const Color(0xFF000000),
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(width: 40), // Spasi setelah logo
          // Menu Navigasi
          // Row(
          //   children: [
          //     // Sesuaikan TAG halaman Anda:
          //     _navItem('About', () => Get.toNamed(AboutPage1.TAG)), // Jika AboutPage1
          //     const SizedBox(width: 20),
          //     _navItem('Contact', () => Get.toNamed(ContactPage1.TAG)), // Jika ContactPage1
          //   ],
          // ),
          // const SizedBox(width: 40), // Spasi setelah navigasi

          // Search Bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: searchController.searchInputController, // Gunakan controller dari SearchController
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: context.labelLarge!.copyWith(
                    color: Colors.grey[500]
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (query) {
                  if (query.trim().isNotEmpty) {
                    searchController.performSearch(query.trim()); // Panggil method dari SearchController
                    // searchLogicController.clearSearchInput(); // Ini sudah dilakukan di performSearch jika sukses
                  }
                  searchController.searchInputController.clear();
                },
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Icon Section
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // _iconBtn(Icons.person, () => _userlogin(authController)),
              // const SizedBox(width: 10),

              // _iconBtn(Icons.favorite_border, () => Get.toNamed(FavoritePage.TAG)),
              // const SizedBox(width: 10),

              // Cart icon dengan badge
              Obx(
                () => GestureDetector(
                  onTap: () => _handleCartClick(authController, cartService),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        if (cartService.itemCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${cartService.itemCount}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Methods yang tidak terkait search tetap di sini ---

  void _showAuthDialog() {
    Get.dialog(AuthDialog());
  }

  // void _showUserMenu(AuthController authController) {
  //   Get.dialog(
  //     AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: Text(
  //         'User Menu',
  //         style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Welcome!',
  //             style: GoogleFonts.poppins(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //           SizedBox(height: 4),
  //           Text(
  //             authController.getUserName() ?? 'User',
  //             style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
  //           ),
  //           SizedBox(height: 20),
  //           _userMenuOption(
  //             icon: Icons.person,
  //             title: 'Profile',
  //             onTap: () {
  //               Get.toNamed(ProfilePage.TAG);
  //             },
  //           ),
  //           _userMenuOption(
  //             icon: Icons.shopping_bag,
  //             title: 'My Orders',
  //             onTap: () {
  //               Get.toNamed(ProductInfoPage.TAG); // Pastikan ProductInfoPage.TAG ada
  //             },
  //           ),
  //           SizedBox(height: 20),
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton.icon(
  //               onPressed: () {
  //                 Get.back();
  //                 final cartService = Get.find<CartService>();
  //                 cartService.clearCart();
  //                 final favController = Get.find<FavoriteController>();
  //                 favController.clearFavorites();
  //                 authController.logout();
  //               },
  //               icon: Icon(Icons.logout, color: Colors.white),
  //               label: Text(
  //                 'Logout',
  //                 style: GoogleFonts.poppins(color: Colors.white),
  //               ),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.red,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _userMenuOption({
  //   required IconData icon,
  //   required String title,
  //   required VoidCallback onTap,
  // }) {
  //   return ListTile(
  //     contentPadding: EdgeInsets.zero,
  //     leading: Icon(icon, color: Colors.grey[600]),
  //     title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
  //     onTap: onTap,
  //   );
  // }

  // void _userlogin (authService) {
  //   if (authService.isLoggedIn.value){
  //     _showUserMenu(authService);
  //   } else {
  //     _showAuthDialog();
  //   }
  // }

  void _handleCartClick(authService, CartService cartService) {
    if (authService.isLoggedIn.value) {
      if (cartService.isNotEmpty) {
        Get.toNamed(CartPages.TAG);
      } else {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Cart Empty', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Your cart is empty. Add some products to get started!',
                  style: GoogleFonts.poppins(fontSize: 14), textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text('OK')),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.to(ShopsPage());
                },
                child: Text('Shop Now'),
              ),
            ],
          ),
        );
      }
    } else {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Login Required', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('Please login to access your shopping cart and place orders.',
                style: GoogleFonts.poppins(fontSize: 14), textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _showAuthDialog();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: Text('Login', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  Widget _iconBtn(IconData icon, [VoidCallback? onPressed]) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        icon: Icon(icon, color: Colors.black, size: 24),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        splashRadius: 20,
      ),
    );
  }

  Widget _navItem(String text, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color(0xFF000000),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}