// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
//
//
// class DeviceController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final RxList<dynamic> devices = <dynamic>[].obs;
//   final RxList<dynamic> filteredDevices = <dynamic>[].obs;
//   final RxList<dynamic> purchasedDevices = <dynamic>[].obs;
//   final RxList<dynamic> filteredPurchasedDevices = <dynamic>[].obs;
//   final RxBool isLoading = true.obs;
//   final RxString searchQuery = ''.obs;
//   final RxInt selectedTabIndex = 1.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchDevices();
//     fetchPurchasedDevices();
//   }
//
//   Future<void> fetchDevices() async {
//     isLoading.value = true;
//     try {
//       final devicesSnapshot = await _firestore.collection('devices').get();
//       devices.value = devicesSnapshot.docs.map((doc) {
//         final data = doc.data();
//         return {
//           'id': doc.id,
//           'deviceName': data['device_name'] ?? 'Unknown Device',
//           'imageUrl': data['img_url'] ?? '',
//           'unitPrice': (data['unit_price'] ?? 0).toDouble(),
//           'availableQuantity': data['available_quantity'] ?? 0,
//         };
//       }).toList();
//
//       // Initialize filtered devices
//       filteredDevices.value = List.from(devices);
//     } catch (e) {
//       print('Error fetching devices: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> fetchPurchasedDevices() async {
//     isLoading.value = true;
//     try {
//       final loansSnapshot = await _firestore.collection('loans').get();
//       final customersSnapshot = await _firestore.collection('customers').get();
//
//       // Create a map of customer IDs to customer data for quick lookup
//       final customerMap = {};
//       for (var doc in customersSnapshot.docs) {
//         customerMap[doc.id] = {
//           'name': doc.data()['name'] ?? 'Unknown',
//           'profileImage': doc.data()['profile_image'] ?? '',
//           'phone': doc.data()['phone'] ?? '',
//         };
//       }
//
//       // Process loan documents to get purchased devices
//       final List<dynamic> purchasedList = [];
//       for (var doc in loansSnapshot.docs) {
//         final data = doc.data();
//         final customerId = data['customer_id'] ?? '';
//         final customerInfo = customerMap[customerId] ?? {'name': 'Unknown', 'profileImage': '', 'phone': ''};
//
//         // Correctly handle transaction_history as an array
//         final transactionHistory = data['transaction_history'] is List ? data['transaction_history'] : [];
//         final transactionCount = transactionHistory.length;
//
//         // Calculate EMI status
//         String status = 'Active';
//         if (transactionCount >= (data['total_month'] ?? 12)) {
//           status = 'Paid Off';
//         } else if (transactionCount > 0) {
//           // Check if overdue by looking at the most recent transaction date
//           final lastTransaction = transactionHistory.last;
//           final lastDate = lastTransaction is Timestamp
//               ? lastTransaction.toDate()
//               : DateTime.now().subtract(Duration(days: 30));
//
//           if (DateTime.now().difference(lastDate).inDays > 30) {
//             status = 'Overdue';
//           }
//         }
//
//         purchasedList.add({
//           'id': doc.id,
//           'deviceName': data['device_name'] ?? 'Unknown Device',
//           'customerName': customerInfo['name'],
//           'customerProfileImage': customerInfo['profileImage'],
//           'customerPhone': customerInfo['phone'],
//           'customerId': customerId,
//           'totalAmount': (data['total_amount'] ?? 0).toDouble(),
//           'totalMonths': data['total_month'] ?? 12,
//           'purchaseDate': data['purchase_date'] is Timestamp
//               ? (data['purchase_date'] as Timestamp).toDate()
//               : DateTime.now(),
//           'status': status,
//           'transactionHistory': transactionHistory, // Include transaction history as an array
//         });
//       }
//
//       purchasedDevices.value = purchasedList;
//       filteredPurchasedDevices.value = List.from(purchasedList);
//     } catch (e) {
//       print('Error fetching purchased devices: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void updateSearchQuery(String query) {
//     searchQuery.value = query;
//
//     if (selectedTabIndex.value == 0) {
//       // Filter available devices
//       if (query.isEmpty) {
//         filteredDevices.value = List.from(devices);
//       } else {
//         filteredDevices.value = devices.where((device) {
//           final deviceName = device['deviceName'].toString().toLowerCase();
//           return deviceName.contains(query.toLowerCase());
//         }).toList();
//       }
//     } else {
//       // Filter purchased devices
//       if (query.isEmpty) {
//         filteredPurchasedDevices.value = List.from(purchasedDevices);
//       } else {
//         filteredPurchasedDevices.value = purchasedDevices.where((device) {
//           final deviceName = device['deviceName'].toString().toLowerCase();
//           final customerName = device['customerName'].toString().toLowerCase();
//           return deviceName.contains(query.toLowerCase()) ||
//               customerName.contains(query.toLowerCase());
//         }).toList();
//       }
//     }
//   }
//
//   void changeTab(int index) {
//     selectedTabIndex.value = index;
//     // Reapply search filter for the selected tab
//     updateSearchQuery(searchQuery.value);
//   }
// }

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


class DeviceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<dynamic> devices = <dynamic>[].obs;
  final RxList<dynamic> filteredDevices = <dynamic>[].obs;
  final RxList<dynamic> purchasedDevices = <dynamic>[].obs;
  final RxList<dynamic> filteredPurchasedDevices = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedTabIndex = 1.obs;

  // Stream subscriptions
  StreamSubscription<QuerySnapshot>? _devicesSubscription;
  StreamSubscription<QuerySnapshot>? _loansSubscription;

  @override
  void onInit() {
    super.onInit();
    // Use streams instead of one-time fetches
    setupDevicesListener();
    setupPurchasedDevicesListener();
  }

  @override
  void onClose() {
    // Clean up subscriptions
    _devicesSubscription?.cancel();
    _loansSubscription?.cancel();
    super.onClose();
  }

  void setupDevicesListener() {
    isLoading.value = true;
    try {
      // Set up a stream listener for devices collection
      _devicesSubscription = _firestore.collection('devices')
          .snapshots()
          .listen((devicesSnapshot) {
        devices.value = devicesSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'deviceName': data['device_name'] ?? 'Unknown Device',
            'imageUrl': data['img_url'] ?? '',
            'unitPrice': (data['unit_price'] ?? 0).toDouble(),
            'availableQuantity': data['available_quantity'] ?? 0,
          };
        }).toList();

        // Initialize filtered devices
        filteredDevices.value = List.from(devices);

        // Update search results if there's an active search
        if (searchQuery.isNotEmpty) {
          updateSearchQuery(searchQuery.value);
        }

        isLoading.value = false;
      }, onError: (e) {
        print('Error in devices stream: $e');
        isLoading.value = false;
      });
    } catch (e) {
      print('Error setting up devices listener: $e');
      isLoading.value = false;
    }
  }

  void setupPurchasedDevicesListener() {
    isLoading.value = true;
    try {
      // Set up a stream listener for loans collection
      _loansSubscription = _firestore.collection('loans')
          .snapshots()
          .listen((loansSnapshot) async {
        final customersSnapshot = await _firestore.collection('customers').get();

        // Create a map of customer IDs to customer data for quick lookup
        final customerMap = {};
        for (var doc in customersSnapshot.docs) {
          customerMap[doc.id] = {
            'name': doc.data()['name'] ?? 'Unknown',
            'profileImage': doc.data()['profile_image'] ?? '',
            'phone': doc.data()['phone'] ?? '',
          };
        }

        // Process loan documents to get purchased devices
        final List<dynamic> purchasedList = [];
        for (var doc in loansSnapshot.docs) {
          final data = doc.data();
          final customerId = data['customer_id'] ?? '';
          final customerInfo = customerMap[customerId] ?? {'name': 'Unknown', 'profileImage': '', 'phone': ''};

          // Correctly handle transaction_history as an array
          final transactionHistory = data['transaction_history'] is List ? data['transaction_history'] : [];
          final transactionCount = transactionHistory.length;

          // Calculate EMI status
          String status = 'Active';
          if (transactionCount >= (data['total_month'] ?? 12)) {
            status = 'Paid Off';
          } else if (transactionCount > 0) {
            // Check if overdue by looking at the most recent transaction date
            final lastTransaction = transactionHistory.last;
            final lastDate = lastTransaction is Timestamp
                ? lastTransaction.toDate()
                : DateTime.now().subtract(Duration(days: 30));

            if (DateTime.now().difference(lastDate).inDays > 30) {
              status = 'Overdue';
            }
          }

          purchasedList.add({
            'id': doc.id,
            'deviceName': data['device_name'] ?? 'Unknown Device',
            'customerName': customerInfo['name'],
            'customerProfileImage': customerInfo['profileImage'],
            'customerPhone': customerInfo['phone'],
            'customerId': customerId,
            'totalAmount': (data['total_amount'] ?? 0).toDouble(),
            'totalMonths': data['total_month'] ?? 12,
            'purchaseDate': data['purchase_date'] is Timestamp
                ? (data['purchase_date'] as Timestamp).toDate()
                : DateTime.now(),
            'status': status,
            'transactionHistory': transactionHistory, // Include transaction history as an array
          });
        }

        purchasedDevices.value = purchasedList;
        filteredPurchasedDevices.value = List.from(purchasedList);

        // Update search results if there's an active search
        if (searchQuery.isNotEmpty) {
          updateSearchQuery(searchQuery.value);
        }

        isLoading.value = false;
      }, onError: (e) {
        print('Error in loans stream: $e');
        isLoading.value = false;
      });
    } catch (e) {
      print('Error setting up purchased devices listener: $e');
      isLoading.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;

    if (selectedTabIndex.value == 0) {
      // Filter available devices
      if (query.isEmpty) {
        filteredDevices.value = List.from(devices);
      } else {
        filteredDevices.value = devices.where((device) {
          final deviceName = device['deviceName'].toString().toLowerCase();
          return deviceName.contains(query.toLowerCase());
        }).toList();
      }
    } else {
      // Filter purchased devices
      if (query.isEmpty) {
        filteredPurchasedDevices.value = List.from(purchasedDevices);
      } else {
        filteredPurchasedDevices.value = purchasedDevices.where((device) {
          final deviceName = device['deviceName'].toString().toLowerCase();
          final customerName = device['customerName'].toString().toLowerCase();
          return deviceName.contains(query.toLowerCase()) ||
              customerName.contains(query.toLowerCase());
        }).toList();
      }
    }
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    // Reapply search filter for the selected tab
    updateSearchQuery(searchQuery.value);
  }

  // Method to refresh data manually if needed
  Future<void> refreshData() async {
    // Cancel existing subscriptions
    _devicesSubscription?.cancel();
    _loansSubscription?.cancel();

    // Reset up listeners
    setupDevicesListener();
    setupPurchasedDevicesListener();
  }
}