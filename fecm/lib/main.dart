import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/sign_in_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/dashboard_page.dart';

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
          primarySwatch: Colors.green,
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
          '/login': (context) => SignInPage(),
          '/register': (context) => SignUpPage(),
          '/dashboard': (context) => DashboardPage(),
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.initializeGoogleSignIn(); // Initialize Google Sign In
      authProvider.checkAuthStatus();
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
          return DashboardPage();
        }

        // Not authenticated - show sign in
        return SignInPage();
      },
    );
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
