
import 'package:flutter_web/models/product_model.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  var query = ''.obs;
  var results = <Product>[].obs;

  void setResults(String q, List<Product> r) {
    query.value = q;
    results.value = r;
  }

  void clear() {
    query.value = '';
    results.clear();
  }
}
