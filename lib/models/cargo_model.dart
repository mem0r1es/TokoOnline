class CargoModel {
  final String? id;
  final String kategori;
  final String name;
  final String? kategoriId;

  CargoModel({
    this.id,
    required this.kategori,
    required this.name,
    required this.kategoriId,
  });

  factory CargoModel.fromDatabase(Map<String, dynamic> data) {
    final kategoriData = data['kategori_id'];

    return CargoModel(
      id: data['id']?.toString(),
      name: data['name'] ?? '',
      kategori: kategoriData['kategori'] ?? 'Unknown',
      kategoriId: kategoriData?['id']?.toString(),
    );
  }

  factory CargoModel.fromJson(Map<String, dynamic> json) => CargoModel(
    id: json['id']?.toString(),
    kategori: json['kategori'] ?? 'Unknown',
    name: json['name'] ?? '',
    kategoriId: json['kategori_id']?.toString(),
  );

  Map<String, dynamic> toDatabase(){
    return {
      'kategori':kategori,
      'kategori_id':kategoriId,
      'name':name,
    };
  }

  Map<String, dynamic> toJson() {
    return{
      'id' : id,
      'kategori' : kategori,
      'kategori_id' : kategoriId,
      'name' : name,
    };
  }
}