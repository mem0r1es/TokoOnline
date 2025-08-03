// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_web/controllers/profile_image_controller.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';

// void showEditProfileOptions({
//   required BuildContext context,
//   required void Function(String) onNameChange,
//   required void Function(String) onEmailChange,
//   required void Function(String) onPhoneChange,
//   void Function()? onChangeProfileImage,
  

//   // Tambahkan nilai awal
//   required String initialName,
//   required String initialEmail,
//   required String initialPhone,
// }) {
//   final isEditingName = false.obs;
//   final isEditingEmail = false.obs;
//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final ProfileImageController imageController = Get.find();

//   // Nilai yang ditampilkan di kanan
//   final currentName = initialName.obs;
//   final currentEmail = initialEmail.obs;
//   final currentPhone = initialPhone.obs;
//   final isChanged = false.obs; // ✅ tambahkan ini

//   Get.dialog(
//     Scaffold(
//       backgroundColor: const Color(0xFFF8F8F8),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         automaticallyImplyLeading: false, // ✅ ini penting
//         leading: Obx(() => IconButton(
//           icon: const Icon(Icons.close, color: Colors.black87),
//           onPressed: () {
//             if (isChanged.value) {
//               Get.defaultDialog(
//                 title: 'Keluar tanpa menyimpan?',
//                 middleText: 'Perubahan yang belum disimpan akan hilang.',
//                 textCancel: 'Lanjut Edit',
//                 textConfirm: 'Keluar',
//                 confirmTextColor: Colors.white,
//                 buttonColor: const Color.fromARGB(255, 0, 0, 0),
//                 onConfirm: () {
//                   Get.back(); // close dialog
//                   Get.back(); // close Edit Profile
//                 },
//               );
//             } else {
//               Get.back();
//             }
//           },
//         )),

//         title: Text(
//           "Edit Profil",
//           style: GoogleFonts.montserrat(
//             color: Colors.black87,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           Obx(() => isChanged.value
//               ? TextButton(
//                   onPressed: () {
//                     Get.back();
//                     Get.snackbar(
//                       "Berhasil",
//                       "Perubahan disimpan",
//                       backgroundColor: Colors.green,
//                       colorText: Colors.white,
//                     );
//                   },
//                   child: Text(
//                     "Selesai",
//                     style: GoogleFonts.montserrat(
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 )
//               : const SizedBox.shrink())
//         ],
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//         child: Obx(() => Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Foto profil
//                 GestureDetector(
//                 onTap: () => imageController.pickImageAndUpload(),
//                 child: Obx(() {
//                   return Column(
//                     children: [
//                       imageController.isLoading.value
//                           ? const CircularProgressIndicator()
//                           : CircleAvatar(
//                               radius: 50,
//                               backgroundColor: Colors.grey[300],
//                               backgroundImage: imageController.profileImageUrl.value.isNotEmpty
//                                   ? MemoryImage(
//                                       // kamu harus simpan hasil URL ke `Image.network` jika perlu cache otomatis,
//                                       // tapi karena ini dari Supabase, kita pakai NetworkImage
//                                       Uint8List(0), // placeholder, kita akan pakai NetworkImage di bawah
//                                     ) // tidak digunakan karena kita akan pakai NetworkImage
//                                   : null,
//                               child: imageController.profileImageUrl.value.isEmpty
//                                   ? const Icon(Icons.person, size: 40, color: Colors.white)
//                                   : null,
//                               foregroundImage: imageController.profileImageUrl.value.isNotEmpty
//                                   ? NetworkImage(imageController.profileImageUrl.value)
//                                   : null,
//                             ),
//                       const SizedBox(height: 8),
//                       Text(
//                         "Ubah Foto Profil",
//                         style: GoogleFonts.montserrat(
//                           color: Colors.blueAccent,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   );
//                 }),
//               ),

//                 // === NAMA ===
//                 if (!isEditingName.value) ...[
//                   ListTile(
//                     leading: const Icon(Icons.person, color: Colors.grey),
//                     title: Text(
//                       "Ubah Nama",
//                       style: GoogleFonts.montserrat(fontSize: 16),
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           currentName.value,
//                           style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black54),
//                         ),
//                         const SizedBox(width: 8),
//                         const Icon(Icons.arrow_forward_ios, size: 16),
//                       ],
//                     ),
//                     onTap: () {
//                       isEditingName.value = true;
//                       nameController.text = currentName.value;
//                     },
//                   ),
//                   const Divider(),
//                 ] else ...[
//                   Text("Nama Baru", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: nameController,
//                     decoration: const InputDecoration(
//                       hintText: "Masukkan nama baru",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           isEditingName.value = false;
//                           nameController.clear();
//                         },
//                         child: const Text("Batal"),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           final value = nameController.text.trim();
//                           if (value.isNotEmpty) {
//                             onNameChange(value);
//                             currentName.value = value;
//                             isEditingName.value = false;
//                             nameController.clear();
//                             isChanged.value = true;
//                           } else {
//                             Get.snackbar("Error", "Nama tidak boleh kosong");
//                           }
//                         },
//                         child: const Text("Simpan"),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                 ],

