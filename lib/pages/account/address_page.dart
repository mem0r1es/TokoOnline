import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/checkout_controller.dart';
import 'package:flutter_web/extensions/extension.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_address.dart';
import '../../controllers/address_controller.dart';

class AddressPage extends GetView<AddressController> {
  static final String TAG = '/address';

  AddressPage({super.key});

  final checkoutController = Get.find<CheckoutController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        // shadowColor: Colors.black,
        title: const Text(
          'Alamat Saya',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.addresses.isEmpty) {
              return const Center(
                child: Text(
                  "No addresses added yet.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              itemCount: controller.addresses.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
                final address = controller.addresses[index];
                if (address.id == null) return SizedBox.shrink();
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    tileColor: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
                    leading: Obx(() => Radio<String>(
                      value: address.id!, // tambahkan ! di sini
                      groupValue: controller.selectedAddressId.value,
                      onChanged: (value) {
                        if (value != null) controller.setDefaultAddress(value);
                      },
                    )),
                    title: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: address.fullName ?? '',
                                      style: context.titleMedium,
                                    ),
                                    TextSpan(
                                      text: ' | ${address.phone ?? ''}',
                                      style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey.shade600,
                                      ), 
                                    )
                                  ]
                                ),
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Get.defaultDialog(
                                    title: 'Delete Address?',
                                    middleText: 'Are you sure you want to delete this address?',
                                    textConfirm: 'Yes',
                                    textCancel: 'No',
                                    confirmTextColor: Colors.white,
                                    onConfirm: () {
                                      // Pastikan ID-nya ada di model InfoUser
                                      if (address.id != null) {
                                        controller.deactivateAddress(address.id!);
                                      }
                                      Get.back();
                                    },
                                  );
                                },
                                child: const Icon(Icons.delete, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Text('${address.address ?? ''}, '
                    '${address.kecamatan ??''}, ${address.kota??''}, '
                    '${address.provinsi?? ''}, ${address.kodepos ?? ''}'),
                    onTap: () {
                      Get.toNamed (AddAddress.TAG, arguments: address);
                    },
                  ),
                );
              },
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AddAddress.TAG);
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}