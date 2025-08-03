
import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/address_controller.dart';
import 'package:flutter_web/controllers/scroll_controller.dart';
import 'package:flutter_web/models/info_user.dart';
// import 'package:flutter_web/controller/cart_controller.dart';
// import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:flutter_web/models/order_history_item.dart';
import 'package:flutter_web/models/product_model.dart';
import 'package:flutter_web/pages/homepage/home_page.dart';
import 'package:flutter_web/pages/profile/profile_page.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:flutter_web/services/checkout_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'package:intl/intl.dart';

class ProductInfoPage extends StatefulWidget {
  static const TAG = '/productinfo';

  const ProductInfoPage({super.key});

  @override
  State<ProductInfoPage> createState() => _ProductInfoPageState();
}

class _ProductInfoPageState extends State<ProductInfoPage> {
  final CheckoutService checkoutService = Get.find<CheckoutService>();

  @override
  void initState() {
    super.initState();
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email != null) {
      checkoutService.loadOrderHistoryFromSupabase(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = Get.find<CustomScrollController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            scrollController.selectedIndex.value = 2;
            Get.offAllNamed(HomePage.TAG);
          },
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Order History",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Obx(() {
          if (checkoutService.orderHistory.isEmpty) {
            return Center(
              child: Text(
                "No order history yet.",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            controller: scrollController.scrollController,
            itemCount: checkoutService.orderHistory.length,
            itemBuilder: (context, index) {
              
              final order = checkoutService.orderHistory[index];
              final formattedTime = DateFormat('dd MMM yyyy • HH:mm').format(order.timestamp);
              // final item = checkoutService.orderHistory[i]; 

              // return ListTile(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadiusGeometry.circular(25)
              //   ),
              //   leading: Image.network(order.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
              // )
              return Column(
                children: [
                  OrderTile(order: order),
                  // const SizedBox(height: 15),
                  const Divider(
                    color: Colors.white,
                  ),
                  // const SizedBox(height: 2),
                ],
              );
              
              // Card(
              //   margin: const EdgeInsets.symmetric(vertical: 8),
              //   child: ListTile(
              //     tileColor: Colors.white,
              //     title: Text(
              //       'Order at $formattedTime',
              //       style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
              //     ),
              //     subtitle: Column(
              //       children: [
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             ClipRRect(
              //               borderRadius: BorderRadius.circular(6),
              //               child: Image.network(
              //                 order.items.first.imageUrl,
              //                 width: 80,
              //                 height: 80,
              //                 fit: BoxFit.cover,
              //                 errorBuilder: (context, error, stackTrace) {
              //                   return Container(
              //                     width: 80,
              //                     height: 80,
              //                     color: Colors.grey[300],
              //                     child: const Icon(Icons.broken_image, color: Colors.grey),
              //                   );
              //                 },
              //               ),
              //             ),
              //             const SizedBox(width: 12),
              //             Expanded(
              //               child: Text(
              //                 '${order.items.first.name} × ${order.items.first.quantity}',
              //                 style: GoogleFonts.poppins(fontSize: 14),
              //               ),
              //             ),
              //             Text(
              //               'Rp ${_rupiah(order.items.first.totalPrice)}',
              //               style: GoogleFonts.poppins(fontSize: 14),
              //             ),
              //           ],
              //         ),
              //         GestureDetector(
              //           child: Center(
              //             child: Text('Lihat Semua')
              //             ),
              //             onTap: () => _orderSummarySection(order),
              //         )
              //       ],
              //     ),
              //     // subtitle: _orderSummarySection(order),
              //     trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              //     onTap: () {
              //       Get.to(() => OrderDetailPage(order: order));
              //     },
              //   ),
              // );
            },
          );
        }),
      ),
    );
  }
  Widget _orderSummarySection(OrderHistoryItem order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...order.items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
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
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${item.name} × ${item.quantity}',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
                Text(
                  'Rp ${_rupiah(item.totalPrice)}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _rupiah(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}



class OrderDetailPage extends StatelessWidget {
  final OrderHistoryItem order;

  OrderDetailPage({super.key, required this.order});

  final addressController = Get.find<AddressController>();
  final checkoutService = Get.find<CheckoutService>();

  @override
  Widget build(BuildContext context) {
    final info = order.infoUser.isNotEmpty ? order.infoUser.first : InfoUser();

    final formattedTime = DateFormat('dd MMM yyyy • HH:mm').format(order.timestamp);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Order Details", style: GoogleFonts.poppins()),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ordered at $formattedTime', style: GoogleFonts.poppins(fontSize: 14)),
              if (order.estimatedArrival != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Estimasi Tiba: ${DateFormat('dd MMM yyyy • HH:mm').format(order.estimatedArrival!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),


              const SizedBox(height: 16),

              Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        // bottomRight: Radius.circular(10),
                        // bottomLeft: Radius.circular(10),
                      )
                    ),
                    tileColor: Colors.orange[100],
                    title: Text(
                      'Pesanan Diterima',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    // subtitle: Text(
                    //   '${order.cargoName}'
                    // ),
                  ),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero
                      
                    ),
                    tileColor: Colors.purple[50],
                    
                    title: Text(
                      'Info Pengiriman',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${order.cargoName}'
                    ),
                  ),
                  const SizedBox(height: 1,),
                  
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero
                    ),
                    tileColor: Colors.purple[50],
                    title: Text(
                      'Status Pengiriman: ${order.status}',
                      // style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    // subtitle: Text(
                    //   '${order.cargoName}'
                    // ),
                  ),
                  const SizedBox(height: 1,),
                ],
              ),

              if (order.estimatedArrival != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue[100],
                  child: Text(
                    'Estimasi Tiba: ${DateFormat('dd MMM yyyy, HH:mm').format(order.estimatedArrival!)}',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),


              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  )
                ),
                tileColor: Colors.purple[50],
                title: Text(
                  'Alamat Pengiriman',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: Row(
                  children: [
                    Icon(Icons.location_on, size: 25, color: Colors.purple),
                    const SizedBox(width: 5,),
                    Expanded(
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '${info.fullName} '
                              ),
                              Text(
                                '| ${info.phone}',
                                style: GoogleFonts.poppins(
                                  // color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                          Text(
                            '${info.address}'
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // _sectionTitle("Contact Information"),
              // Text("Full Name: ${info.fullName}", style: GoogleFonts.poppins(fontSize: 14)),
              // Text("Email: ${info.email}", style: GoogleFonts.poppins(fontSize: 14)),
              // Text("Phone: ${info.phone}", style: GoogleFonts.poppins(fontSize: 14)),
              // Text("Address: ${info.address}", style: GoogleFonts.poppins(fontSize: 14)),
              // const SizedBox(height: 20),

              // _sectionTitle("Order Summary"),
              // const SizedBox(height: 10),

              _orderSummarySection(),
              const SizedBox(height: 10),
              const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Harga Produk:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text("Rp ${_rupiah(order.items.fold(0.0, (sum, item) => sum + item.totalPrice))}")
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ongkos Kirim:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text('Rp ${_rupiah((order.ongkir ?? 0).toDouble())}')
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Bayar:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text('Rp ${_rupiah((order.totalBayar ?? 0).toDouble())}', 
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold))
                  ],
                ),
              ],
            ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Payment Method: ',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    order.paymentMethod,
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _orderSummarySection() {
  return ListTile(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(15)
    ),
    tileColor: Colors.purple[50],
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: order.items
          .map((item) => item.seller)
          .toSet()
          .map((seller) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  seller,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
                ),
              ))
          .toList(),
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...order.items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
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
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${item.name} × ${item.quantity}',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
                Text(
                  'Rp ${_rupiah(item.totalPrice)}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}

// Widget _buildProductImage() {
//     if (item.imageUrl.startsWith('http')) {
//       // Network image
//       return Image.network(
//         item.imageUrl,
//         fit: BoxFit.cover,
//         width: 50,
//         height: 100,
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Center(
//             child: CircularProgressIndicator(
//               value: loadingProgress.expectedTotalBytes != null
//                   ? loadingProgress.cumulativeBytesLoaded /
//                         loadingProgress.expectedTotalBytes!
//                   : null,
//             ),
//           );
//         },
//         errorBuilder: (context, error, stackTrace) {
//           return _buildPlaceholderImage();
//         },
//       );
//     } else {
//       // Asset image
//       return Image.asset(
//         item.imageUrl,
//         fit: BoxFit.cover,
//         width: double.infinity,
//         height: double.infinity,
//         errorBuilder: (context, error, stackTrace) {
//           return _buildPlaceholderImage();
//         },
//       );
//     }
//   }

//   Widget _buildPlaceholderImage() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.grey[200],
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.image_not_supported_outlined,
//             size: 40,
//             color: Colors.grey[400],
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Image not found',
//             style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
//           ),
//         ],
//       ),
//     );
//   }

  String _rupiah(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

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
          Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
          Text(
            // 'Order at $formattedTime',
            itemsToDisplay.first.seller,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          ],)
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
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                        Text(
                          'Rp ${_rupiah(item.totalPrice)}',
                          style: GoogleFonts.poppins(fontSize: 14),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cargo: ${order.cargoName ?? '-'}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Ongkir: Rp ${_rupiah((order.ongkir ?? 0).toDouble())}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Total ${_getTotalQuantity(order)} Harga: ',
                      style: GoogleFonts.poppins(),
                    ),
                    Text(
                      'Rp ${_rupiah(_getTotalWithOngkir(order))}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
                    if (order.estimatedArrival != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Estimasi Tiba: ${DateFormat('dd MMM yyyy').format(order.estimatedArrival!)}',
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF444444),
                          ),
                        ),
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
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500]),
                  ),
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
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