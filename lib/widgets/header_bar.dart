import 'package:flutter/material.dart';
import 'package:flutter_web/pages/contact.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../pages/dashboard.dart';
import '../pages/shops.dart'; 
import '../pages/shopping_cart.dart';
import '../pages/about.dart';
// import 'contact_page.dart';
import 'search_page.dart';
import 'favorite_page.dart';
// import 'search_page.dart';
// import 'cart.dart';// Pastikan path ini sesuai dengan struktur proyek Anda

class HeaderPages extends StatelessWidget {
  const HeaderPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 29),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo dan Teks
          Row(
            children: [
              Image.asset('headers/MeubelHouse_Logos-05.png',
                  width: 50, height: 32),
              const SizedBox(width: 5),
              Text(
                'Toko Online',
                style: GoogleFonts.montserrat(
                  fontSize: 34,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Menu Navigasi
          Row(
            children: [
              _navItem('Home',() => Get.to(const DashboardPage())),
              const SizedBox(width: 20),
              _navItem('Shop',() => Get.to(const ShopsPage())),
              const SizedBox(width: 20),
              _navItem('About',() => Get.to(const AboutPage1())),
              const SizedBox(width: 20),
              _navItem('Contact', ()=> Get.to(const ContactPage1())),
            ],
          ),

          // Icon Section
          Row(
            children: [
              Image.asset('headers/people.png'),
              const SizedBox(width: 10),
              _iconBtn(Icons.search, () => _openSearchDialog(context)),
              const SizedBox(width: 10),
              _iconBtn(Icons.favorite_border, () => Get.to(FavoritePage())),
              const SizedBox(width: 10),
              _iconBtn(Icons.shopping_cart_outlined, () => Get.to(const ShoppingCart())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, [VoidCallback? onPressed]) {
    return SizedBox(
      width: 28,
      height: 28,
      child: TextButton(
        onPressed: onPressed,
        child: Icon(icon, color: Colors.black, size: 24),
      ),
    );
  }

  Widget _navItem(String text, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color(0xFF000000),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _openSearchDialog(BuildContext context) {
    String query = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Product', style: GoogleFonts.poppins()),
          content: TextField(
            onChanged: (val) => query = val,
            decoration: const InputDecoration(hintText: 'Enter product name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (query.trim().isNotEmpty) {
                  Get.to(() => SearchResultPage(query: query));
                }
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}