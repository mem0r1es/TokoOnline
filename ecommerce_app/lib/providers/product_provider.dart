import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  SellerStats? _sellerStats;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Pagination
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoadingMore = false;
  
  // Filters
  String _searchQuery = '';
  String _statusFilter = '';
  String _categoryFilter = '';
  String _orderBy = '-created_at';

  // Getters
  List<Product> get products => _products;
  List<Category> get categories => _categories;
  SellerStats? get sellerStats => _sellerStats;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasNextPage => _hasNextPage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get categoryFilter => _categoryFilter;
  String get orderBy => _orderBy;

  // Load products with filters
  Future<void> loadProducts(String token, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _products.clear();
    }

    _isLoading = refresh;
    _isLoadingMore = !refresh;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ProductService.getSellerProducts(
        token: token,
        page: _currentPage,
        search: _searchQuery,
        status: _statusFilter,
        categoryId: _categoryFilter,
        ordering: _orderBy,
      );

      if (refresh) {
        _products = response.results;
      } else {
        _products.addAll(response.results);
      }

      _hasNextPage = response.next != null;
      if (_hasNextPage) {
        _currentPage++;
      }

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load more products (pagination)
  Future<void> loadMoreProducts(String token) async {
    if (!_hasNextPage || _isLoadingMore) return;
    await loadProducts(token, refresh: false);
  }

  // Search products
  Future<void> searchProducts(String token, String query) async {
    _searchQuery = query;
    await loadProducts(token, refresh: true);
  }

  // Filter by status
  Future<void> filterByStatus(String token, String status) async {
    _statusFilter = status;
    await loadProducts(token, refresh: true);
  }

  // Filter by category
  Future<void> filterByCategory(String token, String categoryId) async {
    _categoryFilter = categoryId;
    await loadProducts(token, refresh: true);
  }

  // Sort products
  Future<void> sortProducts(String token, String orderBy) async {
    _orderBy = orderBy;
    await loadProducts(token, refresh: true);
  }

  // Clear filters
  Future<void> clearFilters(String token) async {
    _searchQuery = '';
    _statusFilter = '';
    _categoryFilter = '';
    _orderBy = '-created_at';
    await loadProducts(token, refresh: true);
  }

  // Create product
  Future<bool> createProduct(String token, CreateProductRequest productData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProduct = await ProductService.createProduct(
        token: token,
        productData: productData,
      );
      
      _products.insert(0, newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(String token, String productId, CreateProductRequest productData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProduct = await ProductService.updateProduct(
        token: token,
        productId: productId,
        productData: productData,
      );
      
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String token, String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ProductService.deleteProduct(token: token, productId: productId);
      _products.removeWhere((p) => p.id == productId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle product status
  Future<bool> toggleProductStatus(String token, String productId, String newStatus) async {
    try {
      final updatedProduct = await ProductService.toggleProductStatus(
        token: token,
        productId: productId,
        newStatus: newStatus,
      );
      
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load categories
  Future<void> loadCategories(String token) async {
    try {
      _categories = await ProductService.getCategories(token: token);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load seller stats
  Future<void> loadSellerStats(String token) async {
    try {
      _sellerStats = await ProductService.getSellerStats(token: token);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}