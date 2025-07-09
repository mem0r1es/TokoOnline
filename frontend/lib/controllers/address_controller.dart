import 'package:flutter_web/services/auth_service.dart';
import 'package:get/get.dart';
import '../models/info_user.dart';
import '../services/address_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressController extends GetxController {
  final supabase = Supabase.instance.client;
  final AddressService _addressService = AddressService();
  final AuthService authService = Get.find<AuthService>();
  var addresses = <InfoUser>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
  final user = authService.currentUser.value;
  if (user == null) return;

  isLoading.value = true;
  try {
    final result = await _addressService.fetchAddresses();
    addresses.value = result;
  } catch (e) {
    print('Error fetching addresses: $e');
  } finally {
    isLoading.value = false;
  }
}


  Future<void> saveAddress(InfoUser address) async {
    await _addressService.saveAddress(address);
    fetchAddresses();
  }

  Future<void> deactivateAddress(String id) async {
    await _addressService.deactivateAddress(id);
    fetchAddresses();
  }
}
