import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/scroll_controller.dart';
import 'package:flutter_web/extensions/extension.dart';
import 'package:flutter_web/pages/account/history/history.dart';
import 'package:flutter_web/pages/homepage/home_page.dart';
import 'package:flutter_web/pages/shop/our_product.dart';
import 'package:flutter_web/pages/shop/ourproduct_2.dart';
import 'package:get/get.dart';

class AfterCheckout extends StatelessWidget {
  static const TAG = '/aftercheckout';
  AfterCheckout({super.key});
  final scrollController = Get.find<CustomScrollController>();

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final totalBayar = args['totalBayar'] as double;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                // image: DecorationImage(
                //   image: AssetImage('assets/images/checkout_background.png'),
                //   fit: BoxFit.cover,
                // ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: BackButton(
                        onPressed: () {
                          scrollController.selectedIndex.value = 0;
                          Get.offAllNamed(HomePage.TAG);
                        },
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Icon(
                      Icons.celebration,
                      size: 100),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle),
                        SizedBox(width: 5,),
                        Text(
                        // 'Kamu membayar Rp ',
                        'Kamu berhasil membayar Rp ${_rupiah(totalBayar)}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(10)
                            )
                          ),
                          onPressed:() => Get.toNamed(HomePage.TAG), 
                          child: Text(
                            'Lanjut Berbelanja',
                            style: context.labelMedium,
                          )
                        ),
                        const SizedBox(width: 10,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(10)
                            )
                          ),
                          onPressed:() => Get.toNamed(ProductInfoPage.TAG), 
                          child: Text(
                            'Lihat Keranjang',
                            style: context.labelMedium,
                          )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20,),
            Text(
              'Terima kasih telah berbelanja di Toko Online kami!',
              style: context.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10,),
            Text(
              'Lihat produk lainnya dari Toko Online kami',
              style: context.labelMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 20,),
            OurProduct2(productLimit: 3),
            const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
  String _rupiah(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}