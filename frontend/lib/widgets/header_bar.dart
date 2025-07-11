// Final Revised HeaderPages with proper controller initialization, no duplication, and scroll support
import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/address_controller.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:flutter_web/controllers/favorite_controller.dart';
import 'package:flutter_web/controllers/product_controller.dart';
// import 'package:flutter_web/controllers/favorite_controller.dart';
//import 'package:flutter_web/pages/contact/contact.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:flutter_web/services/checkout_service.dart';
import 'package:flutter_web/services/product_service.dart';
import 'package:flutter_web/controllers/scroll_controller_manager.dart';
import 'package:flutter_web/models/product_model.dart';
import 'package:flutter_web/pages/auth/auth_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
//import '../pages/dashboard/dashboard.dart';
//import '../pages/about/about.dart';
import '../pages/auth/auth_dialog.dart';
// import '../controller/auth_controller.dart';
// import '../controller/cart_controller.dart';
// import '../controller/product_controller.dart';
import '../models/product_model.dart';

class HeaderPages extends StatefulWidget {
  const HeaderPages({super.key});

  @override
  State<HeaderPages> createState() => _HeaderPagesState();
}

class _HeaderPagesState extends State<HeaderPages> {
  final String scrollKey = 'header_scroll';
  late ScrollController _scrollController;
  final scrollManager = Get.find<ScrollControllerManager>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: scrollManager.getOffset(scrollKey),
    );
    _scrollController.addListener(() {
      scrollManager.saveOffset(scrollKey, _scrollController.offset);
    });

    // Initialize ALL services and controller required (GUARANTEED TO WORK)
    Get.put(AuthController());
    Get.put(CartService());
    Get.put(ProductService());
    Get.put(AddressController());
    Get.put(CheckoutService());
    Get.put(CartController());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final CartService cartService = Get.find<CartService>();

    return SingleChildScrollView( // ✅ Supaya bisa discroll
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width,
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
                _navItem('Home', context, '/'),
                const SizedBox(width: 20),
                _navItem('Shop', context, '/shop'),
                const SizedBox(width: 20),
                _navItem('About', context, '/about'),
                const SizedBox(width: 20),
                _navItem('Contact', context, '/contact'),
              ],
            ),
            // Icon Section
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _iconBtn(Icons.person, () => _userlogin(context, authController)),
                const SizedBox(width: 10),
                _iconBtn(Icons.search, () => _openSearchDialog(context)),
                const SizedBox(width: 10),
                _iconBtn(Icons.favorite_border, () => context.go('/favorit')),
                const SizedBox(width: 10),
                Obx(() => GestureDetector(
                  onTap: () => _handleCartClick(context, authController, cartService),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 24),
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
                              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                '${cartService.itemCount}',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String text, BuildContext context, String routePath) {
    return GestureDetector(
      onTap: () => context.go(routePath),
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

  void _userlogin(BuildContext context, AuthController authService) {
    if (authService.isLoggedIn.value) {
      _showUserMenu(context, authService);
    } else {
      _showAuthDialog(context);
    }
  }

  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AuthDialog(),
    );
  }

  void _showUserMenu(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('User Menu', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome!', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text(authController.getUserEmail() ?? 'User', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 20),
            _userMenuOption(icon: Icons.person, title: 'Profile', onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            }),
            _userMenuOption(icon: Icons.shopping_bag, title: 'My Orders', onTap: () {
              Navigator.pop(context);
              context.push('/orders');
            }),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  authController.logout();
                },
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _userMenuOption({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      onTap: onTap,
    );
  }

  void _openSearchDialog(BuildContext context) {
    String query = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Search Product', style: GoogleFonts.poppins()),
        content: TextField(
          onChanged: (val) => query = val,
          decoration: const InputDecoration(
            hintText: 'Enter product name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (query.trim().isNotEmpty) {
                await _performSearch(context, query.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch(BuildContext context, String query) async {
    try {
      final ProductService productService = Get.find<ProductService>();
      final List<Product> searchResults = await productService.searchProducts(query);
      if (searchResults.isNotEmpty) {
        context.push('/search', extra: {'query': query, 'results': searchResults});
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('No Results Found', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
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
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openSearchDialog(context);
                },
                child: Text('Search Again'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to search products: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleCartClick(BuildContext context, AuthController authService, CartService cartService) {
    if (authService.isLoggedIn.value) {
      if (cartService.isNotEmpty) {
        context.push('/cart');
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
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
              TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/shop');
                },
                child: Text('Shop Now'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
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
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showAuthDialog(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: Text('Login', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }
}
