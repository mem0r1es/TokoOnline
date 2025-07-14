import 'package:flutter/material.dart';
import 'package:flutter_web/services/general_service.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:get/get.dart';
import '../shop/shops.dart';

class Isi extends GetView<GeneralService> {
  const Isi({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
      //   Image.asset(
      //   'background1.png',
      //   width: 1440,
      //   height: 900,
      //   fit: BoxFit.cover,
      // ),
      Obx(() {
        // final url = Get.find<GeneralService>().backgroundUrl.value;
        final url = controller.backgroundUrl.value;
        if (url.isEmpty) {
          // fallback sementara: warna background atau gambar lokal
          return Container(
            width: 1440,
            height: 900,
            color: Colors.grey[200],
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Image.network(
          url,
          width: 1440,
          height: 900,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 1440,
              height: 900,
              color: Colors.red[100],
              child: Center(child: Text("Gagal load gambar")),
            );
          },
        );
      }),

    Padding(
      padding: const EdgeInsets.only(left:50, right: 58, top: 100),
      // mainAxisAlignment= MainAxisAlignment.end,
      // crossAxisAlignment: CrossAxisAlignment.center,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 643,
          height: 443,
          decoration: BoxDecoration(
            color: Color(0xFFFFF3E3).withOpacity(0.9),
          // color: const Color(0xFFF3E3),
          ),
          child: 
          Padding(padding: const EdgeInsets.only(top: 62, left: 41, right: 56, bottom: 37),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang di Toko Online Kami',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Temukan berbagai produk berkualitas dengan harga terbaik.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => ShopsPage());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000000),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Jelajahi Sekarang',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                  ],
                ),
              ),
    // Text('Konten Utama'),
            ),
          ),
        ),
         // Tambahan konten biar bisa scroll
    // Tambahkan widget lain di sini jika diperlukan
      ],
    );
  }
}