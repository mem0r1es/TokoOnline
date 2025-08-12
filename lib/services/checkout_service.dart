import 'package:flutter_web/models/cargo_model.dart';
import 'package:flutter_web/models/info_user.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/order_history_item.dart';
// import '../models/info_user.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class CheckoutService extends GetxService {
  var orderHistory = <OrderHistoryItem>[].obs;
  final _uuid = const Uuid();

  String? userId;

  @override
  void onInit() {
    super.onInit();
    final email = Supabase.instance.client.auth.currentUser?.email;
    userId = Supabase.instance.client.auth.currentUser?.id;
    if (email != null) {
      loadOrderHistoryFromSupabase(email);
    }
  }

  Future<void> saveOrderToSupabase(OrderHistoryItem order, String paymentMethod, CargoModel cargo)async {
    try {
      final orderId = _uuid.v4();
      print('🟢 Saving order with ID: $orderId');

      final info = order.infoUser.first;
      final timestamp = order.timestamp.toIso8601String();
      final fullAddress = '${info.address}, '
      '${info.kecamatan}, '
      '${info.kota}, '
      '${info.provinsi}, '
      '${info.kodepos} ';

        // Hitung total produk + total bayar
        final totalProduk = order.items.fold<int>(0, (sum, item) => sum + item.totalPrice.toInt());
        final ongkir = cargo.harga.toInt(); 
        final totalBayar = totalProduk + ongkir;

        final cargoExist = await supabase
            .from('cargo_options')
            .select()
            .eq('id', cargo.id)
            .maybeSingle();

        if (cargoExist == null) {
          throw Exception('🚨 Cargo ID ${cargo.id} tidak ditemukan di database!');
        }

      // Simpan setiap item sebagai 1 row
      for (final item in order.items) {
        print('🟢 Inserting order: ${{
          'order_id': orderId,
          'timestamp': timestamp,
          'full_name': info.fullName,
          'email': info.email,
          'phone': info.phone,
          'address': fullAddress,
          'payment_method': paymentMethod,
          'items': item.name,
          'item_quantity': item.quantity,
          'total_price': item.totalPrice,
          'imageUrl': item.imageUrl,  // pastikan imageUrl bukan null
          'seller': item.seller,
          'cargo_name': cargo.name,
          'cargo_category': cargo.kategoriId,
          'cargo_id': cargo.id,  // new
          'total_produk': totalProduk,  // new
          'ongkir': ongkir,  // new
          'total_bayar': totalBayar,  // new
          'status': 'menunggu konfirmasi',  // default awal
          'updated_at': DateTime.now().toIso8601String(),
          'estimated_arrival': order.estimatedArrival?.toIso8601String(),
        }}');

        print('📦 cargo.name = ${cargo.name}');
        print('📦 cargo.kategori = ${cargo.kategoriId}');

        await supabase.from('order_history').insert({
          'order_id': orderId,
          'timestamp': timestamp,
          'full_name': info.fullName,
          'email': info.email,
          'phone': info.phone,
          'address': fullAddress,
          'payment_method': paymentMethod,
          'items': item.name,
          'item_quantity': item.quantity,
          'total_price': item.totalPrice, // total untuk item ini aja
          'imageUrl': item.imageUrl,
          'seller': item.seller,
          'cargo_name': order.cargoName,
          'cargo_category': order.cargoCategory,  // Ini sekarang string seperti "Hemat Kargo"        
          'cargo_id': cargo.id, // new
          'total_produk': totalProduk, // new
          'ongkir': ongkir, // new
          'total_bayar': totalBayar, // new
          // ✅ Tracking produk otomatis
          'status': 'menunggu konfirmasi',  // default awal
          'updated_at': DateTime.now().toIso8601String(),
          'estimated_arrival': order.estimatedArrival?.toIso8601String(),
        });

        // Kurangi stok produk
        final response = await supabase
          .from('products')
          .select('stock_quantity')
          .eq('id', item.id)
          .single();

        final currentStock = response['stock_quantity'] ?? 0;
        final newStock = currentStock - item.quantity;

        await supabase
          .from('products')
          .update({'stock_quantity': newStock})
          .eq('id', item.id);

      }

      print('✅ Order with ID $orderId save successfully!');
    } catch (e) {
      print('❌ Error saving order: $e');
    }
  }

  Future<void> loadOrderHistoryFromSupabase(String email) async {
    print("Load order history untuk: $email");

    try {
      final response = await supabase
          .from('order_history')
          .select()
          .eq('email', email)
          .order('timestamp');

      orderHistory.clear();

      // Grup by timestamp
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final row in response) {
        final key = row['timestamp'];
        grouped.putIfAbsent(key, () => []).add(row);
      }

      for (final entry in grouped.entries) {
        final items = entry.value.map((item) => CartItem(
          id: item['items'],
          name: item['items'],
          quantity: item['item_quantity'],
          price: (item['total_price'] ?? 0).toDouble(),
          imageUrl: item['imageUrl'] ?? '',
          seller: item['seller'] ?? 'Toko Tidak Diketahui',
        )).toList();

        // Group by seller
        final sellerGroups = <String, List<CartItem>>{};
        for (final item in items) {
          sellerGroups.putIfAbsent(item.seller, () => []).add(item);
        }

        for (final sellerEntry in sellerGroups.entries) {
          final sellerItems = sellerEntry.value;

          final infoUser = InfoUser(
            fullName: entry.value.first['full_name'],
            email: entry.value.first['email'],
            phone: entry.value.first['phone'],
            address: entry.value.first['address'],
            timestamp: DateTime.tryParse(entry.key), provinsiId: '', kecamatanId: '', kotaId: '',
          );

          orderHistory.add(OrderHistoryItem(
            timestamp: DateTime.parse(entry.key),
            paymentMethod: entry.value.first['payment_method'] ?? '',
            infoUser: [infoUser],
            items: sellerItems,
            id: entry.value.first['order_id'], // ditambahkan
            cargoCategory: entry.value.first['cargo_category'], 
            cargoName: entry.value.first['cargo_name'], 
            status: entry.value.first['status'] ?? 'menunggu konfirmasi',
            estimatedArrival: entry.value.first['estimated_arrival'] != null
                ? DateTime.tryParse(entry.value.first['estimated_arrival'])
                : null,
            updatedAt: entry.value.first['updated_at'] != null
                ? DateTime.tryParse(entry.value.first['updated_at'])
                : null,
              ongkir: (entry.value.first['ongkir'] ?? 0).toDouble(), // ditambahkan
              totalBayar: entry.value.first['total_bayar'], // ditambahkan
          ));
        }
      }

      print("Loaded ${orderHistory.length} order history (grouped)");
    } catch (e) {
      print('Error load order: $e');
    }
  }
}
