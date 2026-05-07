import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:untitled/admin/controllers/device_controller.dart';
import 'package:untitled/utils/widgets/log_out_widget.dart';

import 'add_device_page.dart';
import 'emi_details_screen.dart';

class DevicesPage extends StatelessWidget {
  final DeviceController deviceController = Get.put(DeviceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Devices', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [logOutWidget()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search devices...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                deviceController.updateSearchQuery(value);
              },
            ),
          ),
          Obx(
            () => Container(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => deviceController.changeTab(1),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: deviceController.selectedTabIndex.value == 1
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: deviceController.selectedTabIndex.value == 1
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Purchased (${deviceController.purchasedDevices.length})',
                                style: TextStyle(
                                  color: deviceController.selectedTabIndex.value == 1
                                      ? Colors.blue
                                      : Colors.grey,
                                  fontWeight: deviceController.selectedTabIndex.value == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => deviceController.changeTab(0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: deviceController.selectedTabIndex.value == 0
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_box,
                                color: deviceController.selectedTabIndex.value == 0
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Available (${deviceController.devices.length - deviceController.purchasedDevices.length})',
                                style: TextStyle(
                                  color: deviceController.selectedTabIndex.value == 0
                                      ? Colors.blue
                                      : Colors.grey,
                                  fontWeight: deviceController.selectedTabIndex.value == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (deviceController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else if (deviceController.selectedTabIndex.value == 0) {
                // Available Devices Tab
                if (deviceController.filteredDevices.isEmpty) {
                  return Center(child: Text('No devices found'));
                } else {
                  return ListView.builder(
                    itemCount: deviceController.filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = deviceController.filteredDevices[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: getColorForDevice(device['deviceName']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: device['imageUrl'].isNotEmpty
                                ? Image.network(device['imageUrl'], fit: BoxFit.fill)
                                : Icon(Icons.smartphone, color: Colors.white),
                          ),
                          title: Text(device['deviceName']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.inventory_2, color: Colors.teal, size: 18),
                                      SizedBox(width: 4),
                                      Text('${device['availableQuantity']} units'),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.attach_money, color: Colors.grey, size: 18),
                                      SizedBox(width: 4),
                                      Text('\$${device['unitPrice'].toStringAsFixed(0)}'),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(width: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              } else {
                // Purchased Devices Tab
                if (deviceController.filteredPurchasedDevices.isEmpty) {
                  return Center(child: Text('No purchased devices found'));
                } else {
                  return ListView.builder(
                    itemCount: deviceController.filteredPurchasedDevices.length,
                    itemBuilder: (context, index) {
                      final device = deviceController.filteredPurchasedDevices[index];

                      // Get device status color
                      Color statusColor;
                      switch (device['status']) {
                        case 'Active':
                          statusColor = Colors.green;
                          break;
                        case 'Overdue':
                          statusColor = Colors.red;
                          break;
                        case 'Paid Off':
                          statusColor = Colors.blue;
                          break;
                        default:
                          statusColor = Colors.grey;
                      }

                      // Calculate EMI amount
                      final totalAmount = device['totalAmount'] as double;
                      final totalMonths = device['totalMonths'] as int;
                      final monthlyEMI = totalAmount / totalMonths;

                      // Format purchase date
                      final purchaseDate = device['purchaseDate'] as DateTime;
                      final formattedDate = DateFormat('dd MMM, yyyy').format(purchaseDate);

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: getColorForDevice(device['deviceName']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.smartphone, color: Colors.white),
                          ),
                          title: Text(device['deviceName']),
                          subtitle: Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundImage: device['customerProfileImage'].isNotEmpty
                                    ? NetworkImage(device['customerProfileImage'])
                                    : null,
                                child: device['customerProfileImage'].isEmpty
                                    ? Text(
                                        device['customerName'][0].toUpperCase(),
                                        style: TextStyle(fontSize: 8),
                                      )
                                    : null,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  device['customerName'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      device['status'],
                                      style: TextStyle(color: statusColor, fontSize: 12),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '\₹${monthlyEMI.toStringAsFixed(0)}/month',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.arrow_forward_ios, size: 16),
                                onPressed: () {
                                  Get.to(() => EMIDetailsPage(loan: device));
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => EMIDetailsPage(loan: device));
                          },
                        ),
                      );
                    },
                  );
                }
              }
            }),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: () {
              Get.to(() => AddDevicePage());
            },
            label: Text('+ Add New Device', style: TextStyle(color: Colors.white, fontSize: 18)),
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }

  Color getColorForDevice(String deviceName) {
    if (deviceName.toLowerCase().contains('iphone')) {
      return Colors.blue;
    } else if (deviceName.toLowerCase().contains('samsung')) {
      return Colors.purple;
    } else if (deviceName.toLowerCase().contains('google')) {
      return Colors.orange;
    }
    return Colors.grey;
  }
}
