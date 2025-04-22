// import 'package:emi_management/admin/models/device_model.dart';
// import 'package:emi_management/admin/services/add_device_service.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
//
// class AddDeviceController extends GetxController {
//   final AddDeviceService _deviceService = AddDeviceService();
//   RxList<Device> devices = <Device>[].obs;
//   RxList<Device> filteredDevices = <Device>[].obs;
//   RxBool isLoading = false.obs;
//   RxString searchQuery = ''.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchDevices();
//   }
//
//   Future<void> fetchDevices() async {
//     isLoading.value = true;
//     try {
//       devices.value = await _deviceService.getDevices();
//       filteredDevices.value = devices;
//     } catch (e) {
//       print("Error fetching devices: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void updateSearchQuery(String query) {
//     searchQuery.value = query;
//     if (query.isEmpty) {
//       filteredDevices.value = devices;
//     } else {
//       searchDevices(query);
//     }
//   }
//
//   Future<void> searchDevices(String query) async {
//     isLoading.value = true;
//     try {
//       if (query.isEmpty) {
//         filteredDevices.value = devices;
//       } else {
//         var results = await _deviceService.searchDevices(query);
//         filteredDevices.value = results;
//       }
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Expose this method for real-time validation
//   Future<bool> isDeviceNameUnique(String deviceName) async {
//     return await _deviceService.isDeviceNameUnique(deviceName);
//   }
//
//   Future<bool> addDevice(String deviceName, int availableQuantity, double unitPrice, String imageUrl) async {
//     // Validate again just to be sure (in case user bypasses UI validation)
//     bool isUnique = await _deviceService.isDeviceNameUnique(deviceName);
//
//     if (!isUnique) {
//       Get.snackbar(
//         'Error',
//         'A device with this name already exists. Please use a unique name.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }
//
//     // If validation passes, create and add the device
//     final device = Device(
//       id: '',  // Firestore will generate an ID
//       deviceName: deviceName.trim(),
//       availableQuantity: availableQuantity,
//       unitPrice: unitPrice,
//       imageUrl: imageUrl,
//       dId: '', // Will be set in the service
//     );
//
//     bool success = await _deviceService.addDevice(device);
//     if (success) {
//       await fetchDevices();
//     }
//     return success;
//   }
// }
//
//
//


import 'package:emi_management/admin/models/device_model.dart';
import 'package:emi_management/admin/services/add_device_service.dart';
import 'package:emi_management/admin/controllers/device_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AddDeviceController extends GetxController {
  final AddDeviceService _deviceService = AddDeviceService();
  RxList<Device> devices = <Device>[].obs;
  RxList<Device> filteredDevices = <Device>[].obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    isLoading.value = true;
    try {
      devices.value = await _deviceService.getDevices();
      filteredDevices.value = devices;
    } catch (e) {
      print("Error fetching devices: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredDevices.value = devices;
    } else {
      searchDevices(query);
    }
  }

  Future<void> searchDevices(String query) async {
    isLoading.value = true;
    try {
      if (query.isEmpty) {
        filteredDevices.value = devices;
      } else {
        var results = await _deviceService.searchDevices(query);
        filteredDevices.value = results;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Expose this method for real-time validation
  Future<bool> isDeviceNameUnique(String deviceName) async {
    return await _deviceService.isDeviceNameUnique(deviceName);
  }

  Future<bool> addDevice(String deviceName, int availableQuantity, double unitPrice, String imageUrl) async {
    // Validate again just to be sure (in case user bypasses UI validation)
    bool isUnique = await _deviceService.isDeviceNameUnique(deviceName);

    if (!isUnique) {
      Get.snackbar(
        'Error',
        'A device with this name already exists. Please use a unique name.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // If validation passes, create and add the device
    final device = Device(
      id: '',  // Firestore will generate an ID
      deviceName: deviceName.trim(),
      availableQuantity: availableQuantity,
      unitPrice: unitPrice,
      imageUrl: imageUrl,
      dId: '', // Will be set in the service
    );

    bool success = await _deviceService.addDevice(device);
    if (success) {
      await fetchDevices();

      // Refresh other controllers that might be using this data
      // This is the key part to update all views
      try {
        // Update the main DeviceController if it exists
        if (Get.isRegistered<DeviceController>()) {
          final deviceController = Get.find<DeviceController>();
          deviceController.refreshData();
        }
      } catch (e) {
        print("Error refreshing DeviceController: $e");
      }
    }
    return success;
  }
}
