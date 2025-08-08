import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toko_online_getx/data/services/supabase_service.dart';
import 'package:toko_online_getx/modules/auth/views/login_view.dart';
import 'package:url_strategy/url_strategy.dart';
import 'binding.dart';
import 'routes/get_router.dart'; // pastikan ini berisi getPages list
import 'routes/app_routes.dart'; // pastikan ini berisi AppRoutes.login misalnya

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  await Supabase.initialize(
    url: 'https://mccdwczueketpqlbobyw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jY2R3Y3p1ZWtldHBxbGJvYnl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyOTEwMTcsImV4cCI6MjA2Njg2NzAxN30.LAQPMZgZvIUtRVjzkLFh-wXO_RiP9IuwZ3kgSpYghqE',
  );

  Get.put(SupabaseService());

  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Seller Portal',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialScreenBindings(),
      initialRoute: '/seller-dashboard', // atau '/' jika kamu mau pakai default
      getPages: getRoutePages,       // pastikan ini list of GetPage
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const Scaffold(
          body: Center(child: Text('404 - Page Not Found')),
        ),
      ),
    );
  }
}
