import 'package:get/get.dart';
import '../models/product_model.dart';

class FavoriteController extends GetxController {
  final RxList<Product> _favorites = <Product>[].obs;

  List<Product> get favorites => _favorites;

  void toggleFavorite(Product product) {
    if (_favorites.contains(product)) {
      _favorites.remove(product);
    } else {
      _favorites.add(product);
    }
  }

  bool isFavorite(Product product) {
    return _favorites.contains(product);
  }
}