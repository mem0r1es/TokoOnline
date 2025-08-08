// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:toko_online_getx/routes/app_routes.dart';
import 'package:toko_online_getx/service/add_productservice.dart';

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
    print('✅ SupabaseService initialized.');

    _client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
        print('🔐 Auth state changed: signed in.');
          currentUser.value = session?.user;
          await loadUserProfile(); // Load profile immediately after sign-in
          Get.offAllNamed(AppRoutes.sellerDashboard); // Navigate to home
        } else if (event == AuthChangeEvent.signedOut) {
          print('🔒 Auth state changed: signed out.');
          currentUser.value = null;
          userRoles.clear();
          // Use `offAllNamed` to remove all previous routes
          Get.offAllNamed(AppRoutes.login);
        }
      });

    // Panggil loadUserProfile() secara langsung untuk sesi awal
    final session = _client.auth.currentSession;
    if (session != null) {
      print('✅ Found existing session.');
      currentUser.value = session.user;
      loadUserProfile();
    }else {
      print('❌ No existing session found.');
    }
  }
  
  // ============= AUTH METHODS =============
  
  // SUPABASE SERVICE (PERBAIKAN)

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
    final AuthResponse authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final User? user = authResponse.user;

    if (user == null) {
      // Jika user null, Supabase sudah mengirim email konfirmasi
      // Ini terjadi jika user sudah terdaftar tapi belum diverifikasi
      return {
        'success': true,
        'message': 'Registration successful, please check your email for confirmation.',
      };
    }
    
    // 2. Insert user profile ke tabel 'profiles'
    final profileData = {
      'id': user.id,
      'email': email,
      'full_name': fullName,
      'store_name': shopName,
      'phone': phone,
      'shop_description': shopDescription,
      'roles': ['buyer', 'seller'], // Auto assign roles
    };
    
    await _client.from('profiles').insert(profileData);
    
    return {
      'success': true,
      'message': 'Registration successful! Please verify your email and login.',
    };

  } on AuthException catch (e) {
    String errorMessage;
    if (e.message.contains('Email rate limit exceeded')) {
      errorMessage = 'Please check your email. Too many requests have been made to this address.';
    } else if (e.message.contains('User already registered')) {
      errorMessage = 'Email already registered. Please login instead.';
    } else {
      errorMessage = e.message;
    }
    return {
      'success': false,
      'message': errorMessage,
    };
  } on PostgrestException catch (e) {
    return {
      'success': false,
      'message': 'Error creating user profile: ${e.message}',
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'An unexpected error occurred: $e',
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

      // if (response.user!.emailConfirmedAt == null) {
      //   return {
      //     'success': false,
      //     'message': 'Your email is not activated yet. Please check your inbox.',
      //   };
      // }
      
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
    } on AuthApiException catch (e) {
      // Map Supabase Auth Errors to user-friendly messages
      if (e.statusCode == 400 && e.message.contains('Invalid login credentials')) {
        return {
          'success': false,
          'message': 'Incorrect email or password.',
        };
      } else if (e.statusCode == 400 && e.message.contains('Your email is not activated yet. Please check your inbox.')) {
        return {
          'success': false,
          'message': 'Your email is not activated yet. Please check your inbox.',
        };
      } else {
        return {
          'success': false,
          'message': e.message ?? 'Authentication failed. Please try again.',
        };
      }
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
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      
      final response = await _client
          .from('profiles')
          .select('roles') // <--- HANYA MENGAMBIL ROLES DI SINI
          .eq('id', userId)
          .maybeSingle();
      
      if (response != null) {
        final roles = List<String>.from(response['roles'] ?? ['buyer']);
        userRoles.value = roles;
      } else {
        userRoles.value = ['buyer']; // Default to buyer role on error
      }
    } catch (e) {
      print('Error loading profile: $e');
      userRoles.value = ['buyer'];
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

  Future<Map<String, dynamic>?> getProfileData() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        print('❌ getProfileData: User ID is null, cannot fetch profile.');
        return null;
      }

      print('🚀 Fetching profile for user ID: $userId');

      final response = await _client
          .from('profiles')
          .select('full_name, store_name') // <--- AMBIL SEMUA DATA YANG DIBUTUHKAN
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        print('📦 Data received from Supabase: $response');
      } else {
        print('⚠️ Profile data not found for user ID: $userId');
      }

      return response;
    } catch (e,stacktrace) {
      print('Error getting profile data: $e');
      print('Stacktrace:\n$stacktrace');
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
      if (sellerId == null) {
        // Query dengan filter
        print('sellerId null: tidak mengambil produk');
        return[];
      }
        // Query tanpa filter
        final response = await _client
            .from('products')
            .select()
            .eq('seller_id', sellerId)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
            
        return List<Map<String, dynamic>>.from(response);
      
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
  
  String? get userId => _client.auth.currentUser?.id;
  
  String? get userEmail => _client.auth.currentUser?.email;
}