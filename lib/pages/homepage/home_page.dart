
import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/scroll_controller.dart';
import 'package:flutter_web/pages/profile/profile_page.dart';
import 'package:flutter_web/pages/shop/shops.dart';
import 'package:get/get.dart';
// import 'package:flutter_web/services/product_service.dart';
// import 'package:flutter_web/widgets/billing.dart';
import '../../widgets/header_bar.dart';
import 'isi.dart' ;
import '../shop/our_product.dart';
import '../about/about_page.dart';
import '../contact/contact_page.dart';
// import '../widgets/billing.dart';// Pastikan path ini sesuai dengan struktur proyek And
// import 'package:get/get.dart';

class HomePage extends GetView<CustomScrollController> {
  static final String TAG = '/';

  const HomePage({super.key});

  final List <Widget> _pages = const [
    _HomeContent(),
    ShopsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        currentIndex: controller.selectedIndex.value,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple[800],
        unselectedItemColor: Colors.grey,
        onTap: (index){
          controller.changePage(index);
        },
        ),
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: _pages,
        )
      ),
    );
  }

  
}

class _HomeContent extends GetView<CustomScrollController>{
  const _HomeContent ();

  @override
  Widget build(BuildContext context) {
      // final scrollController = Get.find<CustomScrollController>().getController('home_scroll');
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          controller: controller.scrollController,
          children: [
            const HeaderPages(),
            const Isi(),
            OurProduct(),
        
            const SizedBox(height: 60), // Jarak sebelum footer
        
            // FOOTER: About dan Contact di bawah
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: const Color(0xFFF8F4FF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Bikin child-nya full lebar
                children: [
                  AboutPage(),
                  const SizedBox(height: 12),
                  ContactPage(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

