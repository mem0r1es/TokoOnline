import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filters.dart';
import 'add_edit_product_page.dart';
import 'product_detail_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (authProvider.accessToken != null) {
      productProvider.loadProducts(authProvider.accessToken!, refresh: true);
      productProvider.loadCategories(authProvider.accessToken!);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      if (authProvider.accessToken != null && productProvider.hasNextPage && !productProvider.isLoadingMore) {
        productProvider.loadMoreProducts(authProvider.accessToken!);
      }
    }
  }

  void _onSearch() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (authProvider.accessToken != null) {
      productProvider.searchProducts(authProvider.accessToken!, _searchController.text);
    }
  }

  void _goToAddProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditProductPage(),
      ),
    ).then((_) => _loadInitialData());
  }

  void _goToProductDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    ).then((_) => _loadInitialData());
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ProductFilters(
        onApplyFilters: () {
          Navigator.pop(context);
          _loadInitialData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _goToAddProduct,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onSubmitted: (_) => _onSearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _onSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Active Filters Display
              if (productProvider.searchQuery.isNotEmpty || 
                  productProvider.statusFilter.isNotEmpty || 
                  productProvider.categoryFilter.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Text('Active filters: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: [
                            if (productProvider.searchQuery.isNotEmpty)
                              Chip(
                                label: Text('Search: ${productProvider.searchQuery}'),
                                onDeleted: () {
                                  _searchController.clear();
                                  _onSearch();
                                },
                              ),
                            if (productProvider.statusFilter.isNotEmpty)
                              Chip(
                                label: Text('Status: ${productProvider.statusFilter}'),
                                onDeleted: () => productProvider.filterByStatus(
                                  Provider.of<AuthProvider>(context, listen: false).accessToken!,
                                  '',
                                ),
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          productProvider.clearFilters(
                            Provider.of<AuthProvider>(context, listen: false).accessToken!,
                          );
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),
              
              // Products Grid
              Expanded(
                child: productProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : productProvider.products.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () async => _loadInitialData(),
                            child: GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: productProvider.products.length + 
                                  (productProvider.isLoadingMore ? 2 : 0),
                              itemBuilder: (context, index) {
                                if (index >= productProvider.products.length) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                
                                final product = productProvider.products[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () => _goToProductDetail(product),
                                  onEdit: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AddEditProductPage(product: product),
                                    ),
                                  ).then((_) => _loadInitialData()),
                                  onDelete: () => _showDeleteConfirmation(product),
                                  onToggleStatus: () => _toggleProductStatus(product),
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddProduct,
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first product to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _goToAddProduct,
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String productId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (authProvider.accessToken != null) {
      final success = await productProvider.deleteProduct(
        authProvider.accessToken!,
        productId,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productProvider.errorMessage ?? 'Failed to delete product'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleProductStatus(Product product) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    final newStatus = product.status == 'active' ? 'inactive' : 'active';
    
    if (authProvider.accessToken != null) {
      final success = await productProvider.toggleProductStatus(
        authProvider.accessToken!,
        product.id,
        newStatus,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productProvider.errorMessage ?? 'Failed to update product status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}