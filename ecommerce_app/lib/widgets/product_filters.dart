import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';

class ProductFilters extends StatefulWidget {
  final VoidCallback onApplyFilters;

  const ProductFilters({
    Key? key,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<ProductFilters> createState() => _ProductFiltersState();
}

class _ProductFiltersState extends State<ProductFilters> {
  String _selectedStatus = '';
  String _selectedCategory = '';
  String _selectedSort = '-created_at';

  final List<Map<String, String>> _statusOptions = [
    {'value': '', 'label': 'All Status'},
    {'value': 'active', 'label': 'Active'},
    {'value': 'inactive', 'label': 'Inactive'},
    {'value': 'sold', 'label': 'Sold'},
    {'value': 'pending', 'label': 'Pending Review'},
  ];

  final List<Map<String, String>> _sortOptions = [
    {'value': '-created_at', 'label': 'Newest First'},
    {'value': 'created_at', 'label': 'Oldest First'},
    {'value': 'name', 'label': 'Name A-Z'},
    {'value': '-name', 'label': 'Name Z-A'},
    {'value': 'price', 'label': 'Price Low to High'},
    {'value': '-price', 'label': 'Price High to Low'},
    {'value': '-views_count', 'label': 'Most Viewed'},
  ];

  @override
  void initState() {
    super.initState();
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    _selectedStatus = productProvider.statusFilter;
    _selectedCategory = productProvider.categoryFilter;
    _selectedSort = productProvider.orderBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Filter & Sort Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          
          // Status Filter
          _buildFilterSection(
            title: 'Status',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statusOptions.map((option) {
                final isSelected = _selectedStatus == option['value'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatus = option['value']!;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      option['label']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Category Filter
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return _buildFilterSection(
                title: 'Category',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // All Categories option
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = '';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedCategory.isEmpty ? Colors.blue.shade600 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedCategory.isEmpty ? Colors.blue.shade600 : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          'All Categories',
                          style: TextStyle(
                            color: _selectedCategory.isEmpty ? Colors.white : Colors.grey.shade700,
                            fontWeight: _selectedCategory.isEmpty ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    // Category options
                    ...productProvider.categories.map((category) {
                      final isSelected = _selectedCategory == category.id.toString();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category.id.toString();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            category.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Sort Options
          _buildFilterSection(
            title: 'Sort By',
            child: Column(
              children: _sortOptions.map((option) {
                final isSelected = _selectedSort == option['value'];
                return RadioListTile<String>(
                  title: Text(option['label']!),
                  value: option['value']!,
                  groupValue: _selectedSort,
                  onChanged: (value) {
                    setState(() {
                      _selectedSort = value!;
                    });
                  },
                  activeColor: Colors.blue.shade600,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = '';
      _selectedCategory = '';
      _selectedSort = '-created_at';
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (authProvider.accessToken != null) {
      productProvider.clearFilters(authProvider.accessToken!);
    }
    
    widget.onApplyFilters();
  }

  void _applyFilters() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (authProvider.accessToken != null) {
      // Apply filters one by one
      if (_selectedStatus != productProvider.statusFilter) {
        productProvider.filterByStatus(authProvider.accessToken!, _selectedStatus);
      }
      
      if (_selectedCategory != productProvider.categoryFilter) {
        productProvider.filterByCategory(authProvider.accessToken!, _selectedCategory);
      }
      
      if (_selectedSort != productProvider.orderBy) {
        productProvider.sortProducts(authProvider.accessToken!, _selectedSort);
      }
      
      // If no changes were made, just refresh
      if (_selectedStatus == productProvider.statusFilter &&
          _selectedCategory == productProvider.categoryFilter &&
          _selectedSort == productProvider.orderBy) {
        productProvider.loadProducts(authProvider.accessToken!, refresh: true);
      }
    }
    
    widget.onApplyFilters();
  }
}