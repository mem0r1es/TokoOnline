import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../widgets/product_model.dart';

class SearchResultPage extends StatelessWidget {
  final String query;
  final List<Product> results;

  const SearchResultPage({Key? key, required this.query, required this.results})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartService = Get.find<CartService>();
    final authService = Get.find<AuthService>();

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
                  : _buildSearchResults(cartService, authService),
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
          const SizedBox(height: 12),
          Text(
            'Try searching for:',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSuggestionChip('gaming'),
              _buildSuggestionChip('furniture'),
              _buildSuggestionChip('electronics'),
              _buildSuggestionChip('chair'),
              _buildSuggestionChip('desk'),
            ],
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

  Widget _buildSuggestionChip(String suggestion) {
    return ActionChip(
      label: Text(suggestion, style: GoogleFonts.poppins(fontSize: 12)),
      onPressed: () {
        // You can implement re-search with suggestion here
        Get.back();
      },
      backgroundColor: Colors.blue[50],
      side: BorderSide(color: Colors.blue[200]!),
    );
  }

  Widget _buildSearchResults(CartService cartService, AuthService authService) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return _buildProductCard(product, cartService, authService);
      },
    );
  }

  Widget _buildProductCard(
    Product product,
    CartService cartService,
    AuthService authService,
  ) {
    String productId = product.id ?? product.title;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildProductImage(product),
              ),
            ),
          ),

          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Category
                  if (product.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.category!,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    'Rp ${_formatPrice(product.price)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[600],
                    ),
                  ),

                  const Spacer(),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
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
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(
                          cartService.hasItem(productId)
                              ? Icons.shopping_cart
                              : Icons.shopping_cart_outlined,
                          size: 16,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.imagePath.startsWith('http')) {
      return Image.network(
        product.imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
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
            size: 32,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
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
        'Login Required',
        'Please login first to add products to cart',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(Icons.login, color: Colors.white),
      );
      return;
    }

    // Check stock
    if (product.stock != null && product.stock! <= 0) {
      Get.snackbar(
        'Out of Stock',
        '${product.title} is currently out of stock',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(Icons.inventory_2, color: Colors.white),
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
