import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/favorite_controller.dart';
// import 'package:flutter_web/controllers/page_controller.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/controllers/product_controller.dart';
import 'package:flutter_web/models/cart_item.dart';
import 'package:flutter_web/pages/auth/auth_dialog.dart';
import 'package:flutter_web/pages/shop/product_dialog.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
// import '../../controller/cart_controller.dart';
// import '../../controller/auth_controller.dart';
import '../../models/product_model.dart';

class SearchResultPage extends GetView<FavoriteController> {
  final String query;
  final List<Product> results;
  static final String TAG = '/searchresult';

  SearchResultPage({super.key, required this.query, required this.results});
  // final favC = Get.find<FavoriteController>();
  final ProductController productController = Get.put(ProductController());
  // final favC = Get.put(FavoriteController());

  @override
  Widget build(BuildContext context) {
    final cartService = Get.find<CartService>();
    final authController = Get.find<AuthController>();
    // final favC = Get.put(FavoriteController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search: "$query"',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search result header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Found ${results.length} products for "$query"',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      
            const SizedBox(height: 20),
      
            // Search results
            Expanded(
              child: results.isEmpty
                  ? _buildEmptyState()
                  : _buildSearchResults(cartService, authController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No products found',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSuggestionChip(String suggestion) {
  //   return ActionChip(
  //     label: Text(suggestion, style: GoogleFonts.poppins(fontSize: 12)),
  //     onPressed: () {
  //       // You can implement re-search with suggestion here
  //       Get.back();
  //     },
  //     backgroundColor: Colors.blue[50],
  //     side: BorderSide(color: Colors.blue[200]!),
  //   );
  // }

  Widget _buildSearchResults(CartService cartService, AuthController authController) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2; 

        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 800) {
          crossAxisCount = 3;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final product = results[index];
              return _buildProductCard(product, cartService, authController);
            },
          ),
        );
      },
    );
  }


  Widget _buildProductCard(
    Product product,
    CartService cartService,
    AuthController authController,
  ) {

    String productId = product.id ?? product.title;
  
    return SizedBox(
      width: 280,
      child: GestureDetector(
        onTap: (){
          Get.toNamed('${ProductDialog.TAG}?id=${product.id}');
          // Get.to(ProductDialog(product: product));
          // Get.toNamed('/product', arguments: product);
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
                    Text(
                      product.storeName ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
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
                              'Rp ${_formatPrice(product.price)}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

  void _showAuthDialog() {
    Get.dialog(AuthDialog());
  }

  void _handleAddToCart(
    Product product,
    String productId,
    CartService cartService,
    AuthController authController,
  ) {
    if (!authController.isLoggedIn.value) {
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
    cartService.addItem(CartItem(
      id: productId,
      name: product.title,
      price: product.price.toDouble(),
      imageUrl: product.imagePath,
      quantity: 1, // Default quantity is 1
      ),
    );
  }

  void _handleFavorite(Product product) {
    controller.toggleFavorite(product);

    Get.snackbar(
      "Favorites",
      controller.isFavorite(product)
          ? "${product.title} added to favorites"
          : "${product.title} removed from favorites",
      backgroundColor: controller.isFavorite(product) ? Colors.red : Colors.grey,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
      icon: Icon(
        controller.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
        color: Colors.white,
      ),
    );
  }

  factory SearchResultPage.fromArguments() {
  final args = Get.arguments as Map<String, dynamic>;

  return SearchResultPage(
    query: args['query'] ?? '',
    results: args['results'] ?? [],
  );
}

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
