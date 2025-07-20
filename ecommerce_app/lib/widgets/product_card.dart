import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey.shade100,
                ),
                child: product.primaryImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          product.primaryImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Price
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Status and Stock
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(product.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.statusDisplayName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(product.status),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Stock: ${product.stockQuantity}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.edit,
                            label: 'Edit',
                            onPressed: onEdit,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildActionButton(
                            icon: product.status == 'active' ? Icons.pause : Icons.play_arrow,
                            label: product.status == 'active' ? 'Hide' : 'Show',
                            onPressed: onToggleStatus,
                            color: product.status == 'active' ? Colors.orange : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildActionButton(
                          icon: Icons.delete,
                          onPressed: onDelete,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Center(
        child: Icon(
          Icons.image,
          size: 40,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    String? label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: label != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 12, color: color),
                  const SizedBox(width: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              )
            : Icon(icon, size: 12, color: color),
      ),
    );
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
}