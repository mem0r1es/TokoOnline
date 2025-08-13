// File: lib/modules/seller/widgets/seller_top_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toko_online_getx/modules/seller/controllers/dashboard_controller.dart';

class SellerTopBar extends GetView<SellerDashboardController> {
  const SellerTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Welcome Message
          Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${controller.userName.value}!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                controller.shopName.value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          )),
          // User Menu
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              PopupMenuButton<String>(
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: Text(
                        controller.userName.value.isNotEmpty
                            ? controller.userName.value[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Text('Profile'),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Text('Settings'),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Text('Logout', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'logout') {
                    controller.logout();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}