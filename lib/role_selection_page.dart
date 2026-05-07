import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'admin/screens/admin_login_page.dart';
import 'customers/screens/customer_login_screen.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF4E64F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.view_in_ar, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 20),

              // Welcome Text
              const Text(
                'Welcome to Aurora',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),

              // Selection Text
              const Text(
                'Please select your role to continue',
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),

              // Customer Role Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoleButton(
                  title: 'Customer',
                  description: 'Browse products and make purchases',
                  icon: Icons.person,
                  backgroundColor: const Color(0xFF619FFF),
                  onTap: () {
                    Get.to(CustomerLoginScreen());
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Admin Role Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoleButton(
                  title: 'Admin',
                  description: 'Manage products and orders',
                  icon: Icons.shield,
                  backgroundColor: const Color(0xFFAC8EFF),
                  onTap: () {
                    Get.to(() => AdminLoginPage());
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Support Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Need help? ',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4E64F9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;

  const RoleButton({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
