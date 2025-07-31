import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {
  final authC = Get.put(AuthController());

  final emailC = TextEditingController();
  final passC = TextEditingController();
  final usernameC = TextEditingController();
  final firstNameC = TextEditingController();
  final lastNameC = TextEditingController();
  final contactNumberC = TextEditingController();
  final storeNameC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: emailC,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passC,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              TextField(
                controller: usernameC,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: firstNameC,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameC,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: contactNumberC,
                decoration: const InputDecoration(labelText: 'Contact Number'),
              ),
              TextField(
                controller: storeNameC,
                decoration: const InputDecoration(labelText: 'Store Name'),
              ),
              const SizedBox(height: 20),
              authC.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        authC.signUp(
                          email: emailC.text,
                          password: passC.text,
                          username: usernameC.text,
                          firstName: firstNameC.text,
                          lastName: lastNameC.text,
                          contactNumber: contactNumberC.text,
                          storeName: storeNameC.text,
                        );
                      },
                      child: const Text('Register'),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('Sudah punya akun? Login di sini'),
              )
            ],
          ),
        )),
      ),
    );
  }
}
