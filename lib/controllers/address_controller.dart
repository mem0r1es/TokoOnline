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
  var selectedAddressId = ''.obs;
  var selectedAddressUser = Rxn<InfoUser>();



  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    final data = await _addressService.fetchAddresses(); // ✅ ini sudah terfilter
    addresses.assignAll(data);
  // final data = await supabase.from('addresses').select();
  // addresses.assignAll(data.map((e) => InfoUser.fromJson(e)));

  // Set selectedAddressId ke yang default
  final defaultAddress = addresses.firstWhereOrNull((a) => a.isDefault == true);
  if (defaultAddress != null) {
    selectedAddressId.value = defaultAddress.id!;
    selectedAddressUser.value = defaultAddress;
  } else {
    selectedAddressId.value = '';
    selectedAddressUser.value = null;
  }

}




  Future<void> saveAddress(InfoUser address) async {
    await _addressService.saveAddress(address);
    fetchAddresses();
  }

  // In your AddressController
Future<List<Map<String, dynamic>>> fetchProvinces() async {
  final response = await supabase.from('provinces').select('*');
  return response;
}

Future<List<Map<String, dynamic>>> fetchRegencies(String provinceId) async {
  final response = await supabase
      .from('regencies')
      .select('*')
      .eq('province_id', provinceId);
  return response;
}

Future<List<Map<String, dynamic>>> fetchDistricts(String regencyId) async {
  final response = await supabase
      .from('districts')
      .select('*')
      .eq('regency_id', regencyId);
  return response;
}

  Future<void> deactivateAddress(String id) async {
    await _addressService.deactivateAddress(id);
    fetchAddresses();
  }

  Future<void> setDefaultAddress(String addressId) async {
  final email = Supabase.instance.client.auth.currentUser?.email;
  if (email == null) return;

  try {
    await supabase.from('addresses').update({'is_default': false}).eq('email', email);
    await supabase.from('addresses').update({'is_default': true}).eq('id', addressId);

    await fetchAddresses();

    selectedAddressId.value = addressId; // ✅ pastikan ini ada
    final selected = addresses.firstWhereOrNull((a) => a.id == addressId);
    selectedAddressUser.value = selected;

  } catch (e) {
    Get.snackbar('Error', 'Failed to set default address');
  }
}

}
