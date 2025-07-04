import 'package:flutter/material.dart';
import 'package:flutter_web/dashboard/header/contact/contact.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../dashboard.dart';
import 'shop/shops.dart';
import 'shoppingcart/shopping_cart.dart';
import 'about/about.dart';
import 'search/search_page.dart';
import 'favorite/favorite_page.dart';
import 'login/auth_dialog.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import 'shop/product_model.dart';

class HeaderPages extends StatelessWidget {
  const HeaderPages({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ALL services (GUARANTEED TO WORK)
    final AuthService authService = Get.put(AuthService());
    final CartService cartService = Get.put(CartService());
    final ProductService productService = Get.put(
      ProductService(),
    ); // TAMBAH INI

    return Container(
      width: double.infinity,
      height: 100,
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 29),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo dan Teks
          Row(
            children: [
              Image.asset(
                'headers/MeubelHouse_Logos-05.png',
                width: 50,
                height: 32,
              ),
              const SizedBox(width: 5),
              Text(
                'Toko Online',
                style: GoogleFonts.montserrat(
                  fontSize: 34,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Menu Navigasi
          Row(
            children: [
              _navItem('Home', () => Get.to(const DashboardPage())),
              const SizedBox(width: 20),
              _navItem('Shop', () => Get.to(const ShopsPage())),
              const SizedBox(width: 20),
              _navItem('About', () => Get.to(const AboutPage1())),
              const SizedBox(width: 20),
              _navItem('Contact', () => Get.to(const ContactPage1())),
            ],
          ),
          // Icon Section
          Row(
            children: [
              // User icon dengan auth logic
              Obx(
                () => GestureDetector(
                  onTap: () {
                    if (authService.isLoggedIn.value) {
                      _showUserMenu(authService);
                    } else {
                      _showAuthDialog();
                    }
                  },
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: authService.isLoggedIn.value
                        ? Icon(
                            Icons.account_circle,
                            color: Colors.green,
                            size: 24,
                          )
                        : Image.asset('headers/people.png'),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              

              // Search icon
              _iconBtn(Icons.search, () => _openSearchDialog()),
              const SizedBox(width: 10),

              // Favorite icon
              _iconBtn(Icons.favorite_border, () => Get.to(FavoritePage())),
              const SizedBox(width: 10),

              // Cart icon dengan badge
              Obx(
                () => GestureDetector(
                  onTap: () => _handleCartClick(authService, cartService),
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

  // Show auth dialog
  void _showAuthDialog() {
    Get.dialog(AuthDialog());
  }

  // Show user menu
  void _showUserMenu(AuthService authService) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'User Menu',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              authService.getUserEmail() ?? 'User',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),

            // Menu options
            _userMenuOption(
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Profile page coming soon!');
              },
            ),
            _userMenuOption(
              icon: Icons.shopping_bag,
              title: 'My Orders',
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Orders page coming soon!');
              },
            ),
            _userMenuOption(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Settings page coming soon!');
              },
            ),

            SizedBox(height: 20),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  authService.logout();
                },
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Logout',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      onTap: onTap,
    );
  }

  // Handle cart click
  void _handleCartClick(AuthService authService, CartService cartService) {
    if (authService.isLoggedIn.value) {
      // User is logged in, go to cart
      if (cartService.isNotEmpty) {
        Get.to(const ShoppingCart());
      } else {
        // Cart is empty
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Cart Empty',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Your cart is empty. Add some products to get started!',
                  style: GoogleFonts.poppins(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text('OK')),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.to(const ShopsPage());
                },
                child: Text('Shop Now'),
              ),
            ],
          ),
        );
      }
    } else {
      // User not logged in
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Login Required',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Please login to access your shopping cart and place orders.',
                style: GoogleFonts.poppins(fontSize: 14),
                textAlign: TextAlign.center,
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
      child: TextButton(
        onPressed: onPressed,
        child: Icon(icon, color: Colors.black, size: 24),
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

  void _openSearchDialog() {
    String query = '';
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Search Product', style: GoogleFonts.poppins()),
          content: TextField(
            onChanged: (val) => query = val,
            decoration: const InputDecoration(
              hintText: 'Enter product name (e.g., gaming)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                if (query.trim().isNotEmpty) {
                  await _performSearch(query.trim());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text(
                'Search',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performSearch(String query) async {
    try {
      print('🔍 HEADER SEARCH: Starting search for "$query"');

      // Get ProductService yang sudah di-initialize di build()
      final ProductService productService = Get.find<ProductService>();
      final List<Product> searchResults = await productService.searchProducts(
        query,
      );

      print('🔍 HEADER SEARCH: Found ${searchResults.length} results');
      for (var product in searchResults) {
        print('   - ${product.title} (${product.category})');
      }

      if (searchResults.isNotEmpty) {
        Get.to(() => SearchResultPage(query: query, results: searchResults));
      } else {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'No Results Found',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No products found for "$query"',
                  style: GoogleFonts.poppins(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Try searching for:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text('gaming'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Chip(
                      label: Text('furniture'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Chip(
                      label: Text('electronics'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text('OK')),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _openSearchDialog();
                },
                child: Text('Search Again'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ SEARCH ERROR: $e');
      Get.snackbar(
        'Search Error',
        'Failed to search products: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
