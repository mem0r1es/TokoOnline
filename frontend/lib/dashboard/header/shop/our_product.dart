import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/page_controller.dart';
import 'product_model.dart';

class OurProduct extends StatelessWidget {
  OurProduct({super.key});

  final favC = Get.put(FavoriteController());
  final ProductService productService = Get.put(ProductService());


  @override
  Widget build(BuildContext context) {
      final cartService = Get.find<CartService>();
      final authService = Get.find<AuthService>();
      
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Text(
            'Our Products',
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          // Debug buttons (hapus ini nanti setelah testing)
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     ElevatedButton.icon(
          //       onPressed: () async {
          //         await productService.refreshProducts();
          //       },
          //       icon: Icon(Icons.refresh, size: 16),
          //       label: Text('Refresh'),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.blue,
          //         foregroundColor: Colors.white,
          //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //       ),
          //     ),

          //     SizedBox(width: 10),

          //     ElevatedButton.icon(
          //       onPressed: () {
          //         productService.printProductsInfo();
          //       },
          //       icon: Icon(Icons.info, size: 16),
          //       label: Text('Debug'),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.orange,
          //         foregroundColor: Colors.white,
          //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //       ),
          //     ),

          //     SizedBox(width: 10),

          //     // Migrate button (untuk emergency)
          //     ElevatedButton.icon(
          //       onPressed: () async {
          //         await productService.migrateStaticProductsToDatabase();
          //       },
          //       icon: Icon(Icons.cloud_upload, size: 16),
          //       label: Text('Migrate'),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.green,
          //         foregroundColor: Colors.white,
          //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //       ),
          //     ),
          //   ],
          // ),

          // const SizedBox(height: 20),

          // Products Grid
          Obx(() {
            if (productService.isLoading.value) {
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

            if (productService.products.isEmpty) {
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
                        onPressed: () => productService.refreshProducts(),
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

            // Products grid
            return Column(
              children: [
                // Products count info
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Showing ${productService.products.length} products',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                // Products grid
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: productService.products
                      .map(
                        (product) =>
                            _productCard(product, cartService, authService),
                      )
                      .toList(),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _productCard(
    Product product,
    CartService cartService,
    AuthService authService,
  ) {
    // Use database ID if available, fallback to title
    String productId = product.id ?? product.title;

    return SizedBox(
      width: 200,
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
              height: 200,
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildProductImage(product),
              ),
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Product Description
                  Text(
                    product.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Price and Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rp ${_rupiah(product.price)}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[600],
                            ),
                          ),
                          if (product.category != null) ...[
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                product.category!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Stock info
                      if (product.stock != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Stock',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${product.stock}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: product.stock! > 0
                                    ? Colors.green[600]
                                    : Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      // Add to Cart Button
                      Expanded(
                        flex: 3,
                        child: Obx(
                          () => ElevatedButton.icon(
                            onPressed: () => _handleAddToCart(
                              product,
                              productId,
                              cartService,
                              authService,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cartService.hasItem(productId)
                                  ? Colors.green
                                  : Colors.black,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Icon(
                              cartService.hasItem(productId)
                                  ? Icons.shopping_cart
                                  : Icons.shopping_cart_outlined,
                              size: 18,
                            ),
                            label: Text(
                              cartService.hasItem(productId)
                                  ? 'In Cart'
                                  : 'Add Cart',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 8),

                      // Favorite Button
                      Obx(
                        () => Container(
                          decoration: BoxDecoration(
                            color: favC.isFavorite(product)
                                ? Colors.red[50]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: favC.isFavorite(product)
                                  ? Colors.red
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => _handleFavorite(product),
                            icon: Icon(
                              favC.isFavorite(product)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: favC.isFavorite(product)
                                  ? Colors.red
                                  : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
        width: double.infinity,
        height: double.infinity,
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

  void _handleAddToCart(
    Product product,
    String productId,
    CartService cartService,
    AuthService authService,
  ) {
    if (!authService.isLoggedIn.value) {
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

    // Check stock
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

    // Add to cart
    cartService.addItem(
      id: productId,
      name: product.title,
      price: product.price.toDouble(),
      imageUrl: product.imagePath,
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
