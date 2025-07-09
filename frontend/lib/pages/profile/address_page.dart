import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/info_user.dart';
import '../../pages/profile/add_address.dart';
import '../../controllers/address_controller.dart';

class AddressPage extends StatefulWidget {

  AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  // final AddressController addressController = Get.put(AddressController());
  final AddressController addressController = Get.find<AddressController>();

  String? _selectedAddressId;

//   @override
//   void initState() {
//   super.initState();
//   // final userEmail = authController.getUserEmail()?? '';
//   _emailController.text = authController.getUserEmail() ?? '';
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        // shadowColor: Colors.black,
        title: const Text(
          'My Address',
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
          if (addressController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (addressController.addresses.isEmpty) {
            return const Center(
              child: Text(
                "No addresses added yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: addressController.addresses.length,
            itemBuilder: (context, index) {
              final address = addressController.addresses[index];
              final addressId = address.id ?? index.toString();
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  tileColor: Color(0xFFFFF3E3).withOpacity(0.9),
                  // leading: Radio<String>(
                  //   value: addressId,
                  //   groupValue: _selectedAddressId,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _selectedAddressId = value;
                  //     });
                  //   },
                  // ),
                  title: Row(
                    children: [
                      Expanded(child: Text(address.fullName ?? '')),
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
                                  addressController.deactivateAddress(address.id!);
                                }
                                Get.back();
                              },
                            );
                          },
                          child: const Icon(Icons.delete, color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                  subtitle: Text('${address.address}\n${address.phone ?? ''}'),
                  onTap: () {
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
          Get.to(() => const AddAddress());
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
