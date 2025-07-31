
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/controllers/favorite_controller.dart';
import 'package:flutter_web/controllers/profile_image_controller.dart';
import 'package:flutter_web/pages/auth/auth_dialog.dart';
import 'package:flutter_web/pages/favorite/favorite_page.dart';
import 'package:flutter_web/pages/history/history.dart';
import 'package:flutter_web/pages/profile/address_page.dart';
import 'package:flutter_web/pages/profile/edit_profile_option.dart';
import 'package:flutter_web/pages/shop/shops.dart';
import 'package:flutter_web/pages/shoppingcart/cart.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends GetView<AuthController> {
  static final String TAG = '/profile';
  
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final CartService cartService = Get.find();
    

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
          shadowColor: Colors.transparent,
          title: const Text('Profile Page',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Obx(
                  () => GestureDetector(
                    onTap: () => _handleCartClick(controller, cartService),
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                          if (cartService.itemCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${cartService.itemCount}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ProfilePic(),
                  ),
                  const SizedBox(width: 30),
                  Expanded( // Gunakan Expanded agar mengambil sisa ruang horizontal
                    child: Obx(() { // Gunakan Obx untuk reaktif terhadap isLoggedIn
                      if (controller.isLoggedIn.value) {
                        // Jika sudah login, tampilkan info pengguna
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang,',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                            ),
                            Text(
                              controller.getUserName() ?? 'Pengguna', // Ambil name dari controller
                              style: GoogleFonts.montserrat(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (controller.userProfile.value?.phone?.isNotEmpty == true)
                              Text(
                                'Nomor HP: ${controller.userProfile.value!.phone!}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),


                             ElevatedButton.icon(
                              onPressed: () {
                                showEditProfileOptions(
                                  context: context,
                                  onNameChange: (value) => controller.updateName(value),
                                  onEmailChange: (value) => controller.updateEmail(value),
                                  onPhoneChange: (value) {
                                    Get.snackbar('Coming Soon', 'Fitur ganti nomor HP akan tersedia di versi selanjutnya');
                                  },
                                );
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: Text('Edit Profil', style: GoogleFonts.poppins()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple[100],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                            // Tambahkan detail profil lain di sini jika ada (nama lengkap, nomor telepon, dll.)
                            // Misalnya:
                            // Text('Nama Lengkap: ${controller.userProfile.fullName}', style: GoogleFonts.poppins()),
                            // Text('Telepon: ${controller.userProfile.phoneNumber}', style: GoogleFonts.poppins()),
                          ],
                        );
                      } else {
                        // Jika belum login, tampilkan tombol Login/Register
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align tombol ke kiri
                          children: [
                            Text(
                              'Anda belum login.',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                // Tombol Login
                                GestureDetector(
                                  onTap: () {
                                    Get.dialog(AuthDialog()); // Tampilkan dialog login
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.purple[50], // Warna yang lebih standar untuk login
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: GoogleFonts.poppins(color: Colors.purple[500], fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10), // Spasi antar tombol
          
                                // Tombol Register
                                GestureDetector(
                                  onTap: () {
                                    // Navigasi ke halaman register atau tampilkan dialog register
                                    // Misalnya: Get.toNamed(RegisterPage.TAG);
                                    Get.snackbar('Info', 'Halaman Register Segera Hadir!');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300], // Warna untuk register
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(color: Colors.grey[500]!)
                                    ),
                                    child: Text(
                                      'Register',
                                      style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              //   ],
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top:10.0, bottom: 10.0),
                child: Text('Akun Saya',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(25)
                ),
                leading: const Icon(Icons.location_on),
                tileColor: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
                // shape: Border.all(color: Colors.white),
                title: const Text(
                  'Alamat Saya',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () {
                  final AuthController authController = Get.find<AuthController>();
                  if (!authController.isLoggedIn.value) { // Jika belum login
                    Get.dialog(
                      AuthDialog(), // Tampilkan dialog login Anda
                      // barrierDismissible: false, // Mungkin Anda ingin pengguna tidak bisa menutupnya tanpa aksi
                    );
                    // Penting: Jangan ubah selectedIndex jika belum login
                    // Agar BottomNavigationBar tetap di tab sebelumnya atau tab Home
                    return; // Hentikan eksekusi lebih lanjut
                  }
                  // Aksi ketika alamat saya ditekan
                  Get.toNamed(AddressPage.TAG);
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(25)
                ),
                leading: const Icon(Icons.favorite),
                tileColor: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
                // shape: Border.all(color: Colors.white),
                title: const Text(
                  'Favorite Saya',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () {
                  // final AuthController authController = Get.find<AuthController>();
                  // if (!authController.isLoggedIn.value) { // Jika belum login
                  //   Get.dialog(
                  //     AuthDialog(), 
                  //     // barrierDismissible: false, // Jika ingin pengguna tidak bisa menutupnya tanpa aksi
                  //   );
                  //   return; // Hentikan eksekusi lebih lanjut
                  // }
                  // Aksi ketika alamat saya ditekan
                  Get.toNamed(FavoritePage.TAG);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top:10.0, bottom: 10.0),
                child: Text('Pesanan Saya',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(25)
                ),
                leading: const Icon(Icons.shopping_bag),
                tileColor: Color.fromARGB(255, 243, 229, 242).withOpacity(0.9),
                // shape: Border.all(color: Colors.white),
                title: const Text(
                  'Riwayat Pesanan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () {
                  final AuthController authController = Get.find<AuthController>();
                  if (!authController.isLoggedIn.value) { // Jika belum login
                    Get.dialog(
                      AuthDialog(), 
                      // barrierDismissible: false, // Jika ingin pengguna tidak bisa menutupnya tanpa aksi
                    );
                    return; // Hentikan eksekusi lebih lanjut
                  }
                  // Aksi ketika alamat saya ditekan
                  Get.toNamed(ProductInfoPage.TAG);
                },
              ),
              const SizedBox(height: 30),
          
              // Tombol Logout (hanya muncul jika sudah login)
              Obx(() => controller.isLoggedIn.value
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back(); // Tutup halaman profil
                          final cartService = Get.find<CartService>();
                          cartService.clearCart();
                          final favController = Get.find<FavoriteController>();
                          favController.clearFavorites();
                          controller.logout(); // Panggil method logout dari AuthController
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: Text(
                          'Logout',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        )
    );
  }
}

void _handleCartClick(authService, CartService cartService) {
    if (authService.isLoggedIn.value) {
      if (cartService.isNotEmpty) {
        Get.toNamed(CartPages.TAG);
      } else {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Cart Empty', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Your cart is empty. Add some products to get started!',
                  style: GoogleFonts.poppins(fontSize: 14), textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text('OK')),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.to(ShopsPage());
                },
                child: Text('Shop Now'),
              ),
            ],
          ),
        );
      }
    } else {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Login Required', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('Please login to access your shopping cart and place orders.',
                style: GoogleFonts.poppins(fontSize: 14), textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _showAuthDialog();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: Text('Login', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _showAuthDialog() {
    Get.dialog(AuthDialog());
  }

// You can replace the SVG string below with your own camera icon SVG data.
const String cameraIcon = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 17C14.7614 17 17 14.7614 17 12C17 9.23858 14.7614 7 12 7C9.23858 7 7 9.23858 7 12C7 14.7614 9.23858 17 12 17Z" stroke="#000" stroke-width="2"/>
  <path d="M20 21H4C2.89543 21 2 20.1046 2 19V7C2 5.89543 2.89543 5 4 5H7L9 3H15L17 5H20C21.1046 5 22 5.89543 22 7V19C22 20.1046 21.1046 21 20 21Z" stroke="#000" stroke-width="2"/>
</svg>
''';

class ProfilePic extends StatelessWidget {
  ProfilePic({super.key});

  final ProfileImageController controller =
      Get.put(ProfileImageController(), permanent: true); 

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final imageProvider = controller.profileImageUrl.value.isNotEmpty
          ? NetworkImage(controller.profileImageUrl.value)
          : const AssetImage('assets/default_profile.png') as ImageProvider;

      return SizedBox(
        height: 115,
        width: 115,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              backgroundImage: imageProvider,
              backgroundColor: Colors.grey[200],
            ),
            if (controller.isLoading.value)
              const Center(child: CircularProgressIndicator()),
            Positioned(
              right: -10,
              bottom: 0,
              child: SizedBox(
                height: 46,
                width: 46,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFF5F6F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: const BorderSide(color: Colors.white),
                    ),
                  ),
                  onPressed: () async {
                    Uint8List? imageBytes;

                    if (kIsWeb) {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        withData: true,
                      );
                      if (result != null && result.files.first.bytes != null) {
                        imageBytes = result.files.first.bytes!;
                      }
                    } else {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        imageBytes = await pickedFile.readAsBytes();
                      }
                    }

                    if (imageBytes != null) {
                      await controller.updateProfileImage(imageBytes);
                      if (Get.isSnackbarOpen) {
                        await Future.delayed(const Duration(seconds: 2));
                      }
                    } else {
                      Get.snackbar(
                        'Batal',
                        'Tidak ada gambar yang dipilih',
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                  child: SvgPicture.string(cameraIcon),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

