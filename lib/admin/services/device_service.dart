// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:emi_management/admin/models/device_model.dart';
//
// class DeviceService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<List<Device>> getDevices() async {
//     try {
//       QuerySnapshot snapshot = await _firestore.collection('devices').get();
//       return snapshot.docs
//           .map((doc) => Device.fromFirestore(
//           doc.data() as Map<String, dynamic>, doc.id))
//           .toList();
//     } catch (e) {
//       print('Error getting devices: $e');
//       return [];
//     }
//   }
//
//   Future<List<Device>> searchDevices(String query) async {
//     try {
//       // Search by device name
//       QuerySnapshot snapshot = await _firestore
//           .collection('devices')
//           .where('device_name', isGreaterThanOrEqualTo: query)
//           .where('device_name', isLessThanOrEqualTo: query + '\uf8ff')
//           .get();
//
//       return snapshot.docs
//           .map((doc) => Device.fromFirestore(
//           doc.data() as Map<String, dynamic>, doc.id))
//           .toList();
//     } catch (e) {
//       print('Error searching devices: $e');
//       return [];
//     }
//   }
//
//   Future<bool> addDevice(Device device) async {
//     try {
//       await _firestore.collection('devices').add(device.toFirestore());
//       return true;
//     } catch (e) {
//       print('Error adding device: $e');
//       return false;
//     }
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emi_management/admin/models/device_model.dart';

class DeviceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Device>> getDevices() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      return snapshot.docs
          .map((doc) => Device.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting devices: $e');
      return [];
    }
  }

  Future<List<Device>> searchDevices(String query) async {
    try {
      // Search by device name
      QuerySnapshot snapshot = await _firestore
          .collection('devices')
          .where('device_name', isGreaterThanOrEqualTo: query)
          .where('device_name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => Device.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error searching devices: $e');
      return [];
    }
  }

  Future<bool> addDevice(Device device) async {
    try {
      // Create a new document reference to get an ID first
      DocumentReference docRef = _firestore.collection('devices').doc();

      // Update the device with the generated document ID
      Map<String, dynamic> deviceData = device.toFirestore();
      deviceData['d_id'] = docRef.id;

      // Now save the document with the d_id field
      await docRef.set(deviceData);
      return true;
    } catch (e) {
      print('Error adding device: $e');
      return false;
    }
  }
}