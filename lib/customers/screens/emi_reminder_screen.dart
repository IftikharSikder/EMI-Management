// import 'package:emi_management/customers/controllers/emi_controller.dart';
// import 'package:emi_management/customers/screens/emi_details_screen.dart';
// import 'package:emi_management/customers/screens/profile_page.dart';
// import 'package:emi_management/customers/screens/upcoming_emi.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
//
// class EMIReminderScreen extends StatefulWidget {
//   const EMIReminderScreen({super.key});
//
//   @override
//   State<EMIReminderScreen> createState() => _EMIReminderScreenState();
// }
//
// class _EMIReminderScreenState extends State<EMIReminderScreen> {
//   final EMIController emiController = Get.put(EMIController());
//
//   final RxBool notificationAlertEnabled = true.obs;
//   final RxBool emailAlertEnabled = false.obs;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedPreferences();
//     getUserNamePass();
//
//     ever(emiController.isLoading, (isLoading) {
//       if (!isLoading) {
//         _checkForOverdueEMIs();
//       }
//     });
//   }
//   getUserNamePass(){
//
//   }
//
//   void _checkForOverdueEMIs() {
//     if (emiController.emiList.isNotEmpty) {
//       final overdueEmi = emiController.emiList.firstWhereOrNull(
//             (emi) => emi['status'] == 'Overdue',
//       );
//
//       if (overdueEmi != null) {
//         final dueDate = DateTime.now().subtract(Duration(days: overdueEmi['days_remaining'].abs()));
//
//         // Future.delayed(Duration(seconds: 3),(()=>Get.off(() => DeviceLockedScreen(
//         //   dueDate: dueDate,
//         //   amountDue: overdueEmi['amount'],
//         // ))));
//       }
//     }
//   }
//
//   Future<void> _loadSavedPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     notificationAlertEnabled.value = prefs.getBool('notificationAlertEnabled') ?? true;
//
//     emailAlertEnabled.value = prefs.getBool('emailAlertEnabled') ?? false;
//   }
//
//   Future<void> _savePreferences(String key, bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(key, value);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue[50],
//       appBar: AppBar(
//         title: const Text(
//           'EMI Reminders',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue[700],
//         elevation: 0,
//         actions: [
//           InkWell(
//             child: Padding(
//               padding: const EdgeInsets.only(right: 10.0),
//               child: ClipOval(
//                 child: Image.network(
//                   "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
//                   width: 28,
//                   height: 28,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             onTap: () {
//               // if (emiController.emiList.isNotEmpty && emiController.emiList[0]['loan_id'] != null) {
//               //   Get.to(() => const ProfilePage(), arguments: {
//               //     'loan_id': emiController.emiList[0]['loan_id'],
//               //   });
//               // } else {
//               //   Get.snackbar('Error', 'Loan ID not found for profile');
//               // }
//               Get.to(ProfilePage());
//             },
//
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (emiController.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.calendar_today, color: Colors.blue[700], size: 20),
//                           const SizedBox(width: 8),
//                           const Text(
//                             "This Month's Summary",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.blue[700],
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           emiController.currentMonth.value,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       // Total Due Card
//                       Expanded(
//                         child: Container(
//                           height: 120,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [Colors.blue[400]!, Colors.blue[600]!],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.blue.withValues(alpha: 0.3),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Row(
//                                 children: [
//                                   Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     'Total Due',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 '₹${emiController.totalDueAmount.value.toStringAsFixed(0)}',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 24,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               Row(
//                                 children: List.generate(5, (index) {
//                                   return Container(
//                                     width: 8,
//                                     height: 8,
//                                     margin: const EdgeInsets.only(right: 5),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white.withValues(alpha: 0.7),
//                                       shape: BoxShape.circle,
//                                     ),
//                                   );
//                                 }),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       // Pending EMIs Card
//                       Expanded(
//                         child: Container(
//                           height: 120,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withValues(alpha: 0.2),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(Icons.notifications_active, color: Colors.orange[700], size: 22),
//                                   const SizedBox(width: 8),
//                                   const Text(
//                                     'Pending EMIs',
//                                     style: TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 '${emiController.pendingEMIs.value}',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 24,
//                                   color: Colors.blue[800],
//                                 ),
//                               ),
//                               Container(
//                                 height: 8,
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   color: emiController.pendingEMIs.value > 3 ?
//                                   Colors.red[400] : Colors.green[400],
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 14),
//
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     ' Upcoming EMIs',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Get.to(UpcomingEmi());
//                     },
//                     child: const Text('View All'),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 8),
//
//               Expanded(
//                 child:
//                 emiController.emiList.isEmpty
//                     ? const Center(child: Text('No EMIs due this month'))
//                     : ListView.builder(
//                   itemCount: emiController.emiList.length>2?2:emiController.emiList.length,
//                   itemBuilder: (context, index) {
//                     final emi = emiController.emiList[index];
//                     final daysText =
//                     emi['days_remaining'] < 0
//                         ? '${-emi['days_remaining']} days ago'
//                         : emi['days_remaining'] == 0
//                         ? 'Today'
//                         : '${emi['days_remaining']} days left';
//
//                     Color statusColor;
//                     if (emi['status'] == 'Overdue') {
//                       statusColor = Colors.red[100]!;
//                     } else if (emi['status'] == 'Due Today') {
//                       statusColor = Colors.orange[100]!;
//                     } else {
//                       statusColor = Colors.green[100]!;
//                     }
//
//                     return Card(
//                       color: Colors.white,
//                       elevation: 1,
//                       margin: const EdgeInsets.only(bottom: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: InkWell(
//                         onTap: () {
//                           Get.to(
//                                 () => EmiDetailsScreen(),
//                             arguments: {
//                               'loan_id': emi['loan_id'],
//                               'device_name': emi['device_name'],
//                             },
//                           );
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Row(
//                             crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             '${emi['device_name']}',
//                                             style: const TextStyle(
//                                               fontWeight:
//                                               FontWeight.bold,
//                                               fontSize: 16,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       emi['bank_name'],
//                                       style: TextStyle(
//                                         color: Colors.grey[600],
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 12),
//                                     Text(
//                                       '₹${emi['amount'].toStringAsFixed(0)}',
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Column(
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 4,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: statusColor,
//                                       borderRadius:
//                                       BorderRadius.circular(4),
//                                     ),
//                                     child: Text(
//                                       emi['status'],
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color:
//                                         emi['status'] == 'Overdue'
//                                             ? Colors.red[800]
//                                             : emi['status'] ==
//                                             'Due Today'
//                                             ? Colors.orange[800]
//                                             : Colors.green[800],
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(height: 20),
//                                   const Text(
//                                     'Due Date',
//                                     style: TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     daysText,
//                                     style: TextStyle(
//                                       color:
//                                       emi['status'] == 'Overdue'
//                                           ? Colors.red[800]
//                                           : emi['status'] ==
//                                           'Due Today'
//                                           ? Colors.orange[800]
//                                           : Colors.black87,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//               const Text(
//                 ' Reminder Settings',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Card(
//                 color: Colors.white,
//                 elevation: 1,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.notifications_active,
//                             color: Colors.blue,
//                           ),
//                           const SizedBox(width: 12),
//                           const Expanded(
//                             child: Text(
//                               'Notification Alert',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                           Obx(() => Switch(
//                             value: notificationAlertEnabled.value,
//                             onChanged: (value) {
//                               notificationAlertEnabled.value = value;
//                               _savePreferences('notificationAlertEnabled', value);
//                             },
//                             activeColor: Colors.blue,
//                           )),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(Icons.email_outlined, color: Colors.blue),
//                           const SizedBox(width: 12),
//                           const Expanded(
//                             child: Text(
//                               'Email Alert',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                           Obx(() => Switch(
//                             value: emailAlertEnabled.value,
//                             onChanged: (value) {
//                               emailAlertEnabled.value = value;
//                               _savePreferences('emailAlertEnabled', value);
//                             },
//                             activeColor: Colors.blue,
//                           )),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }


import 'package:emi_management/customers/controllers/emi_controller.dart';
import 'package:emi_management/customers/screens/emi_details_screen.dart';
import 'package:emi_management/customers/screens/profile_page.dart';
import 'package:emi_management/customers/screens/upcoming_emi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EMIReminderScreen extends StatefulWidget {
  const EMIReminderScreen({super.key});

  @override
  State<EMIReminderScreen> createState() => _EMIReminderScreenState();
}

