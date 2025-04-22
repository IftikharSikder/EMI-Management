// lib/services/device_event_service.dart
import 'package:get/get.dart';

class DeviceEventService extends GetxService {
  // Event stream for device changes
  final RxBool deviceListChanged = false.obs;

  // Notify all listeners that a device was added/modified/deleted
  void notifyDeviceListChanged() {
    deviceListChanged.toggle(); // Toggle to trigger listeners
  }
}