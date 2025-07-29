import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/web_storage.dart';
import '../services/scroll_controller_manager.dart'; // tetap dipakai jika kamu butuh scrollManager

class CustomScrollController extends GetxController {
  final String scrollKey = 'home_scroll';
  final scrollManager = Get.find<ScrollControllerManager>();

  late ScrollController scrollController;
  RxInt selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
    saveSelectedIndex(index); // ✅ gunakan helper cross-platform
  }

  @override
  void onInit() {
    super.onInit();

    selectedIndex.value = loadSelectedIndex() ?? 0; // ✅ gunakan helper cross-platform

    scrollController = ScrollController(
      initialScrollOffset: scrollManager.getOffset(scrollKey),
    );

    scrollController.addListener(() {
      scrollManager.saveOffset(scrollKey, scrollController.offset);
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
