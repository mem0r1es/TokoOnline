import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/checkout_controller.dart';
import 'package:flutter_web/extensions/extension.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/info_user.dart';
import '../../pages/profile/add_address.dart';
import '../../controllers/address_controller.dart';

class AddressPage extends GetView<AddressController> {
  static final String TAG = '/address';

  AddressPage({super.key});

  final checkoutController = Get.find<CheckoutController>();


  // final AddressController addressController = Get.put(AddressController());
  // final AddressController addressController = Get.find<AddressController>();

  String? _selectedAddressId;

//   @override
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
      body: Padding(
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
              final defaultAddressId = controller.addresses.firstWhereOrNull((a) => a.isDefault == true)?.id;
              final address = controller.addresses[index];
              // final addressId = address.id ?? index.toString();
              if (address.id == null) return SizedBox.shrink();
              final addressId = address.id!;
              


              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  tileColor: Color(0xFFFFF3E3).withOpacity(0.9),
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
                                //     style: GoogleFonts.montserrat(
                                //     fontSize: 20,
                                //     fontWeight: FontWeight.bold,
                                // ), 
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
                            // Text(
                            //   address.fullName ?? '', 
                            //   style: GoogleFonts.montserrat(
                            //     fontSize: 20,
                            //     fontWeight: FontWeight.bold,
                            //   ), 
                            // ), 
                            // ),
                            // Text(
                            //   address.phone ?? '',
                            //   style: GoogleFonts.montserrat(
                            //     fontSize: 15,
                            //     fontWeight: FontWeight.normal,
                            //     color: Colors.grey.shade300,
                            //   ),
                            // ),
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
  //                         if (address.isDefault == true)
  // Chip(
  //   label: const Text('Default'),
  //   backgroundColor: Colors.orange.shade100,
  // ),
                        ],
                        
                      ),
                    ],
                  ),
                  
                  subtitle: Text('${address.address ?? ''}, '
                  '${address.kecamatan ??''}, ${address.kota??''}, '
                  '${address.provinsi?? ''}, ${address.kodepos ?? ''}'),
                  onTap: () {
                    // Get.toNamed(AddAddress.TAG);
                    Get.put(CheckoutController());
                    Get.to(() => AddAddress(existingAddress: address));
                      // Optional: Hapus atau nonaktifkan
                      // Get.snackbar('comingsoon',
                      //   'This feature is coming soon!',
                      //   snackPosition: SnackPosition.BOTTOM,
                      //   duration: const Duration(seconds: 2),
                      // );
                    },
                  ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AddAddress.TAG);
          // Get.to(() => const AddAddress());
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget _radioOption(String label) {
//     return Row(
//       children: [
//         Radio <String>(
//           value: label, 
//           groupValue: _selectedPayment, 
//           onChanged: (String? value) {
//             setState(() {
//               _selectedPayment = value;
//             });
//           }),
//         Text(label, style: GoogleFonts.poppins(fontSize: 14)),
//       ],
//     );
//   }
