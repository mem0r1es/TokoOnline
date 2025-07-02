import 'package:flutter/material.dart';
// import 'package:flutter_web/controllers/page_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/page_controller.dart';
import '../widgets/product_model.dart';

class OurProduct extends StatelessWidget {
  OurProduct({super.key});
  final cartC = Get.put(CartController1());
  final favC = Get.put(FavoriteController());

  final List<Product> productList = [
    Product(
      title: 'Syltherine',
      imagePath: 'assets/product1.png',
      description: 'Stylish cafe chair',
      price: 2500000,
    ),
    Product(
      title: 'Product 2',
      imagePath: 'assets/product2.png',
      description: 'Elegant dining table',
      price: 3000000,
    ),
    Product(
      title: 'Product 3',
      imagePath: 'assets/product3.png',
      description: 'Comfortable sofa',
      price: 4500000,
    ),
    Product(
      title: 'Product 4',
      imagePath: 'assets/product4.png',
      description: 'Modern bookshelf',
      price: 1800000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
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
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: productList
                .map((product) => _productCard(product))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Product product) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 4,
        color: Color(0xFFF8F4FF),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(product.imagePath,
                  width: 150, height: 150, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    product.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${_rupiah(product.price)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          cartC.addToCart(product);
                          Get.snackbar("Berhasil", "${product.title} ditambahkan ke keranjang");
                          Text('Jumlah item: ${cartC.cartItems.length}');
                        },
                        child: const Icon(Icons.shopping_cart_outlined),
                      ),
                      // const SizedBox(width:5),
                      Obx(() => IconButton(
                        icon: Icon(
                          favC.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          favC.toggleFavorite(product);
                          Get.snackbar("Info", favC.isFavorite(product)
                            ? "${product.title} ditambahkan ke favorit"
                            : "${product.title} dihapus dari favorit");
                        },
                      )),
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

  String _rupiah(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
