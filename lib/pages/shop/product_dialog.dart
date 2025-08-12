import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/controllers/favorite_controller.dart';
import 'package:flutter_web/controllers/product_controller.dart';
import 'package:flutter_web/models/cart_item.dart';
import 'package:flutter_web/models/product_model.dart';
import 'package:flutter_web/pages/auth/auth_dialog.dart';
import 'package:flutter_web/pages/shoppingcart/checkout_page.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDialog extends StatelessWidget {
  static const TAG = '/productdialog';

  final ProductController productController = Get.find();
  final CartService cartService = Get.find();
  final AuthController authController = Get.find();
  final FavoriteController favC = Get.put(FavoriteController());

  ProductDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = Get.parameters['id'];

    if (productId == null) {
      return _buildError("No product ID provided");
    }

    return Obx(() {
      if (productController.isLoading.value) {
        return WillPopScope(
          onWillPop: () async {
            Get.back();
            return false;
          },
          child: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      }

      final product = productController.getProductById(productId);

      if (product == null) {
        return _buildError("Product not found");
      }

      return ProductDialogContent(
        product: product,
        cartService: cartService,
        authController: authController,
        favC: favC,
      );
    });
  }

  Widget _buildError(String message) {
    return Scaffold(
      body: Center(child: Text(message)),
    );
  }
}

class ProductDialogContent extends StatelessWidget {
  final Product product;
  final CartService cartService;
  final AuthController authController;
  final FavoriteController favC;

  const ProductDialogContent({
    super.key,
    required this.product,
    required this.cartService,
    required this.authController,
    required this.favC,
  });

  @override
  Widget build(BuildContext context) {
    final productId = product.id ?? product.title;
    final stock = product.stock ?? 0;
    final stockColor = stock > 0 ? Colors.green[600] : Colors.red[600];

    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildProductImage(product),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.title, 
                  style: GoogleFonts.poppins(fontSize: 22, 
                  fontWeight: FontWeight.bold)),
                // const SizedBox()
                Obx(() => _buildFavoriteButton()),
              ],
            ),
            const SizedBox(height: 8),
            if (product.category != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  product.category!,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w500),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text('Store: ${product.storeName ?? '-'}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
            const SizedBox(height: 12),
            Text(product.description, style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 16),
            Text('Rp ${_rupiah(product.price)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green[700])),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Stock:', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 5),
                Text('$stock', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: stockColor)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Obx(() {
                  final item = cartService.getItem(productId);
                  return item != null
                    ? _buildCartQuantityControls(productId, item)
                    : _buildAddToCartButton(product, productId);
                }),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    _handleBuyNow(context, product);
                    // final cartItem = CartItem(
                    //   id: product.id ?? product.title, 
                    //   name: product.title, 
                    //   price: product.price.toDouble(), 
                    //   imageUrl: product.imagePath, 
                    //   seller: product.storeName ?? 'Toko Tidak Diketahui',
                    //   quantity: 1,
                    //   );
                    //   Get.to(() => CheckoutPage(singleItem: cartItem,));
                    },
                  child: Text(
                    'Beli Sekarang',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                    ),
                    ),
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Colors.black,
                  //   foregroundColor: Colors.white,
                  //   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  // ),
                ),
                // Obx(() => _buildFavoriteButton()),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCartQuantityControls(String productId, CartItem item) {
    return Row(
      children: [
        IconButton(onPressed: () => cartService.decreaseQuantity(productId), icon: const Icon(Icons.remove_circle_outline)),
        Text('${item.quantity}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
        IconButton(
          onPressed: () {
            cartService.increaseQuantity(productId);
            final email = Supabase.instance.client.auth.currentUser?.email;
            if (email != null) cartService.saveCartToSupabase(email);
          },
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(Product product, String productId) {
    return SizedBox(
      width: 50,
      child: 
      // ElevatedButton.icon(
      //   onPressed: () => _handleAddToCart(product, productId),
      //   icon: const Icon(Icons.shopping_cart_outlined, size: 18),
      //   label: Text('Add Cart', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: Colors.black,
      //     foregroundColor: Colors.white,
      //     padding: const EdgeInsets.symmetric(vertical: 12),
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //   ),
      // ),
      IconButton(
        onPressed: () => _handleAddToCart(product, productId),
        icon: const Icon(Icons.shopping_cart_outlined, size: 18),
        // label: Text('Add Cart', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      decoration: BoxDecoration(
        color: favC.isFavorite(product) ? Colors.red[50] : Colors.grey[100],
        border: Border.all(color: favC.isFavorite(product) ? Colors.red : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          favC.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
          color: favC.isFavorite(product) ? Colors.red : Colors.grey[600],
          size: 20,
        ),
        onPressed: () => _handleFavorite(product),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.imagePath.isEmpty) return _buildPlaceholderImage();
    if (product.imagePath.startsWith('http')) {
      return Image.network(
        product.imagePath,
        fit: BoxFit.contain,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    } else {
      return Image.asset(
        product.imagePath,
        fit: BoxFit.contain,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text('Image not found', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _handleAddToCart(Product product, String productId) async {
    final currentUser = authController.currentUser.value;

    if (currentUser == null || currentUser.email == null) {
      Get.dialog(const AuthDialog());
      Get.snackbar("Login Required", "Please login first to add products to cart",
        backgroundColor: Colors.orange, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if ((product.stock ?? 0) <= 0) {
      Get.snackbar("Out of Stock", "${product.title} is currently out of stock",
        backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    cartService.addItem(CartItem(
      id: productId,
      name: product.title,
      price: product.price.toDouble(),
      imageUrl: product.imagePath,
      seller: product.storeName ?? 'Toko Tidak Diketahui',
    ));

    await cartService.saveCartToSupabase(currentUser.email!);
  }

  void _handleBuyNow(BuildContext context, Product product) async {
  int quantity = 1;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          final stock = product.stock ?? 0;
          final maxQty = stock < 1 ? 0 : stock;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: _buildProductImage(product),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          Text('Rp ${_rupiah(product.price)}', style: GoogleFonts.poppins(color: Colors.green[700])),
                          Text('Stock: $stock', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text("Quantity", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                    ),
                    Text('$quantity', style: GoogleFonts.poppins(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: quantity < maxQty
                          ? () => setState(() => quantity++)
                          : () {
                              Get.snackbar(
                                'Stok Habis',
                                'Jumlah maksimal dalam stok telah tercapai.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                              );
                            },
                    ),
                  ],
                ),
                // const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: stock == 0
                        ? null
                        : () {
                            final currentUser = authController.currentUser.value;
                            if (currentUser == null || currentUser.email == null) {
                              Get.dialog(const AuthDialog());
                              return;
                            }

                            final cartItem = CartItem(
                              id: product.id ?? product.title,
                              name: product.title,
                              price: product.price.toDouble(),
                              imageUrl: product.imagePath,
                              seller: product.storeName ?? 'Toko Tidak Diketahui',
                              quantity: quantity,
                            );

                            Navigator.pop(context);
                            Get.to(() => CheckoutPage(singleItem: cartItem));
                          },
                    child: Text("Beli Sekarang", style: GoogleFonts.poppins(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
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
      icon: Icon(
        favC.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
        color: Colors.white,
      ),
    );
  }

  String _rupiah(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
