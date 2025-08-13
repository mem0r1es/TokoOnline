// lib/modules/admin/controllers/users_controller.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/supabase_service.dart';

class UsersController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService.to;
  
  // Observable states
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredUsers = <Map<String, dynamic>>[].obs;
  
  // Search and Filter
  final TextEditingController searchController = TextEditingController();
  final RxString selectedRole = 'all'.obs;
  final RxString selectedStatus = 'all'.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  // Load all users from database
  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      
      final response = await _supabaseService.client
          .from('profiles')
          .select('*');
      
      allUsers.value = List<Map<String, dynamic>>.from(response);
      filteredUsers.value = allUsers;
      print('Loaded ${allUsers.length} users');
        } catch (e) {
      print('Error loading users: $e');
      Get.snackbar(
        'Error',
        'Failed to load users: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Search users by name or email
  void searchUsers(String query) {
    if (query.isEmpty) {
      _applyFilters();
      return;
    }
    
    final searchQuery = query.toLowerCase();
    filteredUsers.value = allUsers.where((user) {
      final name = (user['full_name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      return name.contains(searchQuery) || email.contains(searchQuery);
    }).toList();
    
    // Apply role and status filters on search results
    _applyRoleFilter();
    _applyStatusFilter();
  }
  
  // Filter by role
  void filterByRole(String role) {
    selectedRole.value = role;
    _applyFilters();
  }
  
  // Filter by status
  void filterByStatus(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }
  
  // Apply all filters
  void _applyFilters() {
    filteredUsers.value = allUsers;
    
    // Apply search if exists
    if (searchController.text.isNotEmpty) {
      searchUsers(searchController.text);
      return;
    }
    
    // Apply role filter
    _applyRoleFilter();
    
    // Apply status filter
    _applyStatusFilter();
  }
  
  void _applyRoleFilter() {
    if (selectedRole.value != 'all') {
      filteredUsers.value = filteredUsers.where((user) {
        final roles = user['roles'] as List<dynamic>? ?? [];
        return roles.contains(selectedRole.value);
      }).toList();
    }
  }
  
  void _applyStatusFilter() {
    if (selectedStatus.value != 'all') {
      filteredUsers.value = filteredUsers.where((user) {
        return user['status'] == selectedStatus.value;
      }).toList();
    }
  }
  
  // View user detail
  void viewUserDetail(Map<String, dynamic> user) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.red,
              child: Text(
                (user['full_name'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(user['full_name'] ?? 'User Details'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID', user['id'] ?? 'N/A'),
                _buildDetailRow('Email', user['email'] ?? 'N/A'),
                _buildDetailRow('Full Name', user['full_name'] ?? 'N/A'),
                _buildDetailRow('Phone', user['phone']?.toString() ?? 'N/A'),
                _buildDetailRow('Roles', (user['roles'] as List?)?.join(', ') ?? 'N/A'),
                _buildDetailRow('Status', user['status'] ?? 'N/A'),
                _buildDetailRow('Store Name', user['store_name'] ?? 'N/A'),
                _buildDetailRow('Shop Description', user['shop_description'] ?? 'N/A'),
                _buildDetailRow('Address', user['address'] ?? 'N/A'),
                _buildDetailRow('Business Info', user['business_info'] ?? 'N/A'),
                _buildDetailRow('Created At', _formatDateTime(user['created_at'])),
                _buildDetailRow('Updated At', _formatDateTime(user['updated_at'])),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
// Edit user
void editUser(Map<String, dynamic> user) {
  // Controllers for edit form
  final nameController = TextEditingController(text: user['full_name']);
  final phoneController = TextEditingController(text: user['phone']?.toString());
  final storeController = TextEditingController(text: user['store_name']);
  
  // Use regular variables with StatefulBuilder
  String selectedEditStatus = user['status'] ?? 'active';
  List<String> selectedRoles = List<String>.from(user['roles'] ?? []);
  
  Get.dialog(
    StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: storeController,
                    decoration: const InputDecoration(
                      labelText: 'Store Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedEditStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedEditStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Roles Checkboxes
                  const Text('Roles:', style: TextStyle(fontWeight: FontWeight.bold)),
                  CheckboxListTile(
                    title: const Text('Buyer'),
                    value: selectedRoles.contains('buyer'),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          if (!selectedRoles.contains('buyer')) {
                            selectedRoles.add('buyer');
                          }
                        } else {
                          selectedRoles.remove('buyer');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Seller'),
                    value: selectedRoles.contains('seller'),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          if (!selectedRoles.contains('seller')) {
                            selectedRoles.add('seller');
                          }
                        } else {
                          selectedRoles.remove('seller');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Admin'),
                    value: selectedRoles.contains('admin'),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          if (!selectedRoles.contains('admin')) {
                            selectedRoles.add('admin');
                          }
                        } else {
                          selectedRoles.remove('admin');
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate roles
                if (selectedRoles.isEmpty) {
                  Get.snackbar('Error', 'User must have at least one role');
                  return;
                }
                
                // Close dialog first
                Get.back();
                
                // Then update user
                await updateUser(
                  user['id'],
                  {
                    'full_name': nameController.text,
                    'phone': phoneController.text,
                    'store_name': storeController.text,
                    'status': selectedEditStatus,
                    'roles': selectedRoles,
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    ),
  );
}
  
Future<void> updateUser(String userId, Map<String, dynamic> data) async {
  try {
    isLoading.value = true;
    
    print('🔄 Updating user: $userId');
    print('📝 Data to update: $data');
    
    // Make sure updated_at is in correct format
    data['updated_at'] = DateTime.now().toUtc().toIso8601String();
    
    // Try update without select first
    await _supabaseService.client
        .from('profiles')
        .update(data)
        .eq('id', userId);
    
    print('✅ Update query executed');
    
    // Verify by fetching the updated user
    final updated = await _supabaseService.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    
    print('👤 User after update:');
    print('   Name: ${updated['full_name']}');
    print('   Status: ${updated['status']}');
    print('   Roles: ${updated['roles']}');
    
    Get.snackbar(
      'Success',
      'User updated successfully',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[900],
    );
    
    // Reload users
    await loadUsers();
    
  } on PostgrestException catch (e) {
    print('❌ PostgrestException: ${e.message}');
    print('   Code: ${e.code}');
    print('   Details: ${e.details}');
    
    Get.snackbar(
      'Database Error',
      'Failed to update: ${e.message}',
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
    );
  } catch (e) {
    print('❌ General Error: $e');
    print('   Type: ${e.runtimeType}');
    
    Get.snackbar(
      'Error',
      'Failed to update user',
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
    );
  } finally {
    isLoading.value = false;
  }
}
  
  // Delete user
  void deleteUser(Map<String, dynamic> user) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete User'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this user?'),
            const SizedBox(height: 16),
            Text(
              'User: ${user['full_name'] ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Email: ${user['email'] ?? 'N/A'}'),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone!',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await performDeleteUser(user['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  // Perform delete user
  Future<void> performDeleteUser(String userId) async {
    try {
      isLoading.value = true;
      
      // Soft delete - update status to 'deleted' or 'inactive'
      await _supabaseService.client
          .from('profiles')
          .update({'status': 'inactive', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
      
      // Or hard delete (be careful!)
      // await _supabaseService.client
      //     .from('profiles')
      //     .delete()
      //     .eq('id', userId);
      
      Get.snackbar(
        'Success',
        'User deleted successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
      
      // Reload users
      await loadUsers();
    } catch (e) {
      print('Error deleting user: $e');
      Get.snackbar(
        'Error',
        'Failed to delete user: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Helper to build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  // Format date time
  String _formatDateTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateString;
    }
  }
}