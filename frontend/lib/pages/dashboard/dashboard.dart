import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/scroll_controller_manager.dart';
import '../../widgets/header_bar.dart';
import 'isi.dart';
import '../shop/our_product.dart';
import '../about/about_page.dart';
import '../contact/contact_page.dart';
// import '../widgets/billing.dart';// Pastikan path ini sesuai dengan struktur proyek And
import 'package:get/get.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String scrollKey = 'dashboard_scroll';
  late ScrollController _scrollController;
  late ScrollControllerManager scrollManager; 

  @override
  void initState() {
    super.initState();
    scrollManager = Get.find<ScrollControllerManager>();
    _scrollController = ScrollController(
      initialScrollOffset: scrollManager.getOffset(scrollKey),
    );
    _scrollController.addListener(() {
      scrollManager.saveOffset(scrollKey, _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        controller: _scrollController,
        children: [
          const HeaderPages(),
          const Isi(),
          OurProduct(),

          const SizedBox(height: 60), // Jarak sebelum footer

          // FOOTER: About dan Contact di bawah
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFF8F4FF),
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
