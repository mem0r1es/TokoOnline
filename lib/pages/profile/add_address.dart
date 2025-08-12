import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/address_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/info_user.dart';
import '../../services/address_service.dart';
import '../../services/address_service.dart';

class AddAddress extends StatefulWidget {
  static final String TAG = '/add-address';
  final InfoUser? existingAddress;

  const AddAddress({super.key, this.existingAddress});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _kodepos = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _addressController = TextEditingController();
  final _detail = TextEditingController();
  
  final authController = Get.find<AuthController>();
  final addressController = Get.find<AddressController>();

  String? _selectedProvinceId;
  String? _selectedRegencyId;
  
  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> regencies = [];
  
  bool isLoadingProvinces = true;
  bool isLoadingRegencies = false;

  bool get isEditing => widget.existingAddress != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      provinces = await addressController.fetchProvinces();
      
      if (widget.existingAddress != null) {
        _nameController.text = widget.existingAddress!.fullName ?? '';
        _phoneController.text = widget.existingAddress!.phone ?? '';
        _kodepos.text = widget.existingAddress!.kodepos ?? '';
        _kecamatanController.text = widget.existingAddress!.kecamatan ?? '';
        _addressController.text = widget.existingAddress!.address ?? '';
        _detail.text = widget.existingAddress!.detail ?? '';
        
        if (widget.existingAddress!.provinsiId != null) {
          _selectedProvinceId = widget.existingAddress!.provinsiId;
          regencies = await addressController.fetchRegencies(_selectedProvinceId!);
          
          if (widget.existingAddress!.kotaId != null) {
            _selectedRegencyId = widget.existingAddress!.kotaId;
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data: ${e.toString()}");
    } finally {
      setState(() {
        isLoadingProvinces = false;
      });
    }
  }

  Future<void> _loadRegencies(String provinceId) async {
    setState(() {
      isLoadingRegencies = true;
      _selectedRegencyId = null;
      regencies = [];
    });

    try {
      regencies = await addressController.fetchRegencies(provinceId);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat kabupaten/kota");
    } finally {
      setState(() {
        isLoadingRegencies = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          isEditing ? "Edit Alamat" : "Tambah Alamat",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title("Detail Alamat"),
                  const SizedBox(height: 20),
                  _formInput("Nama Lengkap", controller: _nameController),
                  const SizedBox(height: 16),
                  _formInput("Nomor Telepon", controller: _phoneController),
                  const SizedBox(height: 16),
                  
                  // Province Dropdown - Revisi utama di sini
                  _dropdownInput(
                    "Provinsi",
                    value: _selectedProvinceId,
                    items: isLoadingProvinces
                        ? [const DropdownMenuItem(value: null, child: Text("Memuat..."))]
                        : provinces.map((province) {
                            final provinceId = province['id'].toString();
                            return DropdownMenuItem(
                              value: provinceId,
                              child: Text(province['name']),
                            );
                          }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProvinceId = value;
                        _selectedRegencyId = null;
                        regencies = [];
                        _kecamatanController.clear();
                      });
                      if (value != null) {
                        _loadRegencies(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Regency Dropdown - Revisi utama di sini
                  _dropdownInput(
                    _selectedProvinceId == null ? "Pilih provinsi terlebih dahulu" : "Kabupaten/Kota",
                    value: _selectedRegencyId,
                    items: isLoadingRegencies
                        ? [const DropdownMenuItem(value: null, child: Text("Memuat..."))]
                        : regencies.map((regency) {
                            final regencyId = regency['id'].toString();
                            return DropdownMenuItem(
                              value: regencyId,
                              child: Text("${regency['type']} ${regency['name']}"),
                            );
                          }).toList(),
                    onChanged: _selectedProvinceId == null 
                        ? null 
                        : (value) {
                            setState(() {
                              _selectedRegencyId = value;
                              _kecamatanController.clear();
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  
                  _formInput("Kecamatan", controller: _kecamatanController),
                  const SizedBox(height: 16),
                  
                  _formInput("Kode Pos", controller: _kodepos),
                  const SizedBox(height: 16),
                  _formInput("Alamat Lengkap", controller: _addressController),
                  const SizedBox(height: 16),
                  _formInput("Detail Lainnya (Opsional)", controller: _detail),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSaveOrUpdate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        isEditing ? "PERBARUI ALAMAT" : "SIMPAN ALAMAT",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      );

  Widget _formInput(String label, {TextEditingController? controller, bool readOnly = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              fillColor: readOnly ? Colors.grey[100] : Colors.white,
              filled: true,
            ),
          ),
        ],
      );

  Widget _dropdownInput(
    String label, {
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: onChanged == null ? Colors.grey[100] : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: items.any((item) => item.value == value) ? value : null,
              items: items,
              onChanged: onChanged,
              hint: Text(
                onChanged == null ? label : "Pilih $label",
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
              icon: const Icon(Icons.arrow_drop_down),
              borderRadius: BorderRadius.circular(8),
              dropdownColor: Colors.white,
              elevation: 1,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSaveOrUpdate() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _selectedProvinceId == null ||
        _selectedRegencyId == null ||
        _kecamatanController.text.isEmpty) {
      Get.snackbar(
        "Perhatian",
        "Harap lengkapi semua data yang diperlukan",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final province = provinces.firstWhere(
        (p) => p['id'].toString() == _selectedProvinceId!);
      final regency = regencies.firstWhere(
        (r) => r['id'].toString() == _selectedRegencyId!);

      final info = InfoUser(
        id: widget.existingAddress?.id,
        fullName: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        provinsi: province['name'],
        provinsiId: _selectedProvinceId!,
        kota: "${regency['type']} ${regency['name']}",
        kotaId: _selectedRegencyId!,
        kecamatan: _kecamatanController.text,
        kodepos: _kodepos.text,
        detail: _detail.text,
        email: authController.getUserEmail() ?? '',
        timestamp: DateTime.now(),
      );

      final addressService = AddressService();
      await addressService.saveAddress(info);
      await addressController.fetchAddresses();

      Get.back();
      Get.snackbar(
        "Success",
        isEditing ? "Alamat berhasil diperbarui" : "Alamat berhasil ditambahkan",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal menyimpan alamat: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}