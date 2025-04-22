
import 'package:emi_management/role_selection_page.dart';
import 'package:emi_management/utils/methods/logout_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

logOutWidget(){
  return IconButton(onPressed: (){
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await logoutUser();
                  Get.offAll(RoleSelectionPage());
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Yes",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () => Get.back(),
                child: const Text(
                  "No",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }, icon: Icon(Icons.logout,color: Colors.white,));
}