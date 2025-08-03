import 'package:flutter/material.dart';
import 'package:flutter_web/pages/history/history.dart';
import 'package:flutter_web/pages/homepage/home_page.dart';
import 'package:get/get.dart';

class AfterCheckout extends StatelessWidget {
  static const TAG = '/aftercheckout';
  const AfterCheckout({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final totalBayar = args['totalBayar'] as double;
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                'Kamu membayar Rp ${_rupiah(totalBayar)}',
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
                    'Lanjut Berbelanja'
                  )
                ),
                const SizedBox(width: 10,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10)
                    )
                  ),
                  onPressed:() => Get.toNamed(HomePage.TAG), 
                  child: Text(
                    'Lihat Keranjang'
                  )
                ),
              ],
            ),
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