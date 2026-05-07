import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/customers/controllers/emi_controller.dart';
import 'package:untitled/customers/screens/profile_page.dart';

import 'device_details_screen.dart';
import 'emi_details_screen.dart';

class UpcomingEmi extends StatelessWidget {
  UpcomingEmi({super.key});

  final EMIController emiController = Get.put(EMIController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Upcoming EMI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
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
                Get.to(
                  () => const ProfilePage(),
                  arguments: {'loan_id': emiController.emiList[0]['loan_id']},
                );
              } else {
                Get.snackbar('Error', 'Loan ID not found for profile');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: TextField(
                onChanged: (value) {
                  emiController.searchEMIs(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by device name',
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                  suffixIcon: Obx(
                    () => emiController.searchText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              emiController.clearSearch();
                            },
                          )
                        : SizedBox(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

            Obx(
              () => emiController.filteredEmiList.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: Colors.blue[300]),
                            const SizedBox(height: 16),
                            Text(
                              emiController.emiList.isEmpty
                                  ? 'No EMIs due this month'
                                  : 'No matching EMIs found',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: emiController.filteredEmiList.length,
                        itemBuilder: (context, index) {
                          final emi = emiController.filteredEmiList[index];
                          final daysText = emi['days_remaining'] < 0
                              ? '${-emi['days_remaining']} days ago'
                              : emi['days_remaining'] == 0
                              ? 'Today'
                              : '${emi['days_remaining']} days left';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.07),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: emi['status'] == 'Overdue'
                                  ? Border.all(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Get.to(
                                    () => EmiDetailsScreen(),
                                    arguments: {
                                      'loan_id': emi['loan_id'],
                                      'device_name': emi['device_name'],
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 6,
                                    left: 16,
                                    right: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.smartphone,
                                              color: Colors.blue[700],
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    '${emi['device_name']}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                  // IconButton(onPressed: (){
                                                  //   Get.to(DeviceDetailsScreen());
                                                  // }, icon: Icon(Icons.add))
                                                  SizedBox(width: 10),
                                                  InkWell(
                                                    child: Container(
                                                      padding: EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Color(0xFF1976D2),
                                                        ),
                                                        //color: Colors.blue,
                                                        borderRadius: BorderRadius.circular(14),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "details",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Get.to(DeviceDetailsScreen());
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                emi['bank_name'],
                                                style: TextStyle(
                                                  color: Colors.black.withValues(alpha: .5),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: emi['status'] == 'Overdue'
                                                  ? const Color(0xFFFFEAEA)
                                                  : emi['status'] == 'Due Today'
                                                  ? const Color(0xFFFFF4EA)
                                                  : const Color(0xFFEAFFEF),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              emi['status'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: emi['status'] == 'Overdue'
                                                    ? Colors.red[700]
                                                    : emi['status'] == 'Due Today'
                                                    ? Colors.orange[700]
                                                    : Colors.green[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 9, bottom: 6),
                                        child: Divider(
                                          color: Colors.blue.withValues(alpha: 0.07),
                                          height: 1,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Amount',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '₹${emi['amount'].toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Due Date',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time_filled,
                                                    size: 14,
                                                    color: emi['status'] == 'Overdue'
                                                        ? Colors.red[800]
                                                        : emi['status'] == 'Due Today'
                                                        ? Colors.orange[800]
                                                        : Colors.blue[800],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    daysText,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: emi['status'] == 'Overdue'
                                                          ? Colors.red[800]
                                                          : emi['status'] == 'Due Today'
                                                          ? Colors.orange[800]
                                                          : Colors.blue[800],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
