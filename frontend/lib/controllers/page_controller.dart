import 'package:get/get.dart';
import '../dashboard/header/shop/product_model.dart';
// import '../widgets/product_model.dart';
// import 'package:math_'

class PageControllerX extends GetxController {
  var selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }
}

class CartController1 extends GetxController {
  var cartItems = <Product>[].obs;

  void addToCart(Product product) {
    // Jika produk sudah ada, tambah qty
    final index = cartItems.indexWhere((p) => p.title == product.title);
    if (index >= 0) {
      cartItems[index].quantity++;
      cartItems.refresh(); // ← supaya UI update
    } else {
      cartItems.add(product);
    }
  }
}

// class favorite extends GetxController {
//   var cartItem = <Product>[].obs;
//   // var cartItem.value = <Product>
//   void favchoice (Product product){
//     cartItem.value = cartItem();
//   } 
//   void favorites (){
//     if (cartItem.contains(cartItem.value)) {
//       cartItem.remove(cartItem.value);
//     } else {
//       cartItem.value;
//     }
//   }
// }

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

class UserController extends GetxController {
  var FirstName = ''.obs;

  void setName (String value) {
    FirstName.value = value;
  }
}