class _EMIReminderScreenState extends State<EMIReminderScreen> {
  final EMIController emiController = Get.put(EMIController());

  final RxBool notificationAlertEnabled = true.obs;
  final RxBool emailAlertEnabled = false.obs;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();

    // React to changes in the EMI list
    ever(emiController.emiList, (_) {
      _checkForOverdueEMIs();
    });
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    notificationAlertEnabled.value = prefs.getBool('notificationAlertEnabled') ?? true;
    emailAlertEnabled.value = prefs.getBool('emailAlertEnabled') ?? false;
  }

  void _checkForOverdueEMIs() {
    if (emiController.emiList.isNotEmpty) {
      final overdueEmi = emiController.emiList.firstWhereOrNull(
            (emi) => emi['status'] == 'Overdue',
      );

      if (overdueEmi != null) {
        final dueDate = DateTime.now().subtract(Duration(days: overdueEmi['days_remaining'].abs()));
        // Your device locking logic here
      }
    }
  }

  Future<void> _savePreferences(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text(
          'EMI Reminders',
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
              Get.to(() => const ProfilePage());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Manual refresh
          await emiController.refreshData();
        },
        child: Obx(() {
          if (emiController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              "This Month's Summary",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            emiController.currentMonth.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Total Due Card
                        Expanded(
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      'Total Due',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₹${emiController.totalDueAmount.value.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(right: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Pending EMIs Card
                        Expanded(
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.notifications_active, color: Colors.orange[700], size: 22),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Pending EMIs',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${emiController.pendingEMIs.value}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                Container(
                                  height: 8,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: emiController.pendingEMIs.value > 3 ?
                                    Colors.red[400] : Colors.green[400],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      ' Upcoming EMIs',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() =>  UpcomingEmi());
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Expanded(
                  child:
                  emiController.emiList.isEmpty
                      ? const Center(child: Text('No EMIs due this month'))
                      : ListView.builder(
                    itemCount: emiController.emiList.length > 2 ? 2 : emiController.emiList.length,
                    itemBuilder: (context, index) {
                      final emi = emiController.emiList[index];
                      final daysText =
                      emi['days_remaining'] < 0
                          ? '${-emi['days_remaining']} days ago'
                          : emi['days_remaining'] == 0
                          ? 'Today'
                          : '${emi['days_remaining']} days left';

                      Color statusColor;
                      if (emi['status'] == 'Overdue') {
                        statusColor = Colors.red[100]!;
                      } else if (emi['status'] == 'Due Today') {
                        statusColor = Colors.orange[100]!;
                      } else {
                        statusColor = Colors.green[100]!;
                      }

                      return Card(
                        color: Colors.white,
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(
                                  () =>  EmiDetailsScreen(),
                              arguments: {
                                'loan_id': emi['loan_id'],
                                'device_name': emi['device_name'],
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${emi['device_name']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        emi['bank_name'],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '₹${emi['amount'].toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        emi['status'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: emi['status'] == 'Overdue'
                                              ? Colors.red[800]
                                              : emi['status'] == 'Due Today'
                                              ? Colors.orange[800]
                                              : Colors.green[800],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Due Date',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      daysText,
                                      style: TextStyle(
                                        color: emi['status'] == 'Overdue'
                                            ? Colors.red[800]
                                            : emi['status'] == 'Due Today'
                                            ? Colors.orange[800]
                                            : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  ' Reminder Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Notification Alert',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Obx(() => Switch(
                              value: notificationAlertEnabled.value,
                              onChanged: (value) {
                                notificationAlertEnabled.value = value;
                                _savePreferences('notificationAlertEnabled', value);
                              },
                              activeColor: Colors.blue,
                            )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, color: Colors.blue),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Email Alert',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Obx(() => Switch(
                              value: emailAlertEnabled.value,
                              onChanged: (value) {
                                emailAlertEnabled.value = value;
                                _savePreferences('emailAlertEnabled', value);
                              },
                              activeColor: Colors.blue,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}