// lib/routes/app_routes.dart

abstract class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  
  // Dashboard Routes
  static const String sellerDashboard = '/seller-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  
  // Seller Features Routes (untuk nanti)
  static const String sellerProducts = '/seller/products';
  static const String sellerAddProduct = '/seller/products/add';
  static const String sellerEditProduct = '/seller/products/edit/:id';
  static const String sellerOrders = '/seller/orders';
  static const String sellerOrderDetail = '/seller/orders/:id';
  static const String sellerProfile = '/seller/profile';
  static const String sellerSettings = '/seller/settings';
  static const String sellerNotifications = '/seller/order-view';
  
  // Admin Features Routes (untuk nanti)
  static const String adminUsers = '/admin/users';
  static const String adminProducts = '/admin/products';
  static const String adminOrders = '/admin/orders';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';
  
  // Default Route
  static const String initial = login;
}