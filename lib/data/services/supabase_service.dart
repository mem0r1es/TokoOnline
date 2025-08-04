import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find();
  
  late final SupabaseClient _client;
  SupabaseClient get client => _client;
  
  // Observable untuk track auth state
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxList<String> userRoles = <String>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _client = Supabase.instance.client;
    
    // Listen to auth state changes
    _client.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      if (data.session != null) {
        _loadUserProfile();
      } else {
        userRoles.clear();
      }
    });
    
    // Check initial session
    final session = _client.auth.currentSession;
    if (session != null) {
      currentUser.value = session.user;
      _loadUserProfile();
    }
  }
  
  // ============= AUTH METHODS =============
  
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String shopName,
    String? phone,
    String? shopDescription,
  }) async {
    try {
      isLoading.value = true;
      
      // 1. Register user dengan Supabase Auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'shop_name': shopName,
          'shop_description': shopDescription,
          'phone': phone,
        }, // Pass all data as metadata
      );
      
      // Check if email already exists
      if (response.user == null) {
        // Try to login first to check if user exists
        try {
          final loginCheck = await _client.auth.signInWithPassword(
            email: email,
            password: password,
          );
          if (loginCheck.user != null) {
            return {
              'success': false,
              'message': 'Email already registered. Please login instead.',
            };
          }
        } catch (e) {
          // Login failed, continue with original error
        }
        throw Exception('Registration failed');
      }
      
      // 2. Wait a bit for auth.users to be ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 3. Try to create or update profile
      try {
        final profileData = {
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'shop_name': shopName,
          'phone': phone,
          'shop_description': shopDescription,
          'roles': ['buyer', 'seller'], // Auto assign both roles
          'status': 'active', // No approval needed
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        print('Attempting to upsert profile with data: $profileData');
        
        // Use upsert to handle existing profile and force update roles
        await _client.from('profiles').upsert(
          profileData,
          onConflict: 'id',
        );
        
        print('Profile upserted successfully');
        
        // Verify the profile was created with correct roles
        final verifyProfile = await _client
            .from('profiles')
            .select('id, email, roles')
            .eq('id', response.user!.id)
            .maybeSingle();
            
        print('Profile after upsert: $verifyProfile');
        
      } catch (e) {
        print('Profile creation error: $e');
        // If upsert fails, try update only to ensure roles are set
        try {
          await _client.from('profiles').update({
            'full_name': fullName,
            'shop_name': shopName,
            'phone': phone,
            'shop_description': shopDescription,
            'roles': ['buyer', 'seller'], // Ensure seller role
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', response.user!.id);
          
          print('Profile updated via fallback');
        } catch (updateError) {
          print('Profile update error: $updateError');
        }
      }
      
      // 4. Auto login after registration
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // 5. Force update roles after login (in case trigger overrode them)
      await Future.delayed(const Duration(milliseconds: 1000));
      try {
        await _client.from('profiles').update({
          'roles': ['buyer', 'seller'],
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', response.user!.id);
        
        print('Roles updated after login');
      } catch (e) {
        print('Failed to update roles after login: $e');
      }
      
      return {
        'success': true,
        'message': 'Registration successful',
        'user': response.user,
      };
    } catch (e) {
      // Handle specific Supabase auth errors
      if (e.toString().contains('User already registered')) {
        return {
          'success': false,
          'message': 'Email already registered. Please login instead.',
        };
      }
      
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Login failed');
      }
      
      // Set current user
      currentUser.value = response.user;
      
      // Load user profile to get roles - wait until complete
      await loadUserProfile();
      
      // Add small delay to ensure roles are properly set
      await Future.delayed(const Duration(milliseconds: 200));
      
      return {
        'success': true,
        'message': 'Login successful',
        'user': response.user,
        'roles': userRoles,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      currentUser.value = null;
      userRoles.clear();
    } catch (e) {
      print('Logout error: $e');
    }
  }
  
  // ============= PROFILE METHODS =============
  
  // Make this public so it can be called from auth controller
  Future<void> loadUserProfile() async {
    try {
      final userId = currentUser.value?.id;
      if (userId == null) return;
      
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response != null) {
        final roles = List<String>.from(response['roles'] ?? ['buyer']);
        userRoles.value = roles;
      } else {
        // Profile doesn't exist, create one with default buyer role
        print('Profile not found for user $userId, creating default profile...');
        
        try {
          await _client.from('profiles').upsert({
            'id': userId,
            'email': currentUser.value?.email,
            'roles': ['buyer'],
            'status': 'active',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id'); // Use upsert to prevent duplicate error
          
          userRoles.value = ['buyer'];
        } catch (e) {
          print('Error creating default profile: $e');
          // Try to load again in case it was created by another process
          final retryResponse = await _client
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();
              
          if (retryResponse != null) {
            final roles = List<String>.from(retryResponse['roles'] ?? ['buyer']);
            userRoles.value = roles;
          } else {
            userRoles.value = ['buyer']; // Default to buyer role
          }
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      userRoles.value = ['buyer']; // Default to buyer role on error
    }
  }
  
  // Keep the private one for internal use
  Future<void> _loadUserProfile() => loadUserProfile();
  
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle(); // Use maybeSingle() instead of single()
      
      return response;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }
  
  Future<bool> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      
      await _client
          .from('profiles')
          .update(data)
          .eq('id', userId);
      
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
  
  // ============= PRODUCT METHODS =============
  
  Future<List<Map<String, dynamic>>> getProducts({
    String? sellerId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      if (sellerId != null) {
        // Query dengan filter
        final response = await _client
            .from('products')
            .select()
            .eq('seller_id', sellerId)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
            
        return List<Map<String, dynamic>>.from(response);
      } else {
        // Query tanpa filter
        final response = await _client
            .from('products')
            .select()
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
            
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', productId)
          .single();
      
      return response;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }
  
  Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      productData['seller_id'] = currentUser.value?.id;
      productData['created_at'] = DateTime.now().toIso8601String();
      productData['updated_at'] = DateTime.now().toIso8601String();
      
      await _client.from('products').insert(productData);
      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }
  
  Future<bool> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      
      await _client
          .from('products')
          .update(data)
          .eq('id', productId);
      
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }
  
  Future<bool> deleteProduct(String productId) async {
    try {
      await _client
          .from('products')
          .delete()
          .eq('id', productId);
      
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }
  
  // ============= ORDER METHODS =============
  
  Future<List<Map<String, dynamic>>> getOrders({
    String? sellerId,
    String? buyerId,
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Build query dengan kondisi
      PostgrestFilterBuilder query;
      
      // Start with base query
      query = _client
          .from('orders_order')
          .select('*, orders_orderitem(*)');
      
      // Apply filters
      if (buyerId != null && status != null) {
        query = query
            .eq('user_id', buyerId)
            .eq('status', status);
      } else if (buyerId != null) {
        query = query.eq('user_id', buyerId);
      } else if (status != null) {
        query = query.eq('status', status);
      }
      
      // Execute query with order and pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      // Filter by seller if needed
      if (sellerId != null) {
        List<Map<String, dynamic>> filteredOrders = [];
        
        for (var order in response) {
          bool hasSellerProduct = false;
          final orderItems = List<Map<String, dynamic>>.from(
            order['orders_orderitem'] ?? []
          );
          
          for (var item in orderItems) {
            final productId = item['product_id'];
            
            final product = await _client
                .from('products')
                .select('seller_id')
                .eq('id', productId)
                .maybeSingle();
            
            if (product != null && product['seller_id'] == sellerId) {
              hasSellerProduct = true;
              break;
            }
          }
          
          if (hasSellerProduct) {
            filteredOrders.add(order);
          }
        }
        
        return filteredOrders;
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting orders: $e');
      return [];
    }
  }
  
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _client
          .from('orders_order')
          .update({'status': status})
          .eq('id', orderId);
      
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
  
  // ============= CATEGORY METHODS =============
  
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('name');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }
  
  Future<bool> addCategory(Map<String, dynamic> categoryData) async {
    try {
      categoryData['created_at'] = DateTime.now().toIso8601String();
      
      await _client.from('categories').insert(categoryData);
      return true;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }
  
  // ============= HELPER METHODS =============
  
  bool get isAuthenticated => currentUser.value != null;
  
  bool get isAdmin => userRoles.contains('admin');
  
  bool get isSeller => userRoles.contains('seller');
  
  bool get isBuyer => userRoles.contains('buyer');
  
  bool hasRole(String role) => userRoles.contains(role);
  
  String? get userId => currentUser.value?.id;
  
  String? get userEmail => currentUser.value?.email;
}