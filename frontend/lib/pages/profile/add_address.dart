import 'package:flutter/material.dart';
import 'package:flutter_web/services/address_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/address_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/info_user.dart';
import '../../services/cart_service.dart';

class AddAddress extends StatefulWidget {
  static final String TAG = '/add-address';
  final InfoUser? existingAddress;  // Untuk edit

  const AddAddress({Key? key, this.existingAddress}) : super(key: key);

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  // final _firstNameController = TextEditingController();
  // final _lastNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provinsi = TextEditingController();
  final _kota = TextEditingController();
  final _kecamatan = TextEditingController();
  final _kodepos = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _detail = TextEditingController();
  final authController = Get.find<AuthController>();
  final cartService = Get.find<CartService>();
  final addressController = Get.find<AddressController>();

  bool get isEditing => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();

    final userEmail = authController.getUserEmail() ?? '';
    _emailController.text = userEmail;

    if (widget.existingAddress != null) {
      final nameParts = widget.existingAddress!.fullName?.split(' ') ?? [];
      // _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
      // _lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      _nameController.text = widget.existingAddress!.fullName ?? '';
      _addressController.text = widget.existingAddress!.address ?? '';
      _phoneController.text = widget.existingAddress!.phone ?? '';
      _provinsi.text = widget.existingAddress!.provinsi ?? '';
      _kota.text = widget.existingAddress!.kota ?? '';
      _kecamatan.text = widget.existingAddress!.kecamatan ?? '';
      _kodepos.text = widget.existingAddress!.kodepos ?? '';
      _detail.text = widget.existingAddress!.detail ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          isEditing ? "Edit Address" : "Add Address",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title("Alamat Detil"),
                  const SizedBox(height: 20),
                  _formInput("Nama Lengkap", controller: _nameController),
                  const SizedBox(height: 16),
                  _formInput("Nomor Telepon", controller: _phoneController),
                  const SizedBox(height: 16),
                  _formInput("Provinsi", controller: _provinsi),
                  const SizedBox(height: 16),
                  _formInput("Kota", controller: _kota),
                  const SizedBox(height: 16),
                  _formInput("Kecamatan", controller: _kecamatan),
                  const SizedBox(height: 16),
                  _formInput("Kode Pos", controller: _kodepos),
                  const SizedBox(height: 16),
                  // _formInput("Country / Region"),
                  // const SizedBox(height: 16),
                  _formInput("Alamat Lengkap", controller: _addressController),
                  const SizedBox(height: 16),
                  // _formInput("Email Address", controller: _emailController, readOnly: true),
                  // const SizedBox(height: 16),
                  _formInput("Detail Lainnya", controller: _detail),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _handleSaveOrUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 249, 248, 248),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    ),
                    child: Text(isEditing ? "Update" : "Submit", style: GoogleFonts.poppins(fontSize: 16)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String text) => Text(
        text,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
      );

  Widget _formInput(String label, {TextEditingController? controller, bool readOnly = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              fillColor: readOnly ? Colors.grey[200] : Colors.white,
              filled: true,
            ),
          ),
        ],
      );

  // Widget _formRow(String leftLabel, String rightLabel) => Row(
  //       children: [
  //         Expanded(child: _formInput(leftLabel, controller: _firstNameController)),
  //         const SizedBox(width: 16),
  //         Expanded(child: _formInput(rightLabel, controller: _lastNameController)),
  //       ],
  //     );

  Future<void> _handleSaveOrUpdate() async {
    if (
      // _firstNameController.text.isEmpty ||
      //   _lastNameController.text.isEmpty ||
      
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    final info = InfoUser(
      id: widget.existingAddress?.id,  // Penting untuk update Supabase
      timestamp: DateTime.now(),
      // fullName: '${_firstNameController.text} ${_lastNameController.text}',
      fullName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      provinsi: _provinsi.text,
      kota: _kota.text,
      kecamatan: _kecamatan.text,
      kodepos: _kodepos.text,
      detail: _detail.text,
    );

    // await cartService.saveAddressToSupabase(info);
    final addressService = AddressService();
    await addressService.saveAddress(info);
    await addressController.fetchAddresses();

    Get.back();
    Get.snackbar(
      "Success",
      isEditing ? "Address updated successfully" : "Address added successfully",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
