import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
import 'add_edit_product_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.accessToken == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final product = await ProductService.getProduct(
        token: authProvider.accessToken!,
        productId: widget.productId,
      );
      
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (_product != null)
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditProductPage(product: _product),
                ),
              ).then((_) => _loadProduct()),
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _product != null
                  ? _buildProductDetail()
                  : const Center(child: Text('Product not found')),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load product',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProduct,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail() {
    final product = _product!;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Gallery
          if (product.images != null && product.images!.isNotEmpty)
            _buildImageGallery(product.images!)
          else
            _buildPlaceholderImage(),
          
          // Product Information
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Price
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Status and Stock Info
                Row(
                  children: [
                    _buildInfoChip(
                      label: product.statusDisplayName,
                      color: _getStatusColor(product.status),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      label: 'Stock: ${product.stockQuantity}',
                      color: product.stockQuantity > 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      label: product.conditionDisplayName,
                      color: Colors.blue,
                    ),
                  ],
                ),
                
                if (product.category != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoChip(
                    label: 'Category: ${product.category!.name}',
                    color: Colors.purple,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Product Details
          if (_hasProductDetails(product))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailsList(product),
                ],
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Additional Attributes
          if (product.attributes != null && product.attributes!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional Attributes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...product.attributes!.map((attr) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            '${attr.name}:',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            attr.value,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Statistics
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Views',
                        value: product.viewsCount.toString(),
                        icon: Icons.visibility,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Created',
                        value: _formatDate(product.createdAt),
                        icon: Icons.calendar_today,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<ProductImage> images) {
    return Container(
      height: 300,
      color: Colors.white,
      child: Column(
        children: [
          // Main Image
          Expanded(
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  images[index].imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Image Indicators
          if (images.length > 1)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == entry.key
                          ? Colors.blue.shade600
                          : Colors.grey.shade300,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 300,
      color: Colors.white,
      child: Center(
        child: Icon(
          Icons.image,
          size: 64,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildInfoChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailsList(Product product) {
    final details = <Map<String, String>>[];
    
    if (product.brand != null) details.add({'label': 'Brand', 'value': product.brand!});
    if (product.model != null) details.add({'label': 'Model', 'value': product.model!});
    if (product.color != null) details.add({'label': 'Color', 'value': product.color!});
    if (product.size != null) details.add({'label': 'Size', 'value': product.size!});
    if (product.weight != null) details.add({'label': 'Weight', 'value': '${product.weight} kg'});
    
    return Column(
      children: details.map((detail) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                '${detail['label']}:',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Text(
                detail['value']!,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue.shade600),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasProductDetails(Product product) {
    return product.brand != null ||
        product.model != null ||
        product.color != null ||
        product.size != null ||
        product.weight != null;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'sold':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}