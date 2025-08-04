import 'package:flutter/material.dart';
import 'package:flutter_web/extensions/extension.dart';
import 'package:flutter_web/models/order_history_item.dart';
import 'package:flutter_web/pages/history/order_detail.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderTile extends StatefulWidget {
  final OrderHistoryItem order;

  const OrderTile({super.key, required this.order});

  @override
  State<OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends State<OrderTile> {
  int _getTotalQuantity(OrderHistoryItem order) {
  return order.items.fold<int>(0, (sum, item) => sum + (item.quantity));
}

  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final formattedTime = DateFormat('dd MMM yyyy • HH:mm').format(order.timestamp);

    // Tampilkan hanya item pertama kalau belum expand
    final itemsToDisplay = _showAll ? order.items : [order.items.first];

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(20)
      ),
      tileColor: Colors.purple[50],
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                itemsToDisplay.first.seller,
                style: context.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${order.capitalizedStatus}',
                style: context.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...itemsToDisplay.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            item.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${item.name} × ${item.quantity}',
                            style: context.bodyMedium,
                          ),
                        ),
                        Text(
                          'Rp ${_rupiah(item.totalPrice)}',
                          style: context.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              )),
              const SizedBox(height:8),

              Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Total ${_getTotalQuantity(order)} Harga: ',
                      style: context.bodyMedium,
                    ),
                    Text(
                      'Rp ${_rupiah(_getTotalWithOngkir(order))}',
                      style: context.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (order.items.length > 1 && !_showAll)
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAll = true;
                  });
                },
                child: Text(
                  'Lihat Semua ↓', 
                  style: context.bodySmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500]),
                  ),
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // Get.toNamed(OrderDetailPage.TAG);
        Get.to(() => OrderDetailPage(order: order));
      },
      
    );
    // Divider(height: 50),
  }

 String _rupiah(double price) {
  return price
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

double _getTotalWithOngkir(OrderHistoryItem order) {
  final totalProduk = order.items.fold<double>(
    0.0,
    (sum, item) => sum + (item.totalPrice ?? 0),
  );
  return totalProduk + (order.ongkir ?? 0);
}

}