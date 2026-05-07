import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/admin/models/device_model.dart';

class AddDeviceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _devicesCollection = FirebaseFirestore.instance.collection('devices');

  Future<bool> isDeviceNameUnique(String deviceName) async {
    try {
      String lowercaseName = deviceName.toLowerCase().trim();
      QuerySnapshot snapshot = await _devicesCollection.get();

      for (var doc in snapshot.docs) {
        String existingName = (doc.data() as Map<String, dynamic>)['device_name']?.toString() ?? '';
        if (existingName.toLowerCase() == lowercaseName) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print("Error checking device name uniqueness: $e");
      return false;
    }
  }

  Future<List<Device>> getDevices() async {
    try {
      QuerySnapshot snapshot = await _devicesCollection.get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Device(
          id: doc.id,
          deviceName: data['device_name'] ?? '',
          availableQuantity: data['available_quantity'] ?? 0,
          unitPrice: (data['unit_price'] ?? 0.0).toDouble(),
          imageUrl: data['img_url'] ?? '',
          dId: data['d_id'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error getting devices: $e");
      return [];
    }
  }

  Future<List<Device>> searchDevices(String query) async {
    try {
      QuerySnapshot snapshot = await _devicesCollection.get();

      List<Device> results = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String deviceName = data['device_name'] ?? '';

        if (deviceName.toLowerCase().contains(query.toLowerCase())) {
          results.add(
            Device(
              id: doc.id,
              deviceName: deviceName,
              availableQuantity: data['available_quantity'] ?? 0,
              unitPrice: (data['unit_price'] ?? 0.0).toDouble(),
              imageUrl: data['img_url'] ?? '',
              dId: data['d_id'] ?? '',
            ),
          );
        }
      }

      return results;
    } catch (e) {
      print("Error searching devices: $e");
      return [];
    }
  }

  Future<bool> addDevice(Device device) async {
    try {
      DocumentReference docRef = await _devicesCollection.add({
        'device_name': device.deviceName,
        'available_quantity': device.availableQuantity,
        'unit_price': device.unitPrice,
        'img_url': device.imageUrl,
        'd_id': '',
      });

      await docRef.update({'d_id': docRef.id});

      return true;
    } catch (e) {
      print("Error adding device: $e");
      return false;
    }
  }
}
