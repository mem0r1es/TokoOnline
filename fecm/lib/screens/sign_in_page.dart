import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../providers/auth_provider.dart';
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Clear previous errors
    authProvider.clearError();

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      // Navigation akan di-handle oleh AuthWrapper
      print('Login successful');
    }
    // Error sudah di-handle oleh AuthProvider dan akan ditampilkan di UI
  }

  Future<void> _handleGoogleSignIn(AuthProvider authProvider) async {
    authProvider.clearError();

    final success = await authProvider.signInWithGoogle();

    if (success) {
      print('Google Sign In successful');
      // Navigation akan di-handle oleh AuthWrapper
    }
    // Error sudah di-handle oleh AuthProvider dan akan ditampilkan di UI
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Forgot password feature coming soon!'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<AuthProvider>(
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

                                // Error Message
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

                                // Google Sign In Button
                                SocialLoginButton(
                                  icon: Icons.login,
                                  text: authProvider.isLoading
                                      ? 'Signing in...'
                                      : 'Sign in with Google',
                                  color: Colors.blue[50]!,
                                  textColor: Colors.blue,
                                  onPressed: authProvider.isLoading
                                      ? () {}
                                      : () => _handleGoogleSignIn(authProvider),
                                ),

                                SizedBox(height: 30),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                        child:
                                            Divider(color: Colors.grey[300])),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'Or continue with email',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child:
                                            Divider(color: Colors.grey[300])),
                                  ],
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
                                  onChanged: (_) => authProvider.clearError(),
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
                                  onChanged: (_) => authProvider.clearError(),
                                ),
                                SizedBox(height: 10),

                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: _handleForgotPassword,
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

                                // Sign In Button
                                CustomButton(
                                  text: 'Sign in',
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () => _signIn(authProvider),
                                  isLoading: authProvider.isLoading,
                                ),

                                SizedBox(height: 20),

                                // Auth method info
                                if (authProvider.authMethod != 'none') ...[
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.green.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                            authProvider.authMethod == 'google'
                                                ? Icons.account_circle
                                                : Icons.email,
                                            color: Colors.green.shade600,
                                            size: 16),
                                        SizedBox(width: 8),
                                        Text(
                                          'Last signed in with ${authProvider.authMethod == 'google' ? 'Google' : 'Email'}',
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
}
