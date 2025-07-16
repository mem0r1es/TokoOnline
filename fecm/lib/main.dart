import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/sign_in_page.dart'; // Ganti ke screen yang benar
import 'screens/sign_up_page.dart'; // Ganti ke screen yang benar
import 'screens/dashboard_page.dart'; // Tambah dashboard screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Flutter Auth App',
        theme: ThemeData(
          primarySwatch: Colors.green, // Sesuaikan dengan warna UI lo
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[800],
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        home: AuthWrapper(),
        routes: {
          '/login': (context) => SignInPage(), // Update route
          '/register': (context) => SignUpPage(), // Update route
          '/dashboard': (context) => DashboardPage(), // Tambah dashboard route
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check auth status saat app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Loading state
        if (authProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.green,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Authenticated - go to dashboard
        if (authProvider.isAuthenticated && authProvider.user != null) {
          return DashboardPage(); // Pake DashboardPage yang proper
        }

        // Not authenticated - show sign in
        return SignInPage(); // Pake SignInPage yang udah ada
      },
    );
  }
}

// Optional: Error Boundary untuk handle unexpected errors
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final String error;

  const ErrorBoundary({
    Key? key,
    required this.child,
    required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (error.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart app atau clear error
                    Provider.of<AuthProvider>(context, listen: false)
                        .clearError();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}

// App-level configuration
class AppConfig {
  static const String appName = 'LOREM Auth';
  static const String version = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://localhost:8000/api';

  // Theme Configuration
  static const Color primaryColor = Colors.green;
  static const Color secondaryColor = Colors.blue;

  // Debug mode
  static const bool isDebugMode = true;

  static void debugPrint(String message) {
    if (isDebugMode) {
      print('[DEBUG] $message');
    }
  }
}
