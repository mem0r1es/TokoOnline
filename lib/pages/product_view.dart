import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_online_getx/modules/seller/controllers/dashboard_controller.dart';
import 'package:toko_online_getx/modules/seller/widgets/sidebar_seller.dart';
import 'package:toko_online_getx/pages/add_product.dart';
import 'package:toko_online_getx/widgets/seller_top_bar.dart';

class ProductView extends GetView<SellerDashboardController> {
  static final String TAG = '/product-view';
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SidebarSeller(),
          Expanded(
            child: Column(
              children: [
                const SellerTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Obx(() => Text(
                            'Showing ${controller.totalProducts.value.toString()} products',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          )),
                        ),
                        Expanded(
                          child: Obx(() {
                            if (controller.isLoading.value) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (controller.products.isEmpty) {
                              return const Center(
                                child: Text('No products found', style: TextStyle(fontSize: 16)),
                              );
                            }

                            return ListView.builder(
                              itemCount: controller.products.length,
                              itemBuilder: (context, index) {
                                final product = controller.products[index];
                                return Card(
                                  elevation: 1,
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: Image.network(
                                      product.filePath,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                        const Icon(Icons.broken_image, size: 50),
                                    ),
                                    title: Text(product.name, style: const TextStyle(fontSize: 16)),
                                    subtitle: Text('Price: Rp ${_rupiah(product.price)}'),
                                    // Solusi: Hapus Obx yang tidak perlu dan bungkus Switch dengan SizedBox
                                    trailing: SizedBox(
                                      width: 50, // Berikan lebar yang tetap
                                      child: Switch(
                                        value: product.isActive ?? false,
                                        onChanged: (bool value) {
                                          if (product.id != null) {
                                            controller.updateProductStatus(product.id!, value);
                                          }
                                        },
                                        activeColor: Colors.green,
                                        inactiveThumbColor: Colors.red,
                                      ),
                                    ),
                                    onTap: () => {Get.toNamed(AddProduct.TAG, arguments: product),
                                    },
                                    ),
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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