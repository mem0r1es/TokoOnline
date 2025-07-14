
import 'package:flutter/material.dart';
import 'package:flutter_web/services/scroll_controller_manager.dart';
import 'package:get/get.dart';

class CustomScrollController extends GetxController {
  final String scrollKey = 'home_scroll';
  final scrollManager = Get.find<ScrollControllerManager>();

  late ScrollController scrollController;

  @override
  void onInit() {
    scrollController = ScrollController(
      initialScrollOffset: scrollManager.getOffset(scrollKey),
    );

    scrollController.addListener(() {
      scrollManager.saveOffset(scrollKey, scrollController.offset);
    });

    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