//                 // === EMAIL ===
//                 if (!isEditingEmail.value) ...[
//                   ListTile(
//                     leading: const Icon(Icons.email, color: Colors.grey),
//                     title: Text(
//                       "Ubah Email",
//                       style: GoogleFonts.montserrat(fontSize: 16),
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           currentEmail.value,
//                           style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black54),
//                         ),
//                         const SizedBox(width: 8),
//                         const Icon(Icons.arrow_forward_ios, size: 16),
//                       ],
//                     ),
//                     onTap: () {
//                       isEditingEmail.value = true;
//                       emailController.text = currentEmail.value;
//                     },
//                   ),
//                   const Divider(),
//                 ] else ...[
//                   Text("Email Baru", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: emailController,
//                     decoration: const InputDecoration(
//                       hintText: "Masukkan email baru",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           isEditingEmail.value = false;
//                           emailController.clear();
//                         },
//                         child: const Text("Batal"),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           final value = emailController.text.trim();
//                           if (value.isNotEmpty) {
//                             onEmailChange(value);
//                             currentEmail.value = value;
//                             isEditingEmail.value = false;
//                             emailController.clear();
//                             isChanged.value = true; // ✅ ditambahkan
//                           } else {
//                             Get.snackbar("Error", "Email tidak boleh kosong");
//                           }
//                         },
//                         child: const Text("Simpan"),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                 ],

//                 // === ALAMAT ===
//                 // if (!isEditingAddress.value) ...[
//                 //   ListTile(
//                 //     leading: const Icon(Icons.home, color: Colors.grey),
//                 //     title: Text("Ubah Alamat", style: GoogleFonts.montserrat(fontSize: 16)),
//                 //     trailing: Row(
//                 //       mainAxisSize: MainAxisSize.min,
//                 //       children: [
//                 //         Text(
//                 //           currentAddress.value.isEmpty ? '-' : currentAddress.value,
//                 //           style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black54),
//                 //         ),
//                 //         const SizedBox(width: 8),
//                 //         const Icon(Icons.arrow_forward_ios, size: 16),
//                 //       ],
//                 //     ),
//                 //     onTap: () {
//                 //       isEditingAddress.value = true;
//                 //       addressControllerField.text = currentAddress.value;
//                 //     },
//                 //   ),
//                 //   const Divider(),
//                 // ] else ...[
//                 //   Text("Alamat Baru", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
//                 //   const SizedBox(height: 8),
//                 //   TextField(
//                 //     controller: addressControllerField,
//                 //     decoration: const InputDecoration(
//                 //       hintText: "Masukkan alamat baru",
//                 //       border: OutlineInputBorder(),
//                 //     ),
//                 //     maxLines: 2,
//                 //   ),
//                 //   const SizedBox(height: 10),
//                 //   Row(
//                 //     children: [
//                 //       TextButton(
//                 //         onPressed: () {
//                 //           isEditingAddress.value = false;
//                 //           addressControllerField.clear();
//                 //         },
//                 //         child: const Text("Batal"),
//                 //       ),
//                 //       ElevatedButton(
//                 //         onPressed: () async {
//                 //           final value = addressControllerField.text.trim();
//                 //           if (value.isNotEmpty && addressController.selectedAddressUser.value != null) {
//                 //             final updated = addressController.selectedAddressUser.value!.copyWith(address: value);
//                 //             await addressController.saveAddress(updated);
//                 //             currentAddress.value = value;
//                 //             isEditingAddress.value = false;
//                 //             addressControllerField.clear();
//                 //           } else {
//                 //             Get.snackbar("Error", "Alamat tidak boleh kosong");
//                 //           }
//                 //         },
//                 //         child: const Text("Simpan"),
//                 //       ),
//                 //     ],
//                 //   ),
//                 //   const SizedBox(height: 20),
//                 // ],


//                 // === NOMOR HP ===
//                 ListTile(
//                   leading: const Icon(Icons.phone, color: Colors.grey),
//                   title: Text(
//                     "Ubah Nomor HP",
//                     style: GoogleFonts.montserrat(fontSize: 16),
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         currentPhone.value,
//                         style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black54),
//                       ),
//                       const SizedBox(width: 8),
//                       const Icon(Icons.arrow_forward_ios, size: 16),
//                     ],
//                   ),
//                   onTap: () {
//                     Get.snackbar('Coming Soon', 'Fitur ganti nomor HP akan tersedia di versi selanjutnya');
//                     isChanged.value = true;
//                   },
//                 ),
//               ],
//             )),
//       ),
//     ),
//     barrierDismissible: false,
//   );
  
// }



