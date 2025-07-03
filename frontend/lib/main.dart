import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/dashboard.dart';

void main() {
  runApp(const MyApp());
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Setup Supabase
//   await Supabase.initialize(
//     url: 'https://mccdwczueketpqlbobyw.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jY2R3Y3p1ZWtldHBxbGJvYnl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyOTEwMTcsImV4cCI6MjA2Njg2NzAxN30.LAQPMZgZvIUtRVjzkLFh-wXO_RiP9IuwZ3kgSpYghqE',
//   );

//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(title: 'Toko Online', home: const DashboardPage());
  }
}
