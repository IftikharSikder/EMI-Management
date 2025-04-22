// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class CustomerController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final RxList<Map<String, dynamic>> customers = <Map<String, dynamic>>[].obs;
//   final RxMap<String, List<Map<String, dynamic>>> customerLoans = <String, List<Map<String, dynamic>>>{}.obs;
//   final RxBool isLoading = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchCustomers();
//   }
//
//   Future<void> fetchCustomers() async {
//     isLoading.value = true;
//     try {
//       final customersSnapshot = await _firestore.collection('customers').get();
//       final List<Map<String, dynamic>> customersList = [];
//
//       for (final doc in customersSnapshot.docs) {
//         customersList.add({
//           'id': doc.id,
//           'name': doc.data()['name'] ?? 'Unknown',
//           'email': doc.data()['email'] ?? '',
//           'phone': doc.data()['phone'] ?? '',
//           'password': doc.data()['password'],
//           'profileImage': doc.data()['profile_image'],
//         });
//       }
//
//       customers.value = customersList;
//
//       // Now fetch loans for each customer
//       await fetchCustomerLoans();
//     } catch (e) {
//       print('Error fetching customers: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> fetchCustomerLoans() async {
//     try {
//       final loansSnapshot = await _firestore.collection('loans').get();
//       final Map<String, List<Map<String, dynamic>>> loansMap = {};
//
//       // Initialize the loans map for all customers
//       for (final customer in customers) {
//         loansMap[customer['id']] = [];
//       }
//
//       // Process each loan document
//       for (final doc in loansSnapshot.docs) {
//         final data = doc.data();
//         String customerId = data['customer_id'] ?? '';
//
//         // Trim and normalize the customer ID
//         customerId = customerId.trim();
//
//         if (customerId.isNotEmpty) {
//           // Build the loan data object
//           final DateTime purchaseDate = data['purchase_date'] is Timestamp
//               ? (data['purchase_date'] as Timestamp).toDate()
//               : DateTime.now();
//
//           // Parse transaction history
// // Parse transaction history
//           // Parse transaction history
//           List<Map<String, dynamic>> transactions = [];
//           if (data['transaction_history'] != null) {
//             if (data['transaction_history'] is Map) {
//               // Parse as map (original logic)
//               final transactionData = data['transaction_history'] as Map<String, dynamic>;
//               transactionData.forEach((key, value) {
//                 if (value is Map) {
//                   DateTime transactionDate;
//                   if (value['date'] is Timestamp) {
//                     transactionDate = (value['date'] as Timestamp).toDate();
//                   } else {
//                     transactionDate = DateTime.now();
//                   }
//
//                   transactions.add({
//                     'date': transactionDate,
//                     'amount': value['amount'] ?? 0.0,
//                   });
//                 }
//               });
//             } else if (data['transaction_history'] is List) {
//               // Calculate the monthly EMI based on total amount and months
//               final double totalAmount = (data['total_amount'] ?? 0).toDouble();
//               final int totalMonths = data['total_month'] ?? 12;
//               final double calculatedMonthlyEMI = totalAmount / totalMonths;
//
//               // Parse as list (new logic for array-style transaction history)
//               final transactionList = data['transaction_history'] as List;
//               for (var item in transactionList) {
//                 if (item is Timestamp) {
//                   transactions.add({
//                     'date': item.toDate(),
//                     'amount': calculatedMonthlyEMI, // Use calculated monthly EMI
//                   });
//                 }
//               }
//             }
//           }
//
//           final loanData = {
//             'id': doc.id,
//             'deviceName': data['device_name'] ?? 'Unknown Device',
//             'purchaseDate': purchaseDate,
//             'totalAmount': (data['total_amount'] ?? 0).toDouble(),
//             'totalMonths': data['total_month'] ?? 12,
//             'transactions': transactions,
//             'status': _calculateStatus(
//                 data['purchase_date'],
//                 transactions,
//                 data['total_month'] ?? 12
//             ),
//           };
//
//           // Try to find an exact match first
//           if (loansMap.containsKey(customerId)) {
//             loansMap[customerId]!.add(loanData);
//           } else {
//             // If no direct match, try case-insensitive search
//             String? matchingCustomerId;
//             for (final id in loansMap.keys) {
//               if (id.toLowerCase() == customerId.toLowerCase()) {
//                 matchingCustomerId = id;
//                 break;
//               }
//             }
//
//             if (matchingCustomerId != null) {
//               loansMap[matchingCustomerId]!.add(loanData);
//             } else {
//               // Create a new entry if no match found
//               loansMap[customerId] = [loanData];
//               print('Created new entry for unmatched customer ID: $customerId');
//             }
//           }
//         }
//       }
//
//       customerLoans.value = loansMap;
//
//       // Debug print all customer IDs and their loan counts
//       loansMap.forEach((key, value) {
//         print('Customer ID: $key, Loan count: ${value.length}');
//       });
//
//     } catch (e) {
//       print('Error fetching loans: $e');
//     }
//   }
//
//   String _calculateStatus(dynamic purchaseDate, List<Map<String, dynamic>> transactions, int totalMonths) {
//     // Debug print to verify transaction count vs total months
//     print("Transaction count: ${transactions.length}, Total months: $totalMonths");
//
//     // If total payments equal or exceed total months, then paid off
//     if (transactions.length >= totalMonths) {
//       return 'Paid Off';
//     }
//
//     final currentDate = DateTime.now();
//     DateTime purchaseDateTime;
//
//     // Convert purchase date to DateTime
//     if (purchaseDate is Timestamp) {
//       purchaseDateTime = purchaseDate.toDate();
//     } else {
//       // Fallback if purchase date is not available
//       purchaseDateTime = DateTime.now().subtract(Duration(days: 30));
//     }
//
//     // If no transactions yet, check if first payment is due
//     if (transactions.isEmpty) {
//       // First payment is due one month after purchase
//       DateTime firstPaymentDue = DateTime(
//         purchaseDateTime.year,
//         purchaseDateTime.month + 1,
//         purchaseDateTime.day,
//       );
//
//       // If past due date with no payment
//       if (currentDate.isAfter(firstPaymentDue)) {
//         return 'Overdue';
//       } else {
//         return 'Active';
//       }
//     }
//
//     // Sort transactions by date
//     transactions.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
//
//     // Get last payment date
//     DateTime lastPaymentDate = transactions.last['date'] as DateTime;
//
//     // Calculate next payment date (one month after last payment)
//     DateTime nextPaymentDue = DateTime(
//       lastPaymentDate.year,
//       lastPaymentDate.month + 1,
//       lastPaymentDate.day,
//     );
//
//     // If more than a month has passed since last payment and not fully paid
//     if (currentDate.isAfter(nextPaymentDue) && transactions.length < totalMonths) {
//       return 'Overdue';
//     }
//
//     // Otherwise active
//     return 'Active';
//   }
//
//   List<Map<String, dynamic>> getLoansForCustomer(String customerId) {
//     // Try direct lookup first
//     if (customerLoans.containsKey(customerId)) {
//       return customerLoans[customerId] ?? [];
//     }
//
//     // Try case insensitive lookup
//     for (final key in customerLoans.keys) {
//       if (key.toLowerCase() == customerId.toLowerCase()) {
//         return customerLoans[key] ?? [];
//       }
//     }
//
//     return [];
//   }
//
//   Map<String, int> getEmiStatusCounts(String customerId) {
//     final loans = getLoansForCustomer(customerId);
//     final Map<String, int> statusCounts = {
//       'Active': 0,
//       'Paid Off': 0,
//       'Overdue': 0,
//     };
//
//     for (final loan in loans) {
//       final status = loan['status'] ?? 'Active';
//       statusCounts[status] = (statusCounts[status] ?? 0) + 1;
//     }
//
//     return statusCounts;
//   }
//
//   int getDevicesCount(String customerId) {
//     return getLoansForCustomer(customerId).length;
//   }
// }


