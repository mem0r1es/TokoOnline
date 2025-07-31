import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toko_online_getx/modules/seller/widgets/sidebar_seller.dart';
import'../controllers/dashboard_controller.dart';

class SellerDashboardView extends GetView<SellerDashboardController>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SidebarSeller(),
      appBar: AppBar(
        title: Obx(() => Text('Dashboard - ${controller.sellerName.value}')),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Center(
        child: Text('Selamat datang, Penjual!')),
    );
  }
}
