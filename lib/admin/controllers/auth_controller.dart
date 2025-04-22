import 'package:emi_management/admin/screens/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {

  final isPasswordVisible = false.obs;

  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final emailError = RxString('');
  final passwordError = RxString('');
  final isLoading = RxBool(false);

  void validateAndLogin() async{
    // Reset errors
    emailError.value = '';
    passwordError.value = '';

    // Validate email
    if (emailController.text.isEmpty) {
      emailError.value = 'Email is required';
      return;
    } else if (!GetUtils.isEmail(emailController.text)) {
      emailError.value = 'Please enter a valid email';
      return;
    }

    // Validate password
    if (passwordController.text.isEmpty) {
      passwordError.value = 'Password is required';
      return;
    } else if (passwordController.text.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      return;
    }

    // Attempt login
    isLoading.value = true;

    bool loginSuccess = await _authService.validateLogin(
        emailController.text.trim(),
        passwordController.text.trim()
    );

    isLoading.value = false;

    if (loginSuccess) {
      // Navigate to dashboard on successful login
     await _saveAdminSession(emailController.text,passwordController.text);
      Get.off(() => DashboardPage());
    } else {
      Get.snackbar(
        'Login Failed',
        'Invalid email or password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}


Future<void> _saveAdminSession(String email, String password) async {
  print("----------------------------This is called");
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool("isLogin", true);
  pref.setString("userRole",email);
  pref.setString("userRole","admin");
  pref.setString("email", email);
  pref.setString("password", password);
  //pref.setString("customerId", customerId);
}