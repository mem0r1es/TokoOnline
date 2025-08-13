// lib/modules/admin/views/users/users_management_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toko_online_getx/modules/admin/controllers/users_controller.dart';

class UsersManagementView extends StatelessWidget {
  UsersManagementView({super.key});
  
  // Initialize controller
  final UsersController controller = Get.put(UsersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Users Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Add User Button (optional for future)
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add user functionality
                    Get.snackbar('Info', 'Add user feature');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search and Filter Bar
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Search Field
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name or email...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) => controller.searchUsers(value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Role Filter
                    Expanded(
                      flex: 2,
                      child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedRole.value,
                        decoration: InputDecoration(
                          labelText: 'Filter by Role',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Roles')),
                          DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                          DropdownMenuItem(value: 'seller', child: Text('Seller')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (value) => controller.filterByRole(value!),
                      )),
                    ),
                    const SizedBox(width: 16),
                    
                    // Status Filter
                    Expanded(
                      flex: 2,
                      child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedStatus.value,
                        decoration: InputDecoration(
                          labelText: 'Filter by Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Status')),
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        ],
                        onChanged: (value) => controller.filterByStatus(value!),
                      )),
                    ),
                    const SizedBox(width: 16),
                    
                    // Refresh Button
                    IconButton(
                      onPressed: () => controller.loadUsers(),
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // DataTable
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (controller.filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Roles')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Store')),
                          DataColumn(label: Text('Joined')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: controller.filteredUsers.asMap().entries.map((entry) {
                          int index = entry.key;
                          var user = entry.value;
                          
                          return DataRow(
                            cells: [
                              DataCell(Text('${index + 1}')),
                              DataCell(Text(user['full_name'] ?? 'N/A')),
                              DataCell(Text(user['email'] ?? 'N/A')),
                              DataCell(_buildRoleChips(user['roles'] ?? [])),
                              DataCell(_buildStatusChip(user['status'] ?? 'active')),
                              DataCell(Text(user['store_name'] ?? '-')),
                              DataCell(Text(_formatDate(user['created_at']))),
                              DataCell(_buildActionButtons(user)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Pagination (optional for future)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      'Showing ${controller.filteredUsers.length} of ${controller.allUsers.length} users',
                      style: TextStyle(color: Colors.grey[600]),
                    )),
                    Row(
                      children: [
                        IconButton(
                          onPressed: null, // TODO: Implement pagination
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          onPressed: null, // TODO: Implement pagination
                          icon: const Icon(Icons.chevron_right),
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
  
Widget _buildRoleChips(List<dynamic> roles) {
  return Wrap(
    spacing: 4,
    children: roles.map((role) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          role.toString(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      );
    }).toList(),
  );
}
  
Widget _buildStatusChip(String status) {
  // Simple design dengan border only
  Color borderColor = Colors.grey[400]!;
  Color textColor = Colors.grey[700]!;
  
  if (status == 'active') {
    borderColor = Colors.green;
    textColor = Colors.green[700]!;
  } else if (status == 'inactive') {
    borderColor = Colors.orange;
    textColor = Colors.orange[700]!;
  }
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      border: Border.all(color: borderColor),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      status,
      style: TextStyle(
        fontSize: 12,
        color: textColor,
      ),
    ),
  );
}
  
  Widget _buildActionButtons(Map<String, dynamic> user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Detail
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 20),
          onPressed: () => controller.viewUserDetail(user),
          tooltip: 'View Details',
          color: Colors.blue,
        ),
        // Edit
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: () => controller.editUser(user),
          tooltip: 'Edit User',
          color: Colors.orange,
        ),
        // Delete
        IconButton(
          icon: const Icon(Icons.delete_outlined, size: 20),
          onPressed: () => controller.deleteUser(user),
          tooltip: 'Delete User',
          color: Colors.red,
        ),
      ],
    );
  }
  
  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}