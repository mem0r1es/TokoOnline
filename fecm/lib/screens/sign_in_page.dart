import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Tambah ini
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../providers/auth_provider.dart'; // Ganti dari auth_service ke auth_provider
import 'sign_up_page.dart';
import 'dashboard_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Update fungsi _signIn untuk pake AuthProvider
  void _signIn(AuthProvider authProvider) async {
    print('🔄 Sign in button clicked!'); // Debug print

    if (_formKey.currentState!.validate()) {
      print('✅ Form validation passed'); // Debug print

      // Clear previous errors
      authProvider.clearError();

      print('📧 Email: ${_emailController.text.trim()}'); // Debug print
      print('🔐 Password: ${_passwordController.text}'); // Debug print

      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('🎯 Login result: $success'); // Debug print

      if (success) {
        print('✅ Login successful - should navigate to dashboard');
      } else {
        print('❌ Login failed');
      }
    } else {
      print('❌ Form validation failed'); // Debug print
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
                  // Right side - Sign In Form
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
                                          'Sign in',
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
                                          'No Account ?',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SignUpPage(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Sign up',
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

                                // Social Login Button
                                SocialLoginButton(
                                  icon: Icons.login,
                                  text: 'Sign in with Google',
                                  color: Colors.blue[50]!,
                                  textColor: Colors.blue,
                                  onPressed: () {
                                    // TODO: Implement Google Sign In
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Google Sign In not implemented yet'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 30),

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
                                    return null;
                                  },
                                  onChanged: (_) => authProvider
                                      .clearError(), // Clear error saat typing
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
                                    return null;
                                  },
                                  onChanged: (_) => authProvider
                                      .clearError(), // Clear error saat typing
                                ),
                                SizedBox(height: 10),

                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Forgot password feature coming soon'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Forgot Password',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30),

                                // Sign In Button - Update untuk pake AuthProvider
                                CustomButton(
                                  text: 'Sign in',
                                  onPressed: authProvider
                                          .isLoading // Check loading state
                                      ? null
                                      : () => _signIn(
                                          authProvider), // Pass authProvider
                                  isLoading: authProvider
                                      .isLoading, // Show loading indicator
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
    _passwordController.dispose();
    super.dispose();
  }
}