import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> customers = <Map<String, dynamic>>[].obs;
  final RxMap<String, List<Map<String, dynamic>>> customerLoans = <String, List<Map<String, dynamic>>>{}.obs;
  final RxBool isLoading = false.obs;

  // Stream subscriptions
  StreamSubscription<QuerySnapshot>? _customersSubscription;
  StreamSubscription<QuerySnapshot>? _loansSubscription;

  @override
  void onInit() {
    super.onInit();
    setupCustomersListener();
  }

  @override
  void onClose() {
    // Clean up subscriptions
    _customersSubscription?.cancel();
    _loansSubscription?.cancel();
    super.onClose();
  }

  void setupCustomersListener() {
    isLoading.value = true;
    try {
      _customersSubscription = _firestore.collection('customers')
          .snapshots()
          .listen((customersSnapshot) {
        final List<Map<String, dynamic>> customersList = [];

        for (final doc in customersSnapshot.docs) {
          customersList.add({
            'id': doc.id,
            'name': doc.data()['name'] ?? 'Unknown',
            'email': doc.data()['email'] ?? '',
            'phone': doc.data()['phone'] ?? '',
            'password': doc.data()['password'],
            'profileImage': doc.data()['profile_image'],
          });
        }

        customers.value = customersList;

        // Now fetch loans for each customer
        setupLoansListener();
      }, onError: (e) {
        print('Error in customers stream: $e');
        isLoading.value = false;
      });
    } catch (e) {
      print('Error setting up customers listener: $e');
      isLoading.value = false;
    }
  }

  void setupLoansListener() {
    try {
      _loansSubscription = _firestore.collection('loans')
          .snapshots()
          .listen((loansSnapshot) {
        final Map<String, List<Map<String, dynamic>>> loansMap = {};

        // Initialize the loans map for all customers
        for (final customer in customers) {
          loansMap[customer['id']] = [];
        }

        // Process each loan document
        for (final doc in loansSnapshot.docs) {
          final data = doc.data();
          String customerId = data['customer_id'] ?? '';

          // Trim and normalize the customer ID
          customerId = customerId.trim();

          if (customerId.isNotEmpty) {
            // Build the loan data object
            final DateTime purchaseDate = data['purchase_date'] is Timestamp
                ? (data['purchase_date'] as Timestamp).toDate()
                : DateTime.now();

            // Parse transaction history
            List<Map<String, dynamic>> transactions = [];
            if (data['transaction_history'] != null) {
              if (data['transaction_history'] is Map) {
                // Parse as map (original logic)
                final transactionData = data['transaction_history'] as Map<String, dynamic>;
                transactionData.forEach((key, value) {
                  if (value is Map) {
                    DateTime transactionDate;
                    if (value['date'] is Timestamp) {
                      transactionDate = (value['date'] as Timestamp).toDate();
                    } else {
                      transactionDate = DateTime.now();
                    }

                    transactions.add({
                      'date': transactionDate,
                      'amount': value['amount'] ?? 0.0,
                    });
                  }
                });
              } else if (data['transaction_history'] is List) {
                // Calculate the monthly EMI based on total amount and months
                final double totalAmount = (data['total_amount'] ?? 0).toDouble();
                final int totalMonths = data['total_month'] ?? 12;
                final double calculatedMonthlyEMI = totalAmount / totalMonths;

                // Parse as list (new logic for array-style transaction history)
                final transactionList = data['transaction_history'] as List;
                for (var item in transactionList) {
                  if (item is Timestamp) {
                    transactions.add({
                      'date': item.toDate(),
                      'amount': calculatedMonthlyEMI, // Use calculated monthly EMI
                    });
                  }
                }
              }
            }

            final loanData = {
              'id': doc.id,
              'deviceName': data['device_name'] ?? 'Unknown Device',
              'purchaseDate': purchaseDate,
              'totalAmount': (data['total_amount'] ?? 0).toDouble(),
              'totalMonths': data['total_month'] ?? 12,
              'transactions': transactions,
              'status': _calculateStatus(
                  data['purchase_date'],
                  transactions,
                  data['total_month'] ?? 12
              ),
            };

            // Try to find an exact match first
            if (loansMap.containsKey(customerId)) {
              loansMap[customerId]!.add(loanData);
            } else {
              // If no direct match, try case-insensitive search
              String? matchingCustomerId;
              for (final id in loansMap.keys) {
                if (id.toLowerCase() == customerId.toLowerCase()) {
                  matchingCustomerId = id;
                  break;
                }
              }

              if (matchingCustomerId != null) {
                loansMap[matchingCustomerId]!.add(loanData);
              } else {
                // Create a new entry if no match found
                loansMap[customerId] = [loanData];
                print('Created new entry for unmatched customer ID: $customerId');
              }
            }
          }
        }

        customerLoans.value = loansMap;
        isLoading.value = false;

        // Debug print all customer IDs and their loan counts
        loansMap.forEach((key, value) {
          print('Customer ID: $key, Loan count: ${value.length}');
        });
      }, onError: (e) {
        print('Error in loans stream: $e');
        isLoading.value = false;
      });
    } catch (e) {
      print('Error setting up loans listener: $e');
      isLoading.value = false;
    }
  }

  String _calculateStatus(dynamic purchaseDate, List<Map<String, dynamic>> transactions, int totalMonths) {
    // Debug print to verify transaction count vs total months
    print("Transaction count: ${transactions.length}, Total months: $totalMonths");

    // If total payments equal or exceed total months, then paid off
    if (transactions.length >= totalMonths) {
      return 'Paid Off';
    }

    final currentDate = DateTime.now();
    DateTime purchaseDateTime;

    // Convert purchase date to DateTime
    if (purchaseDate is Timestamp) {
      purchaseDateTime = purchaseDate.toDate();
    } else {
      // Fallback if purchase date is not available
      purchaseDateTime = DateTime.now().subtract(Duration(days: 30));
    }

    // If no transactions yet, check if first payment is due
    if (transactions.isEmpty) {
      // First payment is due one month after purchase
      DateTime firstPaymentDue = DateTime(
        purchaseDateTime.year,
        purchaseDateTime.month + 1,
        purchaseDateTime.day,
      );

      // If past due date with no payment
      if (currentDate.isAfter(firstPaymentDue)) {
        return 'Overdue';
      } else {
        return 'Active';
      }
    }

    // Sort transactions by date
    transactions.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // Get last payment date
    DateTime lastPaymentDate = transactions.last['date'] as DateTime;

    // Calculate next payment date (one month after last payment)
    DateTime nextPaymentDue = DateTime(
      lastPaymentDate.year,
      lastPaymentDate.month + 1,
      lastPaymentDate.day,
    );

    // If more than a month has passed since last payment and not fully paid
    if (currentDate.isAfter(nextPaymentDue) && transactions.length < totalMonths) {
      return 'Overdue';
    }

    // Otherwise active
    return 'Active';
  }

  List<Map<String, dynamic>> getLoansForCustomer(String customerId) {
    // Try direct lookup first
    if (customerLoans.containsKey(customerId)) {
      return customerLoans[customerId] ?? [];
    }

    // Try case insensitive lookup
    for (final key in customerLoans.keys) {
      if (key.toLowerCase() == customerId.toLowerCase()) {
        return customerLoans[key] ?? [];
      }
    }

    return [];
  }

  Map<String, int> getEmiStatusCounts(String customerId) {
    final loans = getLoansForCustomer(customerId);
    final Map<String, int> statusCounts = {
      'Active': 0,
      'Paid Off': 0,
      'Overdue': 0,
    };

    for (final loan in loans) {
      final status = loan['status'] ?? 'Active';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    return statusCounts;
  }

  int getDevicesCount(String customerId) {
    return getLoansForCustomer(customerId).length;
  }

  // Method to refresh data manually if needed
  Future<void> refreshData() async {
    // Cancel existing subscriptions
    _customersSubscription?.cancel();
    _loansSubscription?.cancel();

    // Reset up listeners
    setupCustomersListener();
  }
}