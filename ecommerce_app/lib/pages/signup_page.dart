import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';
import 'signin_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedUserType = 'seller';

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        contactNumber: _contactController.text.trim(),
        userType: _selectedUserType,
        password: _passwordController.text,
        passwordConfirm: _passwordController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please sign in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _goToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
                ),
              ),
              child: Row(
                children: [
                  // Left side - Image section (same as sign in)
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 20,
                                  right: 20,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            width: 150,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Right side - Sign up form
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Container(
                            width: 400,
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: const TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Welcome to ',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: 'LOREM',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Sign up',
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: _goToSignIn,
                                        child: const Text(
                                          'Have an Account ?\nSign in',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  
                                  // Email Field
                                  const Text(
                                    'Enter your username or email address',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
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
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Name Fields
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'User name',
                                              style: TextStyle(fontSize: 14, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 8),
                                            CustomTextField(
                                              controller: _usernameController,
                                              hintText: 'User name',
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please enter username';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Contact Number',
                                              style: TextStyle(fontSize: 14, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 8),
                                            CustomTextField(
                                              controller: _contactController,
                                              hintText: 'Contact Number',
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please enter contact number';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // First Name and Last Name
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'First Name',
                                              style: TextStyle(fontSize: 14, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 8),
                                            CustomTextField(
                                              controller: _firstNameController,
                                              hintText: 'First Name',
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please enter first name';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Last Name',
                                              style: TextStyle(fontSize: 14, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 8),
                                            CustomTextField(
                                              controller: _lastNameController,
                                              hintText: 'Last Name',
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please enter last name';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // User Type Selection
                                  const Text(
                                    'User Type',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedUserType,
                                        isExpanded: true,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedUserType = newValue!;
                                          });
                                        },
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'seller',
                                            child: Text('Seller'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'admin',
                                            child: Text('Admin'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Password Field
                                  const Text(
                                    'Enter your Password',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  CustomTextField(
                                    controller: _passwordController,
                                    hintText: 'Password',
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 30),
                                  
                                  // Sign Up Button
                                  CustomButton(
                                    text: 'Sign up',
                                    onPressed: _signUp,
                                    isLoading: authProvider.isLoading,
                                  ),
                                ],
                              ),
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