import 'package:flutter/material.dart';
// import 'package:flutter_web/widgets/billing.dart';
import 'header/header_bar.dart';
import 'isi.dart' ;
import 'header/shop/our_product.dart';
import 'header/about/about_page.dart';
import 'header/contact/contact_page.dart';
// import '../widgets/billing.dart';// Pastikan path ini sesuai dengan struktur proyek And

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const HeaderPages(),
          const Isi(),
          OurProduct(),

          // Konten lainnya...

          const SizedBox(height: 60), // Jarak sebelum footer

          // FOOTER: About dan Contact di bawah
          Container(
            padding: const EdgeInsets.all(20),
            color: Color(0xFFF8F4FF),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Expanded(child: AboutPage()),
                SizedBox(width: 20),
                Expanded(child: ContactPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

