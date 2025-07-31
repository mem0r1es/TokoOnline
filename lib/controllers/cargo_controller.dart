import 'package:flutter_web/models/cargo_model.dart';
import 'package:get/get.dart';

class CargoController extends GetxController {
  var selectedCargoName = ''.obs;
  var selectedCategory = ''.obs;
  final expandedKategori = ''.obs;
  final selectedCargo = Rxn<CargoModel>();

  void selectCargo(CargoModel cargo) {
    selectedCargo.value = cargo;
    selectedCargoName.value = cargo.name;
    selectedCategory.value = cargo.kategoriName;
  }
    int get selectedCargoPrice => selectedCargo.value?.harga ?? 0;


  // void selectCargo(String name, String category) {
  //   selectedCargoName.value = name;
  //   selectedCategory.value = category;
  // }
}
