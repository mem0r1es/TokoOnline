import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Toko Online',
      home: const DashboardPage(),
    );
  }
}
