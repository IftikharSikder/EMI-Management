import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> validateLogin(String email, String password) async {
    try {
      // Query the credentials document in admin collection
      DocumentSnapshot credentialsDoc = await _firestore
          .collection('admin')
          .doc('credentials')
          .get();

      if (credentialsDoc.exists) {
        Map<String, dynamic> data = credentialsDoc.data() as Map<String, dynamic>;

        // Check if email and password match
        if (data['email'] == email && data['password'] == password) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error validating login: $e');
      return false;
    }
  }
}


