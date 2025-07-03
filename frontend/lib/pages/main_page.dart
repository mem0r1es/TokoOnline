import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/page_controller.dart';
import '../widgets/header_bar.dart';
import 'dashboard.dart';
// import 'shops.dart';
// import 'about_page.dart';
// import 'contact_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PageControllerX());

    return Scaffold(
      body: Column(
        children: [
          const HeaderPages(), // tetap di atas
          Expanded(
            child: Obx(() {
              return IndexedStack(
                index: controller.selectedIndex.value,
                children: const [
                  DashboardPage(),
                  // ShopsPage(),
                  // AboutPage(),
                  // ContactPage(),
                ],
              );
            }),
          ),
          const SizedBox(height: 500),
        ],
      ),
    );
  }
}
