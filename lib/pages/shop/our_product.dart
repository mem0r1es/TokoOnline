import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/controllers/favorite_controller.dart';
import 'package:flutter_web/controllers/product_controller.dart';
import 'package:flutter_web/controllers/scroll_controller.dart';
import 'package:flutter_web/pages/homepage/home_page.dart';
import 'package:flutter_web/pages/shop/product_dialog.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
// import '../../controller/cart_controller.dart';
// import '../../controller/auth_controller.dart';
// import '../../controller/product_controller.dart';
// import '../../controllers/page_controller.dart';
import '../../models/product_model.dart';

class OurProduct extends GetView<ProductController> {
  final int? productLimit;
  OurProduct({super.key, this.productLimit});

  final FavoriteController favC = Get.put(FavoriteController());
  final cartService = Get.find<CartService>();
  final authController= Get.find<AuthController>();
  final scrollController = Get.find<CustomScrollController>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600; // bisa kamu atur ambangnya
    final childAspectRatio = isLargeScreen ? 0.75 : 0.65;

    return LayoutBuilder(
      builder: (context, constraints) {
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

            final int displayedItemCount = productLimit != null && productLimit! < controller.products.length
                  ? productLimit!
                  : controller.products.length;

              // Tentukan jumlah total item di grid (termasuk tombol)
              final int totalGridItems = productLimit != null && controller.products.length > productLimit!
                  ? displayedItemCount + 1 // Tambah 1 untuk tombol "Lihat Lainnya"
                  : displayedItemCount;

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
                  itemCount: totalGridItems,
                  // itemCount: controller.products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    if (productLimit != null && index == totalGridItems - 1 && controller.products.length > productLimit!) {
                        return _buildViewAllCard(); // Widget khusus untuk tombol "Lihat Lainnya"
                      }
                    final product = controller.products[index];
                    return _productCard(product, cartService, authController);
                  },
                ),
                SizedBox.shrink(), // Jika tidak ada tombol, kembalikan widget kosong
              ],
            );
          }),
        ],
      ),
    );
  },
);
  }

  Widget _buildViewAllCard() {
    return GestureDetector(
      onTap: () {
        scrollController.selectedIndex.value = 1;
        Get.offAllNamed(HomePage.TAG);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Color(0xFFF8F4FF),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_forward_ios, size: 40, color: Colors.black),
              const SizedBox(height: 8),
              Text(
                'Lihat Semua',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productCard(
    Product product,
    CartService cartService,
    AuthController authController,
  ) {

    return SizedBox(
      width: 160,
      child: GestureDetector(
        onTap: (){
          Get.toNamed('${ProductDialog.TAG}?id=${product.id}');
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

  String _rupiah(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
}
