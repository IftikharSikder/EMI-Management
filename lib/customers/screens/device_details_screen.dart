
import 'package:emi_management/customers/controllers/emi_controller.dart';
import 'package:emi_management/customers/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceDetailsScreen extends StatelessWidget {
   DeviceDetailsScreen({super.key});

  final EMIController emiController = Get.put(EMIController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        title: const Text(
          'Device Details',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        elevation: 0,
        actions: [
          InkWell(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ClipOval(
                child: Image.network(
                  "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            onTap: () {
              if (emiController.emiList.isNotEmpty && emiController.emiList[0]['loan_id'] != null) {
                Get.to(() => const ProfilePage(), arguments: {
                  'loan_id': emiController.emiList[0]['loan_id'],
                });
              } else {
                Get.snackbar('Error', 'Loan ID not found for profile');
              }
            },

          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                bottom: 15,
                left: 20,
                right: 20,
              ),
              child: Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/phone.png',
                    height: 160,
                    width: 160,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'iPhone 14 Pro Max',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹129,900',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const Text(
                        'Purchase Date: 15 Feb 2025',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(thickness: 6, color: Color(0xFFF9FAFB)),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Active EMI Plan',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('EMI Details'),
                  const SizedBox(height: 8),
                  _buildDetailRow('EMI Amount', '₹10,825/month'),
                  _buildDetailRow('Total Tenure', '12 months'),
                  _buildDetailRow('EMIs Paid', '4 of 12'),
                  _buildDetailRow(
                    'Next Due Date',
                    '15 Feb 2025',
                    isColoredText: true,
                  ),
                ],
              ),
            ),

            Divider(thickness: 6, color: Color(0xFFF9FAFB)),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Device Specifications'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Storage', '256 GB'),
                  _buildDetailRow('Color', 'Deep Purple'),
                  _buildDetailRow('IMEI Number', '356738294527163'),
                  _buildDetailRow('Serial Number', 'FCDW8KLJH2P9'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isColoredText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isColoredText ? FontWeight.w500 : FontWeight.normal,
              color: isColoredText ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
