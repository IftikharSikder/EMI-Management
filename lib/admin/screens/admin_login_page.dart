import 'package:emi_management/role_selection_page.dart';
import 'package:emi_management/utils/static_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AdminLoginPage extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.blue,
                    size: 36,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  AppStrings.auroratEMIsManager,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 32),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bank icon

                        // Email field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Address',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: controller.emailController,
                              decoration: InputDecoration(
                                hintText: 'Enter Email',
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                //fillColor: Colors.grey[100],
                                fillColor: Colors.grey.shade50,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            Obx(() => controller.emailError.value.isNotEmpty
                                ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                controller.emailError.value,
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            )
                                : SizedBox.shrink()
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Password field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),

                            Obx(() => TextField(
                              controller: controller.passwordController,
                              obscureText: !controller.isPasswordVisible.value,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                                hintText: 'Enter Password',
                                hintStyle: TextStyle(color: Colors.grey),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    controller.isPasswordVisible.value = !controller.isPasswordVisible.value;
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                //fillColor: Colors.grey[100],
                                fillColor: Colors.grey.shade50,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                // Rest of your decoration remains the same
                              ),
                            )),

                            Obx(() => controller.passwordError.value.isNotEmpty
                                ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                controller.passwordError.value,
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            )
                                : SizedBox.shrink()
                            ),
                          ],
                        ),
                        SizedBox(height: 32),

                        // Login button
                        Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.validateAndLogin,
                          child: controller.isLoading.value
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text('Login'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )),
                        SizedBox(height: 16),

                        // Forgot password
                        TextButton(
                          onPressed: () {
                            Get.off(RoleSelectionPage());
                          },
                          child: Text(
                            "You're not a Admin? Click Here",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}