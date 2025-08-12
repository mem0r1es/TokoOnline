import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/product_model.dart';

class FavoriteController extends GetxController {
  final RxList<Product> _favorites = <Product>[].obs;
  final _storage = GetStorage();
  final authController = Get.find<AuthController>();

  List<Product> get favorites => _favorites;

  @override
  void onInit() {
    super.onInit();
    loadFavoritesFromStorage();
  }

  void toggleFavorite(Product product) {
    if (_favorites.any((p) => p.id == product.id)) {
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      _favorites.add(product);
    }
    saveFavoritesToStorage();
  }

  bool isFavorite(Product product) {
    return _favorites.any((p) => p.id == product.id);
  }

  void saveFavoritesToStorage() {
    final userEmail = authController.getUserEmail;
    final favJson = _favorites.map((e) => e.toJson()).toList();
    _storage.write('favorites_$userEmail', favJson);
  }

  void loadFavoritesFromStorage() {
    final userEmail = authController.getUserEmail;
    final List? favJson = _storage.read<List>('favorites_$userEmail');
    if (favJson != null) {
      _favorites.assignAll(
        favJson.map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
    }
  }

  void clearFavorites() {
    _favorites.clear();
    final userEmail = authController.getUserEmail;
    _storage.remove('favorites_$userEmail');
  }
}
