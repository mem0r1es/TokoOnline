import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ScrollControllerManager extends GetxService {
  final _scrollOffsets = <String, double>{}.obs;
  final _storage = GetStorage(); // ✅ storage lokal browser

  void saveOffset(String key, double offset) {
    _scrollOffsets[key] = offset;
    _storage.write('scroll_$key', offset); // simpan offset ke storage
  }

  double getOffset(String key) {
    final stored = _storage.read('scroll_$key');
    if (stored != null) return stored;
    return _scrollOffsets[key] ?? 0.0;
  }

  void clearOffset(String key) {
    _scrollOffsets.remove(key);
    _storage.remove('scroll_$key');
  }
}
