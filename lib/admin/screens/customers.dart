import 'package:emi_management/admin/screens/Customer_profile.dart';
import 'package:emi_management/admin/screens/add_new_customer.dart';
import 'package:emi_management/utils/widgets/log_out_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_controller.dart';

class CustomersScreen extends StatelessWidget {
  final CustomerController customerController = Get.put(CustomerController());
  final RxString selectedFilter = 'All Customers'.obs;

  CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // Handle back button
            Get.back();
          },
        ),
        title: Text('Customers', style: TextStyle(color: Colors.white)),
        actions: [
          logOutWidget()
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                children: [
                  _buildFilterTab('All Customers (${customerController.customers.length})'),
                  SizedBox(width: 10),
                  _buildFilterTab('Active EMI (${_getActiveEmiCustomersCount()})'),
                  SizedBox(width: 10),
                  _buildFilterTab('Paid Off (${_getPaidOffCustomersCount()})'),
                ],
              )),
            ),
          ),
          // Customer list
          Expanded(
            child: Obx(() {
              if (customerController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              final filteredCustomers = _getFilteredCustomers();

              if (filteredCustomers.isEmpty) {
                return Center(child: Text('No customers found'));
              }

              return ListView.builder(
                itemCount: filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = filteredCustomers[index];
                  final customerId = customer['id'];
                  final deviceCount = customerController.getDevicesCount(customerId);
                  final statusCounts = customerController.getEmiStatusCounts(customerId);

                  // Determine overall status for the badge
                  String statusText;
                  Color statusColor;

                  if (statusCounts['Overdue']! > 0) {
                    statusText = 'Overdue';
                    statusColor = Colors.red;
                  } else if (statusCounts['Active']! > 0) {
                    statusText = 'Active';
                    statusColor = Colors.green;
                  } else {
                    statusText = 'Paid Off';
                    statusColor = Colors.blue;
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: customer['profileImage'] != null
                          ? NetworkImage(customer['profileImage'])
                          : null,
                      child: customer['profileImage'] == null
                          ? Text(customer['name'][0])
                          : null,
                    ),
                    title: Text(customer['name']),
                    subtitle: Text('$deviceCount devices purchased'),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor),
                      ),
                    ),
                    onTap: () {
                      Get.to(() => CustomerProfileScreen(customerId: customerId));
                    },
                  );
                },
              );
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
              Get.to(() => AddNewCustomer());
            },
            label: Text('+ Add New Customers', style: TextStyle(color: Colors.white, fontSize: 18)),
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String filterName) {
    bool isSelected = selectedFilter.value.contains(filterName.split(' (')[0]);

    return GestureDetector(
      onTap: () {
        // Extract filter name without the count
        String baseName = filterName.split(' (')[0];

        // Set the selected filter
        if (baseName == 'All Customers') {
          selectedFilter.value = 'All Customers';
          // Stay on current screen/view
        } else if (baseName == 'Active EMI') {
          selectedFilter.value = 'Active EMI';
          // The list will be filtered to show only Active EMI customers
        } else if (baseName == 'Paid Off') {
          selectedFilter.value = 'Paid Off';
          // The list will be filtered to show only Paid Off customers
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.shade100
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(filterName),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredCustomers() {
    if (selectedFilter.value.contains('All Customers')) {
      return customerController.customers;
    } else if (selectedFilter.value.contains('Active EMI')) {
      return customerController.customers.where((customer) {
        final customerId = customer['id'];
        final statusCounts = customerController.getEmiStatusCounts(customerId);
        // Include customers with active EMIs (but not overdue)
        return statusCounts['Active']! > 0;
      }).toList();
    } else if (selectedFilter.value.contains('Paid Off')) {
      return customerController.customers.where((customer) {
        final customerId = customer['id'];
        final statusCounts = customerController.getEmiStatusCounts(customerId);
        // Only include customers who have all loans paid off (no Active or Overdue loans)
        return statusCounts['Active']! == 0 &&
            statusCounts['Overdue']! == 0 &&
            statusCounts['Paid Off']! > 0;
      }).toList();
    }
    return customerController.customers;
  }

  int _getActiveEmiCustomersCount() {
    return customerController.customers.where((customer) {
      final customerId = customer['id'];
      final statusCounts = customerController.getEmiStatusCounts(customerId);
      return statusCounts['Active']! > 0;
    }).length;
  }

  int _getPaidOffCustomersCount() {
    return customerController.customers.where((customer) {
      final customerId = customer['id'];
      final statusCounts = customerController.getEmiStatusCounts(customerId);
      return statusCounts['Active']! == 0 &&
          statusCounts['Overdue']! == 0 &&
          statusCounts['Paid Off']! > 0;
    }).length;
  }
}
