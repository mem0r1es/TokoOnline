import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/cargo_controller.dart';
import 'package:flutter_web/models/cargo_model.dart';
import 'package:flutter_web/services/cargo_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CargoPage extends StatefulWidget {
  static final String TAG = '/cargo';

  const CargoPage({super.key});

  @override
  State<CargoPage> createState() => _CargoPageState();
}

class _CargoPageState extends State<CargoPage> {
  final storage = GetStorage();
  final CargoController cargoController = Get.find<CargoController>();

  @override
  void initState() {
    super.initState();
    storage.remove('selectedCargoName');
    storage.remove('expandedKategori');
  }

  @override
  Widget build(BuildContext context) {
    final CargoService cargoService = Get.find<CargoService>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Opsi Pengiriman',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
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

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data kargo.'));
          }

          final cargoList = snapshot.data!;

          // Kelompokkan cargo berdasarkan kategori
          final Map<int, List<CargoModel>> groupedCargo = {};
          for (var cargo in cargoList) {
            groupedCargo.putIfAbsent(cargo.kategoriId, () => []).add(cargo);
          }

        return Obx(() => ListView(
        children: groupedCargo.entries.map((entry) {
          // final kategoriId = entry.key;
          final cargos = entry.value;

                  // Hitung kisaran harga
                  final hargaList = cargos.map((e) => e.harga).toList();
                  final minHarga = hargaList.reduce((a, b) => a < b ? a : b);
                  final maxHarga = hargaList.reduce((a, b) => a > b ? a : b);
                  final kisaranHarga = (minHarga == maxHarga)
                      ? 'Rp ${_rupiah(minHarga)}'
                      : 'Rp ${_rupiah(minHarga)} - ${_rupiah(maxHarga)}';

          return ExpansionTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            cargos.first.kategoriName,              
                            style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          kisaranHarga,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    children: cargos.map((cargo) {
                      final isSelected = cargoController.selectedCargo.value?.id == cargo.id;
                      return ListTile(
                        title: Text(
                          cargo.name,
                          style: GoogleFonts.poppins(),
                        ),
                        subtitle: Text('Rp ${_rupiah(cargo.harga)}'),
                        tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                        trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                        onTap: () {
                            cargoController.selectCargo(cargo); // Simpan pilihan kargo
                            Get.back(); // Kembali ke halaman sebelumnya (CheckoutPage)
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

  String _rupiah(int price) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(price).replaceAll(',', '.');
  }
}