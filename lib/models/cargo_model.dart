class CargoModel {
  final int id;
  final String name;
  final int harga;
  final int kategoriId;
  final String kategoriName;

  CargoModel({
    required this.id,
    required this.name,
    required this.harga,
    required this.kategoriId,
    required this.kategoriName,
  });

  factory CargoModel.fromDatabase(Map<String, dynamic> json) {
    final kategori = json['kategori_id'] ?? {};
    return CargoModel(
      id: json['id'],
      name: json['name'],
      harga: json['harga'],
      kategoriId: kategori['id'],
      kategoriName: kategori['kategori'],
    );
  }
}
