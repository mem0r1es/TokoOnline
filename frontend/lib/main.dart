import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/controllers/favorite_controller.dart';
import 'package:flutter_web/controllers/product_controller.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web/go_routers.dart';
import 'controllers/scroll_controller_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mccdwczueketpqlbobyw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jY2R3Y3p1ZWtldHBxbGJvYnl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyOTEwMTcsImV4cCI6MjA2Njg2NzAxN30.LAQPMZgZvIUtRVjzkLFh-wXO_RiP9IuwZ3kgSpYghqE',
  );

  await GetStorage.init();

  Get.put(ScrollControllerManager());
  Get.put(AuthController());
  Get.put(CartService());
  Get.put(AuthController());
  Get.put(FavoriteController());
  Get.put(ProductController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Toko Online',
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      routeInformationProvider: goRouter.routeInformationProvider,
    );
  }
}
