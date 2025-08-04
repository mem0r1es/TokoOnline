import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/address_controller.dart';
import 'package:flutter_web/models/info_user.dart';
import 'package:flutter_web/models/order_history_item.dart';
import 'package:flutter_web/services/checkout_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailPage extends StatelessWidget {
  static const TAG = '/orderdetailpage';
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
                    tileColor: order.status == 'Pesanan Diterima'
                        ? Colors.orange[100]
                        : order.status == 'Dalam Pengiriman'
                            ? Colors.blue[100]
                            : order.status == 'Pesanan Selesai'
                                ? Colors.green[100]
                                : Colors.red[200],
                    
                    // tileColor: Colors.orange[100],
                    title: Text(
                      '${order.capitalizedStatus}',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    // subtitle: Text(
                    //   '${order.cargoName}'
                    // ),
                  ),
                  if (order.estimatedArrival != null)
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero
                    ),
                    tileColor: Colors.grey[200],
                    title: Text(
                      'Estimasi Tiba:',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${DateFormat('dd MMM yyyy, HH:mm').format(order.estimatedArrival!)}'
                    ),
                  ),
                  const SizedBox(height: 1,),
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
                  
                  // ListTile(
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.zero
                  //   ),
                  //   tileColor: Colors.purple[50],
                  //   title: Text(
                  //     'Status Pengiriman: ${order.status}',
                  //     // style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  //   ),
                  //   // subtitle: Text(
                  //   //   '${order.cargoName}'
                  //   // ),
                  // ),
                  // const SizedBox(height: 1,),
                ],
              ),

              // if (order.estimatedArrival != null)
              //   Container(
              //     margin: const EdgeInsets.only(bottom: 6),
              //     padding: const EdgeInsets.all(12),
              //     color: Colors.blue[100],
              //     child: Text(
              //       'Estimasi Tiba: ${DateFormat('dd MMM yyyy, HH:mm').format(order.estimatedArrival!)}',
              //       style: GoogleFonts.poppins(fontSize: 14),
              //     ),
              //   ),


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
              // const Divider(),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.stretch,
            //   children: [
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text("Harga Produk:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            //         Text("Rp ${_rupiah(order.items.fold(0.0, (sum, item) => sum + item.totalPrice))}")
            //       ],
            //     ),
            //     const SizedBox(height: 5),
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text("Ongkos Kirim:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            //         Text('Rp ${_rupiah((order.ongkir ?? 0).toDouble())}')
            //       ],
            //     ),
            //     const Divider(),
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text("Total Pesanan:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            //         Text('Rp ${_rupiah((order.totalBayar ?? 0).toDouble())}', 
            //         style: GoogleFonts.poppins(fontWeight: FontWeight.bold))
            //       ],
            //     ),
            //   ],
            // ),

              // const SizedBox(height: 10),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(15)
                  ),
                tileColor: Colors.purple[50],
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Metode Pembayaran: ',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${order.paymentMethod}',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
                    fontWeight: FontWeight.bold),
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

        Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Subtotal Produk:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text("Rp ${_rupiah(order.items.fold(0.0, (sum, item) => sum + item.totalPrice))}")
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Subtotal Pengiriman:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text('Rp ${_rupiah((order.ongkir ?? 0).toDouble())}')
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Pesanan:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text('Rp ${_rupiah((order.totalBayar ?? 0).toDouble())}', 
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold))
                  ],
                ),
              ],
            ),
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