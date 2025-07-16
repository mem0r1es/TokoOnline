import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Tambah ini
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../providers/auth_provider.dart'; // Ganti dari auth_service ke auth_provider
import 'sign_in_page.dart';



class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Update fungsi _signUp untuk pake AuthProvider
  void _signUp(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      // Clear previous errors
      authProvider.clearError();

      // Map UI fields ke Django backend fields
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        firstName:
            _usernameController.text.trim(), // Use username as first name
        lastName: 'User', // Default last name
        password: _passwordController.text,
        passwordConfirm: _passwordController.text, // Same as password
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully! Welcome!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigation akan di-handle oleh AuthWrapper
        print('Registration successful');
      }
      // Error sudah di-handle oleh AuthProvider dan akan ditampilkan di UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<AuthProvider>(
        // Wrap dengan Consumer
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Row(
                children: [
                  // Left side - Logo
                  Container(
                    width: MediaQuery.of(context).size.width * 0.15,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        'Your Logo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  // Right side - Sign Up Form
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 400),
                          padding: EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: 'Welcome to ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'LOREM',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Sign up',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Have an Account ?',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SignInPage(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Sign in',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30),

                                // Tambah Error Message dari AuthProvider
                                if (authProvider.error != null) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12),
                                    margin: EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline,
                                            color: Colors.red.shade600,
                                            size: 20),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            authProvider.error!,
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: authProvider.clearError,
                                          icon: Icon(Icons.close,
                                              size: 16,
                                              color: Colors.red.shade600),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // Email Field
                                Text(
                                  'Enter your username or email address',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                CustomTextField(
                                  controller: _emailController,
                                  hintText: 'Username or email address',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                  onChanged: (_) => authProvider
                                      .clearError(), // Clear error saat typing
                                ),
                                SizedBox(height: 20),

                                // Username and Contact Number Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'User name',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          CustomTextField(
                                            controller: _usernameController,
                                            hintText: 'User name',
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter username';
                                              }
                                              if (value.length < 3) {
                                                return 'Username must be at least 3 characters';
                                              }
                                              return null;
                                            },
                                            onChanged: (_) =>
                                                authProvider.clearError(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Contact Number',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          CustomTextField(
                                            controller: _contactController,
                                            hintText: 'Contact Number',
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter contact number';
                                              }
                                              return null;
                                            },
                                            onChanged: (_) =>
                                                authProvider.clearError(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),

                                // Password Field
                                Text(
                                  'Enter your Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                CustomTextField(
                                  controller: _passwordController,
                                  hintText: 'Password',
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  onChanged: (_) => authProvider.clearError(),
                                ),
                                SizedBox(height: 30),

                                // Sign Up Button - Update untuk pake AuthProvider
                                CustomButton(
                                  text: 'Sign up',
                                  onPressed: authProvider
                                          .isLoading // Check loading state
                                      ? null
                                      : () => _signUp(
                                          authProvider), // Pass authProvider
                                  isLoading: authProvider
                                      .isLoading, // Show loading indicator
                                ),

                                // Tambah info tentang field mapping
                                SizedBox(height: 16),
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: Colors.blue.shade600,
                                          size: 16),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Note: Contact number is saved for future features. Username will be used as display name.',
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

