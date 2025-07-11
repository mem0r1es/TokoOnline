import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/header_bar.dart';
import 'our_product.dart';
import 'package:flutter_web/controllers/scroll_controller_manager.dart'; 
class ShopsPage extends StatefulWidget {
  const ShopsPage({super.key});

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  final String scrollKey = 'shops_scroll'; 
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
          const OurProduct(),

          // Tambahkan bagian lainnya seperti Our Products di sini
          // const SizedBox(height: 40),
          const SizedBox(height: 500), // Placeholder konten
        ],
      ),
    );
  }
}
