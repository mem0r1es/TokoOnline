import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/address_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_web/services/cart_service.dart';

class AddressListWidget extends StatelessWidget {
  final String? selectedAddressId;
  final Function(String?) onAddressSelected;
  final AddressController addressController = Get.find<AddressController>();

  AddressListWidget({super.key, required this.selectedAddressId, required this.onAddressSelected});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (addressController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (addressController.addresses.isEmpty) {
        return const Center(child: Text("No addresses available."));
      }
      return Column(
        children: addressController.addresses.map((address) {
          final id = address.id ?? '';
          return ListTile(
            title: Text(address.fullName ?? ''),
            subtitle: Text(address.address ?? ''),
            leading: Radio<String>(
              value: id,
              groupValue: selectedAddressId,
              onChanged: onAddressSelected,
            ),
            onTap: () => onAddressSelected(id),
          );
        }).toList(),
      );
    });
  }
}
