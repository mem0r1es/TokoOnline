import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class SidebarSeller extends StatelessWidget {
  final SellerDashboardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Obx(() => UserAccountsDrawerHeader(
                accountName: Text(controller.sellerName.value),
                accountEmail: Text('seller@email.com'),
              )),
          ListTile(
            title: Text('Produk Saya'),
            onTap: () {
              // Navigasi ke halaman produk seller nanti
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: controller.logout,
          ),
        ],
      ),
    );
  }
}
