import 'package:flutter/material.dart';
import 'package:flutter_web/binding.dart';
import 'package:flutter_web/routers/get_router.dart';
import 'package:flutter_web/controllers/scroll_controller.dart';
import 'package:flutter_web/services/scroll_controller_manager.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/homepage/home_page.dart';
import 'package:url_strategy/url_strategy.dart';  

void main() async {
  Get.put(ScrollControllerManager()); // ← jika pakai manual, atau pakai Get.lazyPut
  Get.put(CustomScrollController());
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();

  await Supabase.initialize(
    url: 'https://mccdwczueketpqlbobyw.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jY2R3Y3p1ZWtldHBxbGJvYnl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyOTEwMTcsImV4cCI6MjA2Njg2NzAxN30.LAQPMZgZvIUtRVjzkLFh-wXO_RiP9IuwZ3kgSpYghqE',
  );
  

  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: InitialScreenBindings(),
      debugShowCheckedModeBanner: false,
      title: 'Toko Online', 
      getPages: getRoutePages,
      initialRoute: HomePage.TAG,
      // home: const HomePage(),
    );
  }
}
