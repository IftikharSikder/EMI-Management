// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:emi_management/customers/models/loan_model.dart';
// import 'package:emi_management/utils/static_strings.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
//
//
// class EMIController extends GetxController {
//   final RxList<Map<String, dynamic>> emiList = <Map<String, dynamic>>[].obs;
//   final RxList<Map<String, dynamic>> filteredEmiList = <Map<String, dynamic>>[].obs;
//   final RxDouble totalDueAmount = 0.0.obs;
//   final RxInt pendingEMIs = 0.obs;
//   final RxBool isLoading = true.obs;
//   final RxString currentMonth = DateFormat('MMMM yyyy').format(DateTime.now()).obs;
//   final RxString searchText = ''.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchUserLoans();
//   }
//
//   void searchEMIs(String query) {
//     searchText.value = query;
//     if (query.isEmpty) {
//       filteredEmiList.value = emiList;
//     } else {
//       filteredEmiList.value = emiList
//           .where((emi) =>
//       emi['device_name'].toString().toLowerCase().contains(query.toLowerCase()) ||
//           emi['bank_name'].toString().toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     }
//   }
//
//   void clearSearch() {
//     searchText.value = '';
//     filteredEmiList.value = emiList;
//   }
//
//   Future<void> fetchUserLoans() async {
//     isLoading.value = true;
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? email = prefs.getString('email');
//
//       if (email != null) {
//         final QuerySnapshot customerSnapshot = await FirebaseFirestore.instance
//             .collection('customers')
//             .where('email', isEqualTo: email)
//             .get();
//
//         if (customerSnapshot.docs.isNotEmpty) {
//           final customerId = customerSnapshot.docs.first.id;
//           final QuerySnapshot loanSnapshot = await FirebaseFirestore.instance
//               .collection('loans')
//               .where('customer_id', isEqualTo: customerId)
//               .get();
//
//           List<Map<String, dynamic>> emis = [];
//           double totalDue = 0;
//           int pendingCount = 0;
//
//           final now = DateTime.now();
//
//           for (var loanDoc in loanSnapshot.docs) {
//             LoanModel loan = LoanModel.fromFirestore(loanDoc);
//
//             int currentMonthIndex = (now.year - loan.loanCreateDate.year) * 12 +
//                 now.month - loan.loanCreateDate.month;
//
//             for (int monthIndex = 1; monthIndex <= currentMonthIndex && monthIndex < loan.totalMonths; monthIndex++) {
//               DateTime dueDate = loan.getDueDate(monthIndex);
//
//               if (!loan.isMonthPaid(monthIndex)) {
//                 final difference = dueDate.difference(now).inDays;
//
//                 String status;
//                 if (difference < 0) {
//                   status = 'Overdue';
//                 } else if (difference == 0) {
//                   status = 'Due Today';
//                 } else {
//                   status = 'Upcoming';
//                 }
//
//                 Map<String, dynamic> emiRecord = {
//                   'loan_id': loanDoc.id,
//                   'device_name': loan.loanType,
//                   'due_date': dueDate,
//                   'month_index': monthIndex,
//                   'amount': loan.monthlyEMI,
//                   'is_overdue': dueDate.isBefore(DateTime(now.year, now.month, 1)),
//                   'is_current_month': dueDate.year == now.year && dueDate.month == now.month,
//                   'days_remaining': difference,
//                   'status': status,
//                   'bank_name': AppStrings.auroratEMIsManager,
//                 };
//
//                 emis.add(emiRecord);
//
//                 totalDue += loan.monthlyEMI;
//                 pendingCount++;
//               }
//             }
//           }
//
//           totalDueAmount.value = totalDue;
//           pendingEMIs.value = pendingCount;
//
//           emiList.clear();
//           emiList.addAll(emis);
//
//           filteredEmiList.clear();
//           filteredEmiList.addAll(emis);
//         }
//       }
//     } catch (e) {
//       // Handle error
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emi_management/customers/models/loan_model.dart';
import 'package:emi_management/utils/static_strings.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class EMIController extends GetxController {
  final RxList<Map<String, dynamic>> emiList = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredEmiList = <Map<String, dynamic>>[].obs;
  final RxDouble totalDueAmount = 0.0.obs;
  final RxInt pendingEMIs = 0.obs;
  final RxBool isLoading = true.obs;
  final RxString currentMonth = DateFormat('MMMM yyyy').format(DateTime.now()).obs;
  final RxString searchText = ''.obs;

  // For storing Firebase subscription
  StreamSubscription? _loansSubscription;
  String? _customerId;

  @override
  void onInit() {
    super.onInit();
    setupRealTimeUpdates();
  }

  void searchEMIs(String query) {
    searchText.value = query;
    if (query.isEmpty) {
      filteredEmiList.value = emiList;
    } else {
      filteredEmiList.value = emiList
          .where((emi) =>
      emi['device_name'].toString().toLowerCase().contains(query.toLowerCase()) ||
          emi['bank_name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void clearSearch() {
    searchText.value = '';
    filteredEmiList.value = emiList;
  }

  Future<void> setupRealTimeUpdates() async {
    isLoading.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');

      if (email != null) {
        // First get the customer ID
        final QuerySnapshot customerSnapshot = await FirebaseFirestore.instance
            .collection('customers')
            .where('email', isEqualTo: email)
            .get();

        if (customerSnapshot.docs.isNotEmpty) {
          _customerId = customerSnapshot.docs.first.id;

          // Set up real-time listener for loans
          _loansSubscription = FirebaseFirestore.instance
              .collection('loans')
              .where('customer_id', isEqualTo: _customerId)
              .snapshots()
              .listen((snapshot) {
            _processLoanData(snapshot);
          }, onError: (error) {
            print('Error in loan listener: $error');
            isLoading.value = false;
          });
        } else {
          isLoading.value = false;
        }
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      print('Error setting up real-time updates: $e');
      isLoading.value = false;
    }
  }

  void _processLoanData(QuerySnapshot loanSnapshot) {
    try {
      List<Map<String, dynamic>> emis = [];
      double totalDue = 0;
      int pendingCount = 0;

      final now = DateTime.now();

      for (var loanDoc in loanSnapshot.docs) {
        LoanModel loan = LoanModel.fromFirestore(loanDoc);

        int currentMonthIndex = (now.year - loan.loanCreateDate.year) * 12 +
            now.month - loan.loanCreateDate.month;

        for (int monthIndex = 1; monthIndex <= currentMonthIndex && monthIndex < loan.totalMonths; monthIndex++) {
          DateTime dueDate = loan.getDueDate(monthIndex);

          if (!loan.isMonthPaid(monthIndex)) {
            final difference = dueDate.difference(now).inDays;

            String status;
            if (difference < 0) {
              status = 'Overdue';
            } else if (difference == 0) {
              status = 'Due Today';
            } else {
              status = 'Upcoming';
            }

            Map<String, dynamic> emiRecord = {
              'loan_id': loanDoc.id,
              'device_name': loan.loanType,
              'due_date': dueDate,
              'month_index': monthIndex,
              'amount': loan.monthlyEMI,
              'is_overdue': dueDate.isBefore(DateTime(now.year, now.month, 1)),
              'is_current_month': dueDate.year == now.year && dueDate.month == now.month,
              'days_remaining': difference,
              'status': status,
              'bank_name': AppStrings.auroratEMIsManager,
            };

            emis.add(emiRecord);

            totalDue += loan.monthlyEMI;
            pendingCount++;
          }
        }
      }

      // Sort by days remaining (optional)
      emis.sort((a, b) => a['days_remaining'].compareTo(b['days_remaining']));

      // Update the observable variables
      totalDueAmount.value = totalDue;
      pendingEMIs.value = pendingCount;

      emiList.clear();
      emiList.addAll(emis);

      filteredEmiList.clear();
      filteredEmiList.addAll(emis);

      isLoading.value = false;
    } catch (e) {
      print('Error processing loan data: $e');
      isLoading.value = false;
    }
  }

  // Manual refresh method if needed
  Future<void> refreshData() async {
    if (_customerId == null) {
      await setupRealTimeUpdates();
    }
  }

  @override
  void onClose() {
    // Clean up the subscription when the controller is disposed
    _loansSubscription?.cancel();
    super.onClose();
  }
}