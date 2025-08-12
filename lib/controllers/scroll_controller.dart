import 'package:flutter/material.dart';
import 'package:flutter_web/services/scroll_controller_manager.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html; // Pakai universal_html untuk kompatibilitas multi-platform

class CustomScrollController extends GetxController {
  final String scrollKey = 'home_scroll';
  final scrollManager = Get.find<ScrollControllerManager>();

  late ScrollController scrollController;
  RxInt selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
    if (GetPlatform.isWeb) {
      // Hanya dijalankan di web
      html.window.localStorage['selectedIndex'] = index.toString();
    } else {
      // Untuk mobile, simpan menggunakan GetStorage atau SharedPreferences
      // Contoh dengan GetStorage:
      // GetStorage().write('selectedIndex', index);
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (GetPlatform.isWeb) {
      // Hanya dijalankan di web
      final savedIndex = html.window.localStorage['selectedIndex'];
      if (savedIndex != null) {
        selectedIndex.value = int.tryParse(savedIndex) ?? 0;
      }
    } else {
      // Untuk mobile, baca dari GetStorage atau SharedPreferences
      // Contoh dengan GetStorage:
      // selectedIndex.value = GetStorage().read('selectedIndex') ?? 0;
    }
    
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