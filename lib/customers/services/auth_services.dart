import 'package:emi_management/customers/models/customer_model.dart';
import 'package:emi_management/customers/screens/emi_reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String fullPhoneNumber = '';

  final formKey = GlobalKey<FormState>();

  var currentStepName = 'Personal Details'.obs;
  var passwordStrength = 'Weak'.obs;
  var passwordStrengthValue = 0.0.obs;
  var showPassword = false.obs;
  var isLoading = false.obs;

  var nameValid = false.obs;
  var emailValid = false.obs;
  var phoneValid = false.obs;
  var passwordValid = false.obs;

  int get completedStepsCount {
    int count = 0;
    if (nameValid.value) count++;
    if (emailValid.value) count++;
    if (phoneValid.value) count++;
    if (passwordValid.value) count++;
    return count;
  }

  double get progressValue {
    return completedStepsCount / 4.0;
  }

  @override
  void onInit() {
    super.onInit();

    fullNameController.addListener(_validateName);
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
  }

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  void _validateName() {
    nameValid.value = fullNameController.text.trim().isNotEmpty;
  }

  void _validateEmail() {
    emailValid.value = GetUtils.isEmail(emailController.text.trim());
  }

  void _validatePassword() {
    passwordValid.value = passwordController.text.length >= 8;
    updatePasswordStrength(passwordController.text);
  }

  void updatePhoneValidation(String phoneNumber) {
    phoneValid.value = phoneNumber.length >= 10;
  }

  void updatePasswordStrength(String password) {
    if (password.isEmpty) {
      passwordStrength.value = 'Weak';
      passwordStrengthValue.value = 0.0;
      return;
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length >= 8;

    int strength = 0;
    if (hasUppercase) strength++;
    if (hasDigits) strength++;
    if (hasLowercase) strength++;
    if (hasSpecialCharacters) strength++;
    if (hasMinLength) strength++;

    if (strength <= 2) {
      passwordStrength.value = 'Weak';
      passwordStrengthValue.value = 0.3;
    } else if (strength == 3) {
      passwordStrength.value = 'Medium';
      passwordStrengthValue.value = 0.5;
    } else if (strength == 4) {
      passwordStrength.value = 'Strong';
      passwordStrengthValue.value = 0.8;
    } else {
      passwordStrength.value = 'Very Strong';
      passwordStrengthValue.value = 1.0;
    }
  }

  Color getPasswordStrengthColor() {
    switch (passwordStrength.value) {
      case 'Weak':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Strong':
        return Colors.green;
      case 'Very Strong':
        return Colors.green.shade800;
      default:
        return Colors.red;
    }
  }

  Future<bool> isEmailAlreadyExists(String email) async {
    final QuerySnapshot result = await _firestore
        .collection('customers')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<void> createAccount() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final String email = emailController.text.trim();
      final bool emailExists = await isEmailAlreadyExists(email);

      if (emailExists) {
        Get.snackbar(
          'Error',
          'You already have an account with this email. Please try another one.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
        isLoading.value = false;
        return;
      }

      int nextId = 1;
      final customersSnapshot = await _firestore.collection('customers').get();
      if (customersSnapshot.docs.isNotEmpty) {
        final latestUser = customersSnapshot.docs
            .map((doc) => UserModel.fromJson(doc.data()))
            .reduce((a, b) => a.id > b.id ? a : b);
        nextId = latestUser.id + 1;
      }

      final user = UserModel(
        id: nextId,
        name: fullNameController.text.trim(),
        email: email,
        phone: fullPhoneNumber.isNotEmpty ? fullPhoneNumber : phoneController.text.trim(),
        password: passwordController.text,
      );

      await _firestore.collection('customers').add(user.toJson());

      Get.snackbar(
        'Success',
        'Account created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      // SharedPreferences pref = await SharedPreferences.getInstance();
      // pref.setBool("isLogin", true);
      // pref.setString("email", email);
      // pref.setString("password", passwordController.text);
      // Get.offAll(EMIReminderScreen());

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create account: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.removeListener(_validateName);
    emailController.removeListener(_validateEmail);
    passwordController.removeListener(_validatePassword);

    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}


bool isLogin = false;
String userRole = "";
String userEmail = "";
String userPassWord = "";
getData()async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  isLogin = pref.getBool("isLogin")??false;
  userRole = pref.getString("userRole")??"";
  userEmail = pref.getString("email")??"";
  userPassWord = pref.getString("password")??"";
}