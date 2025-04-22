import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> checkUserCredentials(String email, String password) async {
  try {
    CollectionReference customers = FirebaseFirestore.instance.collection('customers');
    QuerySnapshot querySnapshot = await customers
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error checking user credentials: $e');
    return false;
  }
}


Future<bool> checkAdminCredentials(String email, String password) async {
  try {
    CollectionReference admin = FirebaseFirestore.instance.collection('admin');
    QuerySnapshot querySnapshot = await admin
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error checking user credentials: $e');
    return false;
  }
}
