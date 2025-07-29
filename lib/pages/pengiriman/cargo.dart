import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/cargo_controller.dart';
import 'package:flutter_web/models/cargo_model.dart';
import 'package:flutter_web/services/cargo_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class CargoPage extends StatefulWidget {
  static final String TAG = '/cargo';
  CargoPage({super.key});

  @override
  State<CargoPage> createState() => _CargoPageState();
  

}

class _CargoPageState extends State<CargoPage> {
  final storage = GetStorage();
  final CargoController cargoController = Get.find<CargoController>();
  // bool isCargoExpanded = true;
  String? selectedCargoName;
  String? expandedKategori;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();

    storage.remove('selectedCargoName');
    storage.remove('expandedKategori');
    selectedCargoName = storage.read('selectedCargoName');
    // selectedCategory = storage.read('selectedCategory');
    expandedKategori = storage.read('expandedKategori');

    
    // if (selectedCargoName != null) {
    //   cargoController.selectCargo(selectedCargoName!);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final CargoService cargoService = Get.find<CargoService>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Opsi Pengiriman',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)
        ),
      ),
      body: FutureBuilder<List<CargoModel>>(
      future: cargoService.fetchCargo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final cargoList = snapshot.data ?? [];

        final Map<String, List<CargoModel>> groupedCargo = {};
        for (var cargo in cargoList) {
          final kategori = cargo.kategori ?? 'Lainnya';
          groupedCargo.putIfAbsent(kategori, () => []).add(cargo);
        }

        return Obx(() => ListView(
        children: groupedCargo.entries.map((entry) {
          final kategori = entry.key;
          final cargos = entry.value;

          return ExpansionTile(
            key: PageStorageKey<String>(kategori),
            title: Text(
              kategori,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            initiallyExpanded: cargoController.expandedKategori.value == kategori,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                cargoController.expandedKategori.value = kategori;
                storage.write('expandedKategori', kategori);
              } else {
                cargoController.expandedKategori.value = '';
                storage.remove('expandedKategori');
              }
            },
            children: cargos.map((cargo) {
              final isSelected = cargoController.selectedCargoName.value == cargo.name;

              return ListTile(
                title: Text(
                  cargo.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isSelected ? Colors.green : Colors.black,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  cargoController.selectCargo(cargo);
                  storage.write('selectedCargoName', cargo.name);
                  storage.write('expandedKategori', kategori);
                },
              );
            }).toList(),
          );
        }).toList(),
      ));
      },
    ),
  );
  }
}