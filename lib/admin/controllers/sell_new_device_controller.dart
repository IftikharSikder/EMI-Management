import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:random_string/random_string.dart';
import 'package:untitled/admin/screens/dashboard_page.dart';

class SellNewDeviceController extends GetxController {
  final FocusNode? currentFocus = null;
  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Controllers
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final totalMonthController = TextEditingController();

  // Variables for selected data
  var completePhoneNumber = ''.obs;
  var countryCode = ''.obs;
  var selectedDeviceId = Rx<String?>(null);
  var selectedDevice = Rx<Map<String, dynamic>?>(null);
  var devicesList = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isExistingCustomer = false.obs;
  var isEmailExist = false.obs;
  var isEmailInvalid = false.obs;
  var isGeneratingPassword = false.obs;
  var nextCustomerId = 1.obs;

  // Variable to track if form validation should be shown
  var showValidation = false.obs;
  var showPassword = true.obs;
  var passwordGenerated = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDevices();
    fetchLastCustomerId();
  }

  @override
  void onClose() {
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    totalMonthController.dispose();
    super.onClose();
  }

  // Fetch all available devices from Firestore
  Future<void> fetchDevices() async {
    isLoading.value = true;

    try {
      final QuerySnapshot devicesSnapshot = await FirebaseFirestore.instance
          .collection('devices')
          .where('available_quantity', isGreaterThan: 0)
          .get();

      devicesList.value = devicesSnapshot.docs
          .map(
            (DocumentSnapshot doc) => {
              'id': doc.id,
              'device_name': doc['device_name'],
              'img_url': doc['img_url'],
              'unit_price': doc['unit_price'],
              'available_quantity': doc['available_quantity'],
            },
          )
          .toList();
    } catch (e) {
      //print('Error fetching devices: $e');
      Get.snackbar('Error', 'Failed to load devices: $e', snackPosition: SnackPosition.BOTTOM);
    }

    isLoading.value = false;
  }

  // Find the next customer ID by getting the maximum existing ID and adding 1
  Future<void> fetchLastCustomerId() async {
    try {
      final QuerySnapshot customersSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .get();

      if (customersSnapshot.docs.isNotEmpty) {
        int maxId = 0;
        for (var doc in customersSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('id') && data['id'] is int && data['id'] > maxId) {
            maxId = data['id'];
          }
        }
        nextCustomerId.value = maxId + 1;
      }
    } catch (e) {
      //print('Error fetching last customer ID: $e');
    }
  }

  // Check if customer exists with the given phone number
  Future<void> checkCustomerByPhone(String phone) async {
    try {
      final QuerySnapshot customerSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      isExistingCustomer.value = customerSnapshot.docs.isNotEmpty;

      if (isExistingCustomer.value) {
        final customerData = customerSnapshot.docs.first.data() as Map<String, dynamic>;
        nameController.text = customerData['name'] ?? '';
        emailController.text = customerData['email'] ?? '';
        passwordController.text = customerData['password'] ?? '';

        // Reset email validation flags for existing customer
        isEmailExist.value = false;
        isEmailInvalid.value = false;
      } else {
        // Clear fields if no customer found
        nameController.clear();
        emailController.clear();
        passwordController.clear();

        // Reset email validation flags
        isEmailExist.value = false;
        isEmailInvalid.value = false;
      }
    } catch (e) {
      //print('Error checking customer: $e');
      Get.snackbar('Error', 'Failed to check customer: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Check if email already exists in customers collection
  Future<bool> checkEmailExists(String email) async {
    if (email.isEmpty) return false;

    try {
      final QuerySnapshot emailCheck = await FirebaseFirestore.instance
          .collection('customers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return emailCheck.docs.isNotEmpty;
    } catch (e) {
      //print('Error checking email: $e');
      return false;
    }
  }

  // Validate email format with a more strict regex
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    // More strict email regex that checks for valid domains
    // This regex checks that the domain part has at least one period and that the TLD is at least 2 characters
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    // Additional check for common email domains
    if (email.endsWith('@gmail.co') ||
        email.endsWith('@yahoo.co') ||
        email.endsWith('@hotmail.co')) {
      return false; // These should probably be .com, not .co
    }

    return emailRegex.hasMatch(email);
  }

  // Generate a unique random password
  // Future<void> generatePassword() async {
  //   isGeneratingPassword.value = true;
  //
  //   bool isUnique = false;
  //   String newPassword = '';
  //
  //   try {
  //     while (!isUnique) {
  //       // Generate an 8-character password with letters and numbers
  //       newPassword = randomAlphaNumeric(8);
  //
  //       // Check if this password already exists
  //       final QuerySnapshot passwordCheck = await FirebaseFirestore.instance
  //           .collection('customers')
  //           .where('password', isEqualTo: newPassword)
  //           .limit(1)
  //           .get();
  //
  //       isUnique = passwordCheck.docs.isEmpty;
  //     }
  //
  //     passwordController.text = newPassword;
  //   } catch (e) {
  //     //print('Error generating password: $e');
  //     Get.snackbar(
  //       'Error',
  //       'Failed to generate password: $e',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   }
  //
  //   isGeneratingPassword.value = false;
  // }
  Future<void> generatePassword() async {
    // Don't allow generating again if already generated
    if (passwordGenerated.value) return;

    isGeneratingPassword.value = true;

    bool isUnique = false;
    String newPassword = '';

    try {
      while (!isUnique) {
        // Generate an 8-character password with letters and numbers
        newPassword = randomAlphaNumeric(8);

        // Check if this password already exists
        final QuerySnapshot passwordCheck = await FirebaseFirestore.instance
            .collection('customers')
            .where('password', isEqualTo: newPassword)
            .limit(1)
            .get();

        isUnique = passwordCheck.docs.isEmpty;
      }

      passwordController.text = newPassword;
      // Mark password as generated
      passwordGenerated.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate password: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isGeneratingPassword.value = false;
    }
  }

  // Handle form submission
  Future<void> handleSubmit() async {
    if (totalMonthController.text.length == 0) {
      Get.snackbar(
        "Empty",
        "Please enter total month",
        backgroundColor: Colors.blue.shade600, // Matches blue AppBar
        colorText: Colors.white, // Ensures readability
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    if (totalMonthController.text == 0) {
      Get.snackbar("", "Months must be greater than 0");
    }
    // Enable validation
    showValidation.value = true;

    // Check email format and existence before form validation
    if (!isExistingCustomer.value) {
      // Check email format
      isEmailInvalid.value = !isValidEmail(emailController.text);
      if (isEmailInvalid.value) {
        Get.snackbar(
          'Error',
          'Please enter a valid email address',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check if email exists
      if (emailController.text.isNotEmpty) {
        isEmailExist.value = await checkEmailExists(emailController.text);
        if (isEmailExist.value) {
          Get.snackbar(
            'Error',
            'Email already exists. Please use a different email.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDevice.value == null) {
      Get.snackbar('Error', 'Please select a device', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Start loading
    isLoading.value = true;

    try {
      // 1. If new customer, add to customers collection
      String customerId;
      if (!isExistingCustomer.value) {
        // Create new customer document
        DocumentReference newCustomerRef = await FirebaseFirestore.instance
            .collection('customers')
            .add({
              'email': emailController.text,
              'id': nextCustomerId.value,
              'name': nameController.text,
              'password': passwordController.text,
              'phone': completePhoneNumber.value,
            });
        customerId = newCustomerRef.id;
      } else {
        // Get existing customer ID
        final QuerySnapshot customerSnapshot = await FirebaseFirestore.instance
            .collection('customers')
            .where('phone', isEqualTo: completePhoneNumber.value)
            .limit(1)
            .get();
        customerId = customerSnapshot.docs.first.id;
      }

      // 2. Update device quantity
      DocumentReference deviceRef = FirebaseFirestore.instance
          .collection('devices')
          .doc(selectedDeviceId.value);

      // Get current quantity
      DocumentSnapshot deviceSnapshot = await deviceRef.get();
      int currentQuantity = deviceSnapshot['available_quantity'];

      if (currentQuantity <= 1) {
        // Delete the document if this is the last device
        await deviceRef.delete();
      } else {
        // Otherwise decrease the quantity
        await deviceRef.update({'available_quantity': FieldValue.increment(-1)});
      }

      // 3. Create new loan document
      await FirebaseFirestore.instance.collection('loans').add({
        'customer_id': customerId,
        'device_name': selectedDevice.value!['device_name'],
        'purchase_date': DateTime.now(),
        'total_amount': selectedDevice.value!['unit_price'],
        'total_month': int.parse(totalMonthController.text),
        'transaction_history': [],
      });

      // Success message
      Get.snackbar(
        'Success',
        'Product purchased successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearForm();
      Get.offAll(() => DashboardPage());
    } catch (e) {
      Get.snackbar('Error', 'Transaction failed: $e', snackPosition: SnackPosition.BOTTOM);
    }

    isLoading.value = false;
  }

  void resetForm() {
    showValidation.value = false;

    if (Get.focusScope != null) {
      Get.focusScope!.unfocus();
    }

    // Clear form fields
    clearForm();
  }

  // Clear all form data
  void clearForm() {
    // Reset controllers
    phoneController.clear();
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    totalMonthController.clear();

    // Reset observable states
    selectedDeviceId.value = null;
    selectedDevice.value = null;
    isExistingCustomer.value = false;
    isEmailExist.value = false;
    isEmailInvalid.value = false;
    completePhoneNumber.value = '';
    countryCode.value = '';
    passwordGenerated.value = false; // Reset the password generation flag
  }

  void selectDevice(Map<String, dynamic> device) {
    selectedDeviceId.value = device['id'];
    selectedDevice.value = device;
  }

  void updatePhoneInfo(String phone, String code) {
    completePhoneNumber.value = phone;
    countryCode.value = code;
  }

  void updateEmailExistStatus(bool exists) {
    isEmailExist.value = exists;
  }

  void updateEmailInvalidStatus(bool invalid) {
    isEmailInvalid.value = invalid;
  }
}
