import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  _AuthDialogState createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final AuthService authService = Get.find<AuthService>();

  bool isLogin = true; // true = login, false = register
  bool isLoading = false;

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              isLogin ? 'Login' : 'Daftar Akun',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),

            // Form
            if (!isLogin) ...[
              _buildTextField(
                controller: nameController,
                label: 'Nama Lengkap',
                icon: Icons.person,
              ),
              SizedBox(height: 16),
            ],

            _buildTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),

            _buildTextField(
              controller: passwordController,
              label: 'Password',
              icon: Icons.lock,
              obscureText: true,
            ),
            SizedBox(height: 16),

            if (!isLogin) ...[
              _buildTextField(
                controller: confirmPasswordController,
                label: 'Konfirmasi Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              SizedBox(height: 16),
            ],

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isLogin ? 'Login' : 'Daftar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 16),

            // Divider
            Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('atau', style: GoogleFonts.poppins(fontSize: 14)),
                ),
                Expanded(child: Divider()),
              ],
            ),

            SizedBox(height: 16),

            // Google Sign In Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });

                        bool success = await authService.signInWithGoogle();

                        setState(() {
                          isLoading = false;
                        });

                        if (success) {
                          Get.back();
                        }
                      },
                icon: Icon(Icons.login, color: Colors.red),
                label: Text(
                  'Login dengan Google',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Toggle Login/Register
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLogin = !isLogin;
                      _clearForm();
                    });
                  },
                  child: Text(
                    isLogin ? 'Daftar' : 'Login',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            // Forgot Password (hanya saat login)
            if (isLogin) ...[
              SizedBox(height: 8),
              GestureDetector(
                onTap: _showForgotPassword,
                child: Text(
                  'Lupa Password?',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.blue),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (_validateForm()) {
      setState(() {
        isLoading = true;
      });

      bool success;
      if (isLogin) {
        success = await authService.login(
          emailController.text.trim(),
          passwordController.text,
        );
      } else {
        success = await authService.register(
          emailController.text.trim(),
          passwordController.text,
          nameController.text.trim(),
        );
      }

      setState(() {
        isLoading = false;
      });

      if (success) {
        Get.back(); // Close dialog
      }
    }
  }

  bool _validateForm() {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Email tidak boleh kosong');
      return false;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Password tidak boleh kosong');
      return false;
    }

    if (!isLogin) {
      if (nameController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Nama tidak boleh kosong');
        return false;
      }

      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar('Error', 'Password dan konfirmasi password tidak sama');
        return false;
      }

      if (passwordController.text.length < 6) {
        Get.snackbar('Error', 'Password minimal 6 karakter');
        return false;
      }
    }

    return true;
  }

  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
  }

  void _showForgotPassword() {
    final resetEmailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Reset Password'),
        content: TextField(
          controller: resetEmailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (resetEmailController.text.trim().isNotEmpty) {
                await authService.resetPassword(
                  resetEmailController.text.trim(),
                );
                Get.back();
              }
            },
            child: Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
