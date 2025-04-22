import 'package:emi_management/role_selection_page.dart';
import 'package:emi_management/utils/methods/logout_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool biometricEnabled = true;
  bool twoFactorEnabled = true;
  bool isInitialLoadingDone = false;

  @override
  void initState() {
    super.initState();
     getdata();
  }

  String? email;
  String? password;
  String? userName = "Loading...";

  Future<void> getdata() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    email = pref.getString("email");
    password = pref.getString("password");

    if (email != null && email!.isNotEmpty) {
      await fetchUserDetails();
    }

    setState(() {});
  }

  Future<void> fetchUserDetails() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        userName = userData['name'];
        setState(() {});
      }
    } catch (e) {
      Get.snackbar("Error", "Error fetching user details");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage('https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hello, ${userName}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            email.toString(),
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Personal Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.white,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          buildListTile(
                            icon: Icons.person,
                            title: 'Edit Profile',
                            hasTrailing: true,
                          ),
                          const Divider(height: 1, indent: 56),
                          buildListTile(
                            icon: Icons.email,
                            title: 'Email Settings',
                            hasTrailing: true,
                          ),
                          const Divider(height: 1, indent: 56),
                          buildListTile(
                            icon: Icons.phone,
                            title: 'Phone Number',
                            hasTrailing: true,
                          ),
                          const Divider(height: 1, indent: 56),
                          buildListTile(
                            icon: Icons.credit_card,
                            title: 'Linked Cards',
                            hasTrailing: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Security',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.white,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          buildListTile(
                            icon: Icons.lock,
                            title: 'Change PIN',
                            hasTrailing: true,
                          ),
                          const Divider(height: 1, indent: 56),
                          buildSwitchTile(
                            icon: Icons.security,
                            title: 'Two-Factor Authentication',
                            value: twoFactorEnabled,
                            onChanged: (value) {
                              setState(() {
                                twoFactorEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: () {
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blue.withAlpha(30)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout, size: 18, color: Colors.white,),
                  SizedBox(width: 8),
                  Text('Log Out', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget buildListTile({
    required IconData icon,
    required String title,
    required bool hasTrailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: hasTrailing ? const Icon(Icons.chevron_right) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: () {},
    );
  }

  Widget buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.blue),
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